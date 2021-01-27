//
//  MagneticDemoRequest.m
//  ShelfMagnetic
//
//  Created by Jenson on 2021/1/28.
//  Copyright © 2021 Jenson. All rights reserved.
//

#import "MagneticDemoRequest.h"
#import "AFHTTPSessionManager.h"

@interface MagneticDemoRequest ()

@property (nonatomic) AFHTTPSessionManager *manager;
@property (nonatomic, assign) BOOL hasNetWork;
@property (nonatomic, copy, readwrite) NSString * reachabilityStatus;

@end

@implementation MagneticDemoRequest

/// GET 请求
/// @param url 全路径
/// @param parameters 请求参数
/// @param success 成功回调
/// @param failure 失败回调
- (void)requestGet:(NSString *)url
        parameters:(NSDictionary *)parameters
           success:(void (^)(id responseObject))success
           failure:(void (^)(id error))failure{
    
    [self.manager GET:url parameters:parameters headers:@{} progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSDictionary * dic;
            if([responseObject isKindOfClass:[NSData class]]){
                dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:NULL];
            }else if([responseObject isKindOfClass:[NSDictionary class]]){
                dic = responseObject;
            }else{
                failure(nil);
            }
            if (success) {
                success(dic);
            }
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (failure) {
                failure(error);
            }
        });
    }];
    
}

- (AFHTTPSessionManager *)manager{
    if (!_manager) {
        _manager = [[AFHTTPSessionManager manager] initWithBaseURL:[NSURL URLWithString:@"HOST_URL"]];
        [_manager operationQueue].maxConcurrentOperationCount = 5;
        _manager.requestSerializer = [AFHTTPRequestSerializer serializer]; // 上传普通格式
        // 超时时间
        _manager.requestSerializer.timeoutInterval = 15;
        // 设置请求头
        [_manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        // 设置接收的Content-Type
        _manager.responseSerializer.acceptableContentTypes = [[NSSet alloc] initWithObjects:@"application/xml", @"text/xml",@"text/html", @"application/json",@"text/plain",nil];
        [_manager.requestSerializer setValue:@"" forHTTPHeaderField:@"Set-Cookie"];
    }
    return _manager;
}

@end
