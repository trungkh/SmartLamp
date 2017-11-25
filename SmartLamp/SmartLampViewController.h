//
//  SmartLampViewController.h
//
//  Created by Trung Huynh on 7/11/15.
//  Copyright (c) 2015 Smart Lamp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KZColorPicker.h"

#import "LeDataService.h"
#import "ScannerViewController.h"
#import "RearViewController.h"

@class SmartLampViewController;

@protocol SmartLampViewDelegate
//- (void) defaultColorController:(SmartLampViewController *)controller didChangeColor:(UIColor *)color;
- (void) didReceiveVersion:(NSString *)version;
@end

@interface SmartLampViewController : UIViewController <LeDataDelegate, ScannerViewDelegate, RearViewDelegate>

@property(nonatomic, assign) id<SmartLampViewDelegate> delegate;
@property(nonatomic, retain) UIColor *selectedColor;

@property(strong, nonatomic) ScannerViewController *scannerController;
@property(strong, nonatomic) LeDataService *currentService;
@property(strong, nonatomic) RearViewController *rearController;

@end
