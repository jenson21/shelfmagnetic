//
//  CardsController.m
//  dolphinHouse
//
//  Created by lifuqing on 2018/8/31.
//  Copyright © 2018年 HTJ. All rights reserved.
//

#import "CardsController.h"
#import "NSObject+Runtime.h"
#import "CardTableFooterView.h"

#define kTagTableBottomView     3527    //卡片封底视图标记

//卡片父控制器将显示通知
NSString * const kCardsSuperViewWillAppearNotification = @"CardsSuperViewWillAppearNotification";
//卡片父控制器已消失通知
NSString * const kCardsSuperViewDidDisappearNotification = @"CardsSuperViewDidDisappearNotification";



@interface CardsController ()
{
}

/* Request */
@property (nonatomic, strong)   NXHttpManager       *httpManager;
@property (nonatomic)           CardsRefreshType    refreshType;            //卡片列表刷新方式
@property (nonatomic)           CardsClearType      clearType;              //卡片数据清除方式
@property (nonatomic)           BOOL                enableNetworkError;     //使用默认错误提示

/* Bottom */
@property (nonatomic)           BOOL                enableTableBottomView;  //显示表视图封底
@property (nonatomic, strong)   UIView              *tableBottomCustomView; //封底自定义视图

@end


@implementation CardsController

- (instancetype)init
{
    self = [super init];
    if (self) {        
        _cardsArray = [[NSMutableArray alloc] init];
        _cardControllersArray = [[NSMutableArray alloc] init];
        _enableNetworkError = YES;
    }
    return self;
}

//- (NXHttpManager *)httpManager {
//    if (!_httpManager) {
//        _httpManager = [NXHttpManager sharedHttpManager];
//    }
//    return _httpManager;
//}



- (void)loadView
{
    [super loadView];
    
    CGRect frame = self.view.bounds;
    frame.size.width = MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    _tableView = [[CardTableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = NO;

    _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    _tableView.cardControllersArray = _cardControllersArray;
    _tableView.cardsController = self;
    
    if (@available(iOS 11, *)) {
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
    }
    
    [self.view addSubview:_tableView];
    
    self.view.clipsToBounds = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
//    //下拉刷新
//    if ((_refreshType & CardsRefreshTypePullToRefresh) && !_tableView.mj_header) {
//        __weak typeof(self) weakSelf = self;
//        _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
//            [weakSelf requestCards];
//        }];
//    }
//
//    //上拉加载更多
//    if ((_refreshType & CardsRefreshTypeInfiniteScrolling) && !_tableView.mj_footer) {
//        __weak typeof(self) weakSelf = self;
//        _tableView.mj_footer = [MJRefreshAutoStateFooter footerWithRefreshingBlock:^{
//            [weakSelf requestMoreData];
//        }];
//    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    _tableView.delegate = nil;
    _tableView.dataSource = nil;

//    [_tableView.mj_header endRefreshing];
//    [_tableView.mj_footer endRefreshing];
}



#pragma mark - Property

- (void)setRefreshType:(CardsRefreshType)refreshType
{

    if (_refreshType != refreshType) {
        _refreshType = refreshType;
        //下拉刷新
//        if (refreshType & CardsRefreshTypePullToRefresh) {
//            if (!self.tableView.mj_header && self.isViewLoaded) { //下拉刷新控件依赖于表视图的加载
//                __weak typeof(self) weakSelf = self;
//                MJRefreshGifHeader * refreshheader = [MJRefreshGifHeader headerWithRefreshingBlock:^{
//                    [weakSelf requestCards];
//                }];
//                refreshheader.lastUpdatedTimeLabel.hidden = YES;
//                refreshheader.stateLabel.hidden = YES;
//                NSMutableArray * gifImages = [NSMutableArray array];
//                for (int i = 0; i < 35; i++) {
//                    [gifImages addObject:[UIImage imageNamed:[NSString stringWithFormat:@"frame-%d",i]]];
//                }
//                [refreshheader setImages:gifImages duration:0.5 forState:MJRefreshStatePulling];
//                _tableView.mj_header = refreshheader;
//            } else {
//                [_tableView.mj_header endRefreshing];
//            }
//
//            //上拉加载更多
//            if (refreshType & CardsRefreshTypeInfiniteScrolling) {
//                if (!self.tableView.mj_footer && self.isViewLoaded) { //上拉刷新控件依赖于表视图的加载
//                    __weak typeof(self) weakSelf = self;
//                    _tableView.mj_footer = [MJRefreshAutoStateFooter footerWithRefreshingBlock:^{
//                        [weakSelf requestMoreData];
//                    }];
//                }
//            } else {
//                [_tableView.mj_footer endRefreshing];
//            }
//        }
    }
}

- (void)setSuperViewController:(UIViewController *)superViewController
{
    if (_superViewController != superViewController) {
        //移除旧控制器页面显示/隐藏通知的监听
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kCardsSuperViewWillAppearNotification object:_superViewController];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kCardsSuperViewDidDisappearNotification object:_superViewController];
        
        //设置属性
        _superViewController = superViewController;
        
        Class superViewClass = [superViewController class];
        if (superViewClass && superViewClass != [UIViewController class] && superViewClass != [UINavigationController class]) { //不替换基础类的IMP实现
            //监控父控制器的页面显示/隐藏
            @synchronized(self) {
                SEL swizzleSelector = @selector(cards_viewWillAppear:);
                if (![superViewController respondsToSelector:swizzleSelector]) {
                    //为父控制器添加替换方法
                    runtimeAddMethod([superViewController class],
                                       swizzleSelector,
                                       [self class],
                                       swizzleSelector);
                    
                    //交换父控制器的显示方法
                    runtimeSwizzleMethod([superViewController class],
                                           @selector(viewWillAppear:),
                                           [superViewController class],
                                           swizzleSelector);
                }
                
                swizzleSelector = @selector(cards_viewDidDisappear:);
                if (![superViewController respondsToSelector:swizzleSelector]) {
                    //为父控制器添加替换方法
                    runtimeAddMethod([superViewController class],
                                       swizzleSelector,
                                       [self class],
                                       swizzleSelector);
                    
                    //交换父控制器的隐藏方法
                    runtimeSwizzleMethod([superViewController class],
                                           @selector(viewDidDisappear:),
                                           [superViewController class],
                                           swizzleSelector);
                }
            }
            
            //监听父控制器的页面显示/隐藏通知
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(receiveCardsSuperViewWillAppearNotification:)
                                                         name:kCardsSuperViewWillAppearNotification
                                                       object:superViewController];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(receiveCardsSuperViewDidDisappearNotification:)
                                                         name:kCardsSuperViewDidDisappearNotification
                                                       object:superViewController];
        }
    }
}



