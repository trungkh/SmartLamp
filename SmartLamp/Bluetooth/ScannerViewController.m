//
//  ViewController.m
//
//  Created by Jacob on 11/11/13.
//  Copyright (c) 2013 Augmetous Inc.
//


#import <Foundation/Foundation.h>

#import "ScannerViewController.h"
#import "BLECell.h"

@implementation ScannerViewController

@synthesize currentPeripheral;
@synthesize sensorsTable;
@synthesize refreshControl;
@synthesize indicator;
@synthesize delegate;

#pragma mark -
#pragma mark View lifecycle
/****************************************************************************/
/*								View Lifecycle                              */
/****************************************************************************/
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        // Custom initialization
    }
    
    return self;
}

//stuff that needs to happen once on creation
- (void) viewDidLoad
{
    [super viewDidLoad];
    [[LeDiscovery sharedInstance] setDiscoveryDelegate:self];
    
    //Blur effect view controller
    UIBlurEffect * blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *beView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    beView.frame = self.view.bounds;
    
    self.view.frame = self.view.bounds;
    self.view.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.5f];
    [self.view insertSubview:beView atIndex:0];
    self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    
    //self.navigationController.view.frame = self.view.bounds;
    //self.navigationController.view.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.5f];
    //[self.navigationController.view insertSubview:beView atIndex:0];
    //self.navigationController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    
    //Indicator on right
    indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:indicator];
    
    //Cancel button on left
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                   target:self
                                   action:@selector(cancel:)];
    
    self.navigationItem.leftBarButtonItem = buttonItem;
    
    //Notification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterBackgroundNotification:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterForegroundNotification:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//stuff that needs to happen every time we come back to this view controller
