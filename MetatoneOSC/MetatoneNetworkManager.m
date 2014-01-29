//
//  MetatoneNetworkManager.m
//  Metatone
//
//  Created by Charles Martin on 10/04/13.
//  Copyright (c) 2013 Charles Martin. All rights reserved.
//  Modified January 2014 to work with F53OSC
//

#import "MetatoneNetworkManager.h"
#define DEFAULT_PORT 51200
#define DEFAULT_ADDRESS @"10.0.1.2"
#define METATONE_SERVICE_TYPE @"_metatoneapp._udp."
#define OSCLOGGER_SERVICE_TYPE @"_osclogger._udp."



@implementation MetatoneNetworkManager

// Designated Initialiser
-(MetatoneNetworkManager *) initWithDelegate: (id<MetatoneNetworkManagerDelegate>) delegate shouldOscLog: (bool) osclogging {
    self = [super init];
    
    self.delegate = delegate;
    self.deviceID = [[UIDevice currentDevice].identifierForVendor UUIDString];
    self.oscLogging = osclogging;
    
    // Setup OSC Client
    self.oscClient = [[F53OSCClient alloc] init];
    [self.oscClient setHost:DEFAULT_ADDRESS];
    [self.oscClient setPort:DEFAULT_PORT];
    [self.oscClient connect];
    if ([self.oscClient isConnected]) NSLog(@"NETWORK MANAGER: Setup Default OSC Connection.");
    
    
    // Setup OSC Server
    self.oscServer = [[F53OSCServer alloc] init];
    [self.oscServer setDelegate:self];
    [self.oscServer setPort:DEFAULT_PORT];
    [self.oscServer startListening];
    
    NSLog(@"NETWORK MANAGER: attempting to setup default port");
    // Default online message
    self.remoteIPAddress = DEFAULT_ADDRESS;
    self.remotePort = DEFAULT_PORT;
    [self sendMessageOnline];
    
    //self.connection = [[OSCConnection alloc] init];
    //self.connection.delegate = self;
    //self.connection.continuouslyReceivePackets = YES;
//    NSError *error;
//    if (![self.connection bindToAddress:nil port:DEFAULT_PORT error:&error])
//    {
//        NSLog(@"NETWORK MANAGER: Could not bind UDP connection: %@", error);
//        return nil;
//    } else {
//        NSLog(@"NETWORK MANAGER: Setup Default OSC Connection.");
//        self.remoteIPAddress = DEFAULT_ADDRESS;
//        self.remotePort = DEFAULT_PORT;
//        [self.connection receivePacket];
//        [self sendMessageOnline];
//    }
    
    // register with Bonjour
    self.metatoneNetService = [[NSNetService alloc]
                               initWithDomain:@""
                               type:METATONE_SERVICE_TYPE
                               name:[NSString stringWithFormat:@"%@", [UIDevice currentDevice].name]
                               port:DEFAULT_PORT];
    if (self.metatoneNetService != nil) {
        [self.metatoneNetService setDelegate: self];
        [self.metatoneNetService publishWithOptions:0];
        NSLog(@"NETWORK MANAGER: Metatone NetService Published.");
    }
    
    self.localIPAddress = [MetatoneNetworkManager getIPAddress];
    
    if (self.oscLogging) {
        // try to find an OSC Logger to connect to (but only if "oscLogging" is set).
        NSLog(@"NETWORK MANAGER: Browsing for OSC Logger Services...");
        self.oscLoggerServiceBrowser  = [[NSNetServiceBrowser alloc] init];
        [self.oscLoggerServiceBrowser setDelegate:self];
        [self.oscLoggerServiceBrowser searchForServicesOfType:OSCLOGGER_SERVICE_TYPE
                                                     inDomain:@"local."];
    }
    
    
    // try to find Metatone Apps to connect to (always do this)
    NSLog(@"NETWORK MANAGER: Browsing for Metatone App Services...");
    self.metatoneServiceBrowser  = [[NSNetServiceBrowser alloc] init];
    [self.metatoneServiceBrowser setDelegate:self];
    [self.metatoneServiceBrowser searchForServicesOfType:METATONE_SERVICE_TYPE
                                                 inDomain:@"local."];
    return self;
}

