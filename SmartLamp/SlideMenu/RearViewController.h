//
//  RearViewController.h
//
//  Created by Trung Huynh on 7/11/15.
//  Copyright (c) 2015 Smart Lamp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LeDiscovery.h"
#import "ScannerViewController.h"
#import "IASKAppSettingsViewController.h"

@protocol RearViewDelegate
- (void)settingDidEnd;
@end

@interface RearViewController : UIViewController <IASKSettingsDelegate, UITableViewDelegate, UITableViewDataSource>
{
    IASKAppSettingsViewController *appSettingsViewController;
}

@property (nonatomic, retain) IBOutlet UITableView *rearTableView;
@property (strong, nonatomic) ScannerViewController *scannerController;
@property (nonatomic, retain) IASKAppSettingsViewController *appSettingsViewController;

@property (nonatomic, assign) id<RearViewDelegate> delegate;

@property (strong, nonatomic) NSString *version;

@end
