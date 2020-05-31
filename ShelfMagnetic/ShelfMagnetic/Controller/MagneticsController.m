//
//  MagneticsController.m
//  ShelfMagnetic
//
//  Created by Jenson on 2020/5/31.
//  Copyright © 2020 Jenson. All rights reserved.
//

#import "MagneticsController.h"
#import "MagneticsController.h"
#import "NSObject+Runtime.h"
#import "MagneticTableFooterView.h"
#import "NXHttpManager.h"
#import "common.h"
#import "BaseLoadingView.h"

#define kTagTableBottomView     3527    //卡片封底视图标记

//卡片父控制器将显示通知
NSString * const kMagneticsSuperViewWillAppearNotification = @"MagneticsSuperViewWillAppearNotification";
//卡片父控制器已消失通知
NSString * const kMagneticsSuperViewDidDisappearNotification = @"MagneticsSuperViewDidDisappearNotification";

@interface MagneticsController ()
/* Request */
@property (nonatomic, strong)   NXHttpManager       *httpManager;
@property (nonatomic)           MagneticsRefreshType    refreshType;            //卡片列表刷新方式
@property (nonatomic)           MagneticsClearType      clearType;              //卡片数据清除方式
@property (nonatomic)           BOOL                enableNetworkError;     //使用默认错误提示

/* Bottom */
@property (nonatomic)           BOOL                enableTableBottomView;  //显示表视图封底
@property (nonatomic, strong)   UIView              *tableBottomCustomView; //封底自定义视图
@end

@implementation MagneticsController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _MagneticsArray = [[NSMutableArray alloc] init];
        _MagneticControllersArray = [[NSMutableArray alloc] init];
        _enableNetworkError = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    //下拉刷新
    if ((_refreshType & MagneticsRefreshTypePullToRefresh) && !_tableView.mj_header) {
        __weak typeof(self) weakSelf = self;
        _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [weakSelf requestMagnetics];
        }];
    }
    
    //上拉加载更多
    if ((_refreshType & MagneticsRefreshTypeInfiniteScrolling) && !_tableView.mj_footer) {
        __weak typeof(self) weakSelf = self;
        _tableView.mj_footer = [MJRefreshAutoStateFooter footerWithRefreshingBlock:^{
            [weakSelf requestMoreData];
        }];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    _tableView.delegate = nil;
    _tableView.dataSource = nil;

    [_tableView.mj_header endRefreshing];
    [_tableView.mj_footer endRefreshing];
}

- (NXHttpManager *)httpManager {
    if (!_httpManager) {
        _httpManager = [NXHttpManager sharedHttpManager];
    }
    return _httpManager;
}

- (void)loadView
{
    [super loadView];
    
    CGRect frame = self.view.bounds;
    frame.size.width = MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    _tableView = [[MagneticTableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = NO;

    _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    _tableView.MagneticControllersArray = _MagneticControllersArray;
    _tableView.MagneticsController = self;
    
    if (@available(iOS 11, *)) {
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
    }
    
    [self.view addSubview:_tableView];
    
    self.view.clipsToBounds = YES;
}

#pragma mark - Property

- (void)setRefreshType:(MagneticsRefreshType)refreshType
{

    if (_refreshType != refreshType) {
        _refreshType = refreshType;
        //下拉刷新
        if (refreshType & MagneticsRefreshTypePullToRefresh) {
            if (!self.tableView.mj_header && self.isViewLoaded) { //下拉刷新控件依赖于表视图的加载
                __weak typeof(self) weakSelf = self;
                MJRefreshGifHeader * refreshheader = [MJRefreshGifHeader headerWithRefreshingBlock:^{
                    [weakSelf requestMagnetics];
                }];
                refreshheader.lastUpdatedTimeLabel.hidden = YES;
                refreshheader.stateLabel.hidden = YES;
                NSMutableArray * gifImages = [NSMutableArray array];
                for (int i = 0; i < 35; i++) {
                    [gifImages addObject:[UIImage imageNamed:[NSString stringWithFormat:@"frame-%d",i]]];
                }
                [refreshheader setImages:gifImages duration:0.5 forState:MJRefreshStatePulling];
                _tableView.mj_header = refreshheader;
            } else {
                [_tableView.mj_header endRefreshing];
            }

            //上拉加载更多
            if (refreshType & MagneticsRefreshTypeInfiniteScrolling) {
                if (!self.tableView.mj_footer && self.isViewLoaded) { //上拉刷新控件依赖于表视图的加载
                    __weak typeof(self) weakSelf = self;
                    _tableView.mj_footer = [MJRefreshAutoStateFooter footerWithRefreshingBlock:^{
                        [weakSelf requestMoreData];
                    }];
                }
            } else {
                [_tableView.mj_footer endRefreshing];
            }
        }
    }
}

- (void)setSuperViewController:(UIViewController *)superViewController
{
    if (_superViewController != superViewController) {
        //移除旧控制器页面显示/隐藏通知的监听
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kMagneticsSuperViewWillAppearNotification object:_superViewController];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kMagneticsSuperViewDidDisappearNotification object:_superViewController];
        
        //设置属性
        _superViewController = superViewController;
        
        Class superViewClass = [superViewController class];
        if (superViewClass && superViewClass != [UIViewController class] && superViewClass != [UINavigationController class]) { //不替换基础类的IMP实现
            //监控父控制器的页面显示/隐藏
            @synchronized(self) {
                SEL swizzleSelector = @selector(Magnetics_viewWillAppear:);
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
                
                swizzleSelector = @selector(Magnetics_viewDidDisappear:);
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
                                                     selector:@selector(receiveMagneticsSuperViewWillAppearNotification:)
                                                         name:kMagneticsSuperViewWillAppearNotification
                                                       object:superViewController];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(receiveMagneticsSuperViewDidDisappearNotification:)
                                                         name:kMagneticsSuperViewDidDisappearNotification
                                                       object:superViewController];
        }
    }
}



