//
//  MagneticsControllerProtocol.h
//  ShelfMagnetic
//
//  Created by Jenson on 2020/5/31.
//  Copyright © 2020 Jenson. All rights reserved.
//

#import "MagneticContext.h"

NS_ASSUME_NONNULL_BEGIN

@class MagneticsController, MagneticTableView, MagneticPreviewItem;

@protocol MagneticsControllerDelegate

/**
 * Magnetic Content
 * @brief 磁片内容
 */

///内容行数
- (NSInteger)magneticsController:(MagneticsController *)magneticsController rowCountForMagneticContentInTableView:(MagneticTableView *)tableView;

///内容行高
- (CGFloat)magneticsController:(MagneticsController *)magneticsController rowHeightForMagneticContentAtIndex:(NSInteger)index;

///复用内容视图
- (void)magneticsController:(MagneticsController *)magneticsController reuseCell:(UITableViewCell *)cell forMagneticContentAtIndex:(NSInteger)index;



@optional

/**
 * Magnetic Content
 * @brief 磁片内容
 */

///内容视图Class。默认为UITableViewCell。
- (Class)magneticsController:(MagneticsController *)magneticsController cellClassForMagneticContentAtIndex:(NSInteger)index;

///内容视图复用标识符。默认为"CellClass_MagneticType"的形式。
- (NSString *)magneticsController:(MagneticsController *)magneticsController cellIdentifierForMagneticContentAtIndex:(NSInteger)index;

///点击内容事件
- (void)magneticsController:(MagneticsController *)magneticsController didSelectMagneticContentAtIndex:(NSInteger)index;

///内容将显示
- (void)magneticsController:(MagneticsController *)magneticsController willDisplayCell:(UITableViewCell *)cell forMagneticContentAtIndex:(NSInteger)index;

///内容已隐藏
- (void)magneticsController:(MagneticsController *)magneticsController didEndDisplayingCell:(UITableViewCell *)cell forMagneticContentAtIndex:(NSInteger)index;

///头部将要显示
- (void)magneticsController:(MagneticsController *)magneticsController willDisplayingHeaderCell:(UITableViewCell *)cell;

///头部已隐藏
- (void)magneticsController:(MagneticsController *)magneticsController didEndDisplayingHeaderCell:(UITableViewCell *)cell;

/**
 * Suspend Header
 * @brief 顶部悬浮视图
 */

///悬浮视图高度。默认为0.0。
- (CGFloat)magneticsController:(MagneticsController *)magneticsController heightForSuspendHeaderInTableView:(MagneticTableView *)tableView;

///悬浮视图。默认为nil。
- (UIView *)magneticsController:(MagneticsController *)magneticsController viewForSuspendHeaderInTableView:(MagneticTableView *)tableView;



/**
 * Magnetic Header
 * @brief 磁片头部
 */

///是否显示头部视图。默认为NO。
- (BOOL)magneticsController:(MagneticsController *)magneticsController shouldShowMagneticHeaderInTableView:(MagneticTableView *)tableView;

///头部行高
- (CGFloat)magneticsController:(MagneticsController *)magneticsController heightForMagneticHeaderInTableView:(MagneticTableView *)tableView;

///头部视图Class。默认为UITableViewCell。
- (Class)magneticsController:(MagneticsController *)magneticsController cellClassForMagneticHeaderInTableView:(MagneticTableView *)tableView;

///头部视图复用标识符。默认为"CellClass_MagneticType"的形式。
- (NSString *)magneticsController:(MagneticsController *)magneticsController cellIdentifierForMagneticHeaderInTableView:(MagneticTableView *)tableView;

///复用头部视图
- (void)magneticsController:(MagneticsController *)magneticsController reuseCell:(UITableViewCell *)cell forMagneticHeaderInTableView:(MagneticTableView *)tableView;

///点击头部事件
- (void)magneticsController:(MagneticsController *)magneticsController didSelectMagneticHeaderInTableView:(MagneticTableView *)tableView;



/**
 * Magnetic Footer
 * @brief 磁片尾部
 */

///是否显示尾部视图。默认为NO。
- (BOOL)magneticsController:(MagneticsController *)magneticsController shouldShowMagneticFooterInTableView:(MagneticTableView *)tableView;

///尾部行高
- (CGFloat)magneticsController:(MagneticsController *)magneticsController heightForMagneticFooterInTableView:(MagneticTableView *)tableView;

///尾部视图Class。默认为UITableViewCell。
- (Class)magneticsController:(MagneticsController *)magneticsController cellClassForMagneticFooterInTableView:(MagneticTableView *)tableView;

///尾部视图复用标识符。默认为"CellClass_MagneticType"的形式。
- (NSString *)magneticsController:(MagneticsController *)magneticsController cellIdentifierForMagneticFooterInTableView:(MagneticTableView *)tableView;

///复用尾部视图
- (void)magneticsController:(MagneticsController *)magneticsController reuseCell:(UITableViewCell *)cell forMagneticFooterInTableView:(MagneticTableView *)tableView;

///点击尾部事件
- (void)magneticsController:(MagneticsController *)magneticsController didSelectMagneticFooterInTableView:(MagneticTableView *)tableView;



/**
 * Magnetic Spacing
 * @brief 磁片底部间距
 */

