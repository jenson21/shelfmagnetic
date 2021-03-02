//
//  MagneticsController.m
//  ShelfMagnetic
//
//  Created by Jenson on 2020/5/31.
//  Copyright © 2020 Jenson. All rights reserved.
//

#import "MagneticsController.h"
#import "NSObject+Runtime.h"
#import "MagneticTableFooterView.h"
#import "JEBaseLoadingView.h"
#import "MagneticsMoreFooterView.h"
#import "JEHttpManager.h"

#define kTagTableBottomView     3527    //磁片封底视图标记

//磁片父控制器将显示通知
NSString * const kMagneticsSuperViewWillAppearNotification = @"MagneticsSuperViewWillAppearNotification";
//磁片父控制器已消失通知
NSString * const kMagneticsSuperViewDidDisappearNotification = @"MagneticsSuperViewDidDisappearNotification";

@interface MagneticsController ()

@property (nonatomic) JEBaseLoadingView *loadingView;
/* Request */
@property (nonatomic) MagneticsRefreshType refreshType;    //磁片列表刷新方式
@property (nonatomic) MagneticsClearType clearType;        //磁片数据清除方式
@property (nonatomic, assign) BOOL enableNetworkError;     //使用默认错误提示

/* Bottom */
@property (nonatomic, assign) BOOL enableTableBottomView;  //显示表视图封底
@property (nonatomic) UIView *tableBottomCustomView;       //封底自定义视图
@property (nonatomic) UIRefreshControl *refreshControl;    //刷新
//@property (nonatomic) UIControl *moreControl;       //更多

@end

@implementation MagneticsController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _magneticsArray = [[NSMutableArray alloc] init];
        _magneticControllersArray = [[NSMutableArray alloc] init];
        _enableNetworkError = YES;
    }
    return self;
}

- (void)loadView{
    [super loadView];
    
    [self.view addSubview:self.tableView];
    self.view.clipsToBounds = YES;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    //下拉刷新
    if (_refreshType & MagneticsRefreshTypePullToRefresh) {
        self.tableView.refreshControl = self.refreshControl;
    }
    
    //上拉加载更多
//    if ((_refreshType & MagneticsRefreshTypeInfiniteScrolling) && !_tableView.tableFooterView) {
//        self.tableView.tableFooterView = self.moreControl;
//    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (!self.superViewController) {
        [self receiveMagneticsSuperViewWillAppearNotification:nil];
    }
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if (!self.superViewController) {
        [self receiveMagneticsSuperViewDidDisappearNotification:nil];
    }
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    _tableView.delegate = nil;
    _tableView.dataSource = nil;

    [_tableView.refreshControl endRefreshing];
//    [self.moreControl endRefreshing];
}



#pragma mark - Property

- (void)setRefreshType:(MagneticsRefreshType)refreshType{
    if (_refreshType != refreshType) {
        _refreshType = refreshType;
        //下拉刷新
        if (refreshType & MagneticsRefreshTypePullToRefresh) {
            if (!self.tableView.refreshControl && self.isViewLoaded) { //下拉刷新控件依赖于表视图的加载
                self.tableView.refreshControl = self.refreshControl;
            } else {
                [self.tableView.refreshControl endRefreshing];
            }

            //上拉加载更多
//            if (refreshType & MagneticsRefreshTypeInfiniteScrolling) {
//                if (!self.tableView.tableFooterView && self.isViewLoaded) { //上拉刷新控件依赖于表视图的加载
//                    _tableView.tableFooterView = self.moreControl;
//                }
//            } else {
//                [self.moreControl endRefreshing];
//            }
        }
    }
}

