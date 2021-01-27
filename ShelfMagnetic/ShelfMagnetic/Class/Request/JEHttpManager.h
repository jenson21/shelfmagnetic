//
//  JEHttpManager.h
//  ShelfMagnetic
//
//  Created by Jenson on 2020/7/5.
//  Copyright © 2020 Jenson. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JEHttpManager : NSObject

/// 请求
/// @param requestType 请求类型
/// @param url 全路径
/// @param parameters 请求参数
/// @param success 成功回调
/// @param failure 失败回调
+ (void)requestType:(NSInteger)requestType
                           requestUrl:(NSString *)url
                           parameters:(NSDictionary *)parameters
                              success:(void (^)(id responseObject))success
                              failure:(void (^)(id error))failure;

@end

NS_ASSUME_NONNULL_END
