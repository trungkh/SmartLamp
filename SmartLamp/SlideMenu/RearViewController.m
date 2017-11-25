//
//  RearViewController.m
//
//  Created by Trung Huynh on 7/11/15.
//  Copyright (c) 2015 Smart Lamp. All rights reserved.
//

#import "RearViewController.h"
#import "SWRevealViewController.h"
#import "AboutViewController.h"

#define COLOR(color) [UIColor colorWithRed:((color >> 16) & 0xFF)/255.0f \
                                     green:((color >> 8) & 0xFF)/255.0f \
                                      blue:((color >> 0) & 0xFF)/255.0f \
                                     alpha:((color >> 24) & 0xFF)/255.0f]

@implementation RearViewController

@synthesize rearTableView = _rearTableView;
@synthesize scannerController;
@synthesize appSettingsViewController;

@synthesize delegate;
@synthesize version;

- (void)viewDidLoad
{
	[super viewDidLoad];
	//self.navigationItem.title = @"Smart Lamp";
    
    self.rearTableView.backgroundColor =  COLOR(0xFFDADAD0);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    SWRevealViewController *grandParentRevealController = self.revealViewController.revealViewController;
    grandParentRevealController.bounceBackOnOverdraw = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    SWRevealViewController *grandParentRevealController = self.revealViewController.revealViewController;
    grandParentRevealController.bounceBackOnOverdraw = YES;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
    self.appSettingsViewController = nil;
}

#pragma marl - UITableView Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *cellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	NSInteger row = indexPath.row;
    
	if (nil == cell)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
	}
	
    NSString *icon = nil;
    NSString *text = nil;
	if (row == 1)
	{
        icon = @"Connect.png";
		text = @"Connect";
	}
	else if (row == 2)
	{
        icon = @"Disconnect.png";
        text = @"Disconnect";
	}
	else if (row == 3)
	{
        icon = @"Settings.png";
		text = @"Settings";
	}
    else if (row == 4)
    {
        icon = @"Info.png";
        text = @"About";
    }
    
    cell.imageView.image = [UIImage imageNamed:icon];
    //cell.imageView.frame = CGRectMake(0, 0, 1, 1);
    cell.textLabel.text = NSLocalizedString( text, nil );
    //cell.textLabel.font = [UIFont fontWithName:@"Avenir Next Medium" size:20];
    cell.backgroundColor =  [UIColor clearColor];
    
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UINavigationController *navController = nil;
    AboutViewController *aboutController = nil;
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *beView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    beView.frame = self.view.bounds;
    
    UIColor *barColour = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.6f];
    UIView *colourView = [[UIView alloc] initWithFrame:CGRectMake(0.f, -20.f, 320.f, 64.f)];
    colourView.opaque = NO;
    colourView.alpha = 0.7f;
    colourView.backgroundColor = barColour;
    
    switch (indexPath.row)
    {
        case 1:
            //Calling scanner
            navController = [[UINavigationController alloc] initWithRootViewController:scannerController];
            
            navController.view.frame = self.view.bounds;
            navController.view.backgroundColor = [UIColor clearColor];
            [navController.view insertSubview:beView atIndex:0];
            navController.modalPresentationStyle = UIModalPresentationOverCurrentContext;

            [navController.navigationBar setBackgroundImage:[UIImage new]
                                              forBarMetrics:UIBarMetricsDefault];
            navController.navigationBar.barTintColor = barColour;
            [navController.navigationBar.layer insertSublayer:colourView.layer atIndex:1];
            
            [self.revealViewController revealToggleAnimated:YES];
            [self presentViewController:navController animated:YES completion:nil];
            break;
        case 2:
            //Calling disconnected
            if (scannerController.currentPeripheral)
                [[LeDiscovery sharedInstance] disconnectPeripheral:scannerController.currentPeripheral];
            else
                NSLog(@"disconnected");

            [self.revealViewController revealToggleAnimated:YES];
            break;
        case 3:
            //Calling Settings
            navController = [[UINavigationController alloc] initWithRootViewController:self.appSettingsViewController];
            
            /*navController.view.frame = self.view.bounds;
            navController.view.backgroundColor = [UIColor clearColor];
            [navController.view insertSubview:beView atIndex:0];
            navController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            
            [navController.navigationBar setBackgroundImage:[UIImage new]
                                              forBarMetrics:UIBarMetricsDefault];
            navController.navigationBar.barTintColor = barColour;
            [navController.navigationBar.layer insertSublayer:colourView.layer atIndex:1];*/
            
            [self.revealViewController revealToggleAnimated:YES];
            self.appSettingsViewController.showDoneButton = YES;
            [self presentViewController:navController animated:YES completion:nil];
            break;
        case 4:
            //Calling about
            aboutController = [[AboutViewController alloc] initWithNibName:@"AboutViewController" bundle:nil];
            aboutController.view;
            if(version != nil)
                [aboutController.version setText:version];
            else
                [aboutController.version setText:@"unknown"];
            
            navController = [[UINavigationController alloc] initWithRootViewController:aboutController];
            navController.view.frame = self.view.bounds;
            navController.view.backgroundColor = [UIColor clearColor];
            [navController.view insertSubview:beView atIndex:0];
            navController.modalPresentationStyle = UIModalPresentationOverCurrentContext;

            [navController.navigationBar setBackgroundImage:[UIImage new]
                                                          forBarMetrics:UIBarMetricsDefault];
            navController.navigationBar.barTintColor = barColour;
            [navController.navigationBar.layer insertSublayer:colourView.layer atIndex:1];
            
            [self.revealViewController revealToggleAnimated:YES];
            [self presentViewController:navController animated:YES completion:nil];
            break;
        default:
            break;
    }
    
    [self.rearTableView deselectRowAtIndexPath:indexPath animated:YES];
    //_presentedRow = row;  // <- store the presented row
}

- (IASKAppSettingsViewController*)appSettingsViewController
{
    if (!appSettingsViewController)
    {
        appSettingsViewController = [[IASKAppSettingsViewController alloc] init];
        appSettingsViewController.delegate = self;
    }
    return appSettingsViewController;
}

- (void)settingsViewControllerDidEnd:(IASKAppSettingsViewController*)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
    // your code here to reconfigure the app for changed settings
    [delegate settingDidEnd];
}

@end
