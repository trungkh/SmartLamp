//
//  LeDataService.h
//  Data Service Header - Connect to a peripheral
//  and send and receive data.
//
//  Created by Trung Huynh on 7/2/15.
//  Copyright (c) 2015 Smart Lamp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

/****************************************************************************/
/*								Protocol									*/
/****************************************************************************/
@class LeDataService;

@protocol LeDataDelegate<NSObject>
- (void) serviceDidReceiveData:(NSData*)data fromService:(LeDataService*)service;
- (void) serviceDidReceiveCharacteristicsFromService:(LeDataService*)service;
- (void) didWriteFromService:(LeDataService *)service withError:(NSError *)error;
@end


/****************************************************************************/
/*						Data service.                                       */
/****************************************************************************/
@interface LeDataService : NSObject

- (id) initWithPeripheral:(CBPeripheral *)peripheral controller:(id<LeDataDelegate>)controller;

- (void) setController:(id<LeDataDelegate>)controller;

- (void) reset;
- (void) start;

- (void) write:(NSData *)data;

/* Behave properly when heading into and out of the background */
- (void)enteredBackground;
- (void)enteredForeground;

@property (readonly) CBPeripheral *peripheral;
@end