///磁片间距大小。默认为10.0，当高度为0.0时无间距（不占用cell）。
- (CGFloat)magneticsController:(MagneticsController *)magneticsController heightForMagneticSpacingInTableView:(MagneticTableView *)tableView;

///磁片间距颜色。默认为透明。
- (UIColor *)magneticsController:(MagneticsController *)magneticsController colorForMagneticSpacingInTableView:(MagneticTableView *)tableView;

///复用磁片底部间距视图
- (void)magneticsController:(MagneticsController *)magneticsController reuseCell:(UITableViewCell *)cell forMagneticSpaingInTableView:(MagneticTableView *)tableView;
///磁片颜色。
- (UIColor *)magneticsController:(MagneticsController *)magneticsController colorForMagneticBackgroundInTableView:(MagneticTableView *)tableView;



/**
 * Magnetic Error
 * @brief 磁片错误
 */

///是否显示磁片错误提示。默认为NO。
- (BOOL)magneticsController:(MagneticsController *)magneticsController shouldShowMagneticErrorWithCode:(MagneticErrorCode)errorCode;

///是否忽略磁片错误。默认为NO。
- (BOOL)magneticsController:(MagneticsController *)magneticsController shouldIgnoreMagneticErrorWithCode:(MagneticErrorCode)errorCode;

///磁片错误描述。默认为"获取失败 点击重试"。
- (NSAttributedString *)magneticsController:(MagneticsController *)magneticsController errorDescriptionWithCode:(MagneticErrorCode)errorCode;



/**
 * Life Circle
 * @brief 生命周期
 */

///完成初始化监听
- (void)didFinishInitConfigurationInMagneticsController:(MagneticsController *)magneticsController;

///磁片父控制器将显示
- (void)magneticsController:(MagneticsController *)magneticsController superViewWillAppear:(UIViewController *)superViewController;

///磁片父控制器已隐藏
- (void)magneticsController:(MagneticsController *)magneticsController superViewDidDisappear:(UIViewController *)superViewController;



/**
 *  Scroll
 *  @brief 滚动监听（需开启页面滚动监听开关observeScrollEvent）
 */

///向可见磁片发送列表滚动事件（同一个磁片只接收一次回调）
- (void)magneticsController:(MagneticsController *)magneticsController didScrollVisibleCellsInTableView:(MagneticTableView *)tableView;

///向可见磁片发送每个cell的滚动事件
- (void)magneticsController:(MagneticsController *)magneticsController didScrollVisibleCell:(UITableViewCell *)cell forMagneticContentAtIndex:(NSInteger)index;

///向可见磁片发送列表滚动停止事件（同一个磁片只接收一次回调）
- (void)magneticsController:(MagneticsController *)magneticsController didEndScrollingVisibleCellsInTableView:(MagneticTableView *)tableView;

///列表滚动停止时，向可见磁片发送每个cell的曝光百分比
- (void)magneticsController:(MagneticsController *)magneticsController didEndScrollingVisibleCell:(UITableViewCell *)cell exposeFromPercent:(NSInteger)fromPercent toPercent:(NSInteger)toPercent forMagneticContentAtIndex:(NSInteger)index;

///向当前视图可见磁片透传scrollView scrollViewWillBeginDragging代理
- (void)magneticsController:(MagneticsController *)magneticsController scrollViewWillBeginDraggingForCell:(UITableViewCell *)cell;
///向当前视图可见磁片发送停止事件
- (void)magneticsController:(MagneticsController *)magneticsController didEndScrollingForCell:(UITableViewCell *)cell;
///向当前视图可见磁片发送滑动动画事件
- (void)magneticsController:(MagneticsController *)magneticsController didScrollForCell:(UITableViewCell *)cell;

/**
 * Request More
 * @brief 加载更多（属性canRequestMoreData为YES的磁片可响应）
 */

///触发加载更多事件监听
- (void)didTriggerRequestMoreDataActionInMagneticsController:(MagneticsController *)magneticsController;


/**
 * Single Magnetic Request
 * @brief 单磁片请求
 */
///单磁片网络请求结束，包括成功or失败
- (void)magneticRequestDidFinishInMagneticsController:(MagneticsController *)magneticsController;
///网络请求类型，get or post  大小写均可,默认get
- (NSString *)magneticRequestTypeInMagneticsController:(MagneticsController *)magneticsController;
///请求的url, 异步请求必须实现
- (NSString *)magneticRequestURLInMagneticsController:(MagneticsController *)magneticsController;
///请求的参数
- (NSDictionary *)magneticRequestParametersInMagneticsController:(MagneticsController *)magneticsController;
///解析数据源的model,异步请求必须实现
- (Class)magneticRequestParserModelClassInMagneticsController:(MagneticsController *)magneticsController;

/**
 * Expose
 * @brief 曝光统计
 */

- (NSArray *)magneticsController:(MagneticsController *)magneticsController exposureforMagneticHeaderAtIndex:(NSInteger)index;

- (NSArray *)magneticsController:(MagneticsController *)magneticsController exposureforMagneticFooterAtIndex:(NSInteger)index;

- (NSArray *)magneticsController:(MagneticsController *)magneticsController exposureforMagneticContentAtIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
