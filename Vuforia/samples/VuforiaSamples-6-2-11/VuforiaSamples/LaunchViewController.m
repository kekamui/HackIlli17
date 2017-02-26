//
//  LaunchViewController.m
//  VuforiaSamples
//
//  Created by Jonathan Chan on 2017-02-26.
//  Copyright © 2017 Qualcomm. All rights reserved.
//

#import "LaunchViewController.h"

@interface LaunchViewController ()

@property (strong, nonatomic) UIButton *button;

@end

@implementation LaunchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.button = [[UIButton alloc] init];
    self.button.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self.button setImage:[UIImage imageWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"LaunchImage.png"]] forState:UIControlStateNormal];
    [self.view addSubview:self.button];
    
    [self.button addTarget:self action:@selector(didTap:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didTap:(UIButton *)sender {
    [self performSegueWithIdentifier:@"FinishLaunching" sender:self];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