- (void)setSuperViewController:(UIViewController *)superViewController{
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
                SEL swizzleSelector = @selector(magnetics_viewWillAppear:);
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
                
                swizzleSelector = @selector(magnetics_viewDidDisappear:);
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

- (void)magnetics_viewWillAppear:(BOOL)animated{
    [self magnetics_viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kMagneticsSuperViewWillAppearNotification
                                                        object:self
                                                      userInfo:nil];
}

- (void)magnetics_viewDidDisappear:(BOOL)animated{
    [self magnetics_viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kMagneticsSuperViewDidDisappearNotification
                                                        object:self
                                                      userInfo:nil];
}



#pragma mark - Notification

//接收到父控制器将显示通知
- (void)receiveMagneticsSuperViewWillAppearNotification:(NSNotification *)notification{
    for (int i = 0; i < _magneticControllersArray.count; i++) {
        MagneticController *magneticController = _magneticControllersArray[i];
        if ([magneticController respondsToSelector:@selector(magneticsController:superViewWillAppear:)]) {
            [magneticController magneticsController:self superViewWillAppear:_superViewController];
        }
    }
}

//接收到父控制器已隐藏通知
- (void)receiveMagneticsSuperViewDidDisappearNotification:(NSNotification *)notification{
    for (int i = 0; i < _magneticControllersArray.count; i++) {
        MagneticController *magneticController = _magneticControllersArray[i];
        if ([magneticController respondsToSelector:@selector(magneticsController:superViewDidDisappear:)]) {
            [magneticController magneticsController:self superViewDidDisappear:_superViewController];
        }
    }
}



#pragma mark - Error View

//默认点击提示信息事件
- (void)touchErrorViewAction{
    if (_refreshType & MagneticsRefreshTypeLoadingView) {
        [self requestMagnetics];
    } else if (_refreshType & MagneticsRefreshTypePullToRefresh) {
        if (_enableNetworkError) {
            [self.view hideErrorView];
        }
        [_tableView.refreshControl beginRefreshing];
    } else {
        [self requestMagnetics];
    }
}

#pragma mark - Private Methods

//获取index对应的磁片控制器
- (MagneticController *)magneticControllerAtIndex:(NSInteger)index{
    return (index < _magneticControllersArray.count) ? _magneticControllersArray[index] : nil;
}

//是否为磁片间距
- (BOOL)isMagneticSpacing:(MagneticController *)magneticController atIndexPath:(NSIndexPath *)indexPath{
    return (magneticController.showMagneticSpacing && indexPath && indexPath.row == magneticController.rowCountCache - 1);
}

//是否为磁片头部
- (BOOL)isMagneticHeader:(MagneticController *)magneticController atIndexPath:(NSIndexPath *)indexPath{
    return (magneticController.showMagneticHeader && indexPath && indexPath.row == 0);
}

//是否为磁片尾部
- (BOOL)isMagneticFooter:(MagneticController *)magneticController atIndexPath:(NSIndexPath *)indexPath{
    BOOL isMagneticFooter = NO;
    if (magneticController.showMagneticFooter && indexPath) {
        if (magneticController.showMagneticSpacing && indexPath.row == magneticController.rowCountCache - 2) {
            isMagneticFooter = YES;
        }
        if (!magneticController.showMagneticSpacing && indexPath.row == magneticController.rowCountCache - 1) {
            isMagneticFooter = YES;
        }
    }
    return isMagneticFooter;
}

//是否为有效磁片内容
- (BOOL)isValidMagneticContent:(MagneticController *)magneticController atIndexPath:(NSIndexPath *)indexPath{
    if (!magneticController || !indexPath) return NO;
    
    if ([self isMagneticSpacing:magneticController atIndexPath:indexPath]) return NO; //磁片间距
    if ([self isMagneticHeader:magneticController atIndexPath:indexPath]) return NO; //头部视图
    if ([self isMagneticFooter:magneticController atIndexPath:indexPath]) return NO; //尾部视图
    if (magneticController.showMagneticError) return NO; //错误磁片
    
    return YES;
}



#pragma mark - Public Methods

//获取指定类型的磁片控制器
- (NSArray *)queryMagneticControllersWithType:(MagneticType)type{
    NSMutableArray *magneticControllersArray = nil;
    for (int i = 0; i < _magneticControllersArray.count; i++) {
        MagneticController *magneticController = _magneticControllersArray[i];
        if (magneticController.magneticContext.type == type) {
            if (!magneticControllersArray) {
                magneticControllersArray = [NSMutableArray array];
            }
            [magneticControllersArray addObject:magneticController];
        }
    }
    return magneticControllersArray;
}

- (void)scrollToMagneticType:(MagneticType)type animated:(BOOL)animated {
    int i = 0;
    for (i = 0; i < _magneticControllersArray.count; i++) {
        MagneticController *magneticController = _magneticControllersArray[i];
        if (magneticController.magneticContext.type == type) {
            break;
        }
    }
    if (i < _magneticControllersArray.count) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:i] atScrollPosition:UITableViewScrollPositionTop animated:animated];
    }
}

#pragma mark - Request

#pragma mark Parser

//解析磁片数据源，创建磁片控制器
- (NSArray *)parseMagneticControllersWithMagneticsArray:(NSArray *)MagneticsArray{
    NSMutableArray *magneticControllersArray = [NSMutableArray array];
    for (MagneticContext *magneticContext in MagneticsArray) {
        //初始化磁片控制器
        Class class = NSClassFromString(magneticContext.clazz);
        if (![class isSubclassOfClass:[MagneticController class]]) {
            class = [MagneticController class];
        }
        
        MagneticController *magneticController = [[class alloc] init];
        magneticController.delegate = self;
        magneticController.magneticsController = self;
        magneticController.magneticContext = magneticContext;
        [magneticControllersArray addObject:magneticController];
        
        //初始化扩展控制器
        Class extensionClass = NSClassFromString(magneticContext.extensionClazz);
        if ([extensionClass isSubclassOfClass:[MagneticController class]]) {
            MagneticController *extensionController = [[extensionClass alloc] init];
            extensionController.delegate = self;
            extensionController.magneticsController = self;
            extensionController.magneticContext = magneticContext;
            extensionController.isExtension = YES;
            magneticController.extensionController = extensionController;
        }
    }
    return magneticControllersArray;
}

#pragma mark Magnetics

//请求磁片列表
- (void)requestMagnetics{
    [self requestMagneticsWillStart];
}