#pragma mark - Runtime

- (void)cards_viewWillAppear:(BOOL)animated
{
    [self cards_viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kCardsSuperViewWillAppearNotification
                                                        object:self
                                                      userInfo:nil];
}

- (void)cards_viewDidDisappear:(BOOL)animated
{
    [self cards_viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kCardsSuperViewDidDisappearNotification
                                                        object:self
                                                      userInfo:nil];
}



#pragma mark - Notification

//接收到父控制器将显示通知
- (void)receiveCardsSuperViewWillAppearNotification:(NSNotification *)notification
{
    for (int i = 0; i < _cardControllersArray.count; i++) {
        CardController *cardController = _cardControllersArray[i];
        if ([cardController respondsToSelector:@selector(cardsController:superViewWillAppear:)]) {
            [cardController cardsController:self superViewWillAppear:_superViewController];
        }
    }
}

//接收到父控制器已隐藏通知
- (void)receiveCardsSuperViewDidDisappearNotification:(NSNotification *)notification
{
    for (int i = 0; i < _cardControllersArray.count; i++) {
        CardController *cardController = _cardControllersArray[i];
        if ([cardController respondsToSelector:@selector(cardsController:superViewDidDisappear:)]) {
            [cardController cardsController:self superViewDidDisappear:_superViewController];
        }
    }
}



#pragma mark - Error View

//默认点击提示信息事件
- (void)touchErrorViewAction
{
    if (_refreshType & CardsRefreshTypeLoadingView) {
        [self requestCards];
    } else if (_refreshType & CardsRefreshTypePullToRefresh) {
        if (_enableNetworkError) {
            [self.view hideErrorView];
        }
        [_tableView.mj_header beginRefreshing];
    } else {
        [self requestCards];
    }
}

#pragma mark - Private Methods

//获取index对应的卡片控制器
- (CardController *)cardControllerAtIndex:(NSInteger)index
{
    return (index < _cardControllersArray.count) ? _cardControllersArray[index] : nil;
}

//是否为卡片间距
- (BOOL)isCardSpacing:(CardController *)cardController atIndexPath:(NSIndexPath *)indexPath
{
    return (cardController.showCardSpacing && indexPath && indexPath.row == cardController.rowCountCache - 1);
}

//是否为卡片头部
- (BOOL)isCardHeader:(CardController *)cardController atIndexPath:(NSIndexPath *)indexPath
{
    return (cardController.showCardHeader && indexPath && indexPath.row == 0);
}

//是否为卡片尾部
- (BOOL)isCardFooter:(CardController *)cardController atIndexPath:(NSIndexPath *)indexPath
{
    BOOL isCardFooter = NO;
    if (cardController.showCardFooter && indexPath) {
        if (cardController.showCardSpacing && indexPath.row == cardController.rowCountCache - 2) {
            isCardFooter = YES;
        }
        if (!cardController.showCardSpacing && indexPath.row == cardController.rowCountCache - 1) {
            isCardFooter = YES;
        }
    }
    return isCardFooter;
}

//是否为有效卡片内容
- (BOOL)isValidCardContent:(CardController *)cardController atIndexPath:(NSIndexPath *)indexPath
{
    if (!cardController || !indexPath) return NO;
    
    if ([self isCardSpacing:cardController atIndexPath:indexPath]) return NO; //卡片间距
    if ([self isCardHeader:cardController atIndexPath:indexPath]) return NO; //头部视图
    if ([self isCardFooter:cardController atIndexPath:indexPath]) return NO; //尾部视图
    if (cardController.showCardError) return NO; //错误卡片
    
    return YES;
}



#pragma mark - Public Methods

//获取指定类型的卡片控制器
- (NSArray *)queryCardControllersWithType:(CardType)type
{
    NSMutableArray *cardControllersArray = nil;
    for (int i = 0; i < _cardControllersArray.count; i++) {
        CardController *cardController = _cardControllersArray[i];
        if (cardController.cardContext.type == type) {
            if (!cardControllersArray) {
                cardControllersArray = [NSMutableArray array];
            }
            [cardControllersArray addObject:cardController];
        }
    }
    return cardControllersArray;
}

