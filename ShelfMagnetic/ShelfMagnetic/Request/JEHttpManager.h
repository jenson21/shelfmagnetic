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
/// 当前网络网络状态
@property (nonatomic, copy, readonly) NSString * reachabilityStatus;

+ (instancetype)sharedHttpManager;
/// GET 请求
/// @param url 全路径
/// @param parameters 请求参数
/// @param success 成功回调
/// @param failure 失败回调
- (NSURLSessionDataTask  *)requestGet:(NSString *)url
        parameters:(NSDictionary *)parameters
           success:(void (^)(id responseObject))success
           failure:(void (^)(id error))failure;
/// POST 请求
/// @param url 全路径
/// @param parameters 请求参数
/// @param success 成功回调
/// @param failure 失败回调
- (NSURLSessionDataTask  *)requestPost:(NSString *)url
         parameters:(NSDictionary *)parameters
            success:(void (^)(id responseObject))success
            failure:(void (^)(id error))failure;
/// HEAD 请求
/// @param url 全路径
/// @param parameters 请求参数
/// @param success 成功回调
/// @param failure 失败回调
- (NSURLSessionDataTask *)requestHead:(NSString *)url
        parameters:(NSDictionary *)parameters
        success:(void (^)(id responseObject))success
        failure:(void (^)(id error))failure;


/// 多张图上传
/// @param url 全路径
/// @param parameters 请求参数
/// @param images 图片
/// @param imageNames 上床图片的文件名称
/// @param compressionQuality 压缩比例
/// @param success 成功回调
/// @param failure 失败回调
//- (NSURLSessionDataTask *)requestPost:(NSString *)url
//        parameters:(NSDictionary *)parameters
//            images:(NSArray*)images
//         imageNames:(NSArray*)imageNames
//compressionQuality:(CGFloat)compressionQuality
//           success:(void (^)(id responseObject))success
//           failure:(void (^)(NSError *error))failure;

//下载试妆资源包
- (void)downloadMakeUpFilesUrl:(NSString *)url
                          path:(NSString *)path
                      progress:(void (^)(NSProgress *downloadProgress))progress
                       success:(void (^)(id responseObject))success
                       failure:(void (^)(NSError *error))failure;
/// 取消所有请求
- (void)cancelAllRequestTasks;
@end

NS_ASSUME_NONNULL_END
