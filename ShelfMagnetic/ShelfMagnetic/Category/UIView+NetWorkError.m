//
//  UIView+NetWorkError.m
//  ShelfMagnetic
//
//  Created by Jenson on 2020/7/5.
//  Copyright © 2020 Jenson. All rights reserved.
//

#import "UIView+NetWorkError.h"
#import <objc/runtime.h>

@implementation UIView (NetWorkError)
- (void)setErrorView:(JEBaseEmptyView *)errorView {
    objc_setAssociatedObject(self, @selector(errorView), errorView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (JEBaseEmptyView *)errorView {
    JEBaseEmptyView *view = objc_getAssociatedObject(self, @selector(errorView));
    if (!view) {
        view = [[JEBaseEmptyView alloc] initWithFrame:CGRectZero];
        view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.errorView = view;
    }
    return view;
}


- (void)showFailedError:(id)target selector:(SEL)selector {
    [self showFailedMessage:nil target:target selector:selector];
}
- (void)showFailedMessage:(NSString *)message target:(id)target selector:(SEL)selector {
    [self showMessage:message errorType:EErrorTypeFailed target:target selector:selector];
}

/**
 *  网络错误提示
 *  提示语：message，默认为"您还没有连接网络"
 *  图片：默认为"error_network"
 *  按钮：默认为"error_refresh"
 */
- (void)showNetworkError:(id)target selector:(SEL)selector {
    [self showNetworkMessage:nil target:target selector:selector];
}
- (void)showNetworkMessage:(NSString *)message target:(id)target selector:(SEL)selector {
    [self showMessage:message errorType:EErrorTypeNoNetwork target:target selector:selector];
}


- (void)showEmptyError:(id)target selector:(SEL)selector {
    [self showEmptyMessage:nil target:target selector:selector];
}

- (void)showEmptyMessage:(NSString *)message target:(id)target selector:(SEL)selector {
    [self showMessage:message errorType:EErrorTypeNoData target:target selector:selector];
}

- (void)showMessage:(NSString *)message errorType:(EErrorType)type target:(id)target selector:(SEL)selector {
    [self.errorView addTarget:target retrySelector:selector];
    self.errorView.errorType = type;
    if (message) {
        self.errorView.errorDescLabel.text = message;
    }
    if (![self.subviews containsObject:self.errorView]) {
        [self addSubview:self.errorView];
    }
    self.errorView.frame = self.bounds;
}
/**
 *  @brief  显示错误提示视图
 *  @param  message     提示语。支持和NSString。
 *  @param  image       图片
 *  @param  params      扩展参数
 *          buttonIcon      UIImage *   按钮图标，默认为nil。设置target和selector时才显示。
 *          paddingTop      CGFloat     上边距，默认自动适配。距屏幕顶端1/4屏幕高度，或整体居中。
 *          paddingBottom   CGFloat     下边距，默认自动适配。距屏幕底端90，或整体居中。
 *  @param  target      点击事件target
 *  @param  selector    点击事件selector
 */
- (void)showErrorMessage:(id)message
                   image:(UIImage *)image
                  params:(NSDictionary *)params
                  target:(id)target
                selector:(SEL)selector {

}

///隐藏并清除提示视图
- (void)hideErrorView {
    [self.errorView removeFromSuperview];
}
@end
