//
//  MagneticDemoRequest.h
//  ShelfMagnetic
//
//  Created by Jian Dong on 2021/1/28.
//  Copyright © 2021 Jenson. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MagneticDemoRequest : NSObject

/// GET 请求
/// @param url 全路径
/// @param parameters 请求参数
/// @param success 成功回调
/// @param failure 失败回调
- (void)requestGet:(NSString *)url
        parameters:(NSDictionary *)parameters
           success:(void (^)(id responseObject))success
           failure:(void (^)(id error))failure;

@end

NS_ASSUME_NONNULL_END
