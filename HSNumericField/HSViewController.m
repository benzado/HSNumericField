//
//  HSViewController.m
//  HSNumericField
//
//  Created by Benjamin Ragheb on 11/7/11.
//  Copyright (c) 2011 Heroic Software Inc. All rights reserved.
//

#import "HSViewController.h"
#import "HSNumericField.h"

@implementation HSViewController

@synthesize numericField;
@synthesize formatField;

- (IBAction)doEndEditing:(id)sender
{
    [self.view endEditing:YES];
}

- (IBAction)doChangeFormatString:(id)sender
{
    //[self.numericField.formatter setPositiveFormat:self.formatField.text];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