- (void)scrollToCardType:(CardType)type animated:(BOOL)animated {
    int i = 0;
    for (i = 0; i < _cardControllersArray.count; i++) {
        CardController *cardController = _cardControllersArray[i];
        if (cardController.cardContext.type == type) {
            break;
        }
    }
    if (i < _cardControllersArray.count) {
        if (i < self.cardControllersArray.count) {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:i] atScrollPosition:UITableViewScrollPositionTop animated:animated];
        }
    }
}

#pragma mark - Request

#pragma mark Parser

//解析卡片数据源，创建卡片控制器
- (NSArray *)parseCardControllersWithCardsArray:(NSArray *)cardsArray
{
    NSMutableArray *cardControllersArray = [NSMutableArray array];
    for (CardContext *cardContext in cardsArray) {
        //初始化卡片控制器
        Class class = NSClassFromString(cardContext.clazz);
        if (![class isSubclassOfClass:[CardController class]]) {
            class = [CardController class];
        }
        
        CardController *cardController = [[class alloc] init];
        cardController.delegate = self;
        cardController.cardsController = self;
        cardController.cardContext = cardContext;
        [cardControllersArray addObject:cardController];
        
        //初始化扩展控制器
        Class extensionClass = NSClassFromString(cardContext.extensionClazz);
        if ([extensionClass isSubclassOfClass:[CardController class]]) {
            CardController *extensionController = [[extensionClass alloc] init];
            extensionController.delegate = self;
            extensionController.cardsController = self;
            extensionController.cardContext = cardContext;
            extensionController.isExtension = YES;
            cardController.extensionController = extensionController;
        }
    }
    return cardControllersArray;
}

#pragma mark Cards

//请求卡片列表
- (void)requestCards
{
    [self requestCardsWillStart];
}

//卡片列表请求将开始
- (void)requestCardsWillStart
{
    //清空数据源
    if (_clearType == CardsClearTypeBeforeRequest) { //请求前清除数据源
        
        if (_cardControllersArray.count > 0) {
            [_cardsArray removeAllObjects];
            [_cardControllersArray removeAllObjects];
            
            [_tableView reloadData];
        }
    }
    
    //隐藏错误提示
    [self.view hideErrorView];
    
    //显示加载视图
    if (_refreshType & CardsRefreshTypeLoadingView && !_cardControllersArray.count) {
        if (!_loadingView) {
            _loadingView = [[BaseLoadingView alloc] initWithFrame:CGRectMake(0.0, 0.0, 100.0, 100.0)]; //给定足够大的尺寸
        }

        //居中显示
        CGFloat hHeader = CGRectGetHeight(_tableView.tableHeaderView.frame);
        CGFloat hTable = CGRectGetHeight(_tableView.frame);
        CGFloat cY = (hTable - hHeader - _tableView.contentInset.top - _tableView.contentInset.bottom) / 2.0 + hHeader;
        _loadingView.center = CGPointMake(_tableView.frame.size.width / 2.0, cY);;
        [_tableView addSubview:_loadingView];
        [_loadingView startAnimating];
    }
}

//卡片列表请求成功
- (void)requestCardsDidSucceedWithCardsArray:(NSArray *)cardsArray
{
    if (_cardsArray.count
        && cardsArray.count
        && [_cardsArray isEqualToArray:cardsArray]) { //数据未变更
        
        if (_refreshType & CardsRefreshTypePullToRefresh) { //下拉刷新
            [_tableView.mj_header endRefreshing];
        }
        return;
    }
    
    //清空缓存
    if (_clearType == CardsClearTypeAfterRequest) {
        //初始化监听可能调用了UI刷新和数据请求，若请求前没有清除数据源，需要保证回调前清空缓存
        [_cardsArray removeAllObjects];
        [_cardControllersArray removeAllObjects];
        [_tableView reloadData];
    }
    
    //解析数据源
    NSArray *cardControllersArray = [self parseCardControllersWithCardsArray:cardsArray];
    
    //更新数据源
    _cardControllersArray.array = cardControllersArray;
    _cardsArray.array = cardsArray;
    
    //执行卡片初始化监听（可能调用了UI刷新和数据请求，需在_cardsArray和_cardControllersArray赋值后调用）
    for (int i = 0; i < cardControllersArray.count; i++) {
        CardController *cardController = cardControllersArray[i];
        
        if ([cardController respondsToSelector:@selector(didFinishInitConfigurationInCardsController:)]) {
        
            [cardController didFinishInitConfigurationInCardsController:self];
        }
        if ([cardController.extensionController respondsToSelector:@selector(didFinishInitConfigurationInCardsController:)]) {
            [cardController.extensionController didFinishInitConfigurationInCardsController:self];
        }
    }
    
    //隐藏错误提示
    if (_enableNetworkError) {
        [self.view hideErrorView];
    }
    
    //隐藏加载视图
    if (_refreshType & CardsRefreshTypeLoadingView) { //中心加载视图
        [_loadingView stopAnimating];
        [_loadingView removeFromSuperview];
    }
    if (_refreshType & CardsRefreshTypePullToRefresh) { //下拉刷新
        [_tableView.mj_header endRefreshing];
    }
    
    [_tableView reloadData];


    //请求独立数据源
    [self fetchIndependentCardDataWhenRequestCards];
}

