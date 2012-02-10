//
//  HSNumericField.h
//  HSNumericField
//
//  Created by Benjamin Ragheb on 11/7/11.
//  Copyright (c) 2011 Heroic Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HSNumericInputView : UIView <UIInputViewAudioFeedback>
{
    UIResponder *__nextResponder;
}
+ (HSNumericInputView *)sharedInputView;
@end

@interface HSNumericField : UITextField
{
    BOOL isNegative;
    NSMutableString *integerDigits;
    NSMutableString *fractionalDigits;
    NSNumberFormatter *integerFormatter;
}
@property (nonatomic, strong, readwrite) NSNumber *numberValue;
@property (nonatomic) NSNumberFormatterStyle numberStyle;
@end
