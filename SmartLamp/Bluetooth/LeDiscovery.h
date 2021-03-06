//
//  LeDiscovery.h
//  Scan for and discover nearby LE peripherals with the
//  matching service UUID.
//
//  Created by Trung Huynh on 7/2/15.
//  Copyright (c) 2015 Smart Lamp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

/****************************************************************************/
/*							UI protocols									*/
/****************************************************************************/
@protocol LeDiscoveryDelegate <NSObject>
- (void) discoveryDidRefresh;
- (void) discoveryStateChanged:(CBCentralManagerState)state;
- (void) peripheralDidConnect:(CBPeripheral*)peripheral;
- (void) peripheralDidDisconnect:(CBPeripheral*)peripheral;
@end


/****************************************************************************/
/*							Discovery class									*/
/****************************************************************************/
@interface LeDiscovery : NSObject

+ (id) sharedInstance;


/****************************************************************************/
/*								UI controls									*/
/****************************************************************************/
@property (nonatomic, assign) id<LeDiscoveryDelegate> discoveryDelegate;


/****************************************************************************/
/*								Actions										*/
/****************************************************************************/
- (CBCentralManagerState) startScanningForUUIDString:(NSString *)uuidString;

- (void) stopScanning;

- (void) connectPeripheral:(CBPeripheral*)peripheral;
- (void) disconnectPeripheral:(CBPeripheral*)peripheral;

- (void) clearFoundPeripherals;

/****************************************************************************/
/*							Access to the devices							*/
/****************************************************************************/
@property (strong, nonatomic, readonly) NSMutableArray        *foundPeripherals;
@property (strong, nonatomic, readonly) NSMutableArray        *connectedPeripherals;
@property (strong, nonatomic, readonly) NSMutableDictionary   *advertisingData;
@end
