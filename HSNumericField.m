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

static const int kButtonCount = 13;
static const NSInteger kButtonValueChangeSign = 10;
static const NSInteger kButtonValueDecimalPoint = 11;
static const NSInteger kButtonValueDelete = 12;

static const NSInteger kButtonValues[] = {
    1, 2, 3,
    4, 5, 6,
    7, 8, 9,
    kButtonValueChangeSign, kButtonValueDecimalPoint, 0, kButtonValueDelete
};

static NSString * const kButtonLabels[] = {
    @"1", @"2", @"3",
    @"4", @"5", @"6",
    @"7", @"8", @"9",
    @"NumberPadPlusMinus", @".", @"0", @"NumberPadDelete",
};

static const CGRect kInputViewFrame = { 0, 0, 320, 216 };

static const CGRect kButtonFrames[] = {
    { 1,  1, 105,53 }, { 107,  1, 106,53 }, { 214,  1, 105,53 },
    { 1, 55, 105,53 }, { 107, 55, 106,53 }, { 214, 55, 105,53 },
    { 1,109, 105,53 }, { 107,109, 106,53 }, { 214,109, 105,53 },
    { 1,163, 52,53 },
    { 54,163, 52,53 }, { 107,163, 106,53 }, { 214,163, 105,53 }
};

/*
    320px = 1px + 105px + 1px + 106px + 1px + 105px + 1px
    320px = 1px + 105px + 1px + 106px + 1px + 52px + 1px + 52px + 1px
    216px = 1px + 53px + 1px + 53px + 1px + 53px + 1px + 53px + 1px
 */

@interface HSNumericField ()
- (void)updateLabel;
- (void)doChangeSign;
- (void)doInsertDecimalPoint;
- (void)doDelete;
- (void)doClear;
- (void)doInsertZero;
- (void)doInsertDigit:(NSUInteger)digit;
@end

@implementation HSNumericInputView

+ (HSNumericInputView *)sharedInputView
{
    static HSNumericInputView *view = nil;
    
    if (view == nil) {
        view = [[HSNumericInputView alloc] initWithFrame:kInputViewFrame];
    }
    return view;
}

- (UIButton *)createButtonForIndex:(int)buttonIndex
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = kButtonFrames[buttonIndex];
    btn.tag = kButtonValues[buttonIndex];
    NSString *title = kButtonLabels[buttonIndex];
    if ([title length] == 1) {
        UIColor *shadowColor = [UIColor colorWithRed:0.357 green:0.373 blue:0.400 alpha:1.000];
        btn.titleLabel.font = [UIFont boldSystemFontOfSize:36];
        btn.titleLabel.shadowOffset = CGSizeMake(0, -1);
        btn.reversesTitleShadowWhenHighlighted = YES;
        [btn setTitle:title forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn setTitleShadowColor:shadowColor forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
        [btn setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    } else {
        NSString *titleUp = [title stringByAppendingString:@"Up"];
        [btn setImage:[UIImage imageNamed:titleUp] forState:UIControlStateNormal];
        NSString *titleDown = [title stringByAppendingString:@"Down"];
        [btn setImage:[UIImage imageNamed:titleDown] forState:UIControlStateHighlighted];
    }
    [btn
     setBackgroundImage:[UIImage imageNamed:@"NumberPadButtonUp"]
     forState:UIControlStateNormal];
    [btn
     setBackgroundImage:[UIImage imageNamed:@"NumberPadButtonDown"]
     forState:UIControlStateHighlighted];
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
        self.backgroundColor = [UIColor colorWithRed:0.25f green:0.25f blue:0.25f alpha:1];
        for (int btnIdx = 0; btnIdx < kButtonCount; btnIdx++) {
            [self addSubview:[self createButtonForIndex:btnIdx]];
        }
    }
    return self;
}

- (void)setActiveField:(HSNumericField *)field
{
    activeField = field;
}

- (void)numericInputViewButtonTouchUpInside:(id)sender
{
    switch ([sender tag]) {
        case kButtonValueChangeSign:
            [activeField doChangeSign];
            break;
        case kButtonValueDecimalPoint:
            [activeField doInsertDecimalPoint];
            break;
        case kButtonValueDelete:
            [activeField doDelete];
            break;
        case 0:
            [activeField doInsertZero];
            break;
        default:
            [activeField doInsertDigit:[sender tag]];
            break;
    }
    [activeField updateLabel];
    [activeField sendActionsForControlEvents:UIControlEventValueChanged];
}

// MARK: UIInputViewAudioFeedback

- (BOOL)enableInputClicksWhenVisible
{
    return YES;
}

// MARK: UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return NO;
}

@end

// MARK: -

@implementation HSNumericField

- (void)initSubviews
{
    self.inputView = [HSNumericInputView sharedInputView];
    if (self.delegate == nil) {
        self.delegate = [HSNumericInputView sharedInputView];
    }
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
    if (integerDigits == nil) {
        integerDigits = [NSMutableString string];
    }
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
        [[HSNumericInputView sharedInputView] setActiveField:self];
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)resignFirstResponder
{
    if ([super resignFirstResponder]) {
        [[HSNumericInputView sharedInputView] setActiveField:nil];
        return YES;
    } else {
        return NO;
    }
}

@end
