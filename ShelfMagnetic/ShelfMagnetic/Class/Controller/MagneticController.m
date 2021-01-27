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
@property (nonatomic, assign) BOOL showMagneticError;
@property (nonatomic, assign) BOOL showMagneticHeader;
@property (nonatomic, assign) BOOL showMagneticFooter;
@property (nonatomic, assign) BOOL showMagneticSpacing;
@property (nonatomic, assign) NSInteger rowCountCache;
@property (nonatomic, assign) NSInteger extensionRowIndex;
@property (nonatomic, copy)   NSArray *rowHeightsCache;
/* RequestMore */
@property (nonatomic) BOOL canRequestMoreData;

@end


@implementation MagneticController

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (instancetype)init{
    self = [super init];
    if (self) {
    }
    return self;
}


#pragma mark - Property

- (void)setMagneticContext:(MagneticContext *)magneticContext{
    _magneticContext = magneticContext;
}

- (void)setIsPrepared:(BOOL)isPrepared{
    if (_isPrepared != isPrepared) {
        _isPrepared = isPrepared;
        
        [self.delegate refreshMagneticWithType:self.magneticContext.type];
    }
}



#pragma mark - Lazy Loading

#pragma mark Magnetic Content

//内容行数
- (NSInteger)magneticsController:(MagneticsController *)magneticsController rowCountForMagneticContentInTableView:(MagneticTableView *)tableView{
    return 0;
}

//内容行高
- (CGFloat)magneticsController:(MagneticsController *)magneticsController rowHeightForMagneticContentAtIndex:(NSInteger)index{
    return 0.0;
}

//复用内容视图
- (void)magneticsController:(MagneticsController *)magneticsController reuseCell:(UITableViewCell *)cell forMagneticContentAtIndex:(NSInteger)index{
    
}

#pragma mark Magnetic Spacing

//磁片底部间距
- (CGFloat)magneticsController:(MagneticsController *)magneticsController heightForMagneticSpacingInTableView:(MagneticTableView *)tableView{
    return 10.0;
}

#pragma mark Magnetic Error

//是否显示磁片错误提示
- (BOOL)magneticsController:(MagneticsController *)magneticsController shouldShowMagneticErrorWithCode:(MagneticErrorCode)errorCode{
    return NO;
}



#pragma mark - Error

//请求错误磁片数据
- (void)requestErrorMagneticData{
    MagneticErrorCode errorCode = _magneticContext.error.code;
    if (errorCode == MagneticErrorCodeNetwork || errorCode == MagneticErrorCodeFailed) { //磁片请求失败
        //显示加载状态
        _magneticContext.state = MagneticStateLoading;
        [self.magneticsController refreshMagneticWithType:_magneticContext.type];
        
        //重新请求数据
        [self.magneticsController requestMagneticDataWithController:self];
    }
}

@end
