//
//  CardsControllerProtocol.h
//  dolphinHouse
//
//  Created by lifuqing on 2018/8/31.
//  Copyright © 2018年 HTJ. All rights reserved.
//

/**
 *  卡片结构示意图
 *
 *  |————————————————————|
 *  |   Suspend Header   |
 *  |————————————————————|
 *  |       Header       |
 *  |————————————————————|
 *  |                    |
 *  |       Content      |
 *  |                    |
 *  |————————————————————|
 *  |       Footer       |
 *  |————————————————————|
 *  |       Spacing      |
 *  |————————————————————|
 *
 */

#import "CardContext.h"

@class CardsController, CardTableView, CardPreviewItem;

@protocol CardsControllerDelegate

/**
 * Card Content
 * @brief 卡片内容
 */

///内容行数
- (NSInteger)cardsController:(CardsController *)cardsController rowCountForCardContentInTableView:(CardTableView *)tableView;

///内容行高
- (CGFloat)cardsController:(CardsController *)cardsController rowHeightForCardContentAtIndex:(NSInteger)index;

///复用内容视图
- (void)cardsController:(CardsController *)cardsController reuseCell:(UITableViewCell *)cell forCardContentAtIndex:(NSInteger)index;



@optional

/**
 * Card Content
 * @brief 卡片内容
 */

///内容视图Class。默认为UITableViewCell。
- (Class)cardsController:(CardsController *)cardsController cellClassForCardContentAtIndex:(NSInteger)index;

///内容视图复用标识符。默认为"CellClass_CardType"的形式。
- (NSString *)cardsController:(CardsController *)cardsController cellIdentifierForCardContentAtIndex:(NSInteger)index;

///点击内容事件
- (void)cardsController:(CardsController *)cardsController didSelectCardContentAtIndex:(NSInteger)index;

///内容将显示
- (void)cardsController:(CardsController *)cardsController willDisplayCell:(UITableViewCell *)cell forCardContentAtIndex:(NSInteger)index;

///内容已隐藏
- (void)cardsController:(CardsController *)cardsController didEndDisplayingCell:(UITableViewCell *)cell forCardContentAtIndex:(NSInteger)index;

///头部将要显示
- (void)cardsController:(CardsController *)cardsController willDisplayingHeaderCell:(UITableViewCell *)cell;

///头部已隐藏
- (void)cardsController:(CardsController *)cardsController didEndDisplayingHeaderCell:(UITableViewCell *)cell;

/**
 * Suspend Header
 * @brief 顶部悬浮视图
 */

///悬浮视图高度。默认为0.0。
- (CGFloat)cardsController:(CardsController *)cardsController heightForSuspendHeaderInTableView:(CardTableView *)tableView;

///悬浮视图。默认为nil。
- (UIView *)cardsController:(CardsController *)cardsController viewForSuspendHeaderInTableView:(CardTableView *)tableView;



/**
 * Card Header
 * @brief 卡片头部
 */

///是否显示头部视图。默认为NO。
- (BOOL)cardsController:(CardsController *)cardsController shouldShowCardHeaderInTableView:(CardTableView *)tableView;

///头部行高
- (CGFloat)cardsController:(CardsController *)cardsController heightForCardHeaderInTableView:(CardTableView *)tableView;

///头部视图Class。默认为UITableViewCell。
- (Class)cardsController:(CardsController *)cardsController cellClassForCardHeaderInTableView:(CardTableView *)tableView;

///头部视图复用标识符。默认为"CellClass_CardType"的形式。
- (NSString *)cardsController:(CardsController *)cardsController cellIdentifierForCardHeaderInTableView:(CardTableView *)tableView;

///复用头部视图
- (void)cardsController:(CardsController *)cardsController reuseCell:(UITableViewCell *)cell forCardHeaderInTableView:(CardTableView *)tableView;

///点击头部事件
- (void)cardsController:(CardsController *)cardsController didSelectCardHeaderInTableView:(CardTableView *)tableView;



/**
 * Card Footer
 * @brief 卡片尾部
 */

///是否显示尾部视图。默认为NO。
- (BOOL)cardsController:(CardsController *)cardsController shouldShowCardFooterInTableView:(CardTableView *)tableView;

///尾部行高
- (CGFloat)cardsController:(CardsController *)cardsController heightForCardFooterInTableView:(CardTableView *)tableView;

///尾部视图Class。默认为UITableViewCell。
- (Class)cardsController:(CardsController *)cardsController cellClassForCardFooterInTableView:(CardTableView *)tableView;

///尾部视图复用标识符。默认为"CellClass_CardType"的形式。
- (NSString *)cardsController:(CardsController *)cardsController cellIdentifierForCardFooterInTableView:(CardTableView *)tableView;

///复用尾部视图
- (void)cardsController:(CardsController *)cardsController reuseCell:(UITableViewCell *)cell forCardFooterInTableView:(CardTableView *)tableView;

