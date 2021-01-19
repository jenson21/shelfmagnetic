//
//  MagneticsDemoViewController.m
//  ShelfMagnetic
//
//  Created by Jenson on 2021/1/19.
//  Copyright © 2021 Jenson. All rights reserved.
//

#import "MagneticsDemoViewController.h"

@interface MagneticsDemoViewController ()

@end

@implementation MagneticsDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableArray *dataArr = [NSMutableArray array];
    //demo
    MagneticContext *context = [[MagneticContext alloc]init];
    context.type = MagneticTypeDemo;
    [dataArr addObject:context];
    
    //demo2
    context = [[MagneticContext alloc]init];
    context.type = MagneticTypeDemo2;
    context.json = @"TWO";
    [dataArr addObject:context];
    
    //demo3
    context = [[MagneticContext alloc]init];
    context.type = MagneticTypeDemo3;
    context.json = @"THREE";
    [dataArr addObject:context];
    /**
     dataArr add more VC
     */
    [self requestMagneticsDidSucceedWithMagneticsArray:dataArr];
}

@end
