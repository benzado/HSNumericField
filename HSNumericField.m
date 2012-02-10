//
//  HSNumericField.m
//  HSNumericField
//
//  Created by Benjamin Ragheb on 11/7/11.
//  Copyright (c) 2011 Heroic Software Inc. All rights reserved.
//

#import "HSNumericField.h"


/*
 Internal State is represented by three variables:
   isNegative, integerDigits, fractionalDigits
 */

static const NSInteger kButtonValueNil = -1;
static const NSInteger kButtonValueChangeSign = 10;
static const NSInteger kButtonValueDecimalPoint = 11;
static const NSInteger kButtonValueDelete = 12;
static const NSInteger kButtonValueClear = 13;

static const NSInteger kButtonValues[] = {
    1, 2, 3, kButtonValueClear,
    4, 5, 6, kButtonValueNil,
    7, 8, 9, kButtonValueNil,
    kButtonValueDecimalPoint, 0, kButtonValueChangeSign, kButtonValueDelete
};
static NSString * const kButtonLabels[] = {
    @"1", @"2", @"3", @"\xE2\x8A\x97",
    @"4", @"5", @"6", nil,
    @"7", @"8", @"9", nil,
    @".", @"0", @"\xC2\xB1", @"\xE2\x8C\xAB",
};


@implementation HSNumericInputView

+ (HSNumericInputView *)sharedInputView
{
    static HSNumericInputView *view = nil;
    
    if (view == nil) {
        view = [[HSNumericInputView alloc] initWithFrame:CGRectMake(0, 0, 320, 216)];
    }
    return view;
}

- (UIButton *)createButtonForIndex:(int)buttonIndex
{
    NSInteger value = kButtonValues[buttonIndex];
    if (value == kButtonValueNil) return nil;
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.tag = value;
    btn.titleLabel.font = [UIFont boldSystemFontOfSize:36];
    btn.titleLabel.shadowOffset = CGSizeMake(0, 1);
    [btn setTitle:kButtonLabels[buttonIndex] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [btn setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"NumberPadButtonUp"] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"NumberPadButtonDown"] forState:UIControlStateHighlighted];
    [btn
     addTarget:[UIDevice currentDevice] action:@selector(playInputClick)
     forControlEvents:UIControlEventTouchDown];
    [btn
     addTarget:nil action:@selector(numericInputViewButtonTouchUpInside:)
     forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor darkGrayColor];
        CGRect btnFrame = CGRectMake(0, 0, 80, 54);
        for (int btnIdx = 0; btnIdx < 16; btnIdx++) {
            UIButton *btn = [self createButtonForIndex:btnIdx];
            if (btn) {
                [btn setFrame:btnFrame];
                [self addSubview:btn];
            }
            if (btnIdx % 4 < 3) {
                btnFrame.origin.x += btnFrame.size.width;
            } else {
                btnFrame.origin.x = 0;
                btnFrame.origin.y += btnFrame.size.height;
            }
        }
    }
    return self;
}

- (void)setNextResponder:(UIResponder *)responder
{
    __nextResponder = responder;
}

- (UIResponder *)nextResponder
{
    return __nextResponder;
}

// MARK: UIInputViewAudioFeedback

- (BOOL)enableInputClicksWhenVisible
{
    return YES;
}

@end

// MARK: -

@implementation HSNumericField

- (void)initSubviews
{
    self.inputView = [HSNumericInputView sharedInputView];
    integerFormatter = [[NSNumberFormatter alloc] init];
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        [self initSubviews];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self initSubviews];
    }
    return self;
}

- (NSNumber *)numberValue
{
    if (integerDigits == nil) return nil;
    NSMutableString *digits = [NSMutableString string];
    if (isNegative) {
        [digits appendString:@"-"];
    }
    [digits appendString:integerDigits];
    if (fractionalDigits) {
        [digits appendString:@"."];
        [digits appendString:fractionalDigits];
    }
    return [NSNumber numberWithDouble:[digits doubleValue]];
}

