//
//  MagneticDemo2Controller.m
//  ShelfMagnetic
//
//  Created by Jenson on 2021/1/19.
//  Copyright © 2021 Jenson. All rights reserved.
//

#import "MagneticDemo2Controller.h"

@implementation MagneticDemo2Controller

///完成初始化监听
- (void)didFinishInitConfigurationInMagneticsController:(MagneticsController *)magneticsController {
    
    self.isPrepared = self.magneticContext.json;
    
}

/**
 * Magnetic Spacing
 * @brief 磁片头部间距
 */

///磁片头部间距大小。默认为0.0，当高度为0.0时无间距（不占用cell）。
- (CGFloat)magneticsController:(MagneticsController *)magneticsController heightForMagneticHeaderSpacingInTableView:(MagneticTableView *)tableView{
    return 20;
}

///磁片头部间距颜色。默认为透明。
- (UIColor *)magneticsController:(MagneticsController *)magneticsController colorForMagneticHeaderSpacingInTableView:(MagneticTableView *)tableView{
    return [UIColor lightTextColor];
}

/**
 * Magnetic Header
 * @brief 磁片头部
 */

///是否显示头部视图。默认为NO。
- (BOOL)magneticsController:(MagneticsController *)magneticsController shouldShowMagneticHeaderInTableView:(MagneticTableView *)tableView{
    return YES;
}

///头部行高
- (CGFloat)magneticsController:(MagneticsController *)magneticsController heightForMagneticHeaderInTableView:(MagneticTableView *)tableView{
    return 10;
}

///复用头部视图
- (void)magneticsController:(MagneticsController *)magneticsController reuseCell:(UITableViewCell *)cell forMagneticHeaderInTableView:(MagneticTableView *)tableView{
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, 10)];
    title.font = [UIFont boldSystemFontOfSize:10];
    title.textColor = [UIColor blackColor];
    title.text = @"TWO";
    title.textAlignment = NSTextAlignmentCenter;
    [cell.contentView addSubview:title];
}

#pragma mark - Magnetic Content
- (UIColor *)magneticsController:(MagneticController *)magneticsController colorForMagneticBackgroundInTableView:(MagneticTableView *)tableView{
    return [UIColor clearColor];
}

// 内容行数
- (NSInteger)magneticsController:(MagneticController *)magneticsController rowCountForMagneticContentInTableView:(MagneticTableView *)tableView{
    return self.isPrepared ? 1 : 0;
}

// 内容行高
- (CGFloat)magneticsController:(MagneticController *)magneticsController rowHeightForMagneticContentAtIndex:(NSInteger)index{
    return 200;
}

//复用内容视图
- (void)magneticsController:(MagneticsController *)magneticsController reuseCell:(UITableViewCell *)cell forMagneticContentAtIndex:(NSInteger)index{
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, 200)];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = self.magneticContext.json;
    label.backgroundColor = [UIColor magentaColor];
    [cell.contentView addSubview:label];
}

///磁片间距大小。默认为10.0，当高度为0.0时无间距（不占用cell）。
- (CGFloat)magneticsController:(MagneticsController *)magneticsController heightForMagneticSpacingInTableView:(MagneticTableView *)tableView {
    return 10.0;
}
@end
