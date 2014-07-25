//
//  ipolyuVTestViewController.m
//  BeaconLocation
//
//  Created by wangchao on 14-2-12.
//  Copyright (c) 2014年 polyucomp. All rights reserved.
//

#import "ipolyuVTestViewController.h"
#import "ipolyuViewController.h"
#import "ipolyuDefaults.h"
#import "ASIHTTPRequest.h"

@interface ipolyuVTestViewController ()


@property (strong, nonatomic) CLBeaconRegion *beaconRegion;
@property (strong, nonatomic) CLLocationManager *locationManager;

- (IBAction)VTstartRanging:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *VTuuid;
@property (weak, nonatomic) IBOutlet UITextField *VTMajor;
@property (weak, nonatomic) IBOutlet UITextField *VTMinor;
@property (weak, nonatomic) IBOutlet UITextField *VTAccuracy;
@property (weak, nonatomic) IBOutlet UITextField *VTDistance;
- (IBAction)VTdisplayNotification:(UISwitch *)sender;


- (IBAction)btnConnectServer:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *txtDistance;
@property (weak, nonatomic) IBOutlet UITextField *txtEntryTime;

@property (weak, nonatomic) IBOutlet UITextField *txtExitTime;
@property (weak, nonatomic) IBOutlet UILabel *lblVelocity;
@property (weak, nonatomic) IBOutlet UILabel *lblServerResponse;
- (IBAction)btnGetEntryTime:(id)sender;
- (IBAction)btnGetExitTime:(id)sender;




@end

@implementation ipolyuVTestViewController

{
    BOOL _enableNotification;
    UILocalNotification *notice;
    UIAlertView *alert;
    
    NSString *UUID;
    NSString *Major;
    NSString *Minor;
    
    NSDateFormatter *dateFormatter;
    NSDate *intime;
    NSString *entry_time;
    NSString *exit_time;
    NSString *velocity_main;
    NSDate *exittime;
}

- (void) initRegion{
    
    //ranging beacon
    NSUUID *uuid =[ipolyuDefaults sharedDefaults].defaultProximityUUID;
    self.beaconRegion=[[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"PolyU Beacon"];
    [self locationManager:self.locationManager didStartMonitoringForRegion:self.beaconRegion];
    
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region{
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
}

- (void) locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region{
    [self sendNotification:0];
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
    //get enter time
    [self timeMark:0];
    NSLog(@"Enter region");
}
- (void) locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region{
    
    [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
    [self sendNotification:1];
    //get exit time
    [self timeMark:1];
    NSLog(@"Exit region");
}

//mark the entry and exit time. 0 means enter, 1 means exit
-(void) timeMark:(int) entryflag {
    if (entryflag==0) {
        //generate entry time
        if ([self.txtEntryTime.text length]==0) {
            NSDate *systemtime=[NSDate date];
            intime=systemtime;
            self.txtEntryTime.text=[dateFormatter stringFromDate:systemtime];
        }
       
    }
    else
    {
        //generate exit time
        if ([self.txtExitTime.text length]==0) {
            NSDate *systemtime=[NSDate date];
            exittime=systemtime;
            self.txtExitTime.text=[dateFormatter stringFromDate:systemtime];

        }
    }
}

//show notification 0 means enter, 1 means exit. _enbaleNotification is the switch
-(void)sendNotification:(int) entryflag{
    if (entryflag==0) {
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
        NSLog(@"Enter marked");
    }
    else
    {
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
        NSLog(@"Exit marked");
    }
}

-( void) locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region{
    
    //if detecting a beacon. get the detals of it.
    CLBeacon *beacon = [[CLBeacon alloc] init];
    beacon = [beacons lastObject];
    
    //show the details in the view
    self.VTuuid.text = beacon.proximityUUID.UUIDString;
    UUID=beacon.proximityUUID.UUIDString;
    Major=[NSString stringWithFormat:@"%@", beacon.major];
    Minor=[NSString stringWithFormat:@"%@", beacon.minor];
    self.VTMajor.text = [NSString stringWithFormat:@"%@", beacon.major];
    self.VTMinor.text = [NSString stringWithFormat:@"%@", beacon.minor];
    self.VTAccuracy.text = [NSString stringWithFormat:@"%f m", beacon.accuracy];
    //means enter the region
    [self timeMark:0];

    if (beacon.proximity == CLProximityUnknown) {
        self.VTDistance.text = @"Unknown Proximity";
        //means exit the region
        [self timeMark:1];
    } else if (beacon.proximity == CLProximityImmediate) {
        self.VTDistance.text = @"Immediate";
        
    } else if (beacon.proximity == CLProximityNear) {
        self.VTDistance.text = @"Near";
    } else if (beacon.proximity == CLProximityFar) {
        self.VTDistance.text = @"Far";
    }
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
    //set the default distance to 10m
    self.txtDistance.text=@"10";
    
    //set the format of the time
    dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

    
    //Beacon part
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

//Start ranging
- (IBAction)VTstartRanging:(id)sender {
    [self initRegion];
}

//notification swithcer
- (IBAction)VTdisplayNotification:(UISwitch *)sender {
    _enableNotification = sender.isOn;
    NSLog(@"switch changed");
}


//
- (IBAction)btnConnectServer:(id)sender {

    //basic infomation collected
    [self getVelocity];
    
    //URLWithString for connection NSURL
    NSString *urlString=[NSString stringWithFormat:@"http://158.132.236.230:8080/examples/HiBeaconServlet?%@%@&%@%@&%@%@&%@%@&%@%@&%@%@",@"entrytime=",entry_time,@"exittime=",exit_time,@"speed=",velocity_main,@"uuid=",UUID,
                         @"major=",Major,@"minor=",Minor];
    urlString=[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url=[NSURL URLWithString:urlString];
    
    //using ASIHTTPRequest to sent the http request
    ASIHTTPRequest *request=[ASIHTTPRequest requestWithURL:url];
    [request startSynchronous];
    NSError *error=[request error];
    if (!error) {
        //if works normal. Print the server response.
        self.lblServerResponse.text=[request responseString];
        
        //clear data
        self.txtEntryTime.text=@"";
        self.txtExitTime.text=@"";
        
        NSLog(@"%@",[request responseString]);
    }
    else{
    self.lblServerResponse.text=@"Connetion Failed";
    }
}

#pragma delegate of textField
- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    
    [theTextField resignFirstResponder];
    return YES;
}
- (IBAction)btnGetEntryTime:(id)sender {
    
    NSDate *systemtime=[NSDate date];
    self.txtEntryTime.text=[dateFormatter stringFromDate:systemtime];
}

- (IBAction)btnGetExitTime:(id)sender {

    NSDate *systemtime=[NSDate date];
    self.txtExitTime.text=[dateFormatter stringFromDate:systemtime];
}

-(void) getVelocity {
    //get distance
    float distance=[self.txtDistance.text integerValue];
    //get time
    intime=[dateFormatter dateFromString:self.txtEntryTime.text];
    exittime=[dateFormatter dateFromString:self.txtExitTime.text];
    NSTimeInterval intervaltime=[exittime timeIntervalSinceDate:intime];
    float durtime=intervaltime;
    float speed=distance/durtime;
    
    entry_time=self.txtEntryTime.text;
    exit_time=self.txtExitTime.text;
    velocity_main=[NSString stringWithFormat:@"%.2f",speed];
    
    //speed
    self.lblVelocity.text=[NSString stringWithFormat:@"%@%@",velocity_main,@"m/s"];

}
@end