//磁片列表请求将开始
- (void)requestMagneticsWillStart{
    //清空数据源
    if (_clearType == MagneticsClearTypeBeforeRequest) { //请求前清除数据源
        
        if (_magneticControllersArray.count > 0) {
            [_magneticsArray removeAllObjects];
            [_magneticControllersArray removeAllObjects];
            
            [_tableView reloadData];
        }
    }
    
    //隐藏错误提示
    [self.view hideErrorView];
    
    //显示加载视图
    if (_refreshType & MagneticsRefreshTypeLoadingView && !_magneticControllersArray.count) {
        if (!_loadingView) {
            _loadingView = [[JEBaseLoadingView alloc] initWithFrame:CGRectMake(0.0, 0.0, 100.0, 100.0)]; //给定足够大的尺寸
        }

        //居中显示
        CGFloat hHeader = CGRectGetHeight(_tableView.tableHeaderView.frame);
        CGFloat hTable = CGRectGetHeight(_tableView.frame);
        CGFloat cY = (hTable - hHeader - _tableView.contentInset.top - _tableView.contentInset.bottom) / 2.0 + hHeader;
        _loadingView.center = CGPointMake(_tableView.frame.size.width / 2.0, cY);
;
        [_tableView addSubview:_loadingView];

        [_loadingView startAnimating];
    }
}

