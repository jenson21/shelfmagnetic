//
//  MagneticController.h
//  ShelfMagnetic
//
//  Created by Jenson on 2020/5/31.
//  Copyright © 2020 Jenson. All rights reserved.
//

#import "MagneticsControllerProtocol.h"
#import "MagneticContext.h"

@class MagneticsController;

@protocol MagneticControllerDelegate;

@interface MagneticController : NSObject <MagneticsControllerDelegate>

///扩展控制器
@property (nonatomic)                   MagneticController              *extensionController;

///磁片数据源
@property (nonatomic)                   MagneticContext                 *magneticContext;

@property (nonatomic, weak)             id<MagneticControllerDelegate>  delegate;

///磁片列表控制器
@property (nonatomic, weak)             MagneticsController             *magneticsController;

///是否为扩展
@property (nonatomic, assign)           BOOL                            isExtension;

///折叠状态。默认为NO。
@property (nonatomic, assign)           BOOL                            isFold;

///是否完成准备，可渲染
@property (nonatomic, assign)           BOOL                            isPrepared;


///请求错误磁片数据
- (void)requestErrorMagneticData;


@end



/**
 *  缓存参数，用于优化表视图性能
 */
@interface MagneticController (Cache)

///是否显示错误视图
@property (nonatomic, assign)           BOOL        showMagneticError;

///是否显示头部视图
@property (nonatomic, assign)           BOOL        showMagneticHeader;

///是否显示尾部视图
@property (nonatomic, assign)           BOOL        showMagneticFooter;

///是否显示磁片头部间距
@property (nonatomic, assign)           BOOL        showMagneticHeaderSpacing;

///是否显示磁片底部间距
@property (nonatomic, assign)           BOOL        showMagneticSpacing;

///行数缓存
@property (nonatomic, assign)           NSInteger   rowCountCache;

///扩展行数起始index
@property (nonatomic, assign)           NSInteger   extensionRowIndex;

///行高缓存
@property (nonatomic, copy)             NSArray     *rowHeightsCache;
@end



/**
 *  加载更多
 */
@interface MagneticController (RequestMore)

///是否可加载更多。默认为NO。开启后可响应-didTriggerRequestMoreDataActionInMagneticsController:协议。
@property (nonatomic, assign)           BOOL        canRequestMoreData;

@end



@protocol MagneticControllerDelegate <NSObject>

///刷新指定类型的磁片
- (void)refreshMagneticWithType:(MagneticType)type animation:(UITableViewRowAnimation)animation;
///刷新指定类型的磁片
- (void)refreshMagneticWithType:(MagneticType)type;
//刷新指定类型磁片的数据源
- (void)refreshMagneticWithType:(MagneticType)type json:(id)json;

/**
 *  @brief  添加指定Section磁片
 *  @param  magneticType    磁片类型
 *  @param  magneticContext    刷新数据模型
 *  @param  magneticController 刷新controller
 *  @param  index    指定位置
 */
- (void)addSectionWithType:(MagneticType)magneticType
           withMagneticContext:(MagneticContext *)magneticContext
        withMagneticController:(MagneticController *)magneticController
                 withIndex:(NSUInteger)index
             withAnimation:(UITableViewRowAnimation)animation;

/**
 *  @brief  删除指定Section磁片
 *  @param  magneticType    磁片类型
 *  @param  index    指定位置
 */
- (void)deleteSectionWithType:(MagneticType)magneticType
                    withIndex:(NSUInteger)index
                withAnimation:(UITableViewRowAnimation)animation;

@optional

///通用参数字典。用于请求参数、统计埋点等。
- (NSDictionary *)generalParameters;

@end