#pragma mark - Runtime

- (void)Magnetics_viewWillAppear:(BOOL)animated
{
    [self Magnetics_viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kMagneticsSuperViewWillAppearNotification
                                                        object:self
                                                      userInfo:nil];
}

- (void)Magnetics_viewDidDisappear:(BOOL)animated
{
    [self Magnetics_viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kMagneticsSuperViewDidDisappearNotification
                                                        object:self
                                                      userInfo:nil];
}

#pragma mark - Notification

//接收到父控制器将显示通知
- (void)receiveMagneticsSuperViewWillAppearNotification:(NSNotification *)notification
{
    for (int i = 0; i < _MagneticControllersArray.count; i++) {
        MagneticController *MagneticController = _MagneticControllersArray[i];
        if ([MagneticController respondsToSelector:@selector(MagneticsController:superViewWillAppear:)]) {
            [MagneticController MagneticsController:self superViewWillAppear:_superViewController];
        }
    }
}

//接收到父控制器已隐藏通知
- (void)receiveMagneticsSuperViewDidDisappearNotification:(NSNotification *)notification
{
    for (int i = 0; i < _MagneticControllersArray.count; i++) {
        MagneticController *MagneticController = _MagneticControllersArray[i];
        if ([MagneticController respondsToSelector:@selector(MagneticsController:superViewDidDisappear:)]) {
            [MagneticController MagneticsController:self superViewDidDisappear:_superViewController];
        }
    }
}

#pragma mark - Error View

//默认点击提示信息事件
- (void)touchErrorViewAction
{
    if (_refreshType & MagneticsRefreshTypeLoadingView) {
        [self requestMagnetics];
    } else if (_refreshType & MagneticsRefreshTypePullToRefresh) {
        if (_enableNetworkError) {
            [self.view hideErrorView];
        }
        [_tableView.mj_header beginRefreshing];
    } else {
        [self requestMagnetics];
    }
}

#pragma mark - Private Methods

//获取index对应的卡片控制器
- (MagneticController *)MagneticControllerAtIndex:(NSInteger)index
{
    return (index < _MagneticControllersArray.count) ? _MagneticControllersArray[index] : nil;
}

//是否为卡片间距
- (BOOL)isMagneticSpacing:(MagneticController *)MagneticController atIndexPath:(NSIndexPath *)indexPath
{
    return (MagneticController.showMagneticSpacing && indexPath && indexPath.row == MagneticController.rowCountCache - 1);
}

//是否为卡片头部
- (BOOL)isMagneticHeader:(MagneticController *)MagneticController atIndexPath:(NSIndexPath *)indexPath
{
    return (MagneticController.showMagneticHeader && indexPath && indexPath.row == 0);
}

//是否为卡片尾部
- (BOOL)isMagneticFooter:(MagneticController *)MagneticController atIndexPath:(NSIndexPath *)indexPath
{
    BOOL isMagneticFooter = NO;
    if (MagneticController.showMagneticFooter && indexPath) {
        if (MagneticController.showMagneticSpacing && indexPath.row == MagneticController.rowCountCache - 2) {
            isMagneticFooter = YES;
        }
        if (!MagneticController.showMagneticSpacing && indexPath.row == MagneticController.rowCountCache - 1) {
            isMagneticFooter = YES;
        }
    }
    return isMagneticFooter;
}

//是否为有效卡片内容
- (BOOL)isValidMagneticContent:(MagneticController *)MagneticController atIndexPath:(NSIndexPath *)indexPath
{
    if (!MagneticController || !indexPath) return NO;
    
    if ([self isMagneticSpacing:MagneticController atIndexPath:indexPath]) return NO; //卡片间距
    if ([self isMagneticHeader:MagneticController atIndexPath:indexPath]) return NO; //头部视图
    if ([self isMagneticFooter:MagneticController atIndexPath:indexPath]) return NO; //尾部视图
    if (MagneticController.showMagneticError) return NO; //错误卡片
    
    return YES;
}

#pragma mark - Public Methods

//获取指定类型的卡片控制器
- (NSArray *)queryMagneticControllersWithType:(MagneticType)type
{
    NSMutableArray *MagneticControllersArray = nil;
    for (int i = 0; i < _MagneticControllersArray.count; i++) {
        MagneticController *MagneticController = _MagneticControllersArray[i];
        if (MagneticController.MagneticContext.type == type) {
            if (!MagneticControllersArray) {
                MagneticControllersArray = [NSMutableArray array];
            }
            [MagneticControllersArray addObject:MagneticController];
        }
    }
    return MagneticControllersArray;
}

