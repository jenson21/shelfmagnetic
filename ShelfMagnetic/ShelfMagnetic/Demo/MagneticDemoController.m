//
//  MagneticDemoController.m
//  ShelfMagnetic
//
//  Created by Jenson on 2020/7/8.
//  Copyright © 2020 Jenson. All rights reserved.
//

#import "MagneticDemoController.h"

@implementation MagneticDemoController

#pragma mark Magnetic Content

///完成初始化监听
- (void)didFinishInitConfigurationInMagneticsController:(MagneticsController *)magneticsController {
    
    //数据处理，接口请求成功后
    self.isPrepared = YES;
    
}

///请求的url, 异步请求必须实现
- (NSString *)magneticRequestURLInMagneticsController:(MagneticsController *)magneticsController{
    return @"https://github.com/jenson21/shelfmagnetic";
}
///请求的参数
- (NSDictionary *)magneticRequestParametersInMagneticsController:(MagneticsController *)magneticsController{
    return nil;
}

//内容行数
- (NSInteger)magneticsController:(MagneticsController *)magneticsController rowCountForMagneticContentInTableView:(MagneticTableView *)tableView{
    return self.isPrepared ? 1 : 0;
}

//内容行高
- (CGFloat)magneticsController:(MagneticsController *)magneticsController rowHeightForMagneticContentAtIndex:(NSInteger)index{
    return 100.0;
}

//复用内容视图
- (void)magneticsController:(MagneticsController *)magneticsController reuseCell:(UITableViewCell *)cell forMagneticContentAtIndex:(NSInteger)index{
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, 100)];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"ONE";
    label.backgroundColor = [UIColor blueColor];
    [cell addSubview:label];
}

#pragma mark Magnetic Spacing

//磁片底部间距
- (CGFloat)magneticsController:(MagneticsController *)magneticsController heightForMagneticSpacingInTableView:(MagneticTableView *)tableView{
    return 10.0;
}

#pragma mark Magnetic Error

//是否显示磁片错误提示
- (BOOL)magneticsController:(MagneticsController *)magneticsController shouldShowMagneticErrorWithCode:(MagneticErrorCode)errorCode{
    return NO;
}

@end
