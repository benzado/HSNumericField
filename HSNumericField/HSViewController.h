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
@property (nonatomic,strong) IBOutlet UILabel *textLabel;
@property (nonatomic,strong) IBOutlet UILabel *numberLabel;

- (IBAction)doEndEditing:(id)sender;
- (IBAction)numericValueChanged:(HSNumericField *)sender;

@end
