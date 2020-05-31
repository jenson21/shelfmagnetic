//
//  CardTableView.m
//  YoukuiPhone
//
//  Created by liusx on 15/5/18.
//  Copyright (c) 2015年 Youku.com inc. All rights reserved.
//

#import "CardTableView.h"
#import "CardController.h"
#import "CardsController.h"

#define HEIGHT_ERROR        120.0   //错误提示高度

@interface CardTableView ()


@end

@implementation CardTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.backgroundView = nil;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.canCancelContentTouches = YES;
        [self setDelaysContentTouches:NO];
    }
    return self;
}


#pragma mark - Reload

- (void)reloadData
{
    for (int i = 0; i < _cardControllersArray.count; i++) {
        [self setupCacheDataWithSection:i];
    }
    
    [super reloadData];
}

- (void)reloadSections:(NSArray *)sections
{
    for (int i = 0; i < sections.count; i++) {
        NSInteger section = [sections[i] integerValue];
        [self setupCacheDataWithSection:section];
    }
    
    [super reloadData];
}

- (void)reloadSection:(NSInteger)section
{
    [self setupCacheDataWithSection:section];
    
    [super reloadData];
}

- (void)reloadSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation
{
    [sections enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [self setupCacheDataWithSection:idx];
    }];
    
    [super reloadSections:sections withRowAnimation:animation];
}

- (void)insertRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    NSMutableIndexSet *sections = [NSMutableIndexSet indexSet];
    for (NSIndexPath *indexPath in indexPaths) {
        [sections addIndex:indexPath.section];
    }
    
    [sections enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [self setupCacheDataWithSection:idx];
    }];
    
    [super insertRowsAtIndexPaths:indexPaths withRowAnimation:animation];
}

- (void)insertSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation
{
    [sections enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [self setupCacheDataWithSection:idx];
    }];
    
    [super insertSections:sections withRowAnimation:animation];
}



#pragma mark - Cache

//重置指定section的缓存数据
- (void)setupCacheDataWithSection:(NSInteger)section
{
    if (section < 0 || section >= _cardControllersArray.count) return;
    
    CardsController *cardsController = (CardsController *)self.delegate;
    CardController *cardController = _cardControllersArray[section];
    
    //是否显示错误视图
    cardController.showCardError = NO;
    if (cardController.cardContext.error) { //数据错误
        if ([cardController respondsToSelector:@selector(cardsController:shouldShowCardErrorWithCode:)]) {
            cardController.showCardError = [cardController cardsController:cardsController shouldShowCardErrorWithCode:cardController.cardContext.error.code];
        }
    }
    
    //是否显示头部视图
    cardController.showCardHeader = NO;
    if ([cardController respondsToSelector:@selector(cardsController:shouldShowCardHeaderInTableView:)]) {
        cardController.showCardHeader = [cardController cardsController:cardsController shouldShowCardHeaderInTableView:self];
    }
    if (cardController.showCardError) { //显示错误视图时隐藏头部视图
        cardController.showCardHeader = NO;
    }
    
    //是否显示尾部视图
    cardController.showCardFooter = NO;
    if ([cardController respondsToSelector:@selector(cardsController:shouldShowCardFooterInTableView:)]) {
        cardController.showCardFooter = [cardController cardsController:cardsController shouldShowCardFooterInTableView:self];
    }
    if (cardController.showCardError) { //显示错误视图时隐藏尾部视图
        cardController.showCardFooter = NO;
    }
    
    //是否显示卡片间距
    cardController.showCardSpacing = NO;
    
    CGFloat cardSpacing = 0.0;
    if ([cardController respondsToSelector:@selector(cardsController:heightForCardSpacingInTableView:)]) {
        cardSpacing = [cardController cardsController:cardsController heightForCardSpacingInTableView:self];
        if (cardSpacing <= 0.1) {
            cardSpacing = 0.0;
        }
    }
    if (cardSpacing > 0.0) {
        cardController.showCardSpacing = YES;
    }
    
    //行数缓存
    cardController.extensionRowIndex = 0;
    
    NSInteger rowCount = 0;
    if (cardController.cardContext.error) { //数据错误
        if (cardController.showCardError) rowCount++; //显示错误视图
    } else { //数据正常
        //内容行数
        NSInteger count = [cardController cardsController:cardsController rowCountForCardContentInTableView:self];
        if (count > 0) {
            rowCount += count;
        }
        
        //扩展行数
        cardController.extensionRowIndex = rowCount + (cardController.showCardHeader ? 1 : 0);
        
        if (!cardController.isFold) { //折叠状态不显示扩展区
            count = [cardController.extensionController cardsController:cardsController rowCountForCardContentInTableView:self];
            if (count > 0) {
                rowCount += count;
            }
        }
    }
    
    if (rowCount > 0) { //有可显示的数据
        if (cardController.showCardHeader)  rowCount++; //显示头部视图
        if (cardController.showCardFooter)  rowCount++; //显示尾部视图
        if (cardController.showCardSpacing) rowCount++; //显示卡片间距
    }
    cardController.rowCountCache = rowCount;

    //行高缓存
    NSMutableArray *rowHeights = [NSMutableArray array];
    for (int row = 0; row < rowCount; row++) {
        CGFloat rowHeight = 0.0;
        
        BOOL isCardSpacing = (cardController.showCardSpacing && row == rowCount - 1); //卡片间距
        BOOL isCardHeader = (cardController.showCardHeader && row == 0); //头部视图
        BOOL isCardFooter = NO; //尾部视图
        if (cardController.showCardFooter) {
            if (cardController.showCardSpacing && row == rowCount - 2) {
                isCardFooter = YES;
            }
            if (!cardController.showCardSpacing && row == rowCount - 1) {
                isCardFooter = YES;
            }
        }
        
        if (isCardSpacing) { //卡片间距
            rowHeight = cardSpacing;
        } else if (isCardHeader) { //头部视图
            if ([cardController respondsToSelector:@selector(cardsController:heightForCardHeaderInTableView:)]) {
                rowHeight = [cardController cardsController:cardsController heightForCardHeaderInTableView:self];
            }
        } else if (isCardFooter) { //尾部视图
            if ([cardController respondsToSelector:@selector(cardsController:heightForCardFooterInTableView:)]) {
                rowHeight = [cardController cardsController:cardsController heightForCardFooterInTableView:self];
            }
        } else {
            if (cardController.showCardError) { //错误视图
                rowHeight = HEIGHT_ERROR;
            } else { //数据源
                if (row < cardController.extensionRowIndex) { //卡片内容
                    NSInteger rowIndex = cardController.showCardHeader ? row - 1 : row; //数据源对应的index
                    rowHeight = [cardController cardsController:cardsController rowHeightForCardContentAtIndex:rowIndex];
                } else { //卡片扩展
                    NSInteger rowIndex = row - cardController.extensionRowIndex; //数据源对应的index
                    rowHeight = [cardController.extensionController cardsController:cardsController rowHeightForCardContentAtIndex:rowIndex];
                }
            }
        }
        [rowHeights addObject:@(rowHeight)];
    }
    cardController.rowHeightsCache = rowHeights;
}

@end
