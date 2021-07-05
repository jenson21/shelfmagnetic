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

#define HEIGHT_ERROR        120.0   //错误提示高度

@interface MagneticTableView ()
@end

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
    for (int i = 0; i < _magneticControllersArray.count; i++) {
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
    if (section < 0 || section >= _magneticControllersArray.count) return;
    
    MagneticsController *magneticsController = (MagneticsController *)self.delegate;
    MagneticController *magneticController = _magneticControllersArray[section];
    
    //是否显示错误视图
    magneticController.showMagneticError = NO;
    if (magneticController.magneticContext.error) { //数据错误
        if ([magneticController respondsToSelector:@selector(magneticsController:shouldShowMagneticErrorWithCode:)]) {
            magneticController.showMagneticError = [magneticController magneticsController:magneticsController shouldShowMagneticErrorWithCode:magneticController.magneticContext.error.code];
        }
    }
    
    //是否显示头部视图
    magneticController.showMagneticHeader = NO;
    if ([magneticController respondsToSelector:@selector(magneticsController:shouldShowMagneticHeaderInTableView:)]) {
        magneticController.showMagneticHeader = [magneticController magneticsController:magneticsController shouldShowMagneticHeaderInTableView:self];
    }
    if (magneticController.showMagneticError) { //显示错误视图时隐藏头部视图
        magneticController.showMagneticHeader = NO;
    }
    
    //是否显示尾部视图
    magneticController.showMagneticFooter = NO;
    if ([magneticController respondsToSelector:@selector(magneticsController:shouldShowMagneticFooterInTableView:)]) {
        magneticController.showMagneticFooter = [magneticController magneticsController:magneticsController shouldShowMagneticFooterInTableView:self];
    }
    if (magneticController.showMagneticError) { //显示错误视图时隐藏尾部视图
        magneticController.showMagneticFooter = NO;
    }
    
    //是否显示磁片头部间距
    magneticController.showMagneticHeaderSpacing = NO;
    
    CGFloat magneticHeaderSpacing = 0.0;
    if ([magneticController respondsToSelector:@selector(magneticsController:heightForMagneticHeaderSpacingInTableView:)]) {
        magneticHeaderSpacing = [magneticController magneticsController:magneticsController heightForMagneticHeaderSpacingInTableView:self];
        if (magneticHeaderSpacing <= 0.1) {
            magneticHeaderSpacing = 0.0;
        }
    }
    if (magneticHeaderSpacing > 0.0) {
        magneticController.showMagneticHeaderSpacing = YES;
    }
    
    //是否显示磁片底部间距
    magneticController.showMagneticSpacing = NO;
    
    CGFloat magneticSpacing = 0.0;
    if ([magneticController respondsToSelector:@selector(magneticsController:heightForMagneticSpacingInTableView:)]) {
        magneticSpacing = [magneticController magneticsController:magneticsController heightForMagneticSpacingInTableView:self];
        if (magneticSpacing <= 0.1) {
            magneticSpacing = 0.0;
        }
    }
    if (magneticSpacing > 0.0) {
        magneticController.showMagneticSpacing = YES;
    }
    
    //行数缓存
    magneticController.extensionRowIndex = 0;
    
    NSInteger rowCount = 0;
    if (magneticController.magneticContext.error) { //数据错误
        if (magneticController.showMagneticError) rowCount++; //显示错误视图
    } else { //数据正常
        //内容行数
        NSInteger count = [magneticController magneticsController:magneticsController rowCountForMagneticContentInTableView:self];
        if (count > 0) {
            rowCount += count;
        }
        
        //扩展行数
        magneticController.extensionRowIndex = rowCount + (magneticController.showMagneticHeader ? 1 : 0) + (magneticController.showMagneticHeaderSpacing ? 1 : 0);
        
        if (!magneticController.isFold) { //折叠状态不显示扩展区
            count = [magneticController.extensionController magneticsController:magneticsController rowCountForMagneticContentInTableView:self];
            if (count > 0) {
                rowCount += count;
            }
        }
    }
    
    if (rowCount > 0) { //有可显示的数据
        if (magneticController.showMagneticHeader)  rowCount++; //显示头部视图
        if (magneticController.showMagneticFooter)  rowCount++; //显示尾部视图
        if (magneticController.showMagneticSpacing) rowCount++; //显示磁片间距
        if (magneticController.showMagneticHeaderSpacing) rowCount++;//显示磁片头部间距
    }
    magneticController.rowCountCache = rowCount;
    
    //行高缓存
    NSMutableArray *rowHeights = [NSMutableArray array];
    for (int row = 0; row < rowCount; row++) {
        CGFloat rowHeight = 0.0;
        
        BOOL isMagneticHeaderSpacing = (magneticController.showMagneticHeaderSpacing && row == 0); //磁片头部间距
        BOOL isMagneticSpacing = (magneticController.showMagneticSpacing && row == rowCount - 1); //磁片间距
        
        BOOL isMagneticHeader = NO; //头部视图
        if (magneticController.showMagneticHeaderSpacing) {
            isMagneticHeader = (magneticController.showMagneticHeader && row == 1);
        } else {
            isMagneticHeader = (magneticController.showMagneticHeader && row == 0); //头部视图
        }
        
        BOOL isMagneticFooter = NO; //尾部视图
        if (magneticController.showMagneticFooter) {
            if (magneticController.showMagneticSpacing && row == rowCount - 2) {
                isMagneticFooter = YES;
            }
            if (!magneticController.showMagneticSpacing && row == rowCount - 1) {
                isMagneticFooter = YES;
            }
        }
        
        if(isMagneticHeaderSpacing) { //磁片头部间距
            rowHeight = magneticHeaderSpacing;
        } else if (isMagneticSpacing) { //磁片间距
            rowHeight = magneticSpacing;
        } else if (isMagneticHeader) { //头部视图
            if ([magneticController respondsToSelector:@selector(magneticsController:heightForMagneticHeaderInTableView:)]) {
                rowHeight = [magneticController magneticsController:magneticsController heightForMagneticHeaderInTableView:self];
            }
        } else if (isMagneticFooter) { //尾部视图
            if ([magneticController respondsToSelector:@selector(magneticsController:heightForMagneticFooterInTableView:)]) {
                rowHeight = [magneticController magneticsController:magneticsController heightForMagneticFooterInTableView:self];
            }
        } else {
            if (magneticController.showMagneticError) { //错误视图
                rowHeight = HEIGHT_ERROR;
            } else { //数据源
                if (row < magneticController.extensionRowIndex) { //磁片内容
                    
                    NSInteger rowIndex = row;//数据源对应的index
                    if (magneticController.showMagneticHeaderSpacing) {
                        rowIndex -= 1;
                    }
                    if (magneticController.showMagneticHeader) {
                        rowIndex -= 1;
                    }
                    
                    rowHeight = [magneticController magneticsController:magneticsController rowHeightForMagneticContentAtIndex:rowIndex];
                } else { //磁片扩展
                    NSInteger rowIndex = row - magneticController.extensionRowIndex; //数据源对应的index
                    rowHeight = [magneticController.extensionController magneticsController:magneticsController rowHeightForMagneticContentAtIndex:rowIndex];
                }
            }
        }
        [rowHeights addObject:@(rowHeight)];
    }
    magneticController.rowHeightsCache = rowHeights;
}

@end
