//
//  CardCollectionController.m
//  dolphinHouse
//
//  Created by lifuqing on 2018/9/1.
//  Copyright © 2018年 HTJ. All rights reserved.
//

#import "CardCollectionController.h"

static NSString *cellIdentifier = nil;

static NSString *cellFooterIdentifier = @"cellFooterIdentifier";

@interface CardCollectionController ()<UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong, readwrite) UICollectionView *collectionView;
@property (nonatomic, assign) BOOL hasFooter;
@end

@implementation CardCollectionController

- (void)dealloc {

}

///完成初始化监听
- (void)didFinishInitConfigurationInCardsController:(CardsController *)cardsController {
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
            cellIdentifier = [NSString stringWithFormat:@"%@_%ld", NSStringFromClass([self registerCollectionCellClass]), (long)self.cardContext.type];
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

#pragma mark - Card Content

// 内容行数
- (NSInteger)cardsController:(CardsController *)cardsController rowCountForCardContentInTableView:(CardTableView *)tableView
{
    return self.isPrepared ? 1 : 0;
}

///内容将显示
- (void)cardsController:(CardsController *)cardsController willDisplayCell:(UITableViewCell *)cell forCardContentAtIndex:(NSInteger)index {
    [_collectionView reloadData];
}

// 复用内容视图
- (void)cardsController:(CardsController *)cardsController reuseCell:(UITableViewCell *)cell forCardContentAtIndex:(NSInteger)index
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

    CGFloat width = CGRectGetWidth(self.cardsController.tableView.frame);
    CGFloat height = 0;
    if ([self.collectionDelegate respondsToSelector:@selector(collectionViewHeightInCollectionView:)]) {
        height = [self.collectionDelegate collectionViewHeightInCollectionView:_collectionView];
    }
    if (self.cardContext.type == CardTypeNonMeberDiscount || self.cardContext.type == CardTypeNonMeberHalf || self.cardContext.type == CardTypeNonMeberOneBuy || self.cardContext.type == CardTypeNonMeberCoupon || self.cardContext.type == CardTypeNonMeberExclusive) {
        _collectionView.frame = CGRectMake(20, 0.0, width-40, height);
    }
    else if (self.cardContext.type == CardTypeHomeYiYuanGou) {
         _collectionView.frame = CGRectMake(10, 0.0, width-20, height);
    }
    else {
        _collectionView.frame = CGRectMake(0.0, 0.0, width, height);
    }
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
    if ([self.collectionDelegate respondsToSelector:@selector(cardsController:collectionViewReuseCell:indexPath:)]) {
        [self.collectionDelegate cardsController:self.cardsController collectionViewReuseCell:cell indexPath:indexPath];
    }
    return cell;

}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.collectionDelegate respondsToSelector:@selector(cardsController:didSelectItemAtIndexPath:collectionView:)]) {
        [self.collectionDelegate cardsController:self.cardsController didSelectItemAtIndexPath:indexPath collectionView:collectionView];
    }
}

@end
