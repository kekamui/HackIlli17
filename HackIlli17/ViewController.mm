//
//  ViewController.mm
//  HackIlli17
//
//  Created by Jonathan Chan on 2017-02-25.
//  Copyright © 2017 Jonathan Chan. All rights reserved.
//

#import "ViewController.h"
#import <Vuforia/Vuforia.h>
#import <Vuforia/DataSet.h>

@interface ViewController ()

@property (nonatomic, nullable) Vuforia::DataSet *dataSet;

@property (nonatomic) BOOL extendedTrackingEnabled;
@property (nonatomic) BOOL continuousAutofocusEnabled;
@property (nonatomic) BOOL flashEnabled;
@property (nonatomic) BOOL frontCameraEnabled;

@property (strong, nonatomic, nullable)

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
