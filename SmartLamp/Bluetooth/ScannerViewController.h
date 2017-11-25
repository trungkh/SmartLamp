//
//  ViewController.h
//
//  Created by Jacob on 11/11/13.
//  Copyright (c) 2013 Augmetous Inc.
//

#import <UIKit/UIKit.h>
#import "LeDiscovery.h"

@protocol ScannerViewDelegate <NSObject>
- (void) scannerDidConnect:(CBPeripheral*)peripheral;
- (void) scannerDidDisconnect;
@end

@interface ScannerViewController: UITableViewController  <LeDiscoveryDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *sensorsTable;
@property (strong, nonatomic) IBOutlet UIRefreshControl *refreshControl;

@property (strong, nonatomic) UIActivityIndicatorView *indicator;

@property (weak, nonatomic) CBPeripheral* currentPeripheral;

@property (nonatomic, assign) id<ScannerViewDelegate> delegate;

- (IBAction)refresh:(id)sender;
- (UIImage *)getRSSIImage:(int)rssi;

@end
