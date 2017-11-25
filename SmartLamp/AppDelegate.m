//
//  AppDelegate.m
//
//  Created by Trung Huynh on 7/2/15.
//  Copyright (c) 2015 Smart Lamp. All rights reserved.
//

#import "AppDelegate.h"
#import "SmartLampViewController.h"
#import "RearViewController.h"
#import "ScannerViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ScannerView" bundle:nil];
    ScannerViewController *scannerController = [storyboard instantiateViewControllerWithIdentifier:@"ScannerViewController"];
    
    RearViewController *rearController = [[RearViewController alloc] init];
    //UINavigationController *rearNavigationController = [[UINavigationController alloc] initWithRootViewController:rearViewController];
    rearController.scannerController = scannerController;
    
    SmartLampViewController *smartLampController = [[SmartLampViewController alloc] initWithNibName:nil bundle:nil];
    //self.window.rootViewController = pickerController;
    smartLampController.selectedColor = [UIColor whiteColor];
    smartLampController.scannerController = scannerController;
    smartLampController.rearController = rearController;
    smartLampController.delegate = self;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:smartLampController];

    SWRevealViewController *mainRevealController = [[SWRevealViewController alloc]
        initWithRearViewController:rearController frontViewController:navigationController];
    mainRevealController.rearViewRevealWidth = 180;
    //mainRevealController.delegate = self;
    
    self.viewController = mainRevealController;
    self.window.rootViewController = self.viewController;
    
    // Override point for customization after application launch.
    [self.window makeKeyAndVisible];
    return YES;
}

/*- (NSString*)stringFromFrontViewPosition:(FrontViewPosition)position
{
    NSString *str = nil;
    if ( position == FrontViewPositionLeft ) str = @"FrontViewPositionLeft";
    if ( position == FrontViewPositionRight ) str = @"FrontViewPositionRight";
    if ( position == FrontViewPositionRightMost ) str = @"FrontViewPositionRightMost";
    if ( position == FrontViewPositionRightMostRemoved ) str = @"FrontViewPositionRightMostRemoved";
    return str;
}

- (void)revealController:(SWRevealViewController *)revealController willMoveToPosition:(FrontViewPosition)position
{
    NSLog( @"%@: %@", NSStringFromSelector(_cmd), [self stringFromFrontViewPosition:position]);
}

- (void)revealController:(SWRevealViewController *)revealController didMoveToPosition:(FrontViewPosition)position
{
    NSLog( @"%@: %@", NSStringFromSelector(_cmd), [self stringFromFrontViewPosition:position]);
}

- (void)revealController:(SWRevealViewController *)revealController willRevealRearViewController:(UIViewController *)rearViewController
{
    NSLog( @"%@", NSStringFromSelector(_cmd));
}

- (void)revealController:(SWRevealViewController *)revealController didRevealRearViewController:(UIViewController *)rearViewController
{
    NSLog( @"%@", NSStringFromSelector(_cmd));
}

- (void)revealController:(SWRevealViewController *)revealController willHideRearViewController:(UIViewController *)rearViewController
{
    NSLog( @"%@", NSStringFromSelector(_cmd));
}

- (void)revealController:(SWRevealViewController *)revealController didHideRearViewController:(UIViewController *)rearViewController
{
    NSLog( @"%@", NSStringFromSelector(_cmd));
}

- (void)revealController:(SWRevealViewController *)revealController willShowFrontViewController:(UIViewController *)rearViewController
{
    NSLog( @"%@", NSStringFromSelector(_cmd));
}

- (void)revealController:(SWRevealViewController *)revealController didShowFrontViewController:(UIViewController *)rearViewController
{
    NSLog( @"%@", NSStringFromSelector(_cmd));
}

- (void)revealController:(SWRevealViewController *)revealController willHideFrontViewController:(UIViewController *)rearViewController
{
    NSLog( @"%@", NSStringFromSelector(_cmd));
}

- (void)revealController:(SWRevealViewController *)revealController didHideFrontViewController:(UIViewController *)rearViewController
{
    NSLog( @"%@", NSStringFromSelector(_cmd));
}*/

- (void)didReceiveVersion:(NSString *)version
{
    RearViewController *rearViewController = (RearViewController *)[self.viewController rearViewController];
    [rearViewController setVersion:version];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