- (void)setNumberValue:(NSNumber *)numberValue
{
    if (numberValue == nil) {
        isNegative = NO;
        integerDigits = nil;
        fractionalDigits = nil;
    }
    // TODO: ensure "%F" NEVER returns a string in scientific notation
    NSString *digits = [NSString stringWithFormat:@"%F",
                        [numberValue doubleValue]];
    NSCharacterSet *digitSet = [NSCharacterSet decimalDigitCharacterSet];
    NSScanner *scanner = [NSScanner scannerWithString:digits];
    isNegative = [scanner scanString:@"-" intoString:nil];
    NSString *part;
    if ([scanner scanCharactersFromSet:digitSet intoString:&part]) {
        integerDigits = [part mutableCopy];
    } else {
        integerDigits = nil;
    }
    if ([scanner scanString:@"." intoString:nil] &&
        [scanner scanCharactersFromSet:digitSet intoString:&part]) {
        fractionalDigits = [part mutableCopy];
    } else {
        fractionalDigits = nil;
    }
    NSAssert1([scanner isAtEnd], @"Leftover Digits! '%@'", digits);
}

- (NSNumberFormatterStyle)numberStyle
{
    return [integerFormatter numberStyle];
}

- (void)setNumberStyle:(NSNumberFormatterStyle)numberStyle
{
    [integerFormatter setNumberStyle:numberStyle];
}

// MARK: Private Methods

- (void)updateLabel
{
    NSString *displayString;
    if (integerDigits == nil) {
        displayString = @"";
    } else {
        double sign = isNegative ? -1.0 : 1.0;
        double integerPart = sign * [integerDigits doubleValue];
        displayString = [integerFormatter stringFromNumber:
                         [NSNumber numberWithDouble:integerPart]];
        if (fractionalDigits) {
            displayString = [NSString stringWithFormat:@"%@%@%@",
                             displayString,
                             [integerFormatter decimalSeparator],
                             fractionalDigits];
        }
    }
    self.text = displayString;
}

- (void)doChangeSign
{
    isNegative = !isNegative;
}

- (void)doInsertDecimalPoint
{
    if (fractionalDigits == nil) {
        fractionalDigits = [NSMutableString string];
    }
}

- (void)doDelete
{
    if (fractionalDigits) {
        if ([fractionalDigits length] > 0) {
            NSRange range = NSMakeRange([fractionalDigits length] - 1, 1);
            [fractionalDigits deleteCharactersInRange:range];
        } else {
            fractionalDigits = nil;
        }
    } else {
        if ([integerDigits length] > 1) {
            NSRange range = NSMakeRange([integerDigits length] - 1, 1);
            [integerDigits deleteCharactersInRange:range];
        } else {
            integerDigits = nil;
        }
    }
}

- (void)doClear
{
    isNegative = NO;
    integerDigits = nil;
    fractionalDigits = nil;
}

- (void)doInsertZero
{
    // Handle zero as a special case, because we don't want to allow the first
    // integer digit to be zero.
    if (fractionalDigits) {
        [fractionalDigits appendString:@"0"];
    } else {
        if ([integerDigits length] > 0) {
            [integerDigits appendString:@"0"];
        } else if (integerDigits == nil) {
            integerDigits = [NSMutableString string];
        }
    }
}

- (void)doInsertDigit:(NSUInteger)digitValue
{
    if (fractionalDigits) {
        [fractionalDigits appendFormat:@"%d", digitValue];
    } else {
        if (integerDigits) {
            [integerDigits appendFormat:@"%d", digitValue];
        } else {
            integerDigits = [NSMutableString stringWithFormat:@"%d", digitValue];
        }
    }
}

- (void)numericInputViewButtonTouchUpInside:(id)sender
{
    switch ([sender tag]) {
        case kButtonValueChangeSign:
            [self doChangeSign];
            break;
        case kButtonValueDecimalPoint:
            [self doInsertDecimalPoint];
            break;
        case kButtonValueDelete:
            [self doDelete];
            break;
        case kButtonValueClear:
            [self doClear];
            break;
        case 0:
            [self doInsertZero];
            break;
        default:
            [self doInsertDigit:[sender tag]];
            break;
    }
    [self updateLabel];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

// MARK: UIResponder

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    // Don't allow actions that we cannot support properly.
    if (action == @selector(selectAll:) || action == @selector(copy:)) {
        return [super canPerformAction:action withSender:sender];
    } else {
        return NO;
    }
}

- (BOOL)becomeFirstResponder
{
    if ([super becomeFirstResponder]) {
        [[HSNumericInputView sharedInputView] setNextResponder:self];
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)resignFirstResponder
{
    if ([super resignFirstResponder]) {
        [[HSNumericInputView sharedInputView] setNextResponder:nil];
        return YES;
    } else {
        return NO;
    }
}

@end
