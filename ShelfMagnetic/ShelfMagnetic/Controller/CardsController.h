//
//  CardsController.h
//  dolphinHouse
//
//  Created by lifuqing on 2018/8/31.
//  Copyright © 2018年 HTJ. All rights reserved.
//

#import "CardController.h"
#import "CardErrorCell.h"
#import "CardTableView.h"


///卡片列表刷新方式
typedef NS_OPTIONS(NSUInteger, CardsRefreshType) {
    ///无刷新方式
    CardsRefreshTypeNone                = 0,
    ///下拉刷新
    CardsRefreshTypePullToRefresh       = 1 << 0,
    ///上拉加载更多
    CardsRefreshTypeInfiniteScrolling   = 1 << 1,
    ///中心加载视图
    CardsRefreshTypeLoadingView         = 1 << 2,
};

///卡片数据清除方式
typedef NS_ENUM(NSUInteger, CardsClearType) {
    ///请求前清除
    CardsClearTypeBeforeRequest     = 0,
    ///请求后清除
    CardsClearTypeAfterRequest      = 1,
};



@interface CardsController : UIViewController <UITableViewDataSource, UITableViewDelegate, CardControllerDelegate>

///父视图控制器。内部监控页面显示隐藏，应使用业务子类。
@property (nonatomic, weak)             UIViewController *superViewController;

///卡片表视图
@property (nonatomic, strong, readonly) CardTableView *tableView;

///卡片数据源
@property (nonatomic, strong, readonly) NSMutableArray <CardContext *> *cardsArray;

///卡片控制器数据源
@property (nonatomic, strong, readonly) NSMutableArray <CardController *> *cardControllersArray;

///获取指定类型的卡片控制器
- (NSArray *)queryCardControllersWithType:(CardType)type;

///滚动到指定类型的卡片
- (void)scrollToCardType:(CardType)type animated:(BOOL)animated;
@end



@class NXHttpManager;

@interface CardsController (Request)

@property (nonatomic, strong)   NXHttpManager        *httpManager;

///卡片列表刷新方式
@property (nonatomic)           CardsRefreshType    refreshType;

///卡片数据清除方式
@property (nonatomic)           CardsClearType      clearType;

///使用默认错误提示,default YES
@property (nonatomic)           BOOL                enableNetworkError;

///请求卡片列表（继承实现）
- (void)requestCards;
///加载更多数据。默认回调卡片-didTriggerRequestMoreDataActionInCardsController协议，可继承重写事件。
- (void)requestMoreData;
///请求单卡片数据（继承实现）
- (void)requestCardDataWithController:(CardController *)cardController;

///卡片列表请求将开始
- (void)requestCardsWillStart;
///卡片列表请求成功
- (void)requestCardsDidSucceedWithCardsArray:(NSArray *)cardsArray;
///卡片列表请求失败
- (void)requestCardsDidFailWithError:(NSError *)error;

///加载更多卡片请求成功
- (void)requestMoreCardsDidSucceedWithCardsArray:(NSArray *)cardsArray;
///加载更多卡片失败
- (void)requestMoreCardsDidFailWithError:(NSError *)error;

///卡片数据请求成功
- (void)requestCardDataDidSucceedWithCardContext:(CardContext *)cardContext;
///卡片列表请求失败
- (void)requestCardDataDidFailWithCardContext:(CardContext *)cardContext error:(NSError *)error;

- (void)triggerRefreshAction;
@end


@interface CardsController (Bottom)

///显示表视图封底。默认为NO。若取值为YES且刷新方式不支持CardsRefreshTypeInfiniteScrolling，tableFooterView自动显示封底视图。
@property (nonatomic)           BOOL    enableTableBottomView;
///封底自定义视图。默认为nil，提示“没有更多了”+LOGO。
@property (nonatomic, strong)   UIView  *tableBottomCustomView;

///触发加载更多事件，启动加载动画
- (void)triggerInfiniteScrollingAction;
///完成加载更多事件，停止加载动画
- (void)finishInfiniteScrollingAction;
///完成所有数据加载，显示没有更多了封底图
- (void)didFinishLoadAllData;

@end


@interface CardsController (BottomPrivate)

- (void)refreshTableBottomView; //刷新封底视图

@end