- (void)scrollToMagneticType:(MagneticType)type animated:(BOOL)animated {
    int i = 0;
    for (i = 0; i < _MagneticControllersArray.count; i++) {
        MagneticController *MagneticController = _MagneticControllersArray[i];
        if (MagneticController.MagneticContext.type == type) {
            break;
        }
    }
    if (i < _MagneticControllersArray.count) {
        if (i < self.MagneticControllersArray.count) {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:i] atScrollPosition:UITableViewScrollPositionTop animated:animated];
        }
    }
}

#pragma mark - Request

#pragma mark Parser

//解析卡片数据源，创建卡片控制器
- (NSArray *)parseMagneticControllersWithMagneticsArray:(NSArray *)MagneticsArray
{
    NSMutableArray *MagneticControllersArray = [NSMutableArray array];
    for (MagneticContext *MagneticContext in MagneticsArray) {
        //初始化卡片控制器
        Class class = NSClassFromString(MagneticContext.clazz);
        if (![class isSubclassOfClass:[MagneticController class]]) {
            class = [MagneticController class];
        }
        
        MagneticController *MagneticController = [[class alloc] init];
        MagneticController.delegate = self;
        MagneticController.MagneticsController = self;
        MagneticController.MagneticContext = MagneticContext;
        [MagneticControllersArray addObject:MagneticController];
        
        //初始化扩展控制器
        Class extensionClass = NSClassFromString(MagneticContext.extensionClazz);
        if ([extensionClass isSubclassOfClass:[MagneticController class]]) {
            MagneticController *extensionController = [[extensionClass alloc] init];
            extensionController.delegate = self;
            extensionController.MagneticsController = self;
            extensionController.MagneticContext = MagneticContext;
            extensionController.isExtension = YES;
            MagneticController.extensionController = extensionController;
        }
    }
    return MagneticControllersArray;
}

#pragma mark Magnetics

//请求卡片列表
- (void)requestMagnetics
{
    [self requestMagneticsWillStart];
}