///点击尾部事件
- (void)cardsController:(CardsController *)cardsController didSelectCardFooterInTableView:(CardTableView *)tableView;



/**
 * Card Spacing
 * @brief 卡片底部间距
 */

///卡片间距大小。默认为10.0，当高度为0.0时无间距（不占用cell）。
- (CGFloat)cardsController:(CardsController *)cardsController heightForCardSpacingInTableView:(CardTableView *)tableView;

///卡片间距颜色。默认为透明。
- (UIColor *)cardsController:(CardsController *)cardsController colorForCardSpacingInTableView:(CardTableView *)tableView;

///复用卡片底部间距视图
- (void)cardsController:(CardsController *)cardsController reuseCell:(UITableViewCell *)cell forCardSpaingInTableView:(CardTableView *)tableView;
///卡片颜色。
- (UIColor *)cardsController:(CardsController *)cardsController colorForCardBackgroundInTableView:(CardTableView *)tableView;



/**
 * Card Error
 * @brief 卡片错误
 */

///是否显示卡片错误提示。默认为NO。
- (BOOL)cardsController:(CardsController *)cardsController shouldShowCardErrorWithCode:(CardErrorCode)errorCode;

///是否忽略卡片错误。默认为NO。
- (BOOL)cardsController:(CardsController *)cardsController shouldIgnoreCardErrorWithCode:(CardErrorCode)errorCode;

///卡片错误描述。默认为"获取失败 点击重试"。
- (NSAttributedString *)cardsController:(CardsController *)cardsController errorDescriptionWithCode:(CardErrorCode)errorCode;



/**
 * Life Circle
 * @brief 生命周期
 */

///完成初始化监听
- (void)didFinishInitConfigurationInCardsController:(CardsController *)cardsController;

///卡片父控制器将显示
- (void)cardsController:(CardsController *)cardsController superViewWillAppear:(UIViewController *)superViewController;

///卡片父控制器已隐藏
- (void)cardsController:(CardsController *)cardsController superViewDidDisappear:(UIViewController *)superViewController;



/**
 *  Scroll
 *  @brief 滚动监听（需开启页面滚动监听开关observeScrollEvent）
 */

///向可见卡片发送列表滚动事件（同一个卡片只接收一次回调）
- (void)cardsController:(CardsController *)cardsController didScrollVisibleCellsInTableView:(CardTableView *)tableView;

///向可见卡片发送每个cell的滚动事件
- (void)cardsController:(CardsController *)cardsController didScrollVisibleCell:(UITableViewCell *)cell forCardContentAtIndex:(NSInteger)index;

///向可见卡片发送列表滚动停止事件（同一个卡片只接收一次回调）
- (void)cardsController:(CardsController *)cardsController didEndScrollingVisibleCellsInTableView:(CardTableView *)tableView;

///列表滚动停止时，向可见卡片发送每个cell的曝光百分比
- (void)cardsController:(CardsController *)cardsController didEndScrollingVisibleCell:(UITableViewCell *)cell exposeFromPercent:(NSInteger)fromPercent toPercent:(NSInteger)toPercent forCardContentAtIndex:(NSInteger)index;

///向当前视图可见卡片透传scrollView scrollViewWillBeginDragging代理
- (void)cardsController:(CardsController *)cardsController scrollViewWillBeginDraggingForCell:(UITableViewCell *)cell;
///向当前视图可见卡片发送停止事件
- (void)cardsController:(CardsController *)cardsController didEndScrollingForCell:(UITableViewCell *)cell;

/**
 * Request More
 * @brief 加载更多（属性canRequestMoreData为YES的卡片可响应）
 */

///触发加载更多事件监听
- (void)didTriggerRequestMoreDataActionInCardsController:(CardsController *)cardsController;


/**
 * Single Card Request
 * @brief 单卡片请求
 */
///单卡片网络请求结束，包括成功or失败
- (void)cardRequestDidFinishInCardsController:(CardsController *)cardsController;
///网络请求类型，get or post  大小写均可,默认get
- (NSString *)cardRequestTypeInCardsController:(CardsController *)cardsController;
///请求的url, 异步请求必须实现
- (NSString *)cardRequestURLInCardsController:(CardsController *)cardsController;
///请求的参数
- (NSDictionary *)cardRequestParametersInCardsController:(CardsController *)cardsController;
///解析数据源的model,异步请求必须实现
- (Class)cardRequestParserModelClassInCardsController:(CardsController *)cardsController;

/**
 * Expose
 * @brief 曝光统计
 */

- (NSArray *)cardsController:(CardsController *)cardsController exposureforCardHeaderAtIndex:(NSInteger)index;

- (NSArray *)cardsController:(CardsController *)cardsController exposureforCardFooterAtIndex:(NSInteger)index;

- (NSArray *)cardsController:(CardsController *)cardsController exposureforCardContentAtIndex:(NSInteger)index;

@end
