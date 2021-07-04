//
//  MagneticDemo5Controller.m
//  ShelfMagnetic
//
//  Created by Jenson on 2021/7/4.
//  Copyright © 2021 Jenson. All rights reserved.
//

#import "MagneticDemo5Controller.h"
#import "MagneticDemo5TableViewCell.h"

@implementation MagneticDemo5Controller
///完成初始化监听
- (void)didFinishInitConfigurationInMagneticsController:(MagneticsController *)magneticsController {
    
    self.isPrepared = self.magneticContext.json;
    
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

///磁片间距大小。默认为10.0，当高度为0.0时无间距（不占用cell）。
- (CGFloat)magneticsController:(MagneticsController *)magneticsController heightForMagneticSpacingInTableView:(MagneticTableView *)tableView {
    return 10.0;
}

///内容视图Class。默认为UITableViewCell。
- (Class)magneticsController:(MagneticsController *)magneticsController cellClassForMagneticContentAtIndex:(NSInteger)index{
    return MagneticDemo5TableViewCell.class;
}

///复用内容视图
- (void)magneticsController:(MagneticsController *)magneticsController reuseCell:(UITableViewCell *)cell forMagneticContentAtIndex:(NSInteger)index{
    if ([cell isKindOfClass:MagneticDemo5TableViewCell.class]) {
        ((MagneticDemo5TableViewCell *)cell).content = self.magneticContext.json;
    }
}
///是否展示磁片背景
- (BOOL)magneticsController:(MagneticsController *)magneticsController isShowMagneticBackground:(UIView *)magneticBackground aTableView:(MagneticTableView *)tableView{
    magneticBackground.backgroundColor = UIColor.systemYellowColor;
    magneticBackground.layer.cornerRadius = 8;
    magneticBackground.frame = CGRectMake(15, 0, UIScreen.mainScreen.bounds.size.width - 30, magneticBackground.frame.size.height);
    return YES;
}

@end
