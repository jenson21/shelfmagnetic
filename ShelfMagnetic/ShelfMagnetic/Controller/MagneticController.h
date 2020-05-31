//
//  MagneticController.h
//  ShelfMagnetic
//
//  Created by Jenson on 2020/5/31.
//  Copyright © 2020 Jenson. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

#import "MagneticsControllerProtocol.h"
#import "MagneticContext.h"

@class MagneticsController;
@class NXHttpManager;

@protocol MagneticControllerDelegate;

@interface MagneticController : NSObject <MagneticsControllerDelegate>

@property (nonatomic, strong)   NXHttpManager    *httpManager;

@property (nonatomic, weak)     id<MagneticControllerDelegate> delegate;

///卡片列表控制器
@property (nonatomic, weak)     MagneticsController *MagneticsController;

///扩展控制器
@property (nonatomic, strong)   MagneticController  *extensionController;

///卡片数据源
@property (nonatomic, strong)   MagneticContext     *MagneticContext;

///是否为扩展
@property (nonatomic)           BOOL            isExtension;

///折叠状态。默认为NO。
@property (nonatomic)           BOOL            isFold;

///是否完成准备，可渲染
@property (nonatomic)           BOOL            isPrepared;


///请求错误卡片数据
- (void)requestErrorMagneticData;


@end



/**
 *  缓存参数，用于优化表视图性能
 */
@interface MagneticController (Cache)

///是否显示错误视图
@property (nonatomic)           BOOL        showMagneticError;

///是否显示头部视图
@property (nonatomic)           BOOL        showMagneticHeader;

///是否显示尾部视图
@property (nonatomic)           BOOL        showMagneticFooter;

///是否显示卡片间距
@property (nonatomic)           BOOL        showMagneticSpacing;

///行数缓存
@property (nonatomic)           NSInteger   rowCountCache;

///行高缓存
@property (nonatomic, strong)   NSArray     *rowHeightsCache;

///扩展行数起始index
@property (nonatomic)           NSInteger   extensionRowIndex;

@end



/**
 *  加载更多
 */
@interface MagneticController (RequestMore)

///是否可加载更多。默认为NO。开启后可响应-didTriggerRequestMoreDataActionInMagneticsController:协议。
@property (nonatomic)           BOOL        canRequestMoreData;

@end



@protocol MagneticControllerDelegate <NSObject>

///刷新指定类型的卡片
- (void)refreshMagneticWithType:(MagneticType)type animation:(UITableViewRowAnimation)animation;
///刷新指定类型的卡片
- (void)refreshMagneticWithType:(MagneticType)type;
//刷新指定类型卡片的数据源
- (void)refreshMagneticWithType:(MagneticType)type json:(id)json;

/**
 *  @brief  添加指定Section卡片
 *  @param  MagneticType    卡片类型
 *  @param  MagneticContext    刷新数据模型
 *  @param  MagneticController 刷新controller
 *  @param  index    指定位置
 */
- (void)addSectionWithType:(MagneticType)MagneticType
           withMagneticContext:(MagneticContext *)MagneticContext
        withMagneticController:(MagneticController *)MagneticController
                 withIndex:(NSUInteger)index
             withAnimation:(UITableViewRowAnimation)animation;

/**
 *  @brief  删除指定Section卡片
 *  @param  MagneticType    卡片类型
 *  @param  index    指定位置
 */
- (void)deleteSectionWithType:(MagneticType)MagneticType
                    withIndex:(NSUInteger)index
                withAnimation:(UITableViewRowAnimation)animation;

@optional

///通用参数字典。用于请求参数、统计埋点等。
- (NSDictionary *)generalParameters;NS_ASSUME_NONNULL_END
