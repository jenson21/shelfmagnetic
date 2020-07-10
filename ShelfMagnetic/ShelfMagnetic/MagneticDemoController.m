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
- (NSInteger)MagneticsController:(MagneticsController *)magneticsController rowCountForMagneticContentInTableView:(MagneticTableView *)tableView
{
    return 0;
}

//内容行高
- (CGFloat)MagneticsController:(MagneticsController *)magneticsController rowHeightForMagneticContentAtIndex:(NSInteger)index
{
    return 0.0;
}

//复用内容视图
- (void)MagneticsController:(MagneticsController *)magneticsController reuseCell:(UITableViewCell *)cell forMagneticContentAtIndex:(NSInteger)index
{
    
}

#pragma mark Magnetic Spacing

//磁片底部间距
- (CGFloat)MagneticsController:(MagneticsController *)magneticsController heightForMagneticSpacingInTableView:(MagneticTableView *)tableView
{
    return 10.0;
}

#pragma mark Magnetic Error

//是否显示磁片错误提示
- (BOOL)MagneticsController:(MagneticsController *)magneticsController shouldShowMagneticErrorWithCode:(MagneticErrorCode)errorCode
{
    return NO;
}

@end
