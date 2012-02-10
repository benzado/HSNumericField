//
//  HSAppDelegate.m
//  HSNumericField
//
//  Created by Benjamin Ragheb on 11/7/11.
//  Copyright (c) 2011 Heroic Software Inc. All rights reserved.
//

#import "HSAppDelegate.h"

#import "HSViewController.h"

@implementation HSAppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.viewController = [[HSViewController alloc] initWithNibName:@"HSViewController_iPhone" bundle:nil];
    } else {
        self.viewController = [[HSViewController alloc] initWithNibName:@"HSViewController_iPad" bundle:nil];
    }
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
