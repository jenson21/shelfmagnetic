//
//  CardCollectionController.h
//  dolphinHouse
//
//  Created by lifuqing on 2018/9/1.
//  Copyright © 2018年 HTJ. All rights reserved.
//

#import "CardController.h"
#import "CardsController.h"

@protocol CardCollectionControllerProtocol <NSObject>

#pragma mark -datasource
///数量
- (NSInteger)collectionViewNumberOfItemsInCollectionView:(UICollectionView *)collectionView;

///tableviewcell subview -> collectionView -> collectionViewCell 's size
- (CGSize)collectionViewItemSizeInCollectionView:(UICollectionView *)collectionView sizeForItemAtIndexPath:(NSIndexPath *)indexPath;

///collection的高度
- (CGFloat)collectionViewHeightInCollectionView:(UICollectionView *)collectionView;


#pragma mark -delegate
///组件内部collectionview reusecell
- (void)cardsController:(CardsController *)cardsController collectionViewReuseCell:(UICollectionViewCell *)cell indexPath:(NSIndexPath *)indexPath;

@optional

///collectionView 元数据 class ，默认 [UICollectionViewCell class]
- (Class)collectionViewCellClassInCollectionView:(UICollectionView *)collectionView;

///注册UICollectionViewCell标识符，默认 默认为"CellClass_CardType"的形式。
- (NSString *)collectionViewCellIdentifierInCollectionView:(UICollectionView *)collectionView;

///点击组件内部collectionview的元视图内容事件
- (void)cardsController:(CardsController *)cardsController didSelectItemAtIndexPath:(NSIndexPath *)indexPath collectionView:(UICollectionView *)collectionView;

///元视图横向间距，default is 0，因为是横划 所以LineSpacing 为横向间距
- (CGFloat)collectionViewMinimumLineSpacingInCollectionView:(UICollectionView *)collectionView;

///元视图纵向间距，default is 0
- (CGFloat)collectionViewMinimumInteritemSpacingInCollectionView:(UICollectionView *)collectionView;

///collection section inset default is UIEdgeInsetsZero
- (UIEdgeInsets)collectionViewSectionInsetInCollectionView:(UICollectionView *)collectionView;


///footer more
///collectionView最后是否有footerCell 例如更多
- (BOOL)collectionViewCanShowFooterInCollectionView:(UICollectionView *)collectionView;
///footer class  UICollectionViewCell 子类，默认为UICollectionViewCell
- (Class)collectionViewFooterCellClassInCollectionView:(UICollectionView *)collectionView;

@end

@interface CardCollectionController : CardController 
@property (nonatomic, strong, readonly) UICollectionView *collectionView;
@property (nonatomic, weak) id<CardCollectionControllerProtocol> collectionDelegate;
@property (nonatomic, assign) UICollectionViewScrollDirection scrollDirection;
@end
