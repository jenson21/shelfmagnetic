//
//  ViewController.m
//  ShelfMagnetic
//
//  Created by Jenson on 2020/5/31.
//  Copyright © 2020 Jenson. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSMutableArray *dataArr = [NSMutableArray array];
    MagneticContext *context = [[MagneticContext alloc]init];
    context.type = MagneticTypeDemo;
    [dataArr addObject:context];
    /**
     dataArr add more VC
     */
    [self requestMagneticsDidSucceedWithMagneticsArray:dataArr];
}


@end
