//
//  MagneticDemo4Controller.m
//  ShelfMagnetic
//
//  Created by Jian Dong on 2021/2/27.
//  Copyright © 2021 Jenson. All rights reserved.
//

#import "MagneticDemo4Controller.h"

@interface MagneticDemo4Controller()<MagneticCollectionControllerProtocol>

@end

@implementation MagneticDemo4Controller

///完成初始化监听
- (void)didFinishInitConfigurationInMagneticsController:(MagneticsController *)magneticsController{
    self.collectionDelegate = self;
    self.isPrepared = YES;
}
#pragma mark - Magnetic Content

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
    title.text = @"FOUR";
    title.textAlignment = NSTextAlignmentCenter;
    [cell.contentView addSubview:title];
}

// 内容行数
- (NSInteger)magneticsController:(MagneticsController *)magneticsController rowCountForMagneticContentInTableView:(MagneticTableView *)tableView{
    return self.isPrepared ? 1 : 0;
}

// 内容行高
- (CGFloat)magneticsController:(MagneticsController *)magneticsController rowHeightForMagneticContentAtIndex:(NSInteger)index{
    CGFloat itemW = (UIScreen.mainScreen.bounds.size.width - 24 - 15)/5;
    return (itemW/1.61+10) * 5;
}

- (CGFloat)magneticsController:(MagneticsController *)magneticsController heightForMagneticSpacingInTableView:(MagneticTableView *)tableView{
    return 0;
}

#pragma mark - MagneticCollectionControllerProtocol
///数量
- (NSInteger)collectionViewNumberOfItemsInCollectionView:(UICollectionView *)collectionView {
    return 20;
}

///tableviewcell subview -> collectionView -> collectionViewCell 's size
- (CGSize)collectionViewItemSizeInCollectionView:(UICollectionView *)collectionView sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat itemW = (UIScreen.mainScreen.bounds.size.width - 24 - 15)/5;
    return CGSizeMake(itemW, itemW/1.61);
}

///collection的高度
- (CGFloat)collectionViewHeightInCollectionView:(UICollectionView *)collectionView {
    CGFloat itemW = (UIScreen.mainScreen.bounds.size.width - 24 - 15)/5;
    return (itemW/1.61+10) * 5;
}

///元视图横向间距，default is 0
- (CGFloat)collectionViewMinimumLineSpacingInCollectionView:(UICollectionView *)collectionView {
    return 5;
}
- (CGFloat)collectionViewMinimumInteritemSpacingInCollectionView:(UICollectionView *)collectionView;{
    return 5;
}
- (UIEdgeInsets)collectionViewSectionInsetInCollectionView:(UICollectionView *)collectionView {
    return UIEdgeInsetsMake(5, 10, 0, 10);
}

///组件内部collectionview reusecell
- (void)magneticsController:(MagneticsController *)magneticsController collectionViewReuseCell:(UICollectionViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor blueColor];

}

- (void)magneticsController:(MagneticsController *)magneticsController didSelectItemAtIndexPath:(NSIndexPath *)indexPath collectionView:(UICollectionView *)collectionView{
    
}

@end