//卡片列表请求将开始
- (void)requestMagneticsWillStart
{
    //清空数据源
    if (_clearType == MagneticsClearTypeBeforeRequest) { //请求前清除数据源
        
        if (_MagneticControllersArray.count > 0) {
            [_MagneticsArray removeAllObjects];
            [_MagneticControllersArray removeAllObjects];
            
            [_tableView reloadData];
        }
    }
    
    //隐藏错误提示
    [self.view hideErrorView];
    
    //显示加载视图
    if (_refreshType & MagneticsRefreshTypeLoadingView && !_MagneticControllersArray.count) {
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
- (void)requestMagneticsDidSucceedWithMagneticsArray:(NSArray *)MagneticsArray
{
    if (_MagneticsArray.count
        && MagneticsArray.count
        && [_MagneticsArray isEqualToArray:MagneticsArray]) { //数据未变更
        
        if (_refreshType & MagneticsRefreshTypePullToRefresh) { //下拉刷新
            [_tableView.mj_header endRefreshing];
        }
        return;
    }
    
    //清空缓存
    if (_clearType == MagneticsClearTypeAfterRequest) {
        //初始化监听可能调用了UI刷新和数据请求，若请求前没有清除数据源，需要保证回调前清空缓存
        [_MagneticsArray removeAllObjects];
        [_MagneticControllersArray removeAllObjects];
        [_tableView reloadData];
    }
    
    //解析数据源
    NSArray *MagneticControllersArray = [self parseMagneticControllersWithMagneticsArray:MagneticsArray];
    
    //更新数据源
    _MagneticControllersArray.array = MagneticControllersArray;
    _MagneticsArray.array = MagneticsArray;
    
    //执行卡片初始化监听（可能调用了UI刷新和数据请求，需在_MagneticsArray和_MagneticControllersArray赋值后调用）
    for (int i = 0; i < MagneticControllersArray.count; i++) {
        MagneticController *MagneticController = MagneticControllersArray[i];
        
        if ([MagneticController respondsToSelector:@selector(didFinishInitConfigurationInMagneticsController:)]) {
        
            [MagneticController didFinishInitConfigurationInMagneticsController:self];
        }
        if ([MagneticController.extensionController respondsToSelector:@selector(didFinishInitConfigurationInMagneticsController:)]) {
            [MagneticController.extensionController didFinishInitConfigurationInMagneticsController:self];
        }
    }
    
    //隐藏错误提示
    if (_enableNetworkError) {
        [self.view hideErrorView];
    }
    
    //隐藏加载视图
    if (_refreshType & MagneticsRefreshTypeLoadingView) { //中心加载视图
        [_loadingView stopAnimating];
        [_loadingView removeFromSuperview];
    }
    if (_refreshType & MagneticsRefreshTypePullToRefresh) { //下拉刷新
        [_tableView.mj_header endRefreshing];
    }
    
    [_tableView reloadData];


    //请求独立数据源
    [self fetchIndependentMagneticDataWhenRequestMagnetics];
}

//卡片列表请求失败
- (void)requestMagneticsDidFailWithError:(NSError *)error
{
    //清空数据源
    if (_clearType == MagneticsClearTypeAfterRequest) {
        [_MagneticsArray removeAllObjects];
        [_MagneticControllersArray removeAllObjects];
        
        [_tableView reloadData];
    }
    
    //隐藏加载视图
    if (_refreshType & MagneticsRefreshTypeLoadingView) { //中心加载视图
        [_loadingView stopAnimating];
        [_loadingView removeFromSuperview];
    }
    if (_refreshType & MagneticsRefreshTypePullToRefresh) { //下拉刷新
       [_tableView.mj_header endRefreshing];
    }
    
    //显示错误提示视图
    if (_enableNetworkError) {
        if (error.code == MagneticErrorCodeFailed) { //数据错误
            [self.view showFailedError:self selector:@selector(touchErrorViewAction)];
        } else { //网络错误
            [self.view showNetworkError:self selector:@selector(touchErrorViewAction)];
        }
    }
}



#pragma mark Magnetic Data

//请求独立数据源
- (void)fetchIndependentMagneticDataWhenRequestMagnetics{
    [self.MagneticControllersArray enumerateObjectsUsingBlock:^(MagneticController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.MagneticContext.asyncLoad) {
            [self requestMagneticDataWithController:obj];
        }
    }];
}

//请求单卡片数据
- (void)requestMagneticDataWithController:(MagneticController *)MagneticController
{
    __weak typeof(self) weakSelf = self;
    NSString *type = @"get";
    if ([MagneticController respondsToSelector:@selector(MagneticRequestTypeInMagneticsController:)]) {
        type = [MagneticController MagneticRequestTypeInMagneticsController:self];
    }
    NSString *url = nil;
    if ([MagneticController respondsToSelector:@selector(MagneticRequestURLInMagneticsController:)]) {
        url = [MagneticController MagneticRequestURLInMagneticsController:self];
    }
    NSDictionary *param = nil;
    if ([MagneticController respondsToSelector:@selector(MagneticRequestParametersInMagneticsController:)]) {
        param = [MagneticController MagneticRequestParametersInMagneticsController:self];
    }

    Class modelClass = nil;
    if ([MagneticController respondsToSelector:@selector(MagneticRequestParserModelClassInMagneticsController:)]) {
        modelClass = [MagneticController MagneticRequestParserModelClassInMagneticsController:self];
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
                MagneticController.MagneticContext.json = model;
                MagneticController.MagneticContext.MagneticInfo = responseObject[@"data"];
                [weakSelf MagneticSeparateDataBeReady:MagneticController.MagneticContext];
            }
            else {
                NSError *MagneticError = [NSError errorWithDomain:@"MagneticError" code:MagneticErrorCodeFailed userInfo:nil];
                [weakSelf MagneticSeparateDataUnavailable:MagneticController.MagneticContext error:MagneticError];
            }

        } failure:^(NSError *error) {
            NSError *MagneticError = [NSError errorWithDomain:@"MagneticError" code:MagneticErrorCodeNetwork userInfo:nil];
            [weakSelf MagneticSeparateDataUnavailable:MagneticController.MagneticContext error:MagneticError];
        }];
    }
    else {
        [self.httpManager requestPost:url parameters:param success:^(id responseObject) {
            if ([responseObject isKindOfClass:[NSDictionary class]]
                && [responseObject[@"error"] integerValue] == 0
                && responseObject[@"data"]) {
                id model = [[modelClass alloc] initWithDictionary:responseObject[@"data"] error:nil];
                MagneticController.MagneticContext.json = model;
                MagneticController.MagneticContext.MagneticInfo = responseObject[@"data"];
                [weakSelf MagneticSeparateDataBeReady:MagneticController.MagneticContext];
            }
            else {
                NSError *MagneticError = [NSError errorWithDomain:@"MagneticError" code:MagneticErrorCodeFailed userInfo:nil];
                [weakSelf MagneticSeparateDataUnavailable:MagneticController.MagneticContext error:MagneticError];
            }

        } failure:^(NSError *error) {
            NSError *MagneticError = [NSError errorWithDomain:@"MagneticError" code:MagneticErrorCodeNetwork userInfo:nil];
            [weakSelf MagneticSeparateDataUnavailable:MagneticController.MagneticContext error:MagneticError];
        }];
    }
}

//单卡片请求成功回调
- (void)MagneticSeparateDataBeReady:(MagneticContext *)MagneticContext
{
    NSUInteger MagneticIndex = [_MagneticsArray indexOfObject:MagneticContext];
    if (MagneticIndex != NSNotFound && MagneticIndex < _MagneticControllersArray.count) {
        [self requestMagneticDataDidSucceedWithMagneticContext:MagneticContext];
    }
}

//单卡片请求失败回调
- (void)MagneticSeparateDataUnavailable:(MagneticContext *)MagneticContext error:(NSError *)error{
    NSUInteger MagneticIndex = [_MagneticsArray indexOfObject:MagneticContext];
    if (MagneticIndex != NSNotFound && MagneticIndex < _MagneticControllersArray.count) {
        [self requestMagneticDataDidFailWithMagneticContext:MagneticContext error:error];
    }
}

//卡片数据请求成功
- (void)requestMagneticDataDidSucceedWithMagneticContext:(MagneticContext *)MagneticContext
{
    MagneticContext.error = nil;
    
    NSUInteger index = [_MagneticsArray indexOfObject:MagneticContext];
    MagneticController *MagneticController = [self MagneticControllerAtIndex:index];
    if ([MagneticController respondsToSelector:@selector(MagneticRequestDidFinishInMagneticsController:)]) {
        [MagneticController MagneticRequestDidFinishInMagneticsController:self];
    }
    [_tableView reloadSection:index];
}