//卡片列表请求失败
- (void)requestCardsDidFailWithError:(NSError *)error
{
    //清空数据源
    if (_clearType == CardsClearTypeAfterRequest) {
        [_cardsArray removeAllObjects];
        [_cardControllersArray removeAllObjects];
        
        [_tableView reloadData];
    }
    
    //隐藏加载视图
    if (_refreshType & CardsRefreshTypeLoadingView) { //中心加载视图
        [_loadingView stopAnimating];
        [_loadingView removeFromSuperview];
    }
    if (_refreshType & CardsRefreshTypePullToRefresh) { //下拉刷新
       [_tableView.mj_header endRefreshing];
    }
    
    //显示错误提示视图
    if (_enableNetworkError) {
        if (error.code == CardErrorCodeFailed) { //数据错误
            [self.view showFailedError:self selector:@selector(touchErrorViewAction)];
        } else { //网络错误
            [self.view showNetworkError:self selector:@selector(touchErrorViewAction)];
        }
    }
}



#pragma mark Card Data

//请求独立数据源
- (void)fetchIndependentCardDataWhenRequestCards{
    [self.cardControllersArray enumerateObjectsUsingBlock:^(CardController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.cardContext.asyncLoad) {
            [self requestCardDataWithController:obj];
        }
    }];
}

//请求单卡片数据
- (void)requestCardDataWithController:(CardController *)cardController
{
    __weak typeof(self) weakSelf = self;
    NSString *type = @"get";
    if ([cardController respondsToSelector:@selector(cardRequestTypeInCardsController:)]) {
        type = [cardController cardRequestTypeInCardsController:self];
    }
    NSString *url = nil;
    if ([cardController respondsToSelector:@selector(cardRequestURLInCardsController:)]) {
        url = [cardController cardRequestURLInCardsController:self];
    }
    NSDictionary *param = nil;
    if ([cardController respondsToSelector:@selector(cardRequestParametersInCardsController:)]) {
        param = [cardController cardRequestParametersInCardsController:self];
    }

    Class modelClass = nil;
    if ([cardController respondsToSelector:@selector(cardRequestParserModelClassInCardsController:)]) {
        modelClass = [cardController cardRequestParserModelClassInCardsController:self];
    }
    if (!url || !modelClass) {
        return;
    }

    if ([[type lowercaseString] isEqualToString:@"get"]) {
        [self.httpManager requestGet:url parameters:param success:^(id responseObject) {
            if ([responseObject isKindOfClass:[NSDictionary class]]
                && responseObject[@"errno"] && [responseObject[@"errno"] integerValue] == 0
                && responseObject[@"data"]) {
                id model = [[modelClass alloc] initWithDictionary:responseObject[@"data"] error:nil];
                cardController.cardContext.json = model;
                cardController.cardContext.cardInfo = responseObject[@"data"];
                [weakSelf cardSeparateDataBeReady:cardController.cardContext];
            }
            else {
                NSError *cardError = [NSError errorWithDomain:@"CardError" code:CardErrorCodeFailed userInfo:nil];
                [weakSelf cardSeparateDataUnavailable:cardController.cardContext error:cardError];
            }

        } failure:^(NSError *error) {
            NSError *cardError = [NSError errorWithDomain:@"CardError" code:CardErrorCodeNetwork userInfo:nil];
            [weakSelf cardSeparateDataUnavailable:cardController.cardContext error:cardError];
        }];
    }
    else {
        [self.httpManager requestPost:url parameters:param success:^(id responseObject) {
            if ([responseObject isKindOfClass:[NSDictionary class]]
                && [responseObject[@"error"] integerValue] == 0
                && responseObject[@"data"]) {
                id model = [[modelClass alloc] initWithDictionary:responseObject[@"data"] error:nil];
                cardController.cardContext.json = model;
                cardController.cardContext.cardInfo = responseObject[@"data"];
                [weakSelf cardSeparateDataBeReady:cardController.cardContext];
            }
            else {
                NSError *cardError = [NSError errorWithDomain:@"CardError" code:CardErrorCodeFailed userInfo:nil];
                [weakSelf cardSeparateDataUnavailable:cardController.cardContext error:cardError];
            }

        } failure:^(NSError *error) {
            NSError *cardError = [NSError errorWithDomain:@"CardError" code:CardErrorCodeNetwork userInfo:nil];
            [weakSelf cardSeparateDataUnavailable:cardController.cardContext error:cardError];
        }];
    }
}

//单卡片请求成功回调
- (void)cardSeparateDataBeReady:(CardContext *)cardContext
{
    NSUInteger cardIndex = [_cardsArray indexOfObject:cardContext];
    if (cardIndex != NSNotFound && cardIndex < _cardControllersArray.count) {
        [self requestCardDataDidSucceedWithCardContext:cardContext];
    }
}

//单卡片请求失败回调
- (void)cardSeparateDataUnavailable:(CardContext *)cardContext error:(NSError *)error{
    NSUInteger cardIndex = [_cardsArray indexOfObject:cardContext];
    if (cardIndex != NSNotFound && cardIndex < _cardControllersArray.count) {
        [self requestCardDataDidFailWithCardContext:cardContext error:error];
    }
}

//卡片数据请求成功
- (void)requestCardDataDidSucceedWithCardContext:(CardContext *)cardContext
{
    cardContext.error = nil;
    
    NSUInteger index = [_cardsArray indexOfObject:cardContext];
    CardController *cardController = [self cardControllerAtIndex:index];
    if ([cardController respondsToSelector:@selector(cardRequestDidFinishInCardsController:)]) {
        [cardController cardRequestDidFinishInCardsController:self];
    }
    [_tableView reloadSection:index];
}

