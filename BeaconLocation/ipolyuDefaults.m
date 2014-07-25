//
//  ipolyuDefaults.m
//  BeaconLocation
//
//  Created by wangchao on 14-1-14.
//  Copyright (c) 2014年 polyucomp. All rights reserved.
//

#import "ipolyuDefaults.h"

@implementation ipolyuDefaults


- (id)init
{
    self = [super init];
    if(self)
    {
        // uuidgen should be used to generate UUIDs.
        //default uuids index 0,1,2
        _supportedProximityUUIDs = @[[[NSUUID alloc] initWithUUIDString:@"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"],
                                     [[NSUUID alloc] initWithUUIDString:@"5A4BCFCE-174E-4BAC-A814-092E77F6B7E5"],
                                     [[NSUUID alloc] initWithUUIDString:@"74278BDA-B644-4520-8F0C-720EAF059935"]];
        //default Measured Powser -59
        _defaultPower = @-59;
        _defaultMajor= @ 0;
        _defaultMinor= @ 0;
        
    }
    
    return self;
}

+ (ipolyuDefaults *)sharedDefaults
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (NSUUID *)defaultProximityUUID
{
    //static method return the default uuid with index 0
    return [_supportedProximityUUIDs objectAtIndex:0];
}


@end
