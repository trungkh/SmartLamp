//
//  SmartLampViewController.m
//
//  Created by Trung Huynh on 7/11/15.
//  Copyright (c) 2015 Smart Lamp. All rights reserved.
//

#import "SmartLampViewController.h"
#import "SWRevealViewController.h"


@interface SmartLampViewController() {
@private
    NSTimer *RSSITimer;
}
@end

@implementation SmartLampViewController

@synthesize delegate;
@synthesize selectedColor;

@synthesize scannerController;
@synthesize currentService;
@synthesize rearController;

/* The designated initializer. Override if you create the controller programmatically
 * and want to perform customization that is not appropriate for viewDidLoad.
 */
/*- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
return self;
}*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    SWRevealViewController *revealController = [self revealViewController];
    revealController.frontViewShadowRadius = 1;
    
    //Blur and translucent navigation bar
    UIColor *barColour = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.60f];
    UIView *colourView = [[UIView alloc] initWithFrame:CGRectMake(0.f, -20.f, 320.f, 64.f)];
    colourView.opaque = NO;
    colourView.alpha = .7f;
    colourView.backgroundColor = barColour;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.barTintColor = barColour;
    [self.navigationController.navigationBar.layer insertSublayer:colourView.layer atIndex:1];
    // done
    
    //gesture recognizer
    [self.navigationController.navigationBar addGestureRecognizer:revealController.panGestureRecognizer];
    
    //Reverse color of status bar
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    
    //Add menu item
    UIBarButtonItem *menuBarButton = [[UIBarButtonItem alloc]
                                      initWithImage:[UIImage imageNamed:@"Reveal.png"]
                                      style:UIBarButtonItemStylePlain
                                      target:revealController
                                      action:@selector(revealToggle:)];
    self.navigationItem.leftBarButtonItem = menuBarButton;
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    
    //UIView *container = [[UIView alloc] initWithFrame: IS_IPAD ? CGRectMake(0, 0, 320, 460) :[[UIScreen mainScreen] applicationFrame]];
    UIView *container = [[UIView alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
    container.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    container.backgroundColor = [UIColor darkGrayColor];
    self.view = container;
    
    [self.scannerController setDelegate:self];
    [self.rearController setDelegate:self];
    
    KZColorPicker *picker = [[KZColorPicker alloc] initWithFrame:container.bounds];
    picker.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    picker.selectedColor = self.selectedColor;
    //picker.oldColor = self.selectedColor;

    [picker addTarget:self
               action:@selector(pickerChanged:)
     forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:picker];
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    if (scannerController.currentPeripheral)
    {
        [currentService setController:nil];
    }
}

- (void) pickerChanged:(KZColorPicker *)colorPicker
{
    self.selectedColor = colorPicker.selectedColor;

    if (scannerController.currentPeripheral)
    {
        NSString *str = nil;
        if ([colorPicker.selectedColor isEqual:[UIColor whiteColor]])
        {
            //start to check preferrences
            if (![[NSUserDefaults standardUserDefaults] objectForKey:@"auto_change"])
            {
                NSString  *mainBundlePath = [[NSBundle mainBundle] bundlePath];
                NSString  *settingsPropertyListPath = [mainBundlePath
                                                       stringByAppendingPathComponent:@"Settings.bundle/Root.plist"];
                
                NSDictionary *settingsPropertyList = [NSDictionary
                                                      dictionaryWithContentsOfFile:settingsPropertyListPath];
                
                NSMutableArray      *preferenceArray = [settingsPropertyList objectForKey:@"PreferenceSpecifiers"];
                NSMutableDictionary *registerableDictionary = [NSMutableDictionary dictionary];
                
                for (int i = 0; i < [preferenceArray count]; i++)
                {
                    NSString  *key = [[preferenceArray objectAtIndex:i] objectForKey:@"Key"];
                    if (key)
                    {
                        id  value = [[preferenceArray objectAtIndex:i] objectForKey:@"DefaultValue"];
                        [registerableDictionary setObject:value forKey:key];
                    }
                }
                [[NSUserDefaults standardUserDefaults] registerDefaults:registerableDictionary];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            //end
            
            NSDictionary *location = [[NSUserDefaults standardUserDefaults] objectForKey:@"auto_change"];
            str = [NSString stringWithFormat:@"*255|255|255|%@#", (NSString *)location];
        }
        else
        {
            const CGFloat* colors = CGColorGetComponents( colorPicker.selectedColor.CGColor );
            str = [NSString stringWithFormat:@"*%d|%d|%d#",
                         (int)(colors[0] * 255), (int)(colors[1] * 255), (int)(colors[2] * 255)];
        }
        NSData* tosend = [str dataUsingEncoding:NSUTF8StringEncoding];
        
        [currentService write:tosend];
    }
    
    //[delegate defaultColorController:self didChangeColor:colorPicker.selectedColor];
}

- (void) refreshRSSI
{
    if (scannerController.currentPeripheral) {
        int rssi = [[[currentService peripheral] RSSI] integerValue];
        
        UIImage *signal = [scannerController getRSSIImage:rssi];
        UIBarButtonItem *signalItem = [[UIBarButtonItem alloc]
                                          initWithImage:signal
                                          style:UIBarButtonItemStylePlain
                                          target:nil
                                          action:nil];
        [self.navigationItem setRightBarButtonItem:signalItem animated:NO];
        self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
        
        [[currentService peripheral] readRSSI];
    }
}

#pragma mark -
#pragma mark ScannerViewDelegate Methods
/****************************************************************************/
/*				ScannerViewDelegate Methods                             */
/****************************************************************************/
/** Connected */
- (void) scannerDidConnect:(CBPeripheral *)peripheral
{
    //Create a new DataService with peripheral, and tell it to report to us
    self.currentService = [[LeDataService alloc] initWithPeripheral:(CBPeripheral*)peripheral
                                                         controller:self];
    //start the service
    [currentService start];
    
    RSSITimer = [NSTimer scheduledTimerWithTimeInterval:2.0
                                                 target:self
                                               selector:@selector(refreshRSSI)
                                               userInfo:nil
                                                repeats:YES];

    self.navigationItem.title = [peripheral name];
}