//卡片数据请求失败
- (void)requestCardDataDidFailWithCardContext:(CardContext *)cardContext error:(NSError *)error
{
    NSUInteger index = [_cardsArray indexOfObject:cardContext];
    CardController *cardController = [self cardControllerAtIndex:index];
    if (cardController) {
        if ([error.domain isEqualToString:@"CardError"]) {
            cardContext.error = error;
        } else {
            cardContext.error = [NSError errorWithDomain:@"CardError" code:CardErrorCodeNetwork userInfo:nil];
        }
        
        if ([cardController respondsToSelector:@selector(cardRequestDidFinishInCardsController:)]) {
            [cardController cardRequestDidFinishInCardsController:self];
        }

        if ([cardController respondsToSelector:@selector(cardsController:shouldIgnoreCardErrorWithCode:)]) {
            if ([cardController cardsController:self shouldIgnoreCardErrorWithCode:cardContext.error.code]) {
                cardContext.error = nil; //忽略当前类型错误
            }
        }
        
        [_tableView reloadSection:index];
    }
}


- (void)triggerRefreshAction {
    [_tableView.mj_header beginRefreshing];
}

#pragma mark More

//加载更多事件
- (void)requestMoreData
{
    //触发加载更多事件
    for (int i = 0; i < _cardControllersArray.count; i++) {
        CardController *cardController = _cardControllersArray[i];
        if (cardController.canRequestMoreData && [cardController respondsToSelector:@selector(didTriggerRequestMoreDataActionInCardsController:)]) {
            [cardController didTriggerRequestMoreDataActionInCardsController:self];
        }
    }
}

//加载更多卡片
- (void)requestMoreCardsDidSucceedWithCardsArray:(NSArray *)cardsArray
{
    if (!cardsArray.count) return;
    
    //记录参数
    NSMutableArray *sections = [NSMutableArray array]; //新增卡片对应的sections
    NSInteger startSection = _cardsArray.count;
    //解析数据源
    NSArray *cardControllersArray = [self parseCardControllersWithCardsArray:cardsArray];
    //更新数据源
    [_cardControllersArray addObjectsFromArray:cardControllersArray];
    [_cardsArray addObjectsFromArray:cardsArray];

    //执行卡片初始化监听（可能调用了UI刷新和数据请求，需在_cardsArray和_cardControllersArray赋值后调用）
    for (int i = 0; i < cardControllersArray.count; i++) {
        CardController *cardController = cardControllersArray[i];
        [self requestCardDataWithController:cardController];
        if ([cardController respondsToSelector:@selector(cardRequestDidFinishInCardsController:)]) {
            [cardController cardRequestDidFinishInCardsController:self];
        }
        if ([cardController respondsToSelector:@selector(didFinishInitConfigurationInCardsController:)]) {
            [cardController didFinishInitConfigurationInCardsController:self];
        }
        if ([cardController.extensionController respondsToSelector:@selector(didFinishInitConfigurationInCardsController:)]) {
            [cardController.extensionController didFinishInitConfigurationInCardsController:self];
        }
        [sections addObject:@(startSection + i)];
    }
    //刷新视图
    [_tableView reloadSections:sections];
}

- (void)requestMoreCardsDidFailWithError:(NSError *)error
{
    
}

#pragma mark - CardControllerDelegate

- (void)addSectionWithType:(CardType)cardType
           withCardContext:(CardContext *)cardContext
        withcardController:(CardController *)cardController
                 withIndex:(NSUInteger)index
             withAnimation:(UITableViewRowAnimation)animation{
    NSMutableIndexSet *sections = [NSMutableIndexSet indexSet];
    [self.cardsArray insertObject:cardContext atIndex:index];
    [self.cardControllersArray insertObject:cardController atIndex:index];
    //计算需要操作的section
    for (NSUInteger i = 0; i < self.cardControllersArray.count; i++) {
        CardController *cardController = self.cardControllersArray[i];
        if (cardController.cardContext.type == cardType) {
            [sections addIndex:i];
        }
    }
    [self.tableView insertSections:sections withRowAnimation:animation];
}

- (void)deleteSectionWithType:(CardType)cardType
                    withIndex:(NSUInteger)index
                withAnimation:(UITableViewRowAnimation)animation{
    NSMutableIndexSet *sections = [NSMutableIndexSet indexSet];
    //计算需要操作的section
    for (NSUInteger i = 0; i < self.cardControllersArray.count; i++) {
        CardController *cardController = self.cardControllersArray[i];
        if (cardController.cardContext.type == cardType) {
            [sections addIndex:i];
        }
    }
    [self.cardsArray removeObjectAtIndex:index];
    [self.cardControllersArray removeObjectAtIndex:index];
    [self.tableView deleteSections:sections withRowAnimation:animation];
    
}

