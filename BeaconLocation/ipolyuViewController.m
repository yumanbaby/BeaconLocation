//
//  ipolyuViewController.m
//  BeaconLocation
//
//  Created by wangchao on 14-1-13.
//  Copyright (c) 2014年 polyucomp. All rights reserved.
//

#import "ipolyuViewController.h"
#import "ipolyuBRViewController.h"
#import "ipolyuDefaults.h"

@interface ipolyuViewController ()
- (IBAction)advertisingSwith:(UISwitch *)sender;
@property (weak, nonatomic) IBOutlet UITextField *uuidTextField;
@property (weak, nonatomic) IBOutlet UITextField *majorTextField;
@property (weak, nonatomic) IBOutlet UITextField *minorTextField;
@property (weak, nonatomic) IBOutlet UITextField *measuredpowserTextField;

@end

@implementation ipolyuViewController
{
    //global variables
    CBPeripheralManager *_peripheralManager;
    BOOL _enableAdvertising;
    NSUUID *_uuid;
    NSNumber *_major;
    NSNumber *_minor;
    NSNumber *_power;
    
    NSNumberFormatter *_numberFormatter;
}

- (void)_startAdvertising
{
    
    //config the ibeacon parameter according to the user input
    _uuid= [[NSUUID alloc] initWithUUIDString:self.uuidTextField.text];
    _major = [_numberFormatter numberFromString:self.majorTextField.text];
    _minor = [_numberFormatter numberFromString:self.minorTextField.text];
    _power= [_numberFormatter numberFromString:self.measuredpowserTextField.text];
    
    CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:_uuid major:[_major shortValue] minor:[_minor shortValue] identifier:@"PolyU Beacon"];
    NSDictionary *beaconPeripheralData = [region peripheralDataWithMeasuredPower:_power];
    if (beaconPeripheralData) {
        //startAdvertising
        [_peripheralManager startAdvertising:beaconPeripheralData];
        NSLog(@"start adv");
    }
}

- (void)_updateEmitterForDesiredState
{
    
    if (_peripheralManager.state< CBPeripheralManagerStatePoweredOn) {
        //make sure the bluetooth is on,if not allert the users
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Bluetooth must be enabled" message:@"To configure your device as a beacon" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [errorAlert show];
        return;
    } else {
        
        if (_enableAdvertising) {
            if (!_peripheralManager.isAdvertising) {
                [self _startAdvertising];
            }
        }
        else {
            if (_peripheralManager.isAdvertising) {
                [_peripheralManager stopAdvertising];
                NSLog(@"stop adv");
            }
        }

    }
}

#pragma mark - CBPeripheralManagerDelegate
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    NSLog(@"BLE changed");
    [self _updateEmitterForDesiredState];
}


//
- (void)viewDidLoad
{
    [super viewDidLoad];
    _numberFormatter = [[NSNumberFormatter alloc] init];
    _numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;

    
    if (self) {
        
        //initiate a peripheralManager with default values in ipolyuDefaults class
        _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:nil];
        _uuid = [ipolyuDefaults sharedDefaults].defaultProximityUUID;
        _major=[ipolyuDefaults sharedDefaults].defaultMajor;
        _minor=[ipolyuDefaults sharedDefaults].defaultMinor;
        _power = [ipolyuDefaults sharedDefaults].defaultPower;
        
        self.uuidTextField.text=[[ipolyuDefaults sharedDefaults].defaultProximityUUID UUIDString];
        self.majorTextField.text= [[ipolyuDefaults sharedDefaults].defaultMajor stringValue];
        self.minorTextField.text= [[ipolyuDefaults sharedDefaults].defaultMinor stringValue];
        self.measuredpowserTextField.text= [[ipolyuDefaults sharedDefaults].defaultPower stringValue];

    }
    
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Actions
- (IBAction)advertisingSwith:(UISwitch *)sender {
    //switch of the beacon
    _enableAdvertising = sender.isOn;
    NSLog(@"swith changed");
    //Actions: start the beacon
    [self _updateEmitterForDesiredState];
}

#pragma delegate of textField
- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    //function: after the input press any key to eliminate the input dialogue
    [theTextField resignFirstResponder];
    return YES;
}



@end
