//
//  MagneticsControllerProtocol.h
//  ShelfMagnetic
//
//  Created by Jenson on 2020/5/31.
//  Copyright © 2020 Jenson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MagneticContext.h"

@class MagneticsController, MagneticTableView, MagneticPreviewItem;

@protocol MagneticsControllerDelegate

/**
 * Magnetic Content
 * @brief 卡片内容
 */

///内容行数
- (NSInteger)MagneticsController:(MagneticsController *)MagneticsController rowCountForMagneticContentInTableView:(MagneticTableView *)tableView;

///内容行高
- (CGFloat)MagneticsController:(MagneticsController *)MagneticsController rowHeightForMagneticContentAtIndex:(NSInteger)index;

///复用内容视图
- (void)MagneticsController:(MagneticsController *)MagneticsController reuseCell:(UITableViewCell *)cell forMagneticContentAtIndex:(NSInteger)index;



@optional

/**
 * Magnetic Content
 * @brief 卡片内容
 */

///内容视图Class。默认为UITableViewCell。
- (Class)MagneticsController:(MagneticsController *)MagneticsController cellClassForMagneticContentAtIndex:(NSInteger)index;

///内容视图复用标识符。默认为"CellClass_MagneticType"的形式。
- (NSString *)MagneticsController:(MagneticsController *)MagneticsController cellIdentifierForMagneticContentAtIndex:(NSInteger)index;

///点击内容事件
- (void)MagneticsController:(MagneticsController *)MagneticsController didSelectMagneticContentAtIndex:(NSInteger)index;

///内容将显示
- (void)MagneticsController:(MagneticsController *)MagneticsController willDisplayCell:(UITableViewCell *)cell forMagneticContentAtIndex:(NSInteger)index;

///内容已隐藏
- (void)MagneticsController:(MagneticsController *)MagneticsController didEndDisplayingCell:(UITableViewCell *)cell forMagneticContentAtIndex:(NSInteger)index;

///头部将要显示
- (void)MagneticsController:(MagneticsController *)MagneticsController willDisplayingHeaderCell:(UITableViewCell *)cell;

///头部已隐藏
- (void)MagneticsController:(MagneticsController *)MagneticsController didEndDisplayingHeaderCell:(UITableViewCell *)cell;

/**
 * Suspend Header
 * @brief 顶部悬浮视图
 */

///悬浮视图高度。默认为0.0。
- (CGFloat)MagneticsController:(MagneticsController *)MagneticsController heightForSuspendHeaderInTableView:(MagneticTableView *)tableView;

///悬浮视图。默认为nil。
- (UIView *)MagneticsController:(MagneticsController *)MagneticsController viewForSuspendHeaderInTableView:(MagneticTableView *)tableView;



/**
 * Magnetic Header
 * @brief 卡片头部
 */

///是否显示头部视图。默认为NO。
- (BOOL)MagneticsController:(MagneticsController *)MagneticsController shouldShowMagneticHeaderInTableView:(MagneticTableView *)tableView;

///头部行高
- (CGFloat)MagneticsController:(MagneticsController *)MagneticsController heightForMagneticHeaderInTableView:(MagneticTableView *)tableView;

///头部视图Class。默认为UITableViewCell。
- (Class)MagneticsController:(MagneticsController *)MagneticsController cellClassForMagneticHeaderInTableView:(MagneticTableView *)tableView;

///头部视图复用标识符。默认为"CellClass_MagneticType"的形式。
- (NSString *)MagneticsController:(MagneticsController *)MagneticsController cellIdentifierForMagneticHeaderInTableView:(MagneticTableView *)tableView;

///复用头部视图
- (void)MagneticsController:(MagneticsController *)MagneticsController reuseCell:(UITableViewCell *)cell forMagneticHeaderInTableView:(MagneticTableView *)tableView;

///点击头部事件
- (void)MagneticsController:(MagneticsController *)MagneticsController didSelectMagneticHeaderInTableView:(MagneticTableView *)tableView;



/**
 * Magnetic Footer
 * @brief 卡片尾部
 */

///是否显示尾部视图。默认为NO。
- (BOOL)MagneticsController:(MagneticsController *)MagneticsController shouldShowMagneticFooterInTableView:(MagneticTableView *)tableView;

///尾部行高
- (CGFloat)MagneticsController:(MagneticsController *)MagneticsController heightForMagneticFooterInTableView:(MagneticTableView *)tableView;

///尾部视图Class。默认为UITableViewCell。
- (Class)MagneticsController:(MagneticsController *)MagneticsController cellClassForMagneticFooterInTableView:(MagneticTableView *)tableView;

///尾部视图复用标识符。默认为"CellClass_MagneticType"的形式。
- (NSString *)MagneticsController:(MagneticsController *)MagneticsController cellIdentifierForMagneticFooterInTableView:(MagneticTableView *)tableView;

///复用尾部视图
- (void)MagneticsController:(MagneticsController *)MagneticsController reuseCell:(UITableViewCell *)cell forMagneticFooterInTableView:(MagneticTableView *)tableView;

///点击尾部事件
- (void)MagneticsController:(MagneticsController *)MagneticsController didSelectMagneticFooterInTableView:(MagneticTableView *)tableView;