//刷新指定类型的卡片
- (void)refreshCardWithType:(CardType)type animation:(UITableViewRowAnimation)animation
{
    if (animation != UITableViewRowAnimationNone) {
        NSMutableIndexSet *sections = [NSMutableIndexSet indexSet];
        for (NSUInteger i = 0; i < _cardControllersArray.count; i++) {
            CardController *cardController = _cardControllersArray[i];
            if (cardController.cardContext.type == type) {
                [sections addIndex:i];
            }
        }
        if (sections.count > 0) {
            @synchronized(self) {
                [_tableView beginUpdates];
                [_tableView reloadSections:sections withRowAnimation:animation];
                [_tableView endUpdates];
            }
        }
    } else {
        NSMutableArray *sections = [NSMutableArray array];
        for (int i = 0; i < _cardControllersArray.count; i++) {
            CardController *cardController = _cardControllersArray[i];
            if (cardController.cardContext.type == type) {
                [sections addObject:@(i)];
            
            }
        }
        
        if (sections.count > 0) {
            [_tableView reloadSections:sections];
        }
    }
}

//刷新指定类型的卡片
- (void)refreshCardWithType:(CardType)type
{
    [self refreshCardWithType:type animation:UITableViewRowAnimationNone];
}
//刷新指定卡片的数据源
- (void)refreshCardWithType:(CardType)type json:(id)json {
    NSMutableArray *sections = [NSMutableArray array];
    for (int i = 0; i < _cardControllersArray.count; i++) {
        CardController *cardController = _cardControllersArray[i];
        if (cardController.cardContext.type == type) {
            [sections addObject:@(i)];
            cardController.cardContext.json = json;
            if (CardTypeHomeDynamicWeb !=cardController.cardContext.type ) {
                if ([cardController respondsToSelector:@selector(didFinishInitConfigurationInCardsController:)]) {
                    [cardController didFinishInitConfigurationInCardsController:self];
                }
            }
        }
    }
    
    if (sections.count > 0) {
        [_tableView reloadSections:sections];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    NSArray *visibleCells = [self.tableView visibleCells];
    for (UITableViewCell *visibleCell in visibleCells) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:visibleCell];
        CardController *cardController = [self cardControllerAtIndex:indexPath.section];
        
        if ([cardController respondsToSelector:@selector(cardsController:scrollViewWillBeginDraggingForCell:)]) {
            [cardController cardsController:self scrollViewWillBeginDraggingForCell:visibleCell];
        }
    }
}


#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(CardTableView *)tableView
{
    return _cardControllersArray.count;
}

- (CGFloat)tableView:(CardTableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CardController *cardController = [self cardControllerAtIndex:section];
    CGFloat headerHeight = 0.0;
    if ([cardController respondsToSelector:@selector(cardsController:heightForSuspendHeaderInTableView:)]) {
        headerHeight = [cardController cardsController:self heightForSuspendHeaderInTableView:tableView];
    }
    return headerHeight;
}

- (UIView *)tableView:(CardTableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CardController *cardController = [self cardControllerAtIndex:section];
    
    UIView *headerView = nil;
    if ([cardController respondsToSelector:@selector(cardsController:viewForSuspendHeaderInTableView:)]) {
        headerView = [cardController cardsController:self viewForSuspendHeaderInTableView:tableView];
    }
    return headerView;
}

- (NSInteger)tableView:(CardTableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    CardController *cardController = [self cardControllerAtIndex:section];
    return cardController.rowCountCache;
}

- (CGFloat)tableView:(CardTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CardController *cardController = [self cardControllerAtIndex:indexPath.section];
    return (indexPath.row < cardController.rowHeightsCache.count) ? ceil([cardController.rowHeightsCache[indexPath.row] floatValue]) : 0.0;
}

