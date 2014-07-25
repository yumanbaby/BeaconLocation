//
//  ipolyuDefaults.h
//  BeaconLocation
//  Function: Used to generate uuid if using predefined uuids
//  Created by wangchao on 14-1-14.
//  Copyright (c) 2014年 polyucomp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ipolyuDefaults : NSObject

+ (ipolyuDefaults *)sharedDefaults;

@property (nonatomic, copy, readonly) NSArray *supportedProximityUUIDs;

@property (nonatomic, copy, readonly) NSUUID *defaultProximityUUID;
@property (nonatomic, copy, readonly) NSNumber *defaultPower;
@property (nonatomic, copy, readonly) NSNumber *defaultMajor;
@property (nonatomic, copy, readonly) NSNumber *defaultMinor;

@end