/**
 * Magnetic Spacing
 * @brief 卡片底部间距
 */

///卡片间距大小。默认为10.0，当高度为0.0时无间距（不占用cell）。
- (CGFloat)MagneticsController:(MagneticsController *)MagneticsController heightForMagneticSpacingInTableView:(MagneticTableView *)tableView;

///卡片间距颜色。默认为透明。
- (UIColor *)MagneticsController:(MagneticsController *)MagneticsController colorForMagneticSpacingInTableView:(MagneticTableView *)tableView;

///复用卡片底部间距视图
- (void)MagneticsController:(MagneticsController *)MagneticsController reuseCell:(UITableViewCell *)cell forMagneticSpaingInTableView:(MagneticTableView *)tableView;
///卡片颜色。
- (UIColor *)MagneticsController:(MagneticsController *)MagneticsController colorForMagneticBackgroundInTableView:(MagneticTableView *)tableView;



/**
 * Magnetic Error
 * @brief 卡片错误
 */

///是否显示卡片错误提示。默认为NO。
- (BOOL)MagneticsController:(MagneticsController *)MagneticsController shouldShowMagneticErrorWithCode:(MagneticErrorCode)errorCode;

///是否忽略卡片错误。默认为NO。
- (BOOL)MagneticsController:(MagneticsController *)MagneticsController shouldIgnoreMagneticErrorWithCode:(MagneticErrorCode)errorCode;

///卡片错误描述。默认为"获取失败 点击重试"。
- (NSAttributedString *)MagneticsController:(MagneticsController *)MagneticsController errorDescriptionWithCode:(MagneticErrorCode)errorCode;



/**
 * Life Circle
 * @brief 生命周期
 */

///完成初始化监听
- (void)didFinishInitConfigurationInMagneticsController:(MagneticsController *)MagneticsController;

///卡片父控制器将显示
- (void)MagneticsController:(MagneticsController *)MagneticsController superViewWillAppear:(UIViewController *)superViewController;

///卡片父控制器已隐藏
- (void)MagneticsController:(MagneticsController *)MagneticsController superViewDidDisappear:(UIViewController *)superViewController;



/**
 *  Scroll
 *  @brief 滚动监听（需开启页面滚动监听开关observeScrollEvent）
 */

///向可见卡片发送列表滚动事件（同一个卡片只接收一次回调）
- (void)MagneticsController:(MagneticsController *)MagneticsController didScrollVisibleCellsInTableView:(MagneticTableView *)tableView;

///向可见卡片发送每个cell的滚动事件
- (void)MagneticsController:(MagneticsController *)MagneticsController didScrollVisibleCell:(UITableViewCell *)cell forMagneticContentAtIndex:(NSInteger)index;

///向可见卡片发送列表滚动停止事件（同一个卡片只接收一次回调）
- (void)MagneticsController:(MagneticsController *)MagneticsController didEndScrollingVisibleCellsInTableView:(MagneticTableView *)tableView;

///列表滚动停止时，向可见卡片发送每个cell的曝光百分比
- (void)MagneticsController:(MagneticsController *)MagneticsController didEndScrollingVisibleCell:(UITableViewCell *)cell exposeFromPercent:(NSInteger)fromPercent toPercent:(NSInteger)toPercent forMagneticContentAtIndex:(NSInteger)index;

///向当前视图可见卡片透传scrollView scrollViewWillBeginDragging代理
- (void)MagneticsController:(MagneticsController *)MagneticsController scrollViewWillBeginDraggingForCell:(UITableViewCell *)cell;
///向当前视图可见卡片发送停止事件
- (void)MagneticsController:(MagneticsController *)MagneticsController didEndScrollingForCell:(UITableViewCell *)cell;

/**
 * Request More
 * @brief 加载更多（属性canRequestMoreData为YES的卡片可响应）
 */

///触发加载更多事件监听
- (void)didTriggerRequestMoreDataActionInMagneticsController:(MagneticsController *)MagneticsController;


/**
 * Single Magnetic Request
 * @brief 单卡片请求
 */
///单卡片网络请求结束，包括成功or失败
- (void)MagneticRequestDidFinishInMagneticsController:(MagneticsController *)MagneticsController;
///网络请求类型，get or post  大小写均可,默认get
- (NSString *)MagneticRequestTypeInMagneticsController:(MagneticsController *)MagneticsController;
///请求的url, 异步请求必须实现
- (NSString *)MagneticRequestURLInMagneticsController:(MagneticsController *)MagneticsController;
///请求的参数
- (NSDictionary *)MagneticRequestParametersInMagneticsController:(MagneticsController *)MagneticsController;
///解析数据源的model,异步请求必须实现
- (Class)MagneticRequestParserModelClassInMagneticsController:(MagneticsController *)MagneticsController;

/**
 * Expose
 * @brief 曝光统计
 */

- (NSArray *)MagneticsController:(MagneticsController *)MagneticsController exposureforMagneticHeaderAtIndex:(NSInteger)index;

- (NSArray *)MagneticsController:(MagneticsController *)MagneticsController exposureforMagneticFooterAtIndex:(NSInteger)index;

- (NSArray *)MagneticsController:(MagneticsController *)MagneticsController exposureforMagneticContentAtIndex:(NSInteger)index;

@end
