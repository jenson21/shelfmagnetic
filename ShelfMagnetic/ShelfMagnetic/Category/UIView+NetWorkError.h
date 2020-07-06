//
//  UIView+NetWorkError.h
//  ShelfMagnetic
//
//  Created by Jenson on 2020/7/5.
//  Copyright © 2020 Jenson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JEBaseEmptyView.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIView (NetWorkError)
@property (nonatomic) JEBaseEmptyView *errorView;


- (void)showFailedError:(id)target selector:(SEL)selector;
- (void)showFailedMessage:(NSString *)message target:(id)target selector:(SEL)selector;
/**
 *  网络错误提示
 *  提示语：message，默认为"您还没有连接网络"
 *  图片：默认为"error_network"
 *  按钮：默认为"error_refresh"
 */
- (void)showNetworkError:(id)target selector:(SEL)selector;
- (void)showNetworkMessage:(NSString *)message target:(id)target selector:(SEL)selector;

/**
 *  默认空数据提示
 *  提示语：message，默认为"未获取到内容"
 *  图片：默认为"error_empty"
 *  按钮：默认为nil
 */
- (void)showEmptyError:(id)target selector:(SEL)selector;
- (void)showEmptyMessage:(NSString *)message target:(id)target selector:(SEL)selector;

///隐藏并清除提示视图
- (void)hideErrorView;
@end

NS_ASSUME_NONNULL_END
