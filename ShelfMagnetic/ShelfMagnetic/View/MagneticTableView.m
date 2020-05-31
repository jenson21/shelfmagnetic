//
//  MagneticTableView.m
//  ShelfMagnetic
//
//  Created by Jenson on 2020/5/31.
//  Copyright © 2020 Jenson. All rights reserved.
//

#import "MagneticTableView.h"
#import "MagneticController.h"
#import "MagneticsController.h"

#define HEIGHT_ERROR        100.0   //错误提示高度

@implementation MagneticTableView

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
    for (int i = 0; i < _MagneticControllersArray.count; i++) {
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
    if (section < 0 || section >= _MagneticControllersArray.count) return;
    
    MagneticsController *MagneticsController = (MagneticsController *)self.delegate;
    MagneticController *MagneticController = _MagneticControllersArray[section];
    
    //是否显示错误视图
    MagneticController.showMagneticError = NO;
    if (MagneticController.MagneticContext.error) { //数据错误
        if ([MagneticController respondsToSelector:@selector(MagneticsController:shouldShowMagneticErrorWithCode:)]) {
            MagneticController.showMagneticError = [MagneticController MagneticsController:MagneticsController shouldShowMagneticErrorWithCode:MagneticController.MagneticContext.error.code];
        }
    }
    
    //是否显示头部视图
    MagneticController.showMagneticHeader = NO;
    if ([MagneticController respondsToSelector:@selector(MagneticsController:shouldShowMagneticHeaderInTableView:)]) {
        MagneticController.showMagneticHeader = [MagneticController MagneticsController:MagneticsController shouldShowMagneticHeaderInTableView:self];
    }
    if (MagneticController.showMagneticError) { //显示错误视图时隐藏头部视图
        MagneticController.showMagneticHeader = NO;
    }
    
    //是否显示尾部视图
    MagneticController.showMagneticFooter = NO;
    if ([MagneticController respondsToSelector:@selector(MagneticsController:shouldShowMagneticFooterInTableView:)]) {
        MagneticController.showMagneticFooter = [MagneticController MagneticsController:MagneticsController shouldShowMagneticFooterInTableView:self];
    }
    if (MagneticController.showMagneticError) { //显示错误视图时隐藏尾部视图
        MagneticController.showMagneticFooter = NO;
    }
    
    //是否显示卡片间距
    MagneticController.showMagneticSpacing = NO;
    
    CGFloat MagneticSpacing = 0.0;
    if ([MagneticController respondsToSelector:@selector(MagneticsController:heightForMagneticSpacingInTableView:)]) {
        MagneticSpacing = [MagneticController MagneticsController:MagneticsController heightForMagneticSpacingInTableView:self];
        if (MagneticSpacing <= 0.1) {
            MagneticSpacing = 0.0;
        }
    }
    if (MagneticSpacing > 0.0) {
        MagneticController.showMagneticSpacing = YES;
    }
    
    //行数缓存
    MagneticController.extensionRowIndex = 0;
    
    NSInteger rowCount = 0;
    if (MagneticController.MagneticContext.error) { //数据错误
        if (MagneticController.showMagneticError) rowCount++; //显示错误视图
    } else { //数据正常
        //内容行数
        NSInteger count = [MagneticController MagneticsController:MagneticsController rowCountForMagneticContentInTableView:self];
        if (count > 0) {
            rowCount += count;
        }
        
        //扩展行数
        MagneticController.extensionRowIndex = rowCount + (MagneticController.showMagneticHeader ? 1 : 0);
        
        if (!MagneticController.isFold) { //折叠状态不显示扩展区
            count = [MagneticController.extensionController MagneticsController:MagneticsController rowCountForMagneticContentInTableView:self];
            if (count > 0) {
                rowCount += count;
            }
        }
    }
    
    if (rowCount > 0) { //有可显示的数据
        if (MagneticController.showMagneticHeader)  rowCount++; //显示头部视图
        if (MagneticController.showMagneticFooter)  rowCount++; //显示尾部视图
        if (MagneticController.showMagneticSpacing) rowCount++; //显示卡片间距
    }
    MagneticController.rowCountCache = rowCount;

    //行高缓存
    NSMutableArray *rowHeights = [NSMutableArray array];
    for (int row = 0; row < rowCount; row++) {
        CGFloat rowHeight = 0.0;
        
        BOOL isMagneticSpacing = (MagneticController.showMagneticSpacing && row == rowCount - 1); //卡片间距
        BOOL isMagneticHeader = (MagneticController.showMagneticHeader && row == 0); //头部视图
        BOOL isMagneticFooter = NO; //尾部视图
        if (MagneticController.showMagneticFooter) {
            if (MagneticController.showMagneticSpacing && row == rowCount - 2) {
                isMagneticFooter = YES;
            }
            if (!MagneticController.showMagneticSpacing && row == rowCount - 1) {
                isMagneticFooter = YES;
            }
        }
        
        if (isMagneticSpacing) { //卡片间距
            rowHeight = MagneticSpacing;
        } else if (isMagneticHeader) { //头部视图
            if ([MagneticController respondsToSelector:@selector(MagneticsController:heightForMagneticHeaderInTableView:)]) {
                rowHeight = [MagneticController MagneticsController:MagneticsController heightForMagneticHeaderInTableView:self];
            }
        } else if (isMagneticFooter) { //尾部视图
            if ([MagneticController respondsToSelector:@selector(MagneticsController:heightForMagneticFooterInTableView:)]) {
                rowHeight = [MagneticController MagneticsController:MagneticsController heightForMagneticFooterInTableView:self];
            }
        } else {
            if (MagneticController.showMagneticError) { //错误视图
                rowHeight = HEIGHT_ERROR;
            } else { //数据源
                if (row < MagneticController.extensionRowIndex) { //卡片内容
                    NSInteger rowIndex = MagneticController.showMagneticHeader ? row - 1 : row; //数据源对应的index
                    rowHeight = [MagneticController MagneticsController:MagneticsController rowHeightForMagneticContentAtIndex:rowIndex];
                } else { //卡片扩展
                    NSInteger rowIndex = row - MagneticController.extensionRowIndex; //数据源对应的index
                    rowHeight = [MagneticController.extensionController MagneticsController:MagneticsController rowHeightForMagneticContentAtIndex:rowIndex];
                }
            }
        }
        [rowHeights addObject:@(rowHeight)];
    }
    MagneticController.rowHeightsCache = rowHeights;
}

@end
