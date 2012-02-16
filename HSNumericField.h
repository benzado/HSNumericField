//
//  HSNumericField.h
//  HSNumericField
//
//  Created by Benjamin Ragheb on 11/7/11.
//  Copyright (c) 2011 Heroic Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HSNumericField : UITextField
{
    BOOL isNegative;
    NSMutableString *integerDigits;
    NSMutableString *fractionalDigits;
}
@property (nonatomic, strong, readwrite) NSNumber *numberValue;
@end

@interface HSNumericInputView : UIView <UIInputViewAudioFeedback, UITextFieldDelegate>
{
    __unsafe_unretained HSNumericField *activeField;
}
+ (HSNumericInputView *)sharedInputView;
@end

