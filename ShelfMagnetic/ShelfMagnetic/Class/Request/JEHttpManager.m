//
//  JEHttpManager.m
//  ShelfMagnetic
//
//  Created by Jenson on 2020/7/5.
//  Copyright © 2020 Jenson. All rights reserved.
//

#import "JEHttpManager.h"
#import "AFHTTPSessionManager.h"
#import "JELoadingManager.h"

@class AFNetworkReachabilityManager;

#ifdef DEBUG
#define URLLog(FORMAT, ...)  fprintf(stderr,"%s\n",[[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define URLLog(...)
#endif
@interface JEHttpManager () {

}
@property (nonatomic) AFHTTPSessionManager *manager;
@property (nonatomic, assign) BOOL hasNetWork;
@property (nonatomic, copy, readwrite) NSString * reachabilityStatus;

@end

@implementation JEHttpManager
+ (instancetype)sharedHttpManager{
    static id obj = nil;
    if (obj == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            obj = [[self alloc]init];
        });
    }
    return obj;
}

- (instancetype)init {
    self = [super init];
    if (self) {
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
        [self netWorkStatusChange];
    }
    return self;
}
- (void)cancelAllRequestTasks {
    [_manager.operationQueue cancelAllOperations];
}
/// 监听网络变化
- (void)netWorkStatusChange{
    self.hasNetWork = YES;
    __weak __typeof(&*self)weakSelf = self;
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                break;
            case AFNetworkReachabilityStatusNotReachable:
                weakSelf.reachabilityStatus = @"NotReachable";
                weakSelf.hasNetWork = NO;
                [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"ReachabilityStatus" object:nil userInfo:@{@"netType":@"NotReachable"}]];
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                weakSelf.reachabilityStatus = @"WWAN";
                weakSelf.hasNetWork = YES;
                [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"ReachabilityStatus" object:nil userInfo:@{@"netType":@"WWAN"}]];
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                weakSelf.reachabilityStatus = @"WiFi";
                weakSelf.hasNetWork = YES;
                [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"ReachabilityStatus" object:nil userInfo:@{@"netType":@"WiFi"}]];
                break;
        }
    }];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}


#pragma mark - request
- (NSURLSessionDataTask *)requestGet:(NSString *)url parameters:(NSDictionary *)parameters success:(void (^)(id))success failure:(void (^)(id))failure {

    if (!self.hasNetWork) {
        if (failure) {
            failure(nil);
        }
        return [NSURLSessionDataTask new];
    }
    NSString * identifier = [[[NSUUID UUID] UUIDString] stringByAppendingFormat:@"&%@", [NSString stringWithFormat:@"%lld",@"[NSDate getDateTimeTOMilliSeconds]"]];
    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithDictionary:parameters];
    return [self.manager GET:url parameters:data headers:@{@"Client-Trace-Id":identifier} progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [JEHttpManager logInfo:url para:parameters obj:responseObject error:nil Type:0];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSDictionary * dic;
            if([responseObject isKindOfClass:[NSData class]]){
                dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:NULL];
            }else if([responseObject isKindOfClass:[NSDictionary class]]){
                dic = responseObject;
            }else{
                failure(nil);
            }
            if (dic) {
                //                id datadic = [dic objectForKey:@"data"];
                int errnoCode = [[dic objectForKey:@"errno"] intValue];
                if (errnoCode == 0) {
                    if (success) {
                        success(dic);
                    }
                } else {
                    NSString * errmsg = [NSString stringWithFormat:@"%@",[dic objectForKey:@"errmsg"]];
                    if (errmsg && errmsg.length > 0) {
                        [JELoadingManager showString:errmsg];
                    }
                    if (failure) {
                        failure(dic);
                    }
                }
            }
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [JEHttpManager logInfo:url para:parameters obj:nil error:error Type:0];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (failure) {
                failure(error);
            }
        });
    }];
}


- (NSURLSessionDataTask *)requestPost:(NSString *)url
         parameters:(NSDictionary *)parameters
            success:(void (^)(id responseObject))success
            failure:(void (^)(id))failure {
    if (!self.hasNetWork) {
        if (failure) {
            failure(nil);
        }
        return [NSURLSessionDataTask new];
    }
    NSString * identifier = [[[NSUUID UUID] UUIDString] stringByAppendingFormat:@"&%@", [NSString stringWithFormat:@"%lld",@"[NSDate getDateTimeTOMilliSeconds]"]];
    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithDictionary:parameters];
    return [self.manager POST:url parameters:data headers:@{@"Client-Trace-Id":identifier} progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [JEHttpManager logInfo:url para:parameters obj:responseObject error:nil Type:1];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSDictionary * dic;
            if([responseObject isKindOfClass:[NSData class]]){
                dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:NULL];
            }else if([responseObject isKindOfClass:[NSDictionary class]]){
                dic = responseObject;
            }else{
                if (failure) {
                    failure(nil);
                }
            }
            if (dic) {
//                id datadic = [dic objectForKey:@"data"];
                int errnoCode = [[dic objectForKey:@"errno"] intValue];
                if (errnoCode == 0) {
                    if (success) {
                        success(dic);
                    }
                } else if (errnoCode == 9004) {
                    if (failure) {
                        failure(dic);
                    }
                } else {
                    NSString * errmsg = [dic objectForKey:@"errmsg"];
                    if (errmsg && [errmsg isKindOfClass:[NSString class]] && errmsg.length > 0) {
                        [JELoadingManager showString:responseObject[@"errmsg"]];
                    }
                    if (failure) {
                        failure(dic);
                    }
                }
            }
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [JEHttpManager logInfo:url para:parameters obj:nil error:error Type:1];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (failure) {
                failure(error);
            }
        });
    }];
}