- (UITableViewCell *)tableView:(CardTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CardController *cardController = [self cardControllerAtIndex:indexPath.section];
    //布局参数
    BOOL isCardSpacing = [self isCardSpacing:cardController atIndexPath:indexPath]; //卡片间距
    BOOL isCardHeader = [self isCardHeader:cardController atIndexPath:indexPath]; //头部视图
    BOOL isCardFooter = [self isCardFooter:cardController atIndexPath:indexPath]; //尾部视图

    //复用参数
    Class class = nil;
    NSString *identifier = nil;
    if (isCardSpacing) { //卡片间距
        class = [UITableViewCell class];
        identifier = @"CardSpacingCell";
    } else if (isCardHeader) { //头部视图
        if ([cardController respondsToSelector:@selector(cardsController:cellClassForCardHeaderInTableView:)]) {
            class = [cardController cardsController:self cellClassForCardHeaderInTableView:tableView];
        }
        if ([cardController respondsToSelector:@selector(cardsController:cellIdentifierForCardHeaderInTableView:)]) {
            identifier = [cardController cardsController:self cellIdentifierForCardHeaderInTableView:tableView];
        }
    } else if (isCardFooter) { //尾部视图
        if ([cardController respondsToSelector:@selector(cardsController:cellClassForCardFooterInTableView:)]) {
            class = [cardController cardsController:self cellClassForCardFooterInTableView:tableView];
        }
        if ([cardController respondsToSelector:@selector(cardsController:cellIdentifierForCardFooterInTableView:)]) {
            identifier = [cardController cardsController:self cellIdentifierForCardFooterInTableView:tableView];
        }
    } else {
        if (cardController.showCardError) { //错误卡片
            class = [CardErrorCell class];
            identifier = NSStringFromClass(class);
        } else { //数据源
            if (indexPath.row < cardController.extensionRowIndex) { //卡片内容
                NSInteger rowIndex = cardController.showCardHeader ? indexPath.row - 1 : indexPath.row; //数据源对应的index
                if ([cardController respondsToSelector:@selector(cardsController:cellClassForCardContentAtIndex:)]) {
                    class = [cardController cardsController:self cellClassForCardContentAtIndex:rowIndex];
                }
                if ([cardController respondsToSelector:@selector(cardsController:cellIdentifierForCardContentAtIndex:)]) {
                    identifier = [cardController cardsController:self cellIdentifierForCardContentAtIndex:rowIndex];
                }
            } else { //卡片扩展
                NSInteger rowIndex = indexPath.row - cardController.extensionRowIndex; //数据源对应的index
                if ([cardController.extensionController respondsToSelector:@selector(cardsController:cellClassForCardContentAtIndex:)]) {
                    class = [cardController.extensionController cardsController:self cellClassForCardContentAtIndex:rowIndex];
                }
                if ([cardController.extensionController respondsToSelector:@selector(cardsController:cellIdentifierForCardContentAtIndex:)]) {
                    identifier = [cardController.extensionController cardsController:self cellIdentifierForCardContentAtIndex:rowIndex];
                }
            }
        }
    }
    
    if (!class) {
        class = [UITableViewCell class];
    }
    if (!identifier.length) {
        identifier = [NSString stringWithFormat:@"%@_%ld", NSStringFromClass(class), (long)cardController.cardContext.type]; //同类卡片内部复用cell
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[class alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.clipsToBounds = YES;
        cell.exclusiveTouch = YES;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
       
        if ([cardController respondsToSelector:@selector(cardsController:colorForCardBackgroundInTableView:)]) {
            cell.backgroundColor = [cardController cardsController:self colorForCardBackgroundInTableView:tableView];
            cell.contentView.backgroundColor = [cardController cardsController:self colorForCardBackgroundInTableView:tableView];

        }else{
            cell.backgroundColor = [UIColor whiteColor];
            cell.contentView.backgroundColor = [UIColor whiteColor];
        }
    }
    
    if (isCardSpacing) { //卡片间距
        UIColor *backgroundColor = [UIColor clearColor];
        if ([cardController respondsToSelector:@selector(cardsController:colorForCardSpacingInTableView:)]) {
            backgroundColor = [cardController cardsController:self colorForCardSpacingInTableView:tableView];
        }
        cell.backgroundColor = backgroundColor;
        cell.contentView.backgroundColor = backgroundColor;
        if ([cardController respondsToSelector:@selector(cardsController:reuseCell:forCardSpaingInTableView:)]) {
            [cardController cardsController:self reuseCell:cell forCardSpaingInTableView:tableView];
        }
    } else if (isCardHeader) { //头部视图
        [cardController cardsController:self reuseCell:cell forCardHeaderInTableView:tableView];
    } else if (isCardFooter) { //尾部视图
        [cardController cardsController:self reuseCell:cell forCardFooterInTableView:tableView];
    } else { //数据源
        if (cardController.showCardError) { //错误卡片
            CardErrorCell *cardErrorCell = (CardErrorCell *)cell;
            cardErrorCell.cardController = cardController;
            [cardErrorCell refreshCardErrorView];
        } else {
            if (indexPath.row < cardController.extensionRowIndex) { //卡片内容
                NSInteger rowIndex = cardController.showCardHeader ? indexPath.row - 1 : indexPath.row; //数据源对应的index
                [cardController cardsController:self reuseCell:cell forCardContentAtIndex:rowIndex];
            } else { //卡片扩展
                NSInteger rowIndex = indexPath.row - cardController.extensionRowIndex; //数据源对应的index
                [cardController.extensionController cardsController:self reuseCell:cell forCardContentAtIndex:rowIndex];
            }
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    CardController *cardController = [self cardControllerAtIndex:indexPath.section];
    
    //布局参数
    BOOL isCardSpacing = [self isCardSpacing:cardController atIndexPath:indexPath]; //卡片间距
    BOOL isCardHeader = [self isCardHeader:cardController atIndexPath:indexPath]; //头部视图
    BOOL isCardFooter = [self isCardFooter:cardController atIndexPath:indexPath]; //尾部视图
    
    //卡片回调
    if (!isCardSpacing && !isCardHeader && !isCardFooter && !cardController.showCardError) { //数据源
        if (indexPath.row < cardController.extensionRowIndex) { //卡片内容
            if ([cardController respondsToSelector:@selector(cardsController:willDisplayCell:forCardContentAtIndex:)]) {
                NSInteger rowIndex = cardController.showCardHeader ? indexPath.row - 1 : indexPath.row; //数据源对应的index
                [cardController cardsController:self willDisplayCell:cell forCardContentAtIndex:rowIndex];
            }
        } else { //卡片扩展
            if ([cardController.extensionController respondsToSelector:@selector(cardsController:willDisplayCell:forCardContentAtIndex:)]) {
                NSInteger rowIndex = indexPath.row - cardController.extensionRowIndex; //数据源对应的index
                [cardController.extensionController cardsController:self willDisplayCell:cell forCardContentAtIndex:rowIndex];
            }
        }
    } else if (isCardHeader) {
        if ([cardController respondsToSelector:@selector(cardsController:willDisplayingHeaderCell:)]) {
            [cardController cardsController:self willDisplayingHeaderCell:cell];
        }
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    CardController *cardController = [self cardControllerAtIndex:indexPath.section];
    
    //布局参数
    BOOL isCardSpacing = [self isCardSpacing:cardController atIndexPath:indexPath]; //卡片间距
    BOOL isCardHeader = [self isCardHeader:cardController atIndexPath:indexPath]; //头部视图
    BOOL isCardFooter = [self isCardFooter:cardController atIndexPath:indexPath]; //尾部视图
    
    //卡片回调
    if (!isCardSpacing && !isCardHeader && !isCardFooter && !cardController.showCardError) { //数据源
        if (indexPath.row < cardController.extensionRowIndex) { //卡片内容
            if ([cardController respondsToSelector:@selector(cardsController:didEndDisplayingCell:forCardContentAtIndex:)]) {
                NSInteger rowIndex = cardController.showCardHeader ? indexPath.row - 1 : indexPath.row; //数据源对应的index
                [cardController cardsController:self didEndDisplayingCell:cell forCardContentAtIndex:rowIndex];
            }
        } else { //卡片扩展
            if ([cardController.extensionController respondsToSelector:@selector(cardsController:didEndDisplayingCell:forCardContentAtIndex:)]) {
                NSInteger rowIndex = indexPath.row - cardController.extensionRowIndex; //数据源对应的index
                [cardController.extensionController cardsController:self didEndDisplayingCell:cell forCardContentAtIndex:rowIndex];
            }
        }
    }else if (isCardHeader){
        
        if ([cardController respondsToSelector:@selector(cardsController:didEndDisplayingHeaderCell:)]) {
            [cardController cardsController:self didEndDisplayingHeaderCell:cell];
        }
    }
}

- (void)tableView:(CardTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CardController *cardController = [self cardControllerAtIndex:indexPath.section];
    
    //布局参数
    BOOL isCardSpacing = [self isCardSpacing:cardController atIndexPath:indexPath]; //卡片间距
    BOOL isCardHeader = [self isCardHeader:cardController atIndexPath:indexPath]; //头部视图
    BOOL isCardFooter = [self isCardFooter:cardController atIndexPath:indexPath]; //尾部视图
    
    //点击事件
    if (isCardSpacing) { //卡片间距
        //无效点击
    } else if (isCardHeader) { //头部视图
        if ([cardController respondsToSelector:@selector(cardsController:didSelectCardHeaderInTableView:)]) {
            [cardController cardsController:self didSelectCardHeaderInTableView:tableView];
        }
    } else if (isCardFooter) { //尾部视图
        if ([cardController respondsToSelector:@selector(cardsController:didSelectCardFooterInTableView:)]) {
            [cardController cardsController:self didSelectCardFooterInTableView:tableView];
        }
    } else { //数据源
        if (cardController.showCardError) { //错误卡片
            //无效点击
        } else {
            if (indexPath.row < cardController.extensionRowIndex) { //卡片内容
                if ([cardController respondsToSelector:@selector(cardsController:didSelectCardContentAtIndex:)]) {
                    NSInteger rowIndex = cardController.showCardHeader ? indexPath.row - 1 : indexPath.row; //数据源对应的index
                    [cardController cardsController:self didSelectCardContentAtIndex:rowIndex];
                }
            } else { //卡片扩展
                if ([cardController.extensionController respondsToSelector:@selector(cardsController:didSelectCardContentAtIndex:)]) {
                    NSInteger rowIndex = indexPath.row - cardController.extensionRowIndex; //数据源对应的index
                    [cardController.extensionController cardsController:self didSelectCardContentAtIndex:rowIndex];
                }
            }
        }
    }
}

@end


@implementation CardsController (BottomPrivate)

//设置封底开关
- (void)setEnableTableBottomView:(BOOL)enableTableBottomView
{
    if (_enableTableBottomView != enableTableBottomView) {
        _enableTableBottomView = enableTableBottomView;

        if (self.isViewLoaded) {
            [self refreshTableBottomView];
        }
    }
}

//设置封底自定义视图
- (void)setTableBottomCustomView:(UIView *)tableBottomCustomView
{
    if (_tableBottomCustomView != tableBottomCustomView) {
        _tableBottomCustomView = tableBottomCustomView;

        if (self.isViewLoaded) {
            [self refreshTableBottomView];
        }
    }
}

//刷新封底视图
- (void)refreshTableBottomView
{
    if (!_enableTableBottomView //禁用封底
        || !_cardControllersArray.count) { //无数据源

        if (_tableView.tableFooterView.tag == kTagTableBottomView) {
            _tableView.tableFooterView = nil;
        }
        return;
    }

    if (_refreshType & CardsRefreshTypeInfiniteScrolling) { //显示加载更多控件，移除封底
        _tableView.tableFooterView = nil;
    } else { //显示封底
        if (_tableBottomCustomView) { //自定义封底
            _tableView.tableFooterView = _tableBottomCustomView;
        } else { //默认封底
            if (![_tableView.tableFooterView isKindOfClass:[CardTableFooterView class]]) {
                _tableView.tableFooterView = [[CardTableFooterView alloc] initWithFrame:CGRectMake(0, 0, _tableView.e_width, 50)];
            }
        }
        _tableView.tableFooterView.tag = kTagTableBottomView;
    }
}

//触发加载更多事件，启动加载动画
- (void)triggerInfiniteScrollingAction
{
    [_tableView.mj_footer beginRefreshing];
}

//完成加载更多事件，停止加载动画
- (void)finishInfiniteScrollingAction
{
    [_tableView.mj_footer endRefreshing];
}

///完成所有数据加载，设置
- (void)didFinishLoadAllData{
    self.enableTableBottomView = YES;
    CardsRefreshType refreshType = self.refreshType & (CardsRefreshTypePullToRefresh | CardsRefreshTypeLoadingView);
    self.refreshType = refreshType;
}

@end
