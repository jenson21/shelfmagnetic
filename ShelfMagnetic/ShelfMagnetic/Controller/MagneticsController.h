//
//  MagneticsController.h
//  ShelfMagnetic
//
//  Created by Jenson on 2020/5/31.
//  Copyright © 2020 Jenson. All rights reserved.
//

#import "MagneticController.h"
#import "MagneticErrorCell.h"
#import "MagneticTableView.h"

NS_ASSUME_NONNULL_BEGIN

///磁片列表刷新方式
typedef NS_OPTIONS(NSUInteger, MagneticsRefreshType) {
    ///无刷新方式
    MagneticsRefreshTypeNone                = 0,
    ///下拉刷新
    MagneticsRefreshTypePullToRefresh       = 1 << 0,
    ///上拉加载更多
    MagneticsRefreshTypeInfiniteScrolling   = 1 << 1,
    ///中心加载视图
    MagneticsRefreshTypeLoadingView         = 1 << 2,
};

///磁片数据清除方式
typedef NS_ENUM(NSUInteger, MagneticsClearType) {
    ///请求前清除
    MagneticsClearTypeBeforeRequest     = 0,
    ///请求后清除
    MagneticsClearTypeAfterRequest      = 1,
};

@class MagneticController;

@interface MagneticsController : UIViewController<UITableViewDataSource, UITableViewDelegate, MagneticControllerDelegate>

///父视图控制器。内部监控页面显示隐藏，应使用业务子类。
@property (nonatomic, weak) UIViewController *superViewController;

///磁片表视图
@property (nonatomic, strong, readonly) MagneticTableView *tableView;

///磁片数据源
@property (nonatomic, strong, readonly) NSMutableArray <MagneticContext *> *magneticsArray;

///磁片控制器数据源
@property (nonatomic, strong, readonly) NSMutableArray <MagneticController *> *magneticControllersArray;

///获取指定类型的磁片控制器
- (NSArray *)queryMagneticControllersWithType:(MagneticType)type;

///滚动到指定类型的磁片
- (void)scrollToMagneticType:(MagneticType)type animated:(BOOL)animated;
@end



@class JEHttpManager;

@interface MagneticsController (Request)

@property (nonatomic) JEHttpManager *httpManager;

///磁片列表刷新方式
@property (nonatomic) MagneticsRefreshType refreshType;

///磁片数据清除方式
@property (nonatomic) MagneticsClearType clearType;

///使用默认错误提示,default YES
@property (nonatomic, assign) BOOL enableNetworkError;

///请求磁片列表（继承实现）
- (void)requestMagnetics;
///加载更多数据。默认回调磁片-didTriggerRequestMoreDataActionInMagneticsController协议，可继承重写事件。
- (void)requestMoreData;
///请求单磁片数据（继承实现）
- (void)requestMagneticDataWithController:(MagneticController *)magneticController;

///磁片列表请求将开始
- (void)requestMagneticsWillStart;
///磁片列表请求成功
- (void)requestMagneticsDidSucceedWithMagneticsArray:(NSArray *)magneticsArray;
///磁片列表请求失败
- (void)requestMagneticsDidFailWithError:(NSError *)error;

///加载更多磁片请求成功
- (void)requestMoreMagneticsDidSucceedWithMagneticsArray:(NSArray *)magneticsArray;
///加载更多磁片失败
- (void)requestMoreMagneticsDidFailWithError:(NSError *)error;

///磁片数据请求成功
- (void)requestMagneticDataDidSucceedWithMagneticContext:(MagneticContext *)magneticContext;
///磁片列表请求失败
- (void)requestMagneticDataDidFailWithMagneticContext:(MagneticContext *)magneticContext error:(NSError *)error;

- (void)triggerRefreshAction;
@end


@interface MagneticsController (Bottom)

///显示表视图封底。默认为NO。若取值为YES且刷新方式不支持MagneticsRefreshTypeInfiniteScrolling，tableFooterView自动显示封底视图。
@property (nonatomic, assign) BOOL enableTableBottomView;
///封底自定义视图。默认为nil，提示“没有更多了”+LOGO。
@property (nonatomic) UIView *tableBottomCustomView;

///触发加载更多事件，启动加载动画
- (void)triggerInfiniteScrollingAction;
///完成加载更多事件，停止加载动画
- (void)finishInfiniteScrollingAction;
///完成所有数据加载，显示没有更多了封底图
- (void)didFinishLoadAllData;

@end


@interface MagneticsController (BottomPrivate)

- (void)refreshTableBottomView; //刷新封底视图

@end

NS_ASSUME_NONNULL_END
