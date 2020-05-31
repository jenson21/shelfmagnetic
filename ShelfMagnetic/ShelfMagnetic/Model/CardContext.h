//
//  CardContext.h
//  YoukuiPhone
//
//  Created by yanghu on 14-7-28.
//  Copyright (c) 2014年 Youku.com inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

///卡片类型
typedef NS_ENUM(NSInteger, CardType) {
    CardTypeHomeBanner = 1000,
    CardTypeHomeFive = 1001,
    CardTypeHomeSecondkill = 1002,
    CardTypeHomeTodayNew = 1003,
    CardTypeHomeYiYuanGou = 1004,
    CardTypeHomeMeiZhuang = 1005,
    CardTypeHomeMuYing = 1006,
    CardTypeHomeQingShe = 1007,
    CardTypeHomeZhuanTi = 1008,
    CardTypeHomeCaiNiXiHuan = 1009,
    CardTypeHomeDynamicWeb = 1010,
    CardTypeHomeFeatureAreaTop = 1011,
    CardTypeHomeNewUser = 1012,
    CardTypeHomeGradient = 1013,

    CardTypeImageView         = 2000,
    
    
    CardTypeMineOrder   = 1100,// 个人中心订单
    CardTypeMineShuffling  = 1101,// 个人中心轮播图
    CardTypeMineActivity = 1102,// 个人中心优惠活动
    CardTypeMineService = 1103,// 个人中心我的服务
    CardTypeMineCaiNiXiHuan = 1104,


    CardTypeGoodsDetailCard  = 1200,
    CardTypeGoodsBrandCard  = 1201,
    CardTypeGoodsLikeCard  = 1202,
    CardTypeGoodsDetailDesCard = 1203,
    CardTypeGoodsDiscussCard  = 1204,
    CardTypeGoodsGiveCard   = 1205,

    //   会员中心非会员状态

    CardTypeNonMeberDiscount  = 1300,
    CardTypeNonMeberHalf     = 1301,
    CardTypeNonMeberOneBuy   = 1302,
    CardTypeNonMeberCoupon   = 1303,
    CardTypeNonMeberMeDay    = 1304,
    CardTypeNonMeberGift     = 1305,
    CardTypeNonMeberExclusive = 1306,//专属八大特权
    CardTypeNonMeberExperience = 1307,
    CardTypeMemberTask        = 1308,
    CardTypeOperateCard        = 1309,
    CardTypeMeberCost   = 1310,
    CardTypeMeberHalf  = 1311,
    

    CardTypeCreactArticleTitle  = 1400,
    CardTypeCreactArticleContent     = 1401,
    CardTypeCreactArticlePhoto   = 1402,
    CardTypeCreactArticleGoods   = 1403,
    
    CardTypeArticleInfoBanner   = 1404,
    CardTypeArticleInfoAuthor   = 1405,
    CardTypeArticleInfoContent   = 1406,
    CardTypeArticleInfoGoods   = 1407,
    CardTypeArticleInfoComments   = 1408,
    CardTypeArticleInfoRecommended   = 1409,

    //购物车
    CardTypeShopCard       = 1500,

};
///卡片状态
typedef NS_ENUM(NSInteger, CardState) {
    ///默认状态
    CardStateNormal,
    ///加载状态
    CardStateLoading,
    ///错误状态
    CardStateError,
};

///卡片错误类型
typedef NS_ENUM(NSInteger, CardErrorCode) {
    ///无错误
    CardErrorCodeNone       = 0,
    ///网络错误
    CardErrorCodeNetwork    = -9900,
    ///数据错误
    CardErrorCodeFailed     = -9901,
};

@class CardContext;

@interface CardHeaderContext : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIImage *titleIcon;
@property (nonatomic, copy) NSString *titleIconUrl;
// 那个模块的推荐
@property (nonatomic, copy)NSString *modular;
@property (nonatomic, copy) NSString *desc;
// 小标题
@property (nonatomic, strong) NSString *littleStr;
// 小图标
@property (nonatomic, copy) NSString *icon;
@property (nonatomic, strong) UIImage *descIcon;
@property (nonatomic, copy) NSString *descIconUrl;
/**
 背景图片
 */
@property (nonatomic, copy) NSString *backgroundImageViewName;

///是否有更多，如果yes则有箭头
@property (nonatomic, assign) BOOL extend;

@property (nonatomic, weak) CardContext *cardContext;
@end



@interface CardContext : NSObject
///组件id
@property (nonatomic, copy)     NSString        *cardId;

///header
@property (nonatomic, strong)   CardHeaderContext *headerContext;

///类型
@property (nonatomic)           CardType        type;

///状态
@property (nonatomic)           CardState       state;

///卡片控制器Class
@property (nonatomic, copy)     NSString        *clazz;

///标题
//@property (nonatomic, copy)     NSString        *title;

///描述
//@property (nonatomic, copy)     NSString        *descrip;

///卡片信息（CMS配置的原始数据）
@property (nonatomic, strong)   NSDictionary    *cardInfo;

///数据源,可为model
@property (nonatomic, strong)   id              json;

///错误
@property (nonatomic, strong)   NSError         *error;

///卡片顺序
@property (nonatomic, assign)   NSInteger       cardIndex;

///是否支持加载更多
@property (nonatomic)           BOOL            hasMore;

///是否异步请求
@property (nonatomic, assign)   BOOL            asyncLoad;
//
@property (nonatomic, assign)   NSInteger       currentIndex;

/**
 *  Extension
 *  @brief 扩展区
 */

///扩展区类型
@property (nonatomic)           CardType        extensionType;

///扩展控制器Class
@property (nonatomic, copy)     NSString        *extensionClazz;

@end