/** Disconnected */
- (void) scannerDidDisconnect
{
    [currentService setController:nil];
    self.navigationItem.title = nil;
    [self.navigationItem setRightBarButtonItem:nil animated:NO];
    [delegate didReceiveVersion:nil];
}

#pragma mark -
#pragma mark LeDataDelegate Methods
/****************************************************************************/
/*				LeDataDelegate Methods                                      */
/****************************************************************************/
/** Received data */
- (void) serviceDidReceiveData:(NSData*)data fromService:(LeDataService*)service
{
    if (service != currentService)
        return;
    
    NSString *recv = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSArray *arr = [recv componentsSeparatedByCharactersInSet:
                    [NSCharacterSet characterSetWithCharactersInString:@"*|#"]];
    NSString *ret = nil;
    switch ([arr[2] integerValue]) {
        case 5:
            ret = [NSString stringWithFormat:@"%@.%@", arr[3], arr[4]];
            [delegate didReceiveVersion:ret];
            break;
        default:
            break;
    }
    //NSLog(@"%@, %d", recv, [recv length]);
    //NSLog(@"0:%@ 1:%@ 2:%@ 3:%@ 4:%@", arr[0], arr[1], arr[2], arr[3], arr[4]);
}

/** Confirms the data was received with ack (if supported), or the error */
- (void) didWriteFromService:(LeDataService *)service withError:(NSError *)error{
    //we just assume writes went through
}

/** Confirms service started fully */
- (void) serviceDidReceiveCharacteristicsFromService:(LeDataService*)service
{
    if (service != currentService)
        return;
    
    RSSITimer = [NSTimer scheduledTimerWithTimeInterval:2.0
                                                 target:self
                                               selector:@selector(refreshRSSI)
                                               userInfo:nil
                                                repeats:YES];
}

#pragma mark -
#pragma mark RearViewDelegate Methods
/****************************************************************************/
/*				RearViewDelegate Methods                                    */
/****************************************************************************/
/** Setting Done */
- (void)settingDidEnd
{
    if (scannerController.currentPeripheral)
    {
        NSDictionary *location = [[NSUserDefaults standardUserDefaults] objectForKey:@"timer"];
        NSString *str = [NSString stringWithFormat:@"*255|255|255|3|%@#", (NSString *)location];
        NSData* tosend = [str dataUsingEncoding:NSUTF8StringEncoding];
        [currentService write:tosend];
    }
}

#pragma mark -
#pragma mark Backgrounding Methods
/****************************************************************************/
/*                       Bacgrounding Methods                               */
/****************************************************************************/
- (void)didEnterBackgroundNotification:(NSNotification*)notification
{
    [RSSITimer invalidate];
    
    //if we were trying to reconnect to a peripheral, lets stop for battery life
    if([[currentService peripheral] state] == CBPeripheralStateConnecting)
    {
        //disable any notifications we have
        [currentService enteredBackground];
        
        //disconnect
        [[LeDiscovery sharedInstance] disconnectPeripheral:[currentService peripheral]];
    }
}

- (void)didEnterForegroundNotification:(NSNotification*)notification
{
    RSSITimer = [NSTimer scheduledTimerWithTimeInterval:2.0
                                                 target:self
                                               selector:@selector(refreshRSSI)
                                               userInfo:nil
                                                repeats:YES];
    
    //if we're not connected, try to connect
    if([[currentService peripheral] state] == CBPeripheralStateDisconnected)
    {
        [[LeDiscovery sharedInstance] connectPeripheral:[currentService peripheral]];
    }
}

@end