-(void) stopSearches
{
    [self.metatoneServiceBrowser stop];
    [self.oscLoggerServiceBrowser stop];
    [self.remoteMetatoneIPAddresses removeAllObjects];
    [self.remoteMetatoneNetServices removeAllObjects];
    //[self.connection disconnect];
    [self.oscClient disconnect];
}

#pragma mark Instantiation
-(NSMutableArray *) remoteMetatoneNetServices {
    if (!_remoteMetatoneNetServices) _remoteMetatoneNetServices = [[NSMutableArray alloc] init];
    return _remoteMetatoneNetServices;
}

-(NSMutableArray *) remoteMetatoneIPAddresses {
    if (!_remoteMetatoneIPAddresses) _remoteMetatoneIPAddresses = [[NSMutableArray alloc] init];
    return _remoteMetatoneIPAddresses;
}

# pragma mark NetServiceBrowserDelegate Methods

-(void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didNotSearch:(NSDictionary *)errorDict {
    NSLog(@"NETWORK MANAGER: ERROR: Did not search for OSC Logger");
}

-(void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
    NSLog([NSString stringWithFormat:@"NETWORK MANAGER: Found a NetService: %@", [aNetService type]]);
    
    if ([[aNetService type] isEqualToString:METATONE_SERVICE_TYPE]) {
        NSLog(@"NETWORK MANAGER: Found a metatoneapp. Resolving.");
        [aNetService setDelegate:self];
        [aNetService resolveWithTimeout:5.0];
        [self.remoteMetatoneNetServices addObject:aNetService];
    }
    
    if ([[aNetService type] isEqualToString:OSCLOGGER_SERVICE_TYPE]) {
        NSLog(@"NETWORK MANAGER: Found an OSC Logger. Resolving.");
        self.oscLoggerService = aNetService;
        [self.oscLoggerService setDelegate:self];
        [self.oscLoggerService resolveWithTimeout:10.0];
        //[self.oscLoggerServiceBrowser stop];
        // need to do something about possibility of more than one OSC Logger.
    }
        

}

-(void)netServiceDidResolveAddress:(NSNetService *)sender {
    NSString* firstAddress;
    int firstPort;
    
    for (NSData* data in [sender addresses]) {
        char addressBuffer[100];
        struct sockaddr_in* socketAddress = (struct sockaddr_in*) [data bytes];
        int sockFamily = socketAddress->sin_family;
        if (sockFamily == AF_INET || sockFamily == AF_INET6) {
            const char* addressStr = inet_ntop(sockFamily,
                                               &(socketAddress->sin_addr), addressBuffer,
                                               sizeof(addressBuffer));
            int port = ntohs(socketAddress->sin_port);
            if (addressStr && port) {
                NSLog(@"NETWORK MANAGER: Resolved service of type %@ at %s:%d", [sender type], addressStr, port);
                firstAddress = [NSString stringWithFormat:@"%s",addressStr];
                firstPort = port;
                break;
            }
        }
    }
    
    if ([sender.type isEqualToString:OSCLOGGER_SERVICE_TYPE] && firstAddress && firstPort) {
        self.remoteHostname = sender.hostName;
        self.remoteIPAddress = firstAddress;
        self.remotePort = firstPort;
        
        [self.delegate loggingServerFoundWithAddress:self.remoteIPAddress
                                             andPort:self.remotePort
                                         andHostname:self.remoteHostname];
        [self sendMessageOnline];
        NSLog(@"NETWORK MANAGER: Resolved and Connected to an OSC Logger Service.");
    }
    
    if ([sender.type isEqualToString:METATONE_SERVICE_TYPE] && firstAddress && firstPort) {
        // Save the found address.
        // Need to also check if address is already in the array.
        if (![firstAddress isEqualToString:self.localIPAddress]) {
            [self.remoteMetatoneIPAddresses addObject:@[firstAddress,[NSNumber numberWithInt:firstPort]]];
            NSLog(@"NETWORK MANAGER: Resolved and Connected to a MetatoneApp Service.");
        } else {
            NSLog(@"NETWORK MANAGER: Not connecting to local MetatoneApp Service.");
        }
    }
    
}


-(void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)aNetServiceBrowser {
    NSLog(@"NETWORK MANAGER: NetServiceBrowser will search.");
    //[aNetServiceBrowser
    [self.delegate searchingForLoggingServer];
}

-(void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)aNetServiceBrowser {
    NSLog(@"NETWORK MANAGER: NetServiceBrowser stopped searching.");
    [self.delegate stoppedSearchingForLoggingServer];
}


# pragma mark OSC Sending Methods

-(void)sendMessageWithAccelerationX:(double)x Y:(double)y Z:(double)z
{
    NSArray *contents = @[self.deviceID,
                          [NSNumber numberWithFloat:x],
                          [NSNumber numberWithFloat:y],
                          [NSNumber numberWithFloat:z]];
    
    F53OSCMessage *message = [F53OSCMessage messageWithAddressPattern:@"/metatone/acceleration"
                                                        arguments:contents];
    [self.oscClient sendPacket:message toHost:self.remoteIPAddress onPort:self.remotePort];
//    OSCMutableMessage *message = [[OSCMutableMessage alloc] init];
//    message.address = ;
//    [message addString:self.deviceID];
//    [message addFloat:x];
//    [message addFloat:y];
//    [message addFloat:z];
//    [self.connection sendPacket:message toHost:self.remoteIPAddress port:self.remotePort];
}

-(void)sendMessageWithTouch:(CGPoint)point Velocity:(CGFloat)vel
{
    NSArray *contents = @[self.deviceID,
                          [NSNumber numberWithFloat:point.x],
                          [NSNumber numberWithFloat:point.y],
                          [NSNumber numberWithFloat:vel]];
    F53OSCMessage *message = [F53OSCMessage messageWithAddressPattern:@"/metatone/touch"
                                                            arguments:contents];
    [self.oscClient sendPacket:message toHost:self.remoteIPAddress onPort:self.remotePort];

    
//    OSCMutableMessage *message = [[OSCMutableMessage alloc] init];
//    message.address = @"/metatone/touch";
//    [message addString:self.deviceID];
//    [message addFloat:point.x];
//    [message addFloat:point.y];
//    [message addFloat:vel];
//    [self.connection sendPacket:message toHost:self.remoteIPAddress port:self.remotePort];
}

-(void)sendMesssageSwitch:(NSString *)name On:(BOOL)on
{
    NSString *switchState = on ? @"T" : @"F";
    NSArray *contents = @[self.deviceID,
                          name,
                          switchState];
    F53OSCMessage *message = [F53OSCMessage messageWithAddressPattern:@"/metatone/switch" arguments:contents];
    [self.oscClient sendPacket:message toHost:self.remoteIPAddress onPort:self.remotePort];

//    OSCMutableMessage *message = [[OSCMutableMessage alloc] init];
//    message.address = @"/metatone/switch";
//    [message addString:self.deviceID];
//    [message addString:name];
//    [message addString:on ? @"T" : @"F"];
//    [self.connection sendPacket:message toHost:self.remoteIPAddress port:self.remotePort];
}

-(void)sendMessageTouchEnded
{
    NSArray *contents = @[self.deviceID];
    F53OSCMessage *message = [F53OSCMessage messageWithAddressPattern:@"/metatone/touch/ended" arguments:contents];
    [self.oscClient sendPacket:message toHost:self.remoteIPAddress onPort:self.remotePort];
    
//    OSCMutableMessage *message = [[OSCMutableMessage alloc] init];
//    message.address = @"/metatone/touch/ended";
//    [message addString:self.deviceID];
//    [self.connection sendPacket:message toHost:self.remoteIPAddress port:self.remotePort];
}

-(void)sendMessageOnline
{
    NSArray *contents = @[self.deviceID];
    F53OSCMessage *message = [F53OSCMessage messageWithAddressPattern:@"/metatone/online" arguments:contents];
    [self.oscClient sendPacket:message toHost:self.remoteIPAddress onPort:self.remotePort];
    
    
//    OSCMutableMessage *message = [[OSCMutableMessage alloc] init];
//    message.address = @"/metatone/online";
//    [message addString:self.deviceID];
//    [self.connection sendPacket:message toHost:self.remoteIPAddress port:self.remotePort];
}

-(void)sendMessageOffline
{
    NSArray *contents = @[self.deviceID];
    F53OSCMessage *message = [F53OSCMessage messageWithAddressPattern:@"/metatone/offline"
                                                            arguments:contents];
    [self.oscClient sendPacket:message toHost:self.remoteIPAddress onPort:self.remotePort];

    
//    OSCMutableMessage *message = [[OSCMutableMessage alloc] init];
//    message.address = @"/metatone/offline";
//    [message addString:self.deviceID];
//    [self.connection sendPacket:message toHost:self.remoteIPAddress port:self.remotePort];
}


-(void)sendMetatoneMessage:(NSString *)name withState:(NSString *)state {
    NSArray *contents = @[self.deviceID,
                          name,
                          state];
    F53OSCMessage *message = [F53OSCMessage messageWithAddressPattern:@"/metatone/app"
                                                            arguments:contents];

    // Log the metatone messages as well.
    // [self.oscClient sendPacket:message toHost:self.remoteIPAddress onPort:self.remotePort];
    
    for (NSArray *address in self.remoteMetatoneIPAddresses) {
        [self.oscClient sendPacket:message
                            toHost:(NSString *)address[0]
                              onPort:[((NSNumber *)address[1]) integerValue]];
    }
    
//    OSCMutableMessage *message = [[OSCMutableMessage alloc] init];
//    message.address = @"/metatone/app";
//    [message addString:self.deviceID];
//    [message addString:name];
//    [message addString:state];
//    for (NSArray *address in self.remoteMetatoneIPAddresses) {
//        [self.connection sendPacket:message toHost:(NSString *)address[0] port:[((NSNumber *)address[1]) integerValue]];
//    }
}

#pragma mark OSC Receiving Methods

//-(void)oscConnection:(OSCConnection *)connection didReceivePacket:(OSCPacket *)packet fromHost:(NSString *)host port:(UInt16)port
//{
//    // Received an OSC message
//    if ([packet.address isEqualToString:@"/metatone/app"]) {
//        //NSLog(@"NETWORK MANAGER: Received Metatone App Message");
//        //NSLog([packet description]);
//        if ([packet.arguments count] == 3) {
//            if ([packet.arguments[0] isKindOfClass:[NSString class]] &&
//                [packet.arguments[1] isKindOfClass:[NSString class]] &&
//                [packet.arguments[2] isKindOfClass:[NSString class]])
//            {
//                NSLog(@"NETWORK MANAGER: Correctly Formed Message - passing to delegate.");
//                [self.delegate didReceiveMetatoneMessageFrom:packet.arguments[0] withName:packet.arguments[1] andState:packet.arguments[2]];
//            }
//        }
//    }
//}

-(void)takeMessage:(F53OSCMessage *)message {
    // Received an OSC message
    if ([message.addressPattern isEqualToString:@"/metatone/app"]) {
        //NSLog(@"NETWORK MANAGER: Received Metatone App Message");
        //NSLog([packet description]);
        if ([message.arguments count] == 3) {
            if ([message.arguments[0] isKindOfClass:[NSString class]] &&
                [message.arguments[1] isKindOfClass:[NSString class]] &&
                [message.arguments[2] isKindOfClass:[NSString class]])
            {
                NSLog(@"NETWORK MANAGER: Correctly Formed Message - passing to delegate.");
                [self.delegate didReceiveMetatoneMessageFrom:message.arguments[0] withName:message.arguments[1] andState:message.arguments[2]];
            }
        }
    }
}


#pragma mark IP Address Methods

// Get IP Address
+ (NSString *)getIPAddress {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}

+ (NSString *)getLocalBroadcastAddress {
    NSArray *addressComponents = [[MetatoneNetworkManager getIPAddress] componentsSeparatedByString:@"."];
    NSString *address = nil;
    if ([addressComponents count] == 4)
    {
        address = @"";
        for (int i = 0; i<([addressComponents count] - 1); i++) {
            address = [address stringByAppendingString:addressComponents[i]];
            address = [address stringByAppendingString:@"."];
        }
        address = [address stringByAppendingString:@"255"];
    }
    return address;
}



@end
