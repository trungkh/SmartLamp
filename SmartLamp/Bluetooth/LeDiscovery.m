//
//  LeDiscovery.m
//  Scan for and discover nearby LE peripherals with the
//  matching service UUID.
//
//  Created by Trung Huynh on 7/2/15.
//  Copyright (c) 2015 Smart Lamp. All rights reserved.
//

#import "LeDiscovery.h"

@interface LeDiscovery () <CBCentralManagerDelegate, CBPeripheralDelegate>
{
    CBCentralManager    *centralManager;
    BOOL				pendingInit;
    
    NSDictionary *scanOptions;
    NSDictionary *connectOptions;
    
    dispatch_queue_t eventQueue;
}
@end


@implementation LeDiscovery

@synthesize foundPeripherals;
@synthesize connectedPeripherals;
@synthesize advertisingData;
@synthesize discoveryDelegate;


#pragma mark -
#pragma mark Init
/****************************************************************************/
/*									Init									*/
/****************************************************************************/
+ (id) sharedInstance
{
    static LeDiscovery	*this	= nil;
    
    if (!this)
        this = [[LeDiscovery alloc] init];
    
    return this;
}

- (id) init
{
    self = [super init];
    if (self) {
        pendingInit = YES;
        
        scanOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
        
        connectOptions = @{CBConnectPeripheralOptionNotifyOnConnectionKey:@NO,
                           CBConnectPeripheralOptionNotifyOnDisconnectionKey:@NO,
                           CBConnectPeripheralOptionNotifyOnNotificationKey:@NO,
                           CBCentralManagerScanOptionAllowDuplicatesKey:@NO};
        
        NSDictionary *initOptions = @{CBCentralManagerOptionRestoreIdentifierKey:@"LECentral"};
        
        eventQueue = dispatch_queue_create(nil, DISPATCH_QUEUE_SERIAL);
        
        dispatch_set_target_queue(eventQueue, dispatch_get_main_queue());
        
        centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:eventQueue options:initOptions];
        
        foundPeripherals = [[NSMutableArray alloc] init];
        connectedPeripherals = [[NSMutableArray alloc] init];
        advertisingData = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void) dealloc
{
    // We are a singleton and as such, dealloc shouldn't be called.
    assert(NO);
}

- (void) clearDevices
{
    [foundPeripherals removeAllObjects];
    [connectedPeripherals removeAllObjects];
    [advertisingData removeAllObjects];
    [discoveryDelegate discoveryDidRefresh];
}

- (void) clearFoundPeripherals
{
    for(CBPeripheral *peripheral in foundPeripherals){
        [advertisingData removeObjectForKey:[peripheral identifier]];
        
    }
    [foundPeripherals removeAllObjects];
    [discoveryDelegate discoveryDidRefresh];
}

#pragma mark -
#pragma mark Restoring
/****************************************************************************/
/*								Settings									*/
/****************************************************************************/
/* Reload from file. */
- (void) loadSavedDevices
{
    NSArray	*storedDevices	= [[NSUserDefaults standardUserDefaults] arrayForKey:@"StoredDevices"];
    
    if (![storedDevices isKindOfClass:[NSArray class]]) {
        NSLog(@"No stored array to load");
        return;
    }
    
    for (id deviceUUIDString in storedDevices) {
        
        if (![deviceUUIDString isKindOfClass:[NSString class]])
            continue;
        
        CFUUIDRef uuid = CFUUIDCreateFromString(NULL, (CFStringRef)deviceUUIDString);
        if (!uuid)
            continue;
        
        [centralManager retrievePeripheralsWithIdentifiers:[NSArray arrayWithObject:(__bridge id)uuid]];
        CFRelease(uuid);
    }
}

