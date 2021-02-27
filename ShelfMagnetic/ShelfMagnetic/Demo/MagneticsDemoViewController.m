//
//  MagneticsDemoViewController.m
//  ShelfMagnetic
//
//  Created by Jenson on 2021/1/19.
//  Copyright © 2021 Jenson. All rights reserved.
//

#import "MagneticsDemoViewController.h"

/// 是否刘海屏
#define kIsBangsScreen ({\
    BOOL isBangsScreen = NO; \
    if (@available(iOS 11.0, *)) { \
    UIWindow *window = [[UIApplication sharedApplication].windows firstObject]; \
    isBangsScreen = window.safeAreaInsets.bottom > 0; \
    } \
    isBangsScreen; \
})

#define kTabbarHeight     (kIsBangsScreen?83.0:49.0)
#define kNavgationbarHeight     (kIsBangsScreen?88.0:64.0)
#define kStatusBarHeight     (kIsBangsScreen?44.0:20.0)
#define kSafeAreaInsetsBottom     (kIsBangsScreen?34.0:0.0)

@interface MagneticsDemoViewController ()

@end

@implementation MagneticsDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.frame = CGRectMake(0, kNavgationbarHeight, self.view.bounds.size.width, self.view.bounds.size.height - kNavgationbarHeight);
    
    self.refreshType = MagneticsRefreshTypePullToRefresh | MagneticsRefreshTypeInfiniteScrolling;
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
    
    //demo4
    context = [[MagneticContext alloc]init];
    context.type = MagneticTypeDemo4;
    [dataArr addObject:context];
    
    /**
     dataArr add more VC
     */
    [self requestMagneticsDidSucceedWithMagneticsArray:dataArr];
}

- (void)triggerRefreshAction {
    [super triggerRefreshAction];
    NSMutableArray *dataArr = [NSMutableArray array];
    //demo
    MagneticContext *context = [[MagneticContext alloc]init];
    context.type = MagneticTypeDemo;
    [dataArr addObject:context];
    
    //demo3
    context = [[MagneticContext alloc]init];
    context.type = MagneticTypeDemo3;
    context.json = @"THREE";
    [dataArr addObject:context];
    
    //demo2
    context = [[MagneticContext alloc]init];
    context.type = MagneticTypeDemo2;
    context.json = @"TWO";
    [dataArr addObject:context];
    
    /**
     dataArr add more VC
     */
    [self requestMagneticsDidSucceedWithMagneticsArray:dataArr];
}

//- (void)requestMoreData{
//    MagneticContext *context = [[MagneticContext alloc]init];
//    context.type = MagneticTypeDemo2;
//    context.json = @"FOUR";
//
//    //demo2
//    MagneticContext *context2 = [[MagneticContext alloc]init];
//    context2.type = MagneticTypeDemo3;
//    context2.json = @"FIVE";
//    [self requestMoreMagneticsDidSucceedWithMagneticsArray:@[context, context2]];
//}

@end