//卡片数据请求失败
- (void)requestMagneticDataDidFailWithMagneticContext:(MagneticContext *)MagneticContext error:(NSError *)error
{
    NSUInteger index = [_MagneticsArray indexOfObject:MagneticContext];
    MagneticController *MagneticController = [self MagneticControllerAtIndex:index];
    if (MagneticController) {
        if ([error.domain isEqualToString:@"MagneticError"]) {
            MagneticContext.error = error;
        } else {
            MagneticContext.error = [NSError errorWithDomain:@"MagneticError" code:MagneticErrorCodeNetwork userInfo:nil];
        }
        
        if ([MagneticController respondsToSelector:@selector(MagneticRequestDidFinishInMagneticsController:)]) {
            [MagneticController MagneticRequestDidFinishInMagneticsController:self];
        }

        if ([MagneticController respondsToSelector:@selector(MagneticsController:shouldIgnoreMagneticErrorWithCode:)]) {
            if ([MagneticController MagneticsController:self shouldIgnoreMagneticErrorWithCode:MagneticContext.error.code]) {
                MagneticContext.error = nil; //忽略当前类型错误
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
    for (int i = 0; i < _MagneticControllersArray.count; i++) {
        MagneticController *MagneticController = _MagneticControllersArray[i];
        if (MagneticController.canRequestMoreData && [MagneticController respondsToSelector:@selector(didTriggerRequestMoreDataActionInMagneticsController:)]) {
            [MagneticController didTriggerRequestMoreDataActionInMagneticsController:self];
        }
    }
}

//加载更多卡片
- (void)requestMoreMagneticsDidSucceedWithMagneticsArray:(NSArray *)MagneticsArray
{
    if (!MagneticsArray.count) return;
    
    //记录参数
    NSMutableArray *sections = [NSMutableArray array]; //新增卡片对应的sections
    NSInteger startSection = _MagneticsArray.count;
    //解析数据源
    NSArray *MagneticControllersArray = [self parseMagneticControllersWithMagneticsArray:MagneticsArray];
    //更新数据源
    [_MagneticControllersArray addObjectsFromArray:MagneticControllersArray];
    [_MagneticsArray addObjectsFromArray:MagneticsArray];

    //执行卡片初始化监听（可能调用了UI刷新和数据请求，需在_MagneticsArray和_MagneticControllersArray赋值后调用）
    for (int i = 0; i < MagneticControllersArray.count; i++) {
        MagneticController *MagneticController = MagneticControllersArray[i];
        [self requestMagneticDataWithController:MagneticController];
        if ([MagneticController respondsToSelector:@selector(MagneticRequestDidFinishInMagneticsController:)]) {
            [MagneticController MagneticRequestDidFinishInMagneticsController:self];
        }
        if ([MagneticController respondsToSelector:@selector(didFinishInitConfigurationInMagneticsController:)]) {
            [MagneticController didFinishInitConfigurationInMagneticsController:self];
        }
        if ([MagneticController.extensionController respondsToSelector:@selector(didFinishInitConfigurationInMagneticsController:)]) {
            [MagneticController.extensionController didFinishInitConfigurationInMagneticsController:self];
        }
        [sections addObject:@(startSection + i)];
    }
    //刷新视图
    [_tableView reloadSections:sections];
}

- (void)requestMoreMagneticsDidFailWithError:(NSError *)error
{
    
}

#pragma mark - MagneticControllerDelegate

- (void)addSectionWithType:(MagneticType)MagneticType
           withMagneticContext:(MagneticContext *)MagneticContext
        withMagneticController:(MagneticController *)MagneticController
                 withIndex:(NSUInteger)index
             withAnimation:(UITableViewRowAnimation)animation{
    NSMutableIndexSet *sections = [NSMutableIndexSet indexSet];
    [self.MagneticsArray insertObject:MagneticContext atIndex:index];
    [self.MagneticControllersArray insertObject:MagneticController atIndex:index];
    //计算需要操作的section
    for (NSUInteger i = 0; i < self.MagneticControllersArray.count; i++) {
        MagneticController *MagneticController = self.MagneticControllersArray[i];
        if (MagneticController.MagneticContext.type == MagneticType) {
            [sections addIndex:i];
        }
    }
    [self.tableView insertSections:sections withRowAnimation:animation];
}

- (void)deleteSectionWithType:(MagneticType)MagneticType
                    withIndex:(NSUInteger)index
                withAnimation:(UITableViewRowAnimation)animation{
    NSMutableIndexSet *sections = [NSMutableIndexSet indexSet];
    //计算需要操作的section
    for (NSUInteger i = 0; i < self.MagneticControllersArray.count; i++) {
        MagneticController *MagneticController = self.MagneticControllersArray[i];
        if (MagneticController.MagneticContext.type == MagneticType) {
            [sections addIndex:i];
        }
    }
    [self.MagneticsArray removeObjectAtIndex:index];
    [self.MagneticControllersArray removeObjectAtIndex:index];
    [self.tableView deleteSections:sections withRowAnimation:animation];
    
}

//刷新指定类型的卡片
- (void)refreshMagneticWithType:(MagneticType)type animation:(UITableViewRowAnimation)animation
{
    if (animation != UITableViewRowAnimationNone) {
        NSMutableIndexSet *sections = [NSMutableIndexSet indexSet];
        for (NSUInteger i = 0; i < _MagneticControllersArray.count; i++) {
            MagneticController *MagneticController = _MagneticControllersArray[i];
            if (MagneticController.MagneticContext.type == type) {
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
        for (int i = 0; i < _MagneticControllersArray.count; i++) {
            MagneticController *MagneticController = _MagneticControllersArray[i];
            if (MagneticController.MagneticContext.type == type) {
                [sections addObject:@(i)];
            
            }
        }
        
        if (sections.count > 0) {
            [_tableView reloadSections:sections];
        }
    }
}

//刷新指定类型的卡片
- (void)refreshMagneticWithType:(MagneticType)type
{
    [self refreshMagneticWithType:type animation:UITableViewRowAnimationNone];
}
//刷新指定卡片的数据源
- (void)refreshMagneticWithType:(MagneticType)type json:(id)json {
    NSMutableArray *sections = [NSMutableArray array];
    for (int i = 0; i < _MagneticControllersArray.count; i++) {
        MagneticController *MagneticController = _MagneticControllersArray[i];
        if (MagneticController.MagneticContext.type == type) {
            [sections addObject:@(i)];
            MagneticController.MagneticContext.json = json;
            if (MagneticTypeHomeDynamicWeb !=MagneticController.MagneticContext.type ) {
                if ([MagneticController respondsToSelector:@selector(didFinishInitConfigurationInMagneticsController:)]) {
                    [MagneticController didFinishInitConfigurationInMagneticsController:self];
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
        MagneticController *MagneticController = [self MagneticControllerAtIndex:indexPath.section];
        
        if ([MagneticController respondsToSelector:@selector(MagneticsController:scrollViewWillBeginDraggingForCell:)]) {
            [MagneticController MagneticsController:self scrollViewWillBeginDraggingForCell:visibleCell];
        }
    }
}


#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(MagneticTableView *)tableView
{
    return _MagneticControllersArray.count;
}

- (CGFloat)tableView:(MagneticTableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    MagneticController *MagneticController = [self MagneticControllerAtIndex:section];
    CGFloat headerHeight = 0.0;
    if ([MagneticController respondsToSelector:@selector(MagneticsController:heightForSuspendHeaderInTableView:)]) {
        headerHeight = [MagneticController MagneticsController:self heightForSuspendHeaderInTableView:tableView];
    }
    return headerHeight;
}

- (UIView *)tableView:(MagneticTableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    MagneticController *MagneticController = [self MagneticControllerAtIndex:section];
    
    UIView *headerView = nil;
    if ([MagneticController respondsToSelector:@selector(MagneticsController:viewForSuspendHeaderInTableView:)]) {
        headerView = [MagneticController MagneticsController:self viewForSuspendHeaderInTableView:tableView];
    }
    return headerView;
}

- (NSInteger)tableView:(MagneticTableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    MagneticController *MagneticController = [self MagneticControllerAtIndex:section];
    return MagneticController.rowCountCache;
}

- (CGFloat)tableView:(MagneticTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MagneticController *MagneticController = [self MagneticControllerAtIndex:indexPath.section];
    return (indexPath.row < MagneticController.rowHeightsCache.count) ? ceil([MagneticController.rowHeightsCache[indexPath.row] floatValue]) : 0.0;
}

- (UITableViewCell *)tableView:(MagneticTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MagneticController *MagneticController = [self MagneticControllerAtIndex:indexPath.section];
    //布局参数
    BOOL isMagneticSpacing = [self isMagneticSpacing:MagneticController atIndexPath:indexPath]; //卡片间距
    BOOL isMagneticHeader = [self isMagneticHeader:MagneticController atIndexPath:indexPath]; //头部视图
    BOOL isMagneticFooter = [self isMagneticFooter:MagneticController atIndexPath:indexPath]; //尾部视图

    //复用参数
    Class class = nil;
    NSString *identifier = nil;
    if (isMagneticSpacing) { //卡片间距
        class = [UITableViewCell class];
        identifier = @"MagneticSpacingCell";
    } else if (isMagneticHeader) { //头部视图
        if ([MagneticController respondsToSelector:@selector(MagneticsController:cellClassForMagneticHeaderInTableView:)]) {
            class = [MagneticController MagneticsController:self cellClassForMagneticHeaderInTableView:tableView];
        }
        if ([MagneticController respondsToSelector:@selector(MagneticsController:cellIdentifierForMagneticHeaderInTableView:)]) {
            identifier = [MagneticController MagneticsController:self cellIdentifierForMagneticHeaderInTableView:tableView];
        }
    } else if (isMagneticFooter) { //尾部视图
        if ([MagneticController respondsToSelector:@selector(MagneticsController:cellClassForMagneticFooterInTableView:)]) {
            class = [MagneticController MagneticsController:self cellClassForMagneticFooterInTableView:tableView];
        }
        if ([MagneticController respondsToSelector:@selector(MagneticsController:cellIdentifierForMagneticFooterInTableView:)]) {
            identifier = [MagneticController MagneticsController:self cellIdentifierForMagneticFooterInTableView:tableView];
        }
    } else {
        if (MagneticController.showMagneticError) { //错误卡片
            class = [MagneticErrorCell class];
            identifier = NSStringFromClass(class);
        } else { //数据源
            if (indexPath.row < MagneticController.extensionRowIndex) { //卡片内容
                NSInteger rowIndex = MagneticController.showMagneticHeader ? indexPath.row - 1 : indexPath.row; //数据源对应的index
                if ([MagneticController respondsToSelector:@selector(MagneticsController:cellClassForMagneticContentAtIndex:)]) {
                    class = [MagneticController MagneticsController:self cellClassForMagneticContentAtIndex:rowIndex];
                }
                if ([MagneticController respondsToSelector:@selector(MagneticsController:cellIdentifierForMagneticContentAtIndex:)]) {
                    identifier = [MagneticController MagneticsController:self cellIdentifierForMagneticContentAtIndex:rowIndex];
                }
            } else { //卡片扩展
                NSInteger rowIndex = indexPath.row - MagneticController.extensionRowIndex; //数据源对应的index
                if ([MagneticController.extensionController respondsToSelector:@selector(MagneticsController:cellClassForMagneticContentAtIndex:)]) {
                    class = [MagneticController.extensionController MagneticsController:self cellClassForMagneticContentAtIndex:rowIndex];
                }
                if ([MagneticController.extensionController respondsToSelector:@selector(MagneticsController:cellIdentifierForMagneticContentAtIndex:)]) {
                    identifier = [MagneticController.extensionController MagneticsController:self cellIdentifierForMagneticContentAtIndex:rowIndex];
                }
            }
        }
    }
    
    if (!class) {
        class = [UITableViewCell class];
    }
    if (!identifier.length) {
        identifier = [NSString stringWithFormat:@"%@_%ld", NSStringFromClass(class), (long)MagneticController.MagneticContext.type]; //同类卡片内部复用cell
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[class alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.clipsToBounds = YES;
        cell.exclusiveTouch = YES;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
       
        if ([MagneticController respondsToSelector:@selector(MagneticsController:colorForMagneticBackgroundInTableView:)]) {
            cell.backgroundColor = [MagneticController MagneticsController:self colorForMagneticBackgroundInTableView:tableView];
            cell.contentView.backgroundColor = [MagneticController MagneticsController:self colorForMagneticBackgroundInTableView:tableView];

        }else{
            cell.backgroundColor = [UIColor whiteColor];
            cell.contentView.backgroundColor = [UIColor whiteColor];
        }
    }
    
    if (isMagneticSpacing) { //卡片间距
        UIColor *backgroundColor = [UIColor clearColor];
        if ([MagneticController respondsToSelector:@selector(MagneticsController:colorForMagneticSpacingInTableView:)]) {
            backgroundColor = [MagneticController MagneticsController:self colorForMagneticSpacingInTableView:tableView];
        }
        cell.backgroundColor = backgroundColor;
        cell.contentView.backgroundColor = backgroundColor;
        if ([MagneticController respondsToSelector:@selector(MagneticsController:reuseCell:forMagneticSpaingInTableView:)]) {
            [MagneticController MagneticsController:self reuseCell:cell forMagneticSpaingInTableView:tableView];
        }
    } else if (isMagneticHeader) { //头部视图
        [MagneticController MagneticsController:self reuseCell:cell forMagneticHeaderInTableView:tableView];
    } else if (isMagneticFooter) { //尾部视图
        [MagneticController MagneticsController:self reuseCell:cell forMagneticFooterInTableView:tableView];
    } else { //数据源
        if (MagneticController.showMagneticError) { //错误卡片
            MagneticErrorCell *MagneticErrorCell = (MagneticErrorCell *)cell;
            MagneticErrorCell.MagneticController = MagneticController;
            [MagneticErrorCell refreshMagneticErrorView];
        } else {
            if (indexPath.row < MagneticController.extensionRowIndex) { //卡片内容
                NSInteger rowIndex = MagneticController.showMagneticHeader ? indexPath.row - 1 : indexPath.row; //数据源对应的index
                [MagneticController MagneticsController:self reuseCell:cell forMagneticContentAtIndex:rowIndex];
            } else { //卡片扩展
                NSInteger rowIndex = indexPath.row - MagneticController.extensionRowIndex; //数据源对应的index
                [MagneticController.extensionController MagneticsController:self reuseCell:cell forMagneticContentAtIndex:rowIndex];
            }
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    MagneticController *MagneticController = [self MagneticControllerAtIndex:indexPath.section];
    
    //布局参数
    BOOL isMagneticSpacing = [self isMagneticSpacing:MagneticController atIndexPath:indexPath]; //卡片间距
    BOOL isMagneticHeader = [self isMagneticHeader:MagneticController atIndexPath:indexPath]; //头部视图
    BOOL isMagneticFooter = [self isMagneticFooter:MagneticController atIndexPath:indexPath]; //尾部视图
    
    //卡片回调
    if (!isMagneticSpacing && !isMagneticHeader && !isMagneticFooter && !MagneticController.showMagneticError) { //数据源
        if (indexPath.row < MagneticController.extensionRowIndex) { //卡片内容
            if ([MagneticController respondsToSelector:@selector(MagneticsController:willDisplayCell:forMagneticContentAtIndex:)]) {
                NSInteger rowIndex = MagneticController.showMagneticHeader ? indexPath.row - 1 : indexPath.row; //数据源对应的index
                [MagneticController MagneticsController:self willDisplayCell:cell forMagneticContentAtIndex:rowIndex];
            }
        } else { //卡片扩展
            if ([MagneticController.extensionController respondsToSelector:@selector(MagneticsController:willDisplayCell:forMagneticContentAtIndex:)]) {
                NSInteger rowIndex = indexPath.row - MagneticController.extensionRowIndex; //数据源对应的index
                [MagneticController.extensionController MagneticsController:self willDisplayCell:cell forMagneticContentAtIndex:rowIndex];
            }
        }
    } else if (isMagneticHeader) {
        if ([MagneticController respondsToSelector:@selector(MagneticsController:willDisplayingHeaderCell:)]) {
            [MagneticController MagneticsController:self willDisplayingHeaderCell:cell];
        }
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    MagneticController *MagneticController = [self MagneticControllerAtIndex:indexPath.section];
    
    //布局参数
    BOOL isMagneticSpacing = [self isMagneticSpacing:MagneticController atIndexPath:indexPath]; //卡片间距
    BOOL isMagneticHeader = [self isMagneticHeader:MagneticController atIndexPath:indexPath]; //头部视图
    BOOL isMagneticFooter = [self isMagneticFooter:MagneticController atIndexPath:indexPath]; //尾部视图
    
    //卡片回调
    if (!isMagneticSpacing && !isMagneticHeader && !isMagneticFooter && !MagneticController.showMagneticError) { //数据源
        if (indexPath.row < MagneticController.extensionRowIndex) { //卡片内容
            if ([MagneticController respondsToSelector:@selector(MagneticsController:didEndDisplayingCell:forMagneticContentAtIndex:)]) {
                NSInteger rowIndex = MagneticController.showMagneticHeader ? indexPath.row - 1 : indexPath.row; //数据源对应的index
                [MagneticController MagneticsController:self didEndDisplayingCell:cell forMagneticContentAtIndex:rowIndex];
            }
        } else { //卡片扩展
            if ([MagneticController.extensionController respondsToSelector:@selector(MagneticsController:didEndDisplayingCell:forMagneticContentAtIndex:)]) {
                NSInteger rowIndex = indexPath.row - MagneticController.extensionRowIndex; //数据源对应的index
                [MagneticController.extensionController MagneticsController:self didEndDisplayingCell:cell forMagneticContentAtIndex:rowIndex];
            }
        }
    }else if (isMagneticHeader){
        
        if ([MagneticController respondsToSelector:@selector(MagneticsController:didEndDisplayingHeaderCell:)]) {
            [MagneticController MagneticsController:self didEndDisplayingHeaderCell:cell];
        }
    }
}

- (void)tableView:(MagneticTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MagneticController *MagneticController = [self MagneticControllerAtIndex:indexPath.section];
    
    //布局参数
    BOOL isMagneticSpacing = [self isMagneticSpacing:MagneticController atIndexPath:indexPath]; //卡片间距
    BOOL isMagneticHeader = [self isMagneticHeader:MagneticController atIndexPath:indexPath]; //头部视图
    BOOL isMagneticFooter = [self isMagneticFooter:MagneticController atIndexPath:indexPath]; //尾部视图
    
    //点击事件
    if (isMagneticSpacing) { //卡片间距
        //无效点击
    } else if (isMagneticHeader) { //头部视图
        if ([MagneticController respondsToSelector:@selector(MagneticsController:didSelectMagneticHeaderInTableView:)]) {
            [MagneticController MagneticsController:self didSelectMagneticHeaderInTableView:tableView];
        }
    } else if (isMagneticFooter) { //尾部视图
        if ([MagneticController respondsToSelector:@selector(MagneticsController:didSelectMagneticFooterInTableView:)]) {
            [MagneticController MagneticsController:self didSelectMagneticFooterInTableView:tableView];
        }
    } else { //数据源
        if (MagneticController.showMagneticError) { //错误卡片
            //无效点击
        } else {
            if (indexPath.row < MagneticController.extensionRowIndex) { //卡片内容
                if ([MagneticController respondsToSelector:@selector(MagneticsController:didSelectMagneticContentAtIndex:)]) {
                    NSInteger rowIndex = MagneticController.showMagneticHeader ? indexPath.row - 1 : indexPath.row; //数据源对应的index
                    [MagneticController MagneticsController:self didSelectMagneticContentAtIndex:rowIndex];
                }
            } else { //卡片扩展
                if ([MagneticController.extensionController respondsToSelector:@selector(MagneticsController:didSelectMagneticContentAtIndex:)]) {
                    NSInteger rowIndex = indexPath.row - MagneticController.extensionRowIndex; //数据源对应的index
                    [MagneticController.extensionController MagneticsController:self didSelectMagneticContentAtIndex:rowIndex];
                }
            }
        }
    }
}

@end


@implementation MagneticsController (BottomPrivate)

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
        || !_MagneticControllersArray.count) { //无数据源

        if (_tableView.tableFooterView.tag == kTagTableBottomView) {
            _tableView.tableFooterView = nil;
        }
        return;
    }

    if (_refreshType & MagneticsRefreshTypeInfiniteScrolling) { //显示加载更多控件，移除封底
        _tableView.tableFooterView = nil;
    } else { //显示封底
        if (_tableBottomCustomView) { //自定义封底
            _tableView.tableFooterView = _tableBottomCustomView;
        } else { //默认封底
            if (![_tableView.tableFooterView isKindOfClass:[MagneticTableFooterView class]]) {
                _tableView.tableFooterView = [[MagneticTableFooterView alloc] initWithFrame:CGRectMake(0, 0, _tableView.e_width, 50)];
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
    MagneticsRefreshType refreshType = self.refreshType & (MagneticsRefreshTypePullToRefresh | MagneticsRefreshTypeLoadingView);
    self.refreshType = refreshType;
}

@end