-(void)viewWillAppear:(BOOL)animated
{
    //Going to arbitrarily say you can only connect to one device at a time
    //Want to continue getting RSSI data, and also can't peripheral delegates
    //havent been changed when we come back here
    //so disconnect if we came back with a live peripheral
    if(currentPeripheral)
        [[LeDiscovery sharedInstance] disconnectPeripheral:currentPeripheral];
    
    CBCentralManagerState state = [[LeDiscovery sharedInstance] startScanningForUUIDString:nil];
    if(state == CBCentralManagerStatePoweredOn)
    {
        [indicator startAnimating];
    }else{
        [indicator stopAnimating];
    }
    
    [sensorsTable reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    [[LeDiscovery sharedInstance] stopScanning];
    [[LeDiscovery sharedInstance] setDiscoveryDelegate:nil];
}

- (void)manualSegue
{
    [[LeDiscovery sharedInstance] stopScanning];
    //Switch to main view controller
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancel:(id)sender
{
    [[LeDiscovery sharedInstance] stopScanning];
    //Switch to main view controller
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)refresh:(id)sender
{
    [self.refreshControl beginRefreshing];
    [[LeDiscovery sharedInstance] stopScanning];
    [[LeDiscovery sharedInstance] clearFoundPeripherals];
    
    CBCentralManagerState state = [[LeDiscovery sharedInstance] startScanningForUUIDString:nil];
    if(state == CBCentralManagerStatePoweredOn)
    {
        [indicator startAnimating];
    }else{
        [indicator stopAnimating];
    }
    
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

-(UIImage *) getRSSIImage:(int)rssi
{
    // Update RSSI indicator
    UIImage* image;
    if (rssi < -90) {
        image = nil;
    }
    else if (rssi < -70)
    {
        image = [UIImage imageNamed: @"Signal_1"];
    }
    else if (rssi < -50)
    {
        image = [UIImage imageNamed: @"Signal_2"];
    }
    else
    {
        image = [UIImage imageNamed: @"Signal_3"];
    }
    return image;
}

#pragma mark -
#pragma mark TableView Delegates
/****************************************************************************/
/*							TableView Delegates								*/
/****************************************************************************/
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger	res = 0;
    
    if (section == 0)
        res = [[[LeDiscovery sharedInstance] connectedPeripherals] count];
    else
        res = [[[LeDiscovery sharedInstance] foundPeripherals] count];
    
    return res;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CBPeripheral	*peripheral;
    NSArray			*devices;
    NSInteger		row	= [indexPath row];
    
    static NSString *cellID = @"deviceCell";
    BLECell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    cell.backgroundColor = [UIColor clearColor];
    cell.accessoryType = UITableViewCellAccessoryNone;

    //2 sections, connected devices and discovered devices
    if ([indexPath section] == 0)
    {
        devices = [[LeDiscovery sharedInstance] connectedPeripherals];
        peripheral = [devices objectAtIndex:row];
    }
    else
    {
        devices = [[LeDiscovery sharedInstance] foundPeripherals];
        peripheral = (CBPeripheral*)[devices objectAtIndex:row];
    }
    
    if ([[peripheral name] length])
    {
        [cell.name setText:[peripheral name]];
    }
    else
    {
        [cell.name setText:@"Peripheral"];
    }
    
    [cell.uuid setText:[[peripheral identifier] UUIDString]];
    
    NSDictionary *advertisingData = [[LeDiscovery sharedInstance] advertisingData];
    NSDictionary *peripheralDictionary = [advertisingData objectForKey:[peripheral identifier]];

    int rssi = [[peripheralDictionary objectForKey:@"RSSI"] integerValue];
    cell.imageView.image = [self getRSSIImage:rssi];
    cell.imageView.image = [cell.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [cell.imageView setTintColor:[UIColor blackColor]];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CBPeripheral	*peripheral;
    NSArray			*devices;
    NSInteger		row	= [indexPath row];
    
    if ([indexPath section] == 0) {
        //because I've arbitrarily decided we only connect to one at a time
        //we should never get here
        //connected devices, segue on over
        devices = [[LeDiscovery sharedInstance] connectedPeripherals];
        currentPeripheral = [devices objectAtIndex:row];
        [self manualSegue];
        
    } else {
        //found devices, send off connect which will segue if successful
        devices = [[LeDiscovery sharedInstance] foundPeripherals];
        peripheral = (CBPeripheral*)[devices objectAtIndex:row];
        [[LeDiscovery sharedInstance] connectPeripheral:peripheral];
    }
}

#pragma mark -
#pragma mark LeDiscoveryDelegate
/****************************************************************************/
/*                       LeDiscoveryDelegate Methods                        */
/****************************************************************************/
- (void) discoveryDidRefresh
{
    [indicator startAnimating];
    
    [sensorsTable reloadData];
}

- (void) discoveryStateChanged:(CBCentralManagerState)state
{
    if(state == CBCentralManagerStatePoweredOn)
    {
        [self refresh:nil];
    }
    else
    {
        [indicator stopAnimating];
        
        NSString *title     = @"Bluetooth Power";
        NSString *message   = @"You must turn on Bluetooth in Settings in order to use LE";
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                       message:message
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

/** Peripheral disconnected -- do something? */
-(void)peripheralDidDisconnect:(CBPeripheral *)peripheral
{
    [sensorsTable reloadData];
    currentPeripheral = nil;
    [self.delegate scannerDidDisconnect];
}

/** Peripheral connected */
- (void) peripheralDidConnect:(CBPeripheral *)peripheral
{
    //Going to arbitrarily say you can only connect to one device at a time
    //so go ahead and segue
    self.currentPeripheral = peripheral;

    [self.delegate scannerDidConnect:peripheral];
    
    [self manualSegue];
}

#pragma mark -
#pragma mark Backgrounding Methods
/****************************************************************************/
/*                       Bacgrounding Methods                               */
/****************************************************************************/
- (void)didEnterBackgroundNotification:(NSNotification*)notification
{
    //stop scanning to save battery life
    [[LeDiscovery sharedInstance] stopScanning];
}

- (void)didEnterForegroundNotification:(NSNotification*)notification
{
    //start scanning again
    CBCentralManagerState state = [[LeDiscovery sharedInstance] startScanningForUUIDString:nil];
    if(state == CBCentralManagerStatePoweredOn)
    {
        [indicator startAnimating];
    }else{
        [indicator stopAnimating];
    }
}

@end
