//
//  ViewController.m
//  ShelfMagnetic
//
//  Created by Jenson on 2020/5/31.
//  Copyright © 2020 Jenson. All rights reserved.
//

#import "ViewController.h"
#import "MagneticsDemoViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (IBAction)pushMagnetic:(id)sender {
    MagneticsDemoViewController *magnetics = [[MagneticsDemoViewController alloc] init];
    [self.navigationController pushViewController:magnetics animated:YES];
}
@end
