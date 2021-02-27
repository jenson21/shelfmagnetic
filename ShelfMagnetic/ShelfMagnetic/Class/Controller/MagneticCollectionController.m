//
//  MagneticCollectionController.m
//  gaolvgo
//
//  Created by Jenson on 2021/2/26.
//  Copyright © 2021 Jenson. All rights reserved.
//

#import "MagneticCollectionController.h"
#import "MagneticsController.h"

static NSString *cellIdentifier = nil;

static NSString *cellFooterIdentifier = @"cellFooterIdentifier";

@interface MagneticCollectionController ()<UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong, readwrite) UICollectionView *collectionView;
@property (nonatomic, assign) BOOL hasFooter;
@end

@implementation MagneticCollectionController

- (void)dealloc {

}

///完成初始化监听
- (void)didFinishInitConfigurationInMagneticsController:(MagneticsController *)magneticsController {
}


- (Class)registerCollectionCellClass{
    if ([self.collectionDelegate respondsToSelector:@selector(collectionViewCellClassInCollectionView:)]) {
        return [self.collectionDelegate collectionViewCellClassInCollectionView:self.collectionView];
    }
    return [UICollectionViewCell class];
}

- (NSString *)registerCollectionCellIdentifier{
    if (!cellIdentifier) {
        if ([self.collectionDelegate respondsToSelector:@selector(collectionViewCellIdentifierInCollectionView:)]) {
            cellIdentifier = [self.collectionDelegate collectionViewCellIdentifierInCollectionView:self.collectionView];
        }
        else {
            cellIdentifier = [NSString stringWithFormat:@"%@_%ld", NSStringFromClass([self registerCollectionCellClass]), (long)self.magneticContext.type];
        }
    }
    return cellIdentifier;
}

- (Class)registerFooterCollectionCellClass{
    if ([self.collectionDelegate respondsToSelector:@selector(collectionViewFooterCellClassInCollectionView:)]) {
        return [self.collectionDelegate collectionViewFooterCellClassInCollectionView:self.collectionView];
    }
    return [UICollectionViewCell class];
}

#pragma mark - Magnetic Content

// 内容行数
- (NSInteger)magneticsController:(MagneticsController *)magneticsController rowCountForMagneticContentInTableView:(MagneticTableView *)tableView
{
    return self.isPrepared ? 1 : 0;
}

///内容将显示
- (void)magneticsController:(MagneticsController *)magneticsController willDisplayCell:(UITableViewCell *)cell forMagneticContentAtIndex:(NSInteger)index {
    [_collectionView reloadData];
}

// 复用内容视图
- (void)magneticsController:(MagneticsController *)magneticsController reuseCell:(UITableViewCell *)cell forMagneticContentAtIndex:(NSInteger)index
{
    if (!_collectionView) {
     
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = self.scrollDirection;

        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.tag = 1111;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.scrollsToTop = NO;
        //注册复用Class
        [_collectionView registerClass:[self registerCollectionCellClass] forCellWithReuseIdentifier:[self registerCollectionCellIdentifier]];

        [_collectionView registerClass:[self registerFooterCollectionCellClass] forCellWithReuseIdentifier:cellFooterIdentifier];
    }

    UIView *collectionView = [cell.contentView viewWithTag:1111];
    if (collectionView && collectionView != _collectionView) { //不是当前卡片视图
        [collectionView removeFromSuperview];
    }
    if (![_collectionView isDescendantOfView:cell.contentView]) { //未渲染，或复用cell
        [_collectionView removeFromSuperview];
        [cell.contentView addSubview:_collectionView];
    }

    CGFloat width = CGRectGetWidth(self.magneticsController.tableView.frame);
    CGFloat height = 0;
    if ([self.collectionDelegate respondsToSelector:@selector(collectionViewHeightInCollectionView:)]) {
        height = [self.collectionDelegate collectionViewHeightInCollectionView:_collectionView];
    }
    _collectionView.frame = CGRectMake(0.0, 0.0, width, height);
}

#pragma mark - UICollectionViewDelegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.collectionDelegate respondsToSelector:@selector(collectionViewItemSizeInCollectionView:sizeForItemAtIndexPath:)]) {
        return [self.collectionDelegate collectionViewItemSizeInCollectionView:collectionView sizeForItemAtIndexPath:indexPath];
    }
    return CGSizeZero;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    if ([self.collectionDelegate respondsToSelector:@selector(collectionViewSectionInsetInCollectionView:)]) {
        return [self.collectionDelegate collectionViewSectionInsetInCollectionView:collectionView];
    }
    return UIEdgeInsetsZero;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    if ([self.collectionDelegate respondsToSelector:@selector(collectionViewMinimumLineSpacingInCollectionView:)]) {
        return [self.collectionDelegate collectionViewMinimumLineSpacingInCollectionView:collectionView];
    }
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    if ([self.collectionDelegate respondsToSelector:@selector(collectionViewMinimumInteritemSpacingInCollectionView:)]) {
        return [self.collectionDelegate collectionViewMinimumInteritemSpacingInCollectionView:collectionView];
    }
    return 0;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger dataCount = 0;

    if ([self.collectionDelegate respondsToSelector:@selector(collectionViewNumberOfItemsInCollectionView:)]) {
        dataCount = [self.collectionDelegate collectionViewNumberOfItemsInCollectionView:collectionView];
    }

    if (dataCount > 0 && [self.collectionDelegate respondsToSelector:@selector(collectionViewCanShowFooterInCollectionView:)]) {
        self.hasFooter = [self.collectionDelegate collectionViewCanShowFooterInCollectionView:collectionView];
    }
    return dataCount + (self.hasFooter ? 1 : 0);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = nil;

    if (self.hasFooter && indexPath.item + 1 ==  [collectionView numberOfItemsInSection:0]) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellFooterIdentifier forIndexPath:indexPath];
    }
    else {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    }
    if ([self.collectionDelegate respondsToSelector:@selector(magneticsController:collectionViewReuseCell:indexPath:)]) {
        [self.collectionDelegate magneticsController:self.magneticsController collectionViewReuseCell:cell indexPath:indexPath];
    }
    return cell;

}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.collectionDelegate respondsToSelector:@selector(magneticsController:didSelectItemAtIndexPath:collectionView:)]) {
        [self.collectionDelegate magneticsController:self.magneticsController didSelectItemAtIndexPath:indexPath collectionView:collectionView];
    }
}

@end
