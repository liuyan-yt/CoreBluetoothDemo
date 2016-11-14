//
//  ViewController.m
//  CoreBluetoothDemo
//
//  Created by 柳焱 on 16/11/14.
//  Copyright © 2016年 liuyan. All rights reserved.
//

#import "ViewController.h"
#import "LYCenterBLEVC.h"
#import "LYPeripheralBLEVC.h"

@interface ViewController ()

@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)centerBLE:(id)sender {
    [self.navigationController pushViewController:[[LYCenterBLEVC alloc] init] animated:YES];
    
    
}
- (IBAction)peripheralBLE:(id)sender {
    [self.navigationController pushViewController:[[LYPeripheralBLEVC alloc] init] animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