//磁片列表请求成功
- (void)requestMagneticsDidSucceedWithMagneticsArray:(NSArray *)MagneticsArray{
    if (_magneticsArray.count
        && MagneticsArray.count
        && [_magneticsArray isEqualToArray:MagneticsArray]) { //数据未变更
        
        if (_refreshType & MagneticsRefreshTypePullToRefresh) { //下拉刷新
            [_tableView.refreshControl endRefreshing];
        }
        return;
    }
    
    //清空缓存
    if (_clearType == MagneticsClearTypeAfterRequest) {
        //初始化监听可能调用了UI刷新和数据请求，若请求前没有清除数据源，需要保证回调前清空缓存
        [_magneticsArray removeAllObjects];
        [_magneticControllersArray removeAllObjects];
        [_tableView reloadData];
    }
    
    //解析数据源
    NSArray *magneticControllersArray = [self parseMagneticControllersWithMagneticsArray:MagneticsArray];
    
    //更新数据源
    _magneticControllersArray.array = magneticControllersArray;
    _magneticsArray.array = MagneticsArray;
    
    //执行磁片初始化监听（可能调用了UI刷新和数据请求，需在_magneticsArray和_magneticControllersArray赋值后调用）
    for (int i = 0; i < magneticControllersArray.count; i++) {
        MagneticController *magneticController = magneticControllersArray[i];
        magneticController.magneticContext.isChange = YES;
        if ([magneticController respondsToSelector:@selector(didFinishInitConfigurationInMagneticsController:)]) {
            [magneticController didFinishInitConfigurationInMagneticsController:self];
        }
        if ([magneticController.extensionController respondsToSelector:@selector(didFinishInitConfigurationInMagneticsController:)]) {
            [magneticController.extensionController didFinishInitConfigurationInMagneticsController:self];
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
        [_tableView.refreshControl endRefreshing];
    }
    
    [_tableView reloadData];


    //请求独立数据源
    [self fetchIndependentMagneticDataWhenRequestMagnetics];
}

//磁片列表请求失败
- (void)requestMagneticsDidFailWithError:(NSError *)error{
    //清空数据源
    if (_clearType == MagneticsClearTypeAfterRequest) {
        [_magneticsArray removeAllObjects];
        [_magneticControllersArray removeAllObjects];
        
        [_tableView reloadData];
    }
    
    //隐藏加载视图
    if (_refreshType & MagneticsRefreshTypeLoadingView) { //中心加载视图
        [_loadingView stopAnimating];
        [_loadingView removeFromSuperview];
    }
    if (_refreshType & MagneticsRefreshTypePullToRefresh) { //下拉刷新
       [_tableView.refreshControl endRefreshing];
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
    [self.magneticControllersArray enumerateObjectsUsingBlock:^(MagneticController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.magneticContext.asyncLoad) {
            [self requestMagneticDataWithController:obj];
        }
    }];
}

//请求单磁片数据
- (void)requestMagneticDataWithController:(MagneticController *)magneticController{
    __weak typeof(self) weakSelf = self;
    RequestType type = RequestTypeGet;
    if ([magneticController respondsToSelector:@selector(magneticRequestTypeInMagneticsController:)]) {
        type = [magneticController magneticRequestTypeInMagneticsController:self];
    }
    NSString *url = nil;
    if ([magneticController respondsToSelector:@selector(magneticRequestURLInMagneticsController:)]) {
        url = [magneticController magneticRequestURLInMagneticsController:self];
    }
    NSDictionary *param = nil;
    if ([magneticController respondsToSelector:@selector(magneticRequestParametersInMagneticsController:)]) {
        param = [magneticController magneticRequestParametersInMagneticsController:self];
    }

    Class modelClass = nil;
    if ([magneticController respondsToSelector:@selector(magneticRequestParserModelClassInMagneticsController:)]) {
        modelClass = [magneticController magneticRequestParserModelClassInMagneticsController:self];
    }
    if (!url || !modelClass) {
        return;
    }

    [JEHttpManager requestType:type requestUrl:url parameters:param success:^(id  _Nonnull responseObject) {
        magneticController.magneticContext.magneticInfo = responseObject;
        [weakSelf magneticSeparateDataBeReady:magneticController.magneticContext];
    } failure:^(id  _Nonnull error) {
        NSError *magneticError = [NSError errorWithDomain:@"MagneticError" code:MagneticErrorCodeNetwork userInfo:nil];
        [weakSelf magneticSeparateDataUnavailable:magneticController.magneticContext error:magneticError];
    }];
    
}

//单磁片请求成功回调
- (void)magneticSeparateDataBeReady:(MagneticContext *)magneticContext{
    NSUInteger MagneticIndex = [_magneticsArray indexOfObject:magneticContext];
    if (MagneticIndex != NSNotFound && MagneticIndex < _magneticControllersArray.count) {
        [self requestMagneticDataDidSucceedWithMagneticContext:magneticContext];
    }
}

//单磁片请求失败回调
- (void)magneticSeparateDataUnavailable:(MagneticContext *)magneticContext error:(NSError *)error{
    NSUInteger MagneticIndex = [_magneticsArray indexOfObject:magneticContext];
    if (MagneticIndex != NSNotFound && MagneticIndex < _magneticControllersArray.count) {
        [self requestMagneticDataDidFailWithMagneticContext:magneticContext error:error];
    }
}

//磁片数据请求成功
- (void)requestMagneticDataDidSucceedWithMagneticContext:(MagneticContext *)magneticContext{
    magneticContext.error = nil;
    
    NSUInteger index = [_magneticsArray indexOfObject:magneticContext];
    MagneticController *magneticController = [self magneticControllerAtIndex:index];
    if ([magneticController respondsToSelector:@selector(magneticRequestDidFinishInMagneticsController:)]) {
        [magneticController magneticRequestDidFinishInMagneticsController:self];
    }
    [_tableView reloadSection:index];
}

//磁片数据请求失败
- (void)requestMagneticDataDidFailWithMagneticContext:(MagneticContext *)magneticContext error:(NSError *)error{
    NSUInteger index = [_magneticsArray indexOfObject:magneticContext];
    MagneticController *magneticController = [self magneticControllerAtIndex:index];
    if (magneticController) {
        if ([error.domain isEqualToString:@"MagneticError"]) {
            magneticContext.error = error;
        } else {
            magneticContext.error = [NSError errorWithDomain:@"MagneticError" code:MagneticErrorCodeNetwork userInfo:nil];
        }
        
        if ([magneticController respondsToSelector:@selector(magneticRequestDidFinishInMagneticsController:)]) {
            [magneticController magneticRequestDidFinishInMagneticsController:self];
        }

        if ([magneticController respondsToSelector:@selector(magneticsController:shouldIgnoreMagneticErrorWithCode:)]) {
            if ([magneticController magneticsController:self shouldIgnoreMagneticErrorWithCode:magneticContext.error.code]) {
                magneticContext.error = nil; //忽略当前类型错误
            }
        }
        
        [_tableView reloadSection:index];
    }
}

#pragma mark Refresh
- (void)triggerRefreshAction {
    
}

#pragma mark More

//加载更多事件
- (void)requestMoreData{
    //触发加载更多事件
    for (int i = 0; i < _magneticControllersArray.count; i++) {
        MagneticController *magneticController = _magneticControllersArray[i];
        if (magneticController.canRequestMoreData && [magneticController respondsToSelector:@selector(didTriggerRequestMoreDataActionInMagneticsController:)]) {
            [magneticController didTriggerRequestMoreDataActionInMagneticsController:self];
        }
    }
}

//加载更多磁片
- (void)requestMoreMagneticsDidSucceedWithMagneticsArray:(NSArray *)MagneticsArray{
    if (!MagneticsArray.count) return;
    
    //记录参数
    NSMutableArray *sections = [NSMutableArray array]; //新增磁片对应的sections
    NSInteger startSection = _magneticsArray.count;
    
    //解析数据源
    NSArray *magneticControllersArray = [self parseMagneticControllersWithMagneticsArray:MagneticsArray];
    
    //更新数据源
    [_magneticControllersArray addObjectsFromArray:magneticControllersArray];
    [_magneticsArray addObjectsFromArray:MagneticsArray];
    
    //执行磁片初始化监听（可能调用了UI刷新和数据请求，需在_magneticsArray和_magneticControllersArray赋值后调用）
    for (int i = 0; i < magneticControllersArray.count; i++) {
        MagneticController *magneticController = magneticControllersArray[i];
        if ([magneticController respondsToSelector:@selector(didFinishInitConfigurationInMagneticsController:)]) {
            [magneticController didFinishInitConfigurationInMagneticsController:self];
        }
        if ([magneticController.extensionController respondsToSelector:@selector(didFinishInitConfigurationInMagneticsController:)]) {
            [magneticController.extensionController didFinishInitConfigurationInMagneticsController:self];
        }
        
        [sections addObject:@(startSection + i)];
    }
    
    //刷新视图
    [_tableView reloadSections:sections];
}

- (void)requestMoreMagneticsDidFailWithError:(NSError *)error{
    
}

#pragma mark - MagneticControllerDelegate

- (void)addSectionWithType:(MagneticType)MagneticType
           withMagneticContext:(MagneticContext *)MagneticContext
        withMagneticController:(MagneticController *)magneticController
                 withIndex:(NSUInteger)index
             withAnimation:(UITableViewRowAnimation)animation{
    NSMutableIndexSet *sections = [NSMutableIndexSet indexSet];
    [self.magneticsArray insertObject:MagneticContext atIndex:index];
    [self.magneticControllersArray insertObject:magneticController atIndex:index];
    //计算需要操作的section
    for (NSUInteger i = 0; i < self.magneticControllersArray.count; i++) {
        MagneticController *magneticController = self.magneticControllersArray[i];
        if (magneticController.magneticContext.type == MagneticType) {
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
    for (NSUInteger i = 0; i < self.magneticControllersArray.count; i++) {
        MagneticController *magneticController = self.magneticControllersArray[i];
        if (magneticController.magneticContext.type == MagneticType) {
            [sections addIndex:i];
        }
    }
    [self.magneticsArray removeObjectAtIndex:index];
    [self.magneticControllersArray removeObjectAtIndex:index];
    [self.tableView deleteSections:sections withRowAnimation:animation];
    
}

//刷新指定类型的磁片
- (void)refreshMagneticWithType:(MagneticType)type animation:(UITableViewRowAnimation)animation{
    if (animation != UITableViewRowAnimationNone) {
        NSMutableIndexSet *sections = [NSMutableIndexSet indexSet];
        for (NSUInteger i = 0; i < _magneticControllersArray.count; i++) {
            MagneticController *magneticController = _magneticControllersArray[i];
            if (magneticController.magneticContext.type == type) {
                
                if (magneticController.magneticContext.asyncLoad) {
                    [self requestMagneticDataWithController:magneticController];
                    return;
                }
                
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
        for (int i = 0; i < _magneticControllersArray.count; i++) {
            MagneticController *magneticController = _magneticControllersArray[i];
            if (magneticController.magneticContext.type == type) {
                
                if (magneticController.magneticContext.asyncLoad) {
                    [self requestMagneticDataWithController:magneticController];
                    return;
                }
                
                [sections addObject:@(i)];
            }
        }
        
        if (sections.count > 0) {
            [_tableView reloadSections:sections];
        }
    }
}

//刷新指定类型的磁片
- (void)refreshMagneticWithType:(MagneticType)type{
    [self refreshMagneticWithType:type animation:UITableViewRowAnimationNone];
}

- (void)refreshMagneticWithType:(MagneticType)type json:(id)json {
    NSMutableArray *sections = [NSMutableArray array];
    for (int i = 0; i < _magneticControllersArray.count; i++) {
        MagneticController *magneticController = _magneticControllersArray[i];
        if (magneticController.magneticContext.type == type) {
            [sections addObject:@(i)];
            magneticController.magneticContext.json = json;
            magneticController.magneticContext.isChange = YES;
            if ([magneticController respondsToSelector:@selector(didFinishInitConfigurationInMagneticsController:)]) {
                [magneticController didFinishInitConfigurationInMagneticsController:self];
            }
        }
    }
    
    if (sections.count > 0) {
        [_tableView reloadSections:sections];
    }
}



#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    NSArray *visibleCells = [self.tableView visibleCells];
    for (UITableViewCell *visibleCell in visibleCells) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:visibleCell];
        MagneticController *magneticController = [self magneticControllerAtIndex:indexPath.section];
        
        if ([magneticController respondsToSelector:@selector(magneticsController:scrollViewWillBeginDraggingForCell:)]) {
            [magneticController magneticsController:self scrollViewWillBeginDraggingForCell:visibleCell];
        }
    }
}


#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(MagneticTableView *)tableView{
    return _magneticControllersArray.count;
}

- (CGFloat)tableView:(MagneticTableView *)tableView heightForHeaderInSection:(NSInteger)section{
    MagneticController *magneticController = [self magneticControllerAtIndex:section];
    
    CGFloat headerHeight = 0.0;
    if ([magneticController respondsToSelector:@selector(magneticsController:heightForSuspendHeaderInTableView:)]) {
        headerHeight = [magneticController magneticsController:self heightForSuspendHeaderInTableView:tableView];
    }
    return headerHeight;
}

- (UIView *)tableView:(MagneticTableView *)tableView viewForHeaderInSection:(NSInteger)section{
    MagneticController *magneticController = [self magneticControllerAtIndex:section];
    
    UIView *headerView = nil;
    if ([magneticController respondsToSelector:@selector(magneticsController:viewForSuspendHeaderInTableView:)]) {
        headerView = [magneticController magneticsController:self viewForSuspendHeaderInTableView:tableView];
    }
    return headerView;
}

- (NSInteger)tableView:(MagneticTableView *)tableView numberOfRowsInSection:(NSInteger)section{
    MagneticController *magneticController = [self magneticControllerAtIndex:section];
    return magneticController.rowCountCache;
}

- (CGFloat)tableView:(MagneticTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    MagneticController *magneticController = [self magneticControllerAtIndex:indexPath.section];
    return (indexPath.row < magneticController.rowHeightsCache.count) ? ceil([magneticController.rowHeightsCache[indexPath.row] floatValue]) : 0.0;
}

- (UITableViewCell *)tableView:(MagneticTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MagneticController *magneticController = [self magneticControllerAtIndex:indexPath.section];
    
    //布局参数
    BOOL isMagneticSpacing = [self isMagneticSpacing:magneticController atIndexPath:indexPath]; //磁片间距
    BOOL isMagneticHeader = [self isMagneticHeader:magneticController atIndexPath:indexPath]; //头部视图
    BOOL isMagneticFooter = [self isMagneticFooter:magneticController atIndexPath:indexPath]; //尾部视图
    
    //复用参数
    Class class = nil;
    NSString *identifier = nil;
    if (isMagneticSpacing) { //磁片间距
        class = [UITableViewCell class];
        identifier = @"MagneticSpacingCell";
    } else if (isMagneticHeader) { //头部视图
        if ([magneticController respondsToSelector:@selector(magneticsController:cellClassForMagneticHeaderInTableView:)]) {
            class = [magneticController magneticsController:self cellClassForMagneticHeaderInTableView:tableView];
        }
        if ([magneticController respondsToSelector:@selector(magneticsController:cellIdentifierForMagneticHeaderInTableView:)]) {
            identifier = [magneticController magneticsController:self cellIdentifierForMagneticHeaderInTableView:tableView];
        }
    } else if (isMagneticFooter) { //尾部视图
        if ([magneticController respondsToSelector:@selector(magneticsController:cellClassForMagneticFooterInTableView:)]) {
            class = [magneticController magneticsController:self cellClassForMagneticFooterInTableView:tableView];
        }
        if ([magneticController respondsToSelector:@selector(magneticsController:cellIdentifierForMagneticFooterInTableView:)]) {
            identifier = [magneticController magneticsController:self cellIdentifierForMagneticFooterInTableView:tableView];
        }
    } else {
        if (magneticController.showMagneticError) { //错误磁片
            class = [MagneticErrorCell class];
            identifier = NSStringFromClass(class);
        } else { //数据源
            if (indexPath.row < magneticController.extensionRowIndex) { //磁片内容
                NSInteger rowIndex = magneticController.showMagneticHeader ? indexPath.row - 1 : indexPath.row; //数据源对应的index
                if ([magneticController respondsToSelector:@selector(magneticsController:cellClassForMagneticContentAtIndex:)]) {
                    class = [magneticController magneticsController:self cellClassForMagneticContentAtIndex:rowIndex];
                }
                if ([magneticController respondsToSelector:@selector(magneticsController:cellIdentifierForMagneticContentAtIndex:)]) {
                    identifier = [magneticController magneticsController:self cellIdentifierForMagneticContentAtIndex:rowIndex];
                }
            } else { //磁片扩展
                NSInteger rowIndex = indexPath.row - magneticController.extensionRowIndex; //数据源对应的index
                if ([magneticController.extensionController respondsToSelector:@selector(magneticsController:cellClassForMagneticContentAtIndex:)]) {
                    class = [magneticController.extensionController magneticsController:self cellClassForMagneticContentAtIndex:rowIndex];
                }
                if ([magneticController.extensionController respondsToSelector:@selector(magneticsController:cellIdentifierForMagneticContentAtIndex:)]) {
                    identifier = [magneticController.extensionController magneticsController:self cellIdentifierForMagneticContentAtIndex:rowIndex];
                }
            }
        }
    }
    
    if (!class) {
        class = [UITableViewCell class];
    }
    if (!identifier.length) {
        identifier = [NSString stringWithFormat:@"%@_%ld", NSStringFromClass(class), (long)magneticController.magneticContext.type]; //同类磁片内部复用cell
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[class alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.clipsToBounds = YES;
        cell.exclusiveTouch = YES;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if ([magneticController respondsToSelector:@selector(magneticsController:colorForMagneticBackgroundInTableView:)]) {
            cell.backgroundColor = [magneticController magneticsController:self colorForMagneticBackgroundInTableView:tableView];
            cell.contentView.backgroundColor = [magneticController magneticsController:self colorForMagneticBackgroundInTableView:tableView];

        }else{
            cell.backgroundColor = [UIColor whiteColor];
            cell.contentView.backgroundColor = [UIColor whiteColor];
        }
    }
    
    if (isMagneticSpacing) { //磁片间距
        UIColor *backgroundColor = [UIColor clearColor];
        if ([magneticController respondsToSelector:@selector(magneticsController:colorForMagneticSpacingInTableView:)]) {
            backgroundColor = [magneticController magneticsController:self colorForMagneticSpacingInTableView:tableView];
        }
        cell.backgroundColor = backgroundColor;
        cell.contentView.backgroundColor = backgroundColor;
        if ([magneticController respondsToSelector:@selector(magneticsController:reuseCell:forMagneticSpaingInTableView:)]) {
            [magneticController magneticsController:self reuseCell:cell forMagneticSpaingInTableView:tableView];
        }
    } else if (isMagneticHeader) { //头部视图
        [magneticController magneticsController:self reuseCell:cell forMagneticHeaderInTableView:tableView];
    } else if (isMagneticFooter) { //尾部视图
        [magneticController magneticsController:self reuseCell:cell forMagneticFooterInTableView:tableView];
    } else { //数据源
        if (magneticController.showMagneticError) { //错误磁片
            MagneticErrorCell *magneticErrorCell = (MagneticErrorCell *)cell;
            magneticErrorCell.magneticController = magneticController;
            [magneticErrorCell refreshMagneticErrorView];
        } else {
            if (indexPath.row < magneticController.extensionRowIndex) { //磁片内容
                NSInteger rowIndex = magneticController.showMagneticHeader ? indexPath.row - 1 : indexPath.row; //数据源对应的index
                [magneticController magneticsController:self reuseCell:cell forMagneticContentAtIndex:rowIndex];
            } else { //磁片扩展
                NSInteger rowIndex = indexPath.row - magneticController.extensionRowIndex; //数据源对应的index
                [magneticController.extensionController magneticsController:self reuseCell:cell forMagneticContentAtIndex:rowIndex];
            }
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    MagneticController *magneticController = [self magneticControllerAtIndex:indexPath.section];
    
    //布局参数
    BOOL isMagneticSpacing = [self isMagneticSpacing:magneticController atIndexPath:indexPath]; //磁片间距
    BOOL isMagneticHeader = [self isMagneticHeader:magneticController atIndexPath:indexPath]; //头部视图
    BOOL isMagneticFooter = [self isMagneticFooter:magneticController atIndexPath:indexPath]; //尾部视图
    
    //磁片回调
    if (!isMagneticSpacing && !isMagneticHeader && !isMagneticFooter && !magneticController.showMagneticError) { //数据源
        if (indexPath.row < magneticController.extensionRowIndex) { //磁片内容
            if ([magneticController respondsToSelector:@selector(magneticsController:willDisplayCell:forMagneticContentAtIndex:)]) {
                NSInteger rowIndex = magneticController.showMagneticHeader ? indexPath.row - 1 : indexPath.row; //数据源对应的index
                [magneticController magneticsController:self willDisplayCell:cell forMagneticContentAtIndex:rowIndex];
            }
        } else { //磁片扩展
            if ([magneticController.extensionController respondsToSelector:@selector(magneticsController:willDisplayCell:forMagneticContentAtIndex:)]) {
                NSInteger rowIndex = indexPath.row - magneticController.extensionRowIndex; //数据源对应的index
                [magneticController.extensionController magneticsController:self willDisplayCell:cell forMagneticContentAtIndex:rowIndex];
            }
        }
    } else if (isMagneticHeader) {
        if ([magneticController respondsToSelector:@selector(magneticsController:willDisplayingHeaderCell:)]) {
            [magneticController magneticsController:self willDisplayingHeaderCell:cell];
        }
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    MagneticController *magneticController = [self magneticControllerAtIndex:indexPath.section];
    
    //布局参数
    BOOL isMagneticSpacing = [self isMagneticSpacing:magneticController atIndexPath:indexPath]; //磁片间距
    BOOL isMagneticHeader = [self isMagneticHeader:magneticController atIndexPath:indexPath]; //头部视图
    BOOL isMagneticFooter = [self isMagneticFooter:magneticController atIndexPath:indexPath]; //尾部视图
    
    //磁片回调
    if (!isMagneticSpacing && !isMagneticHeader && !isMagneticFooter && !magneticController.showMagneticError) { //数据源
        if (indexPath.row < magneticController.extensionRowIndex) { //磁片内容
            if ([magneticController respondsToSelector:@selector(magneticsController:didEndDisplayingCell:forMagneticContentAtIndex:)]) {
                NSInteger rowIndex = magneticController.showMagneticHeader ? indexPath.row - 1 : indexPath.row; //数据源对应的index
                [magneticController magneticsController:self didEndDisplayingCell:cell forMagneticContentAtIndex:rowIndex];
            }
        } else { //磁片扩展
            if ([magneticController.extensionController respondsToSelector:@selector(magneticsController:didEndDisplayingCell:forMagneticContentAtIndex:)]) {
                NSInteger rowIndex = indexPath.row - magneticController.extensionRowIndex; //数据源对应的index
                [magneticController.extensionController magneticsController:self didEndDisplayingCell:cell forMagneticContentAtIndex:rowIndex];
            }
        }
    }else if (isMagneticHeader){
        
        if ([magneticController respondsToSelector:@selector(magneticsController:didEndDisplayingHeaderCell:)]) {
            [magneticController magneticsController:self didEndDisplayingHeaderCell:cell];
        }
    }
}

- (void)tableView:(MagneticTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    MagneticController *magneticController = [self magneticControllerAtIndex:indexPath.section];
    
    //布局参数
    BOOL isMagneticSpacing = [self isMagneticSpacing:magneticController atIndexPath:indexPath]; //磁片间距
    BOOL isMagneticHeader = [self isMagneticHeader:magneticController atIndexPath:indexPath]; //头部视图
    BOOL isMagneticFooter = [self isMagneticFooter:magneticController atIndexPath:indexPath]; //尾部视图
    
    //点击事件
    if (isMagneticSpacing) { //磁片间距
        //无效点击
    } else if (isMagneticHeader) { //头部视图
        if ([magneticController respondsToSelector:@selector(magneticsController:didSelectMagneticHeaderInTableView:)]) {
            [magneticController magneticsController:self didSelectMagneticHeaderInTableView:tableView];
        }
    } else if (isMagneticFooter) { //尾部视图
        if ([magneticController respondsToSelector:@selector(magneticsController:didSelectMagneticFooterInTableView:)]) {
            [magneticController magneticsController:self didSelectMagneticFooterInTableView:tableView];
        }
    } else { //数据源
        if (magneticController.showMagneticError) { //错误磁片
            //无效点击
        } else {
            if (indexPath.row < magneticController.extensionRowIndex) { //磁片内容
                if ([magneticController respondsToSelector:@selector(magneticsController:didSelectMagneticContentAtIndex:)]) {
                    NSInteger rowIndex = magneticController.showMagneticHeader ? indexPath.row - 1 : indexPath.row; //数据源对应的index
                    [magneticController magneticsController:self didSelectMagneticContentAtIndex:rowIndex];
                }
            } else { //磁片扩展
                if ([magneticController.extensionController respondsToSelector:@selector(magneticsController:didSelectMagneticContentAtIndex:)]) {
                    NSInteger rowIndex = indexPath.row - magneticController.extensionRowIndex; //数据源对应的index
                    [magneticController.extensionController magneticsController:self didSelectMagneticContentAtIndex:rowIndex];
                }
            }
        }
    }
}

@end


@implementation MagneticsController (BottomPrivate)

//设置封底开关
- (void)setEnableTableBottomView:(BOOL)enableTableBottomView{
    if (_enableTableBottomView != enableTableBottomView) {
        _enableTableBottomView = enableTableBottomView;

        if (self.isViewLoaded) {
            [self refreshTableBottomView];
        }
    }
}

//设置封底自定义视图
- (void)setTableBottomCustomView:(UIView *)tableBottomCustomView{
    if (_tableBottomCustomView != tableBottomCustomView) {
        _tableBottomCustomView = tableBottomCustomView;

        if (self.isViewLoaded) {
            [self refreshTableBottomView];
        }
    }
}

//刷新封底视图
- (void)refreshTableBottomView{
    if (!_enableTableBottomView //禁用封底
        || !_magneticControllersArray.count) { //无数据源

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
                _tableView.tableFooterView = [[MagneticTableFooterView alloc] initWithFrame:CGRectMake(0, 0, _tableView.bounds.size.width, 50)];
            }
        }
        _tableView.tableFooterView.tag = kTagTableBottomView;
    }
}

//触发加载更多事件，启动加载动画
- (void)triggerInfiniteScrollingAction{
//    [self.moreControl beginRefreshing];
}

//完成加载更多事件，停止加载动画
- (void)finishInfiniteScrollingAction{
//    [self.moreControl endRefreshing];
}

///完成所有数据加载，设置
- (void)didFinishLoadAllData{
    self.enableTableBottomView = YES;
    MagneticsRefreshType refreshType = self.refreshType & (MagneticsRefreshTypePullToRefresh | MagneticsRefreshTypeLoadingView);
    self.refreshType = refreshType;
}

#pragma mark - sets/gets

- (MagneticTableView *)tableView{
    if (!_tableView) {
        CGRect frame = self.view.bounds;
        frame.size.width = MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        _tableView = [[MagneticTableView alloc] initWithFrame:frame style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _tableView.magneticControllersArray = _magneticControllersArray;
        _tableView.magneticsController = self;
        
        if (@available(iOS 11, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            _tableView.estimatedRowHeight = 0;
            _tableView.estimatedSectionHeaderHeight = 0;
            _tableView.estimatedSectionFooterHeight = 0;
        }
    }
    return _tableView;
}

- (UIRefreshControl *)refreshControl{
    
    if (!_refreshControl) {
        _refreshControl = [[UIRefreshControl alloc] init];
        _refreshControl.tintColor = [UIColor grayColor];
        _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"下拉刷新"];
        [_refreshControl addTarget:self action:@selector(triggerRefreshAction) forControlEvents:UIControlEventValueChanged];
    }
    return _refreshControl;
}

//- (UIControl *)moreControl{
//
//    if (!_moreControl) {
//        _moreControl = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, 100)];
//        _moreControl.tintColor = [UIColor grayColor];
//        _moreControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"加载更多"];
//        [_moreControl addTarget:self action:@selector(requestMoreData) forControlEvents:UIControlEventTouchDragEnter];
//    }
//    return _moreControl;
//}

@end
