//
//  AppDelegate.h
//
//  Created by Trung Huynh on 7/2/15.
//  Copyright (c) 2015 Smart Lamp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWRevealViewController.h"
#import "SmartLampViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, SmartLampViewDelegate/*, SWRevealViewControllerDelegate*/>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) SWRevealViewController *viewController;

@end

