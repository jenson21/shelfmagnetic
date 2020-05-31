//
//  CardController.h
//  dolphinHouse
//
//  Created by lifuqing on 2018/8/31.
//  Copyright © 2018年 HTJ. All rights reserved.
//

#import "CardContext.h"
#import "CardsControllerProtocol.h"

@class CardsController;
@class NXHttpManager;

@protocol CardControllerDelegate;

@interface CardController : NSObject <CardsControllerDelegate>

@property (nonatomic, strong)   NXHttpManager    *httpManager;

@property (nonatomic, weak)     id<CardControllerDelegate> delegate;

///卡片列表控制器
@property (nonatomic, weak)     CardsController *cardsController;

///扩展控制器
@property (nonatomic, strong)   CardController  *extensionController;

///卡片数据源
@property (nonatomic, strong)   CardContext     *cardContext;

///是否为扩展
@property (nonatomic)           BOOL            isExtension;

///折叠状态。默认为NO。
@property (nonatomic)           BOOL            isFold;

///是否完成准备，可渲染
@property (nonatomic)           BOOL            isPrepared;


///请求错误卡片数据
- (void)requestErrorCardData;


@end



/**
 *  缓存参数，用于优化表视图性能
 */
@interface CardController (Cache)

///是否显示错误视图
@property (nonatomic)           BOOL        showCardError;

///是否显示头部视图
@property (nonatomic)           BOOL        showCardHeader;

///是否显示尾部视图
@property (nonatomic)           BOOL        showCardFooter;

///是否显示卡片间距
@property (nonatomic)           BOOL        showCardSpacing;

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
@interface CardController (RequestMore)

///是否可加载更多。默认为NO。开启后可响应-didTriggerRequestMoreDataActionInCardsController:协议。
@property (nonatomic)           BOOL        canRequestMoreData;

@end



@protocol CardControllerDelegate <NSObject>

///刷新指定类型的卡片
- (void)refreshCardWithType:(CardType)type animation:(UITableViewRowAnimation)animation;
///刷新指定类型的卡片
- (void)refreshCardWithType:(CardType)type;
//刷新指定类型卡片的数据源
- (void)refreshCardWithType:(CardType)type json:(id)json;

/**
 *  @brief  添加指定Section卡片
 *  @param  cardType    卡片类型
 *  @param  cardContext    刷新数据模型
 *  @param  cardController 刷新controller
 *  @param  index    指定位置
 */
- (void)addSectionWithType:(CardType)cardType
           withCardContext:(CardContext *)cardContext
        withcardController:(CardController *)cardController
                 withIndex:(NSUInteger)index
             withAnimation:(UITableViewRowAnimation)animation;

/**
 *  @brief  删除指定Section卡片
 *  @param  cardType    卡片类型
 *  @param  index    指定位置
 */
- (void)deleteSectionWithType:(CardType)cardType
                    withIndex:(NSUInteger)index
                withAnimation:(UITableViewRowAnimation)animation;

@optional

///通用参数字典。用于请求参数、统计埋点等。
- (NSDictionary *)generalParameters;

@end

