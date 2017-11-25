//
//  LeDataService.m
//  Data Service Header - Connect to a peripheral
//  and send and receive data.
//
//  Created by Trung Huynh on 7/2/15.
//  Copyright (c) 2015 Smart Lamp. All rights reserved.
//


#import "LeDataService.h"
#import "LeDiscovery.h"

@interface LeDataService() <CBPeripheralDelegate> {
@private
    CBPeripheral		*servicePeripheral;
    
    CBCharacteristic    *writeCharacteristic;
    CBCharacteristic    *readCharacteristic;
    
    CBService			*dataService;
    
    id<LeDataDelegate>	peripheralDelegate;
}
@end


@implementation LeDataService

@synthesize peripheral = servicePeripheral;

#pragma mark -
#pragma mark Init
/****************************************************************************/
/*								Init										*/
/****************************************************************************/
- (id) initWithPeripheral:(CBPeripheral *)peripheral controller:(id<LeDataDelegate>)controller
{
    self = [super init];
    if (self)
    {
        servicePeripheral = peripheral;
        [servicePeripheral setDelegate:self];
        peripheralDelegate = controller;
    }
    return self;
}


- (void) dealloc
{
    if (servicePeripheral)
    {
        [servicePeripheral setDelegate:[LeDiscovery sharedInstance]];
        servicePeripheral = nil;
    }
}


- (void) reset
{
    if (servicePeripheral)
    {
        servicePeripheral = nil;
    }
}


#pragma mark -
#pragma mark Service interaction
/****************************************************************************/
/*							Service Interactions							*/
/****************************************************************************/
- (void) setController:(id<LeDataDelegate>)controller
{
    peripheralDelegate = controller;
}

- (void) start
{
    //doing this again, as after a connect the Discovery takes peripheral back
    //if we disconnect, then reconnect, we would have lost delegate
    [servicePeripheral setDelegate:self];
    
    [servicePeripheral discoverServices:nil];
}

- (void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    NSArray		*services	= nil;
    
    if (peripheral != servicePeripheral)
    {
        NSLog(@"Wrong Peripheral.\n");
        return;
    }
    
    if (error != nil)
    {
        NSLog(@"Error %@\n", error);
        return;
    }
    
    services = [peripheral services];
    if (!services || ![services count])
    {
        return;
    }
    
    for (CBService *service in services)
    {
        dataService = service;
    }
    
    if (dataService)
    {
        [peripheral discoverCharacteristics:nil forService:dataService];
    }
}

- (void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error;
{
    NSArray		*characteristics	= [service characteristics];
    CBCharacteristic *characteristic;
    
    if (peripheral != servicePeripheral)
    {
        NSLog(@"Wrong Peripheral.\n");
        return;
    }
    
    if (service != dataService)
    {
        NSLog(@"Wrong Service.\n");
        return;
    }
    
    if (error != nil)
    {
        NSLog(@"Error %@\n", error);
        return;
    }
    
    for (characteristic in characteristics)
    {
        NSLog(@"discovered characteristic %@", [characteristic UUID]);
        
        NSLog(@"Discovered Read Characteristic");
        readCharacteristic = characteristic;
        [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        
        NSLog(@"Discovered Write Characteristic");
        writeCharacteristic = characteristic;
    }
    
    //check if we've found all services we need for this device and call delegate
    if(readCharacteristic && writeCharacteristic)
    {
        [peripheralDelegate serviceDidReceiveCharacteristicsFromService:self];
    }
    
    //start to check preferrences
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"timer"])  {
        
        NSString  *mainBundlePath = [[NSBundle mainBundle] bundlePath];
        NSString  *settingsPropertyListPath = [mainBundlePath
                                               stringByAppendingPathComponent:@"Settings.bundle/Root.plist"];
        
        NSDictionary *settingsPropertyList = [NSDictionary
                                              dictionaryWithContentsOfFile:settingsPropertyListPath];
        
        NSMutableArray      *preferenceArray = [settingsPropertyList objectForKey:@"PreferenceSpecifiers"];
        NSMutableDictionary *registerableDictionary = [NSMutableDictionary dictionary];
        
        for (int i = 0; i < [preferenceArray count]; i++)  {
            NSString  *key = [[preferenceArray objectAtIndex:i] objectForKey:@"Key"];
            
            if (key)  {
                id  value = [[preferenceArray objectAtIndex:i] objectForKey:@"DefaultValue"];
                [registerableDictionary setObject:value forKey:key];
            }
        }
        
        [[NSUserDefaults standardUserDefaults] registerDefaults:registerableDictionary];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    //end
    
    //Set timer
    NSDictionary *location = [[NSUserDefaults standardUserDefaults] objectForKey:@"timer"];
    NSString *str = [NSString stringWithFormat:@"*255|255|255|3|%@#", (NSString *)location];
    NSData* tosend = [str dataUsingEncoding:NSUTF8StringEncoding];
    [self write:tosend];
    
    //Request version
    str = [NSString stringWithFormat:@"*255|255|255|4#"];
    tosend = [str dataUsingEncoding:NSUTF8StringEncoding];
    [self write:tosend];
}


#pragma mark -
#pragma mark Characteristics interaction
/****************************************************************************/
/*						Characteristics Interactions						*/
/****************************************************************************/
- (void) write:(NSData *)data
{
    if (!servicePeripheral)
    {
        NSLog(@"Not connected to a peripheral");
        return;
    }
    
    if (!writeCharacteristic)
    {
        NSLog(@"No valid write characteristic");
        return;
    }
    
    if (!data)
    {
        NSLog(@"Nothing to write");
        return;
    }
    
    [servicePeripheral writeValue:data forCharacteristic:writeCharacteristic type:CBCharacteristicWriteWithoutResponse];
    [peripheralDelegate didWriteFromService:self withError:nil];
}

/** If we're connected, we don't want to be getting read change notifications while we're in the background.
 We will want read notifications, so we don't turn those off.
 */
- (void)enteredBackground
{
    // Find the fishtank service
    for (CBService *service in [servicePeripheral services])
    {
        //if ([serviceCBUUIDs containsObject:[service UUID]]) {
        
        // Find the read characteristic
        for (CBCharacteristic *characteristic in [service characteristics])
        {
            //if ( [writeCBUUIDs containsObject:[characteristic UUID]] ) {
            
            // And STOP getting notifications from it
            [servicePeripheral setNotifyValue:NO forCharacteristic:characteristic];
            //}
        }
        //}
    }
}

/** Coming back from the background, we want to register for notifications again for the read changes */
- (void)enteredForeground
{
    // Find the fishtank service
    for (CBService *service in [servicePeripheral services])
    {
        //if ([serviceCBUUIDs containsObject:[service UUID]]) {
        
        // Find the read characteristic
        for (CBCharacteristic *characteristic in [service characteristics])
        {
            //if ( [writeCBUUIDs containsObject:[characteristic UUID]] ) {
            
            // And START getting notifications from it
            [servicePeripheral setNotifyValue:YES forCharacteristic:characteristic];
            //}
        }
        //}
    }
}

- (void) peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (peripheral != servicePeripheral)
    {
        NSLog(@"Wrong peripheral\n");
        return;
    }
    
    if ([error code] != 0)
    {
        NSLog(@"Error %@\n", error);
        return;
    }
    
    [peripheralDelegate serviceDidReceiveData:[readCharacteristic value] fromService:self];
}

- (void) peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    [peripheralDelegate didWriteFromService:self withError:error];
}
@end