- (NSURLSessionDataTask *)requestHead:(NSString *)url parameters:(NSDictionary *)parameters success:(void (^)(id))success failure:(void (^)(id))failure{
    if (!self.hasNetWork) {
        [JELoadingManager showString:@"当前网络异常,请检查网络设置"];
        failure([NSError errorWithDomain:@"HOST_URL" code:-1012 userInfo:nil]);
        return [NSURLSessionDataTask new];
    }
    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithDictionary:parameters];
    
    return [self.manager HEAD:url parameters:data headers:nil success:^(NSURLSessionDataTask * _Nonnull task) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
        NSDictionary *allHeaders = response.allHeaderFields;
        NSLog(@"header----%@",allHeaders);
        NSLog(@"header----%@",response);

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}


- (NSURLSessionDataTask *)requestPost:(NSString *)url
                           parameters:(NSDictionary *)parameters
                               images:(NSArray*)images
                            imageNames:(NSArray*)imageNames
                   compressionQuality:(CGFloat)compressionQuality
                              success:(void (^)(id responseObject))success
                              failure:(void (^)(NSError *error))failure {
    if (!self.hasNetWork) {
        [JELoadingManager showString:@"当前网络异常,请检查网络设置"];
        failure([NSError errorWithDomain:@"HOST_URL" code:-1012 userInfo:nil]);
        return [NSURLSessionDataTask new];
    }
    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithDictionary:parameters];
    //  headers:nil
    return [_manager POST:url parameters:data headers:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        for (int i = 0; i < images.count ;i++) {
            
            id imagedata = images[i];
            id imageName = imageNames[i];

            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyyMMddHHmmss";
            NSString *str = [formatter stringFromDate:[NSDate date]];
            NSString *fileName = [NSString stringWithFormat:@"%@.jpg",str];
            if ([imagedata isKindOfClass:[UIImage class]]) {
                [formData appendPartWithFileData:UIImageJPEGRepresentation(imagedata, compressionQuality) name: imageName ?:  @"iconImg" fileName:fileName mimeType:@"image/png"];
            } else if ([imagedata isKindOfClass:[NSData class]]) {
                [formData appendPartWithFileData:imagedata name:imageName ? imageName:  @"iconImg" fileName:fileName mimeType:@"image/png"];
            }
        }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [JEHttpManager logInfo:url para:parameters obj:responseObject error:nil Type:1];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary * dic;
            if([responseObject isKindOfClass:[NSData class]]){
                dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:NULL];
            }else if([responseObject isKindOfClass:[NSDictionary class]]){
                dic = responseObject;
            }
            int errnoCode = [[dic objectForKey:@"errno"] intValue];
            if (errnoCode == 0) {
                success(responseObject);
            } else {
                failure(nil);
                if (responseObject[@"errmsg"] && [responseObject[@"errmsg"] length]) {
                    [JELoadingManager showString:responseObject[@"errmsg"]];
                }
            }
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [JEHttpManager logInfo:url para:parameters obj:nil error:error Type:1];
        dispatch_async(dispatch_get_main_queue(), ^{
            failure(error);
        });
    }];
}

- (void)downloadMakeUpFilesUrl:(NSString *)url
                          path:(NSString *)path
                      progress:(void (^)(NSProgress *downloadProgress))progress
                       success:(void (^)(id responseObject))success
                       failure:(void (^)(NSError *error))failure {
    [JELoadingManager showString:@"当前网络异常,请检查网络设置"];
    if (!self.hasNetWork) {
        failure([NSError errorWithDomain:@"HOST_URL" code:-1012 userInfo:nil]);
        return;
    }
    /* 创建网络下载对象 */
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSURLSessionDownloadTask *downloadTask = [self.manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            progress(downloadProgress);
        });
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        return [NSURL fileURLWithPath:path];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                failure(error);
            } else {
                success(response);
            }
        });
        
    }];
    [downloadTask resume];
}

+ (void)logInfo:(NSString *)url para:(NSDictionary *)para obj:(id)obj error:(NSError *)error Type:(NSInteger)type {
    
    if (type == 1) {
        URLLog(@"\n--------POST");
    } else {
        URLLog(@"\n--------GET");
    }
    URLLog(@"url:  %@", url);
    URLLog(@"para: %@", para);
    if (error) {
        URLLog(@"%@", [NSString stringWithFormat:@"\nerrorCode - %ld\ninfo - %@\n--------END\n", (long)error.code,error.description]);
    } else {
        URLLog(@"%@", [NSString stringWithFormat:@"responseObject = %@\n--------END\n", [self convertJSONWithDic:obj]]);
    }
}

//字典转JSON
+(NSString *)convertJSONWithDic:(NSDictionary *)dic {
    NSError *err;
    if (dic) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&err];
        if (err) {
            return @"字典转JSON出错";
        }
        NSString *dicString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        dicString = [dicString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        dicString = [dicString stringByReplacingOccurrencesOfString:@"\t" withString:@""];
        dicString = [dicString stringByReplacingOccurrencesOfString:@" " withString:@""];
        dicString = [dicString stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
        return dicString;
    }
    return @"";
}
@end
