//
//  ipolyuBRViewController.m
//  BeaconLocation
//
//  Created by wangchao on 14-1-15.
//  Copyright (c) 2014年 polyucomp. All rights reserved.
//

#import "ipolyuBRViewController.h"
#import "ipolyuViewController.h"
#import "ipolyuDefaults.h"

@interface ipolyuBRViewController ()

@property (strong, nonatomic) CLBeaconRegion *beaconRegion;
@property (strong, nonatomic) CLLocationManager *locationManager;

@property (weak, nonatomic) IBOutlet UITextField *BRMajor;
@property (weak, nonatomic) IBOutlet UITextField *BRMinor;
@property (weak, nonatomic) IBOutlet UITextField *BRAccuracy;
@property (weak, nonatomic) IBOutlet UITextField *BRRSSI;
@property (weak, nonatomic) IBOutlet UITextField *BRDistance;
@property (weak, nonatomic) IBOutlet UITextField *BRUUID;

- (IBAction)BRdisplayNotification:(UISwitch *)sender;
- (IBAction)startRanging:(id)sender;


@end

@implementation ipolyuBRViewController 

{
    BOOL _enableNotification;
    UILocalNotification *notice;
    UIAlertView *alert;
}

- (void) initRegion{
    
    //initiate a beacon, locationManager can handle the beacon, beaconRegion contains
    //the properties of the beacon like Near, Far, Enter/Exit Region....
    NSUUID *uuid =[ipolyuDefaults sharedDefaults].defaultProximityUUID;
    self.beaconRegion=[[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"PolyU Beacon"];
    
    [self locationManager:self.locationManager didStartMonitoringForRegion:self.beaconRegion];
    
}


- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region{
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
}

- (void) locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region{
    [self sendEntryNotification];
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
    NSLog(@"Enter region");
}

- (void) locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region{
    [self sendExitNotification];
    [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
    NSLog(@"Exit region");
}



-(void)sendExitNotification{
    //sendExitNotification
    if (_enableNotification) {
        notice=[[UILocalNotification alloc] init];
        notice.alertBody=@"Exit Region";
        notice.alertAction=@"Open";
        notice.hasAction=YES;
        notice.soundName=UILocalNotificationDefaultSoundName;
        [[UIApplication sharedApplication] scheduleLocalNotification:notice];
        alert =[[UIAlertView alloc] initWithTitle:@"Beacon Region Notification" message:notice.alertBody delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];

    }
    
}
-(void)sendEntryNotification{
    //sendEntryNotification
    if (_enableNotification) {
        
        notice=[[UILocalNotification alloc] init];
        notice.alertBody=@"Entry Region";
        notice.soundName=UILocalNotificationDefaultSoundName;
        notice.alertAction=@"Open";
        notice.hasAction=YES;
        [[UIApplication sharedApplication] scheduleLocalNotification:notice];
        alert =[[UIAlertView alloc] initWithTitle:@"Beacon Region Notification" message:notice.alertBody delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];

    }
   
}


-( void) locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region{
    //if detect a beacon. Get the info of it
    
    CLBeacon *beacon = [[CLBeacon alloc] init];
    beacon = [beacons lastObject];
    
    //beacon details. show in the view
    self.BRUUID.text = beacon.proximityUUID.UUIDString;
    self.BRMajor.text = [NSString stringWithFormat:@"%@", beacon.major];
    self.BRMinor.text = [NSString stringWithFormat:@"%@", beacon.minor];
    self.BRAccuracy.text = [NSString stringWithFormat:@"%f m", beacon.accuracy];
    if (beacon.proximity == CLProximityUnknown) {
        self.BRDistance.text = @"Unknown Proximity";
    } else if (beacon.proximity == CLProximityImmediate) {
        self.BRDistance.text = @"Immediate";
    } else if (beacon.proximity == CLProximityNear) {
        self.BRDistance.text = @"Near";
    } else if (beacon.proximity == CLProximityFar) {
        self.BRDistance.text = @"Far";
    }
    self.BRRSSI.text = [NSString stringWithFormat:@"%li", (long)beacon.rssi];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //ini a locationmanager so it can start finding the region and handle beacon event
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate=self;
    _enableNotification=YES;
    
	// Do any additional setup after loading the view.
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma delegate of textField
- (BOOL)textFieldShouldBeginEditing:(UITextField *)theTextField {
    
    NSLog(@"No Editing txtField");
    return NO;
}



- (IBAction)BRdisplayNotification:(UISwitch *) sender {
    //switch of the notification
    _enableNotification = sender.isOn;
    NSLog(@"switch changed");

}

- (IBAction)startRanging:(id)sender {
    //start ranging
    [self initRegion];
}
@end