- (void) addSavedDevice:(CFUUIDRef) uuid
{
    NSArray			*storedDevices	= [[NSUserDefaults standardUserDefaults] arrayForKey:@"StoredDevices"];
    NSMutableArray	*newDevices		= nil;
    CFStringRef		uuidString		= NULL;
    
    if (![storedDevices isKindOfClass:[NSArray class]]) {
        NSLog(@"Can't find/create an array to store the uuid");
        return;
    }
    
    newDevices = [NSMutableArray arrayWithArray:storedDevices];
    
    uuidString = CFUUIDCreateString(NULL, uuid);
    if (uuidString) {
        [newDevices addObject:(__bridge NSString*)uuidString];
        CFRelease(uuidString);
    }
    /* Store */
    [[NSUserDefaults standardUserDefaults] setObject:newDevices forKey:@"StoredDevices"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) removeSavedDevice:(CFUUIDRef) uuid
{
    NSArray			*storedDevices	= [[NSUserDefaults standardUserDefaults] arrayForKey:@"StoredDevices"];
    NSMutableArray	*newDevices		= nil;
    CFStringRef		uuidString		= NULL;
    
    if ([storedDevices isKindOfClass:[NSArray class]]) {
        newDevices = [NSMutableArray arrayWithArray:storedDevices];
        
        uuidString = CFUUIDCreateString(NULL, uuid);
        if (uuidString) {
            [newDevices removeObject:(__bridge NSString*)uuidString];
            CFRelease(uuidString);
        }
        /* Store */
        [[NSUserDefaults standardUserDefaults] setObject:newDevices forKey:@"StoredDevices"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void) centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals
{
    CBPeripheral	*peripheral;
    
    /* Add to list. */
    for (peripheral in peripherals) {
        [central connectPeripheral:peripheral options:connectOptions];
    }
    [discoveryDelegate discoveryDidRefresh];
}

- (void) centralManager:(CBCentralManager *)central didRetrievePeripheral:(CBPeripheral *)peripheral
{
    [central connectPeripheral:peripheral options:connectOptions];
    [discoveryDelegate discoveryDidRefresh];
}

- (void) centralManager:(CBCentralManager *)central didFailToRetrievePeripheralForUUID:(CFUUIDRef)UUID error:(NSError *)error
{
    /* Nuke from plist. */
    [self removeSavedDevice:UUID];
}

-(void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary *)dict{
    
}

- (void) centralManagerDidUpdateState:(CBCentralManager *)central
{
    static CBCentralManagerState previousState = -1;
    
    CBCentralManagerState newState = [centralManager state];
    
    switch (newState) {
        case CBCentralManagerStatePoweredOff:
        {
            [self clearDevices];
            [discoveryDelegate discoveryDidRefresh];
        }
            
        case CBCentralManagerStateUnauthorized:
        {
            /* Tell user the app is not allowed. */
            break;
        }
            
        case CBCentralManagerStateUnsupported:
        {
            /* Tell user the app is not allowed. */
            break;
        }
            
        case CBCentralManagerStateUnknown:
        {
            /* Bad news, let's wait for another event. */
            break;
        }
            
        case CBCentralManagerStatePoweredOn:
        {
            pendingInit = NO;
            [self loadSavedDevices];
            
            NSArray	*storedDevices	= [[NSUserDefaults standardUserDefaults] arrayForKey:@"StoredDevices"];
            if (![storedDevices isKindOfClass:[NSArray class]]) {
                NSLog(@"No stored array to load");
            }
            else {
                for (id uuid in storedDevices) {
                    
                    if (!uuid) {
                        continue;
                    }
                    
                    if (![uuid isKindOfClass:[CBUUID class]]) {
                        continue;
                    }
                    
                    NSArray *services = @[uuid];
                    [centralManager retrieveConnectedPeripheralsWithServices:services];
                    break;
                }
            }
            
            [discoveryDelegate discoveryDidRefresh];
            break;
        }
            
        case CBCentralManagerStateResetting:
        {
            [self clearDevices];
            [discoveryDelegate discoveryDidRefresh];
            
            pendingInit = YES;
            break;
        }
    }
    
    [discoveryDelegate discoveryStateChanged:newState];
    
    previousState = newState;
}


#pragma mark -
#pragma mark Discovery
/****************************************************************************/
/*								Discovery                                   */
/****************************************************************************/
- (CBCentralManagerState) startScanningForUUIDString:(NSString *)uuidString
{
    NSArray			*uuidArray;
    
    if(uuidString){
        uuidArray	= [NSArray arrayWithObjects:[CBUUID UUIDWithString:uuidString], nil];
    }
    else {
        uuidArray = nil;
    }
    
    [centralManager scanForPeripheralsWithServices:uuidArray options:scanOptions];
    
    return [centralManager state];
}

- (void) stopScanning
{
    [centralManager stopScan];
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    if (![foundPeripherals containsObject:peripheral]) {
        [foundPeripherals addObject:peripheral];
    }
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:RSSI forKey:@"RSSI"];
    [dict setObject:advertisementData forKey:@"advertisementData"];
    
    [advertisingData setObject:dict forKey:[peripheral identifier]];
    
    [discoveryDelegate discoveryDidRefresh];
}


#pragma mark -
#pragma mark Connection/Disconnection
/****************************************************************************/
/*						Connection/Disconnection                            */
/****************************************************************************/
- (void) connectPeripheral:(CBPeripheral*)peripheral
{
    if (![peripheral state]) {
        [centralManager connectPeripheral:peripheral options:connectOptions];
    }
}

- (void) disconnectPeripheral:(CBPeripheral*)peripheral
{
    [centralManager cancelPeripheralConnection:peripheral];
}

- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    if (![connectedPeripherals containsObject:peripheral])
        [connectedPeripherals addObject:peripheral];
    
    if ([foundPeripherals containsObject:peripheral])
        [foundPeripherals removeObject:peripheral];
    
    [peripheral setDelegate:self];
    
    [discoveryDelegate discoveryDidRefresh];
    [discoveryDelegate peripheralDidConnect:peripheral];
}

- (void) centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Attempted connection to peripheral %@ failed: %@", [peripheral name], [error localizedDescription]);
}

- (void) centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    CBPeripheral *_peripheral;
    
    for (_peripheral in connectedPeripherals) {
        if (_peripheral == peripheral) {
            [connectedPeripherals removeObject:peripheral];
            [discoveryDelegate peripheralDidDisconnect:peripheral];
            break;
        }
    }
    
    //put back in our found list
    [foundPeripherals addObject:peripheral];
    
    [discoveryDelegate peripheralDidDisconnect:peripheral];
}


#pragma mark -
#pragma mark Peripheral handling
/****************************************************************************/
/*						Peripheral handling                                 */
/****************************************************************************/
-(void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSMutableDictionary *dict = [advertisingData objectForKey:[peripheral identifier]];
    [dict setObject:[peripheral RSSI] forKey:@"RSSI"];
    [discoveryDelegate discoveryDidRefresh];
}

@end
