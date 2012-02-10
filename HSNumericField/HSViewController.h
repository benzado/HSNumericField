//
//  HSViewController.h
//  HSNumericField
//
//  Created by Benjamin Ragheb on 11/7/11.
//  Copyright (c) 2011 Heroic Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HSNumericField;

@interface HSViewController : UIViewController

@property (nonatomic,strong) IBOutlet HSNumericField *numericField;
@property (nonatomic,strong) IBOutlet UITextField *formatField;

- (IBAction)doEndEditing:(id)sender;
- (IBAction)doChangeFormatString:(id)sender;

@end
