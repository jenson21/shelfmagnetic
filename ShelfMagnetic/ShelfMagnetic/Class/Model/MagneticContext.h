//
//  MagneticContext.h
//  ShelfMagnetic
//
//  Created by Jenson on 2020/5/31.
//  Copyright © 2020 Jenson. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

//磁片类型
typedef NS_ENUM(NSInteger, MagneticType) {
    MagneticTypeDemo = 1000,
    MagneticTypeDemo2 = 1001,
    MagneticTypeDemo3 = 1002,
    MagneticTypeDemo4 = 1003
};
///磁片状态
typedef NS_ENUM(NSInteger, MagneticState) {
    ///默认状态
    MagneticStateNormal,
    ///加载状态
    MagneticStateLoading,
    ///错误状态
    MagneticStateError,
};

///磁片错误类型
typedef NS_ENUM(NSInteger, MagneticErrorCode) {
    ///无错误
    MagneticErrorCodeNone       = 0,
    ///网络错误
    MagneticErrorCodeNetwork    = -5500,
    ///数据错误
    MagneticErrorCodeFailed     = -5501,
};

@class MagneticContext;

@interface MagneticHeaderContext : NSObject

@property (nonatomic, weak) MagneticContext *magneticContext;
@end

@interface MagneticContext : NSObject

///header
@property (nonatomic) MagneticHeaderContext *headerContext;

///磁片控制器Class
@property (nonatomic, copy) NSString *clazz;

///组件id
@property (nonatomic, copy) NSString *magneticId;

///磁片顺序
@property (nonatomic, assign) NSInteger magneticIndex;

///是否支持加载更多
@property (nonatomic, assign) BOOL hasMore;

///是否异步请求
@property (nonatomic, assign) BOOL asyncLoad;
@property (nonatomic, assign) NSInteger currentIndex;

///类型
@property (nonatomic) MagneticType type;

///状态
@property (nonatomic) MagneticState state;

///磁片信息（CMS配置的原始数据）
@property (nonatomic) NSDictionary *magneticInfo;

///数据源,可为model
@property (nonatomic) id json;

///错误
@property (nonatomic) NSError * __nullable error;

/**
 *  Extension
 *  @brief 扩展区
 */

///扩展区类型
@property (nonatomic) MagneticType extensionType;

///扩展控制器Class
@property (nonatomic, copy) NSString *extensionClazz;
// 数据源是否更改
@property (nonatomic, assign) BOOL isChange;
@end

NS_ASSUME_NONNULL_END
