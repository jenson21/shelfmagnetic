//
//  JEBaseEmptyView.h
//  ShelfMagnetic
//
//  Created by Jenson on 2020/7/5.
//  Copyright © 2020 Jenson. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, EErrorType){
    EErrorTypeFailed,   //加载失败
    EErrorTypeNoData,   //无数据
    EErrorTypeNoNetwork //无网
};
@interface JEBaseEmptyView : UIView
@property (nonatomic, assign) EErrorType errorType;
@property (nonatomic, strong, readonly) UIImageView *errorIconView;
@property (nonatomic, strong, readonly) UILabel *errorDescLabel;

- (void)addTarget:(id)target retrySelector:(SEL)selector;
@end

NS_ASSUME_NONNULL_END
