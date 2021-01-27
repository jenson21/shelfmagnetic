//
//  JEHttpManager.m
//  ShelfMagnetic
//
//  Created by Jenson on 2020/7/5.
//  Copyright © 2020 Jenson. All rights reserved.
//

#import "JEHttpManager.h"


#ifdef DEBUG
#define URLLog(FORMAT, ...)  fprintf(stderr,"%s\n",[[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define URLLog(...)
#endif

@implementation JEHttpManager

#pragma mark - request

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
        failure:(void (^)(id error))failure{
    
}

///// GET 请求
//- (NSURLSessionDataTask *)requestGet:(NSString *)url parameters:(NSDictionary *)parameters success:(void (^)(id))success failure:(void (^)(id))failure {
//
//    if (!self.hasNetWork) {
//        if (failure) {
//            failure(nil);
//        }
//        return [NSURLSessionDataTask new];
//    }
//    NSString * identifier = [[[NSUUID UUID] UUIDString] stringByAppendingFormat:@"&%@", [NSString stringWithFormat:@"%lld",[NSDate getDateTimeTOMilliSeconds]]];
//    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithDictionary:parameters];
//    return [self.manager GET:url parameters:data headers:@{@"Client-Trace-Id":identifier} progress:^(NSProgress * _Nonnull downloadProgress) {
//
//    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        [JEHttpManager logInfo:url para:parameters obj:responseObject error:nil Type:0];
//        dispatch_async(dispatch_get_main_queue(), ^{
//
//            NSDictionary * dic;
//            if([responseObject isKindOfClass:[NSData class]]){
//                dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:NULL];
//            }else if([responseObject isKindOfClass:[NSDictionary class]]){
//                dic = responseObject;
//            }else{
//                failure(nil);
//            }
//            if (dic) {
//                //                id datadic = [dic objectForKey:@"data"];
//                int errnoCode = [[dic objectForKey:@"errno"] intValue];
//                if (errnoCode == 0) {
//                    if (success) {
//                        success(dic);
//                    }
//                } else {
//                    NSString * errmsg = [NSString stringWithFormat:@"%@",[dic objectForKey:@"errmsg"]];
//                    if (errmsg && errmsg.length > 0) {
//                        [JELoadingManager showString:errmsg];
//                    }
//                    if (failure) {
//                        failure(dic);
//                    }
//                }
//            }
//        });
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        [JEHttpManager logInfo:url para:parameters obj:nil error:error Type:0];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if (failure) {
//                failure(error);
//            }
//        });
//    }];
//}


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
