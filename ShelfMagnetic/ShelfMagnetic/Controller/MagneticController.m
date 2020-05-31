//
//  MagneticController.m
//  ShelfMagnetic
//
//  Created by Jenson on 2020/5/31.
//  Copyright © 2020 Jenson. All rights reserved.
//

#import "MagneticController.h"
#import "MagneticsController.h"

@interface MagneticController ()

/* Cache */
@property (nonatomic)           BOOL        showMagneticError;
@property (nonatomic)           BOOL        showMagneticHeader;
@property (nonatomic)           BOOL        showMagneticFooter;
@property (nonatomic)           BOOL        showMagneticSpacing;
@property (nonatomic)           NSInteger   rowCountCache;
@property (nonatomic)           NSInteger   extensionRowIndex;
/* RequestMore */
@property (nonatomic)           BOOL        canRequestMoreData;
@property (nonatomic, copy)     NSArray     *rowHeightsCache;

@end



@implementation MagneticController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
//    [_jsonClient cancelAllOperations];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}


#pragma mark - Property

- (void)setMagneticContext:(MagneticContext *)MagneticContext
{
    _MagneticContext = MagneticContext;
}

- (void)setIsPrepared:(BOOL)isPrepared
{
    if (_isPrepared != isPrepared) {
        _isPrepared = isPrepared;
        
        [self.delegate refreshMagneticWithType:self.MagneticContext.type];
    }
}



#pragma mark - Lazy Loading

//- (NXHttpManager *)httpManager
//{
//    if (!_httpManager) {
//        _httpManager = [NXHttpManager sharedHttpManager];
//    }
//    return _httpManager;
//}



#pragma mark Magnetic Content

//内容行数
- (NSInteger)MagneticsController:(MagneticsController *)MagneticsController rowCountForMagneticContentInTableView:(MagneticTableView *)tableView
{
    return 0;
}

//内容行高
- (CGFloat)MagneticsController:(MagneticsController *)MagneticsController rowHeightForMagneticContentAtIndex:(NSInteger)index
{
    return 0.0;
}

//复用内容视图
- (void)MagneticsController:(MagneticsController *)MagneticsController reuseCell:(UITableViewCell *)cell forMagneticContentAtIndex:(NSInteger)index
{
    
}

#pragma mark Magnetic Spacing

//卡片底部间距
- (CGFloat)MagneticsController:(MagneticsController *)MagneticsController heightForMagneticSpacingInTableView:(MagneticTableView *)tableView
{
    return 10.0;
}

#pragma mark Magnetic Error

//是否显示卡片错误提示
- (BOOL)MagneticsController:(MagneticsController *)MagneticsController shouldShowMagneticErrorWithCode:(MagneticErrorCode)errorCode
{
    return NO;
}



#pragma mark - Error

//请求错误卡片数据
- (void)requestErrorMagneticData
{
    MagneticErrorCode errorCode = _MagneticContext.error.code;
    if (errorCode == MagneticErrorCodeNetwork || errorCode == MagneticErrorCodeFailed) { //卡片请求失败
        //显示加载状态
        _MagneticContext.state = MagneticStateLoading;
        [self.MagneticsController refreshMagneticWithType:_MagneticContext.type];
        
        //重新请求数据
        [self.MagneticsController requestMagneticDataWithController:self];
    }
}
