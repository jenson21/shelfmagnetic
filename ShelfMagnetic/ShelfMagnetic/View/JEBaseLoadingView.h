//
//  JEBaseLoadingView.h
//  ShelfMagnetic
//
//  Created by Jenson on 2020/7/5.
//  Copyright © 2020 Jenson. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JEBaseLoadingView : UIView
///旋转动画的图片。若未设置，默认加载通用loading动画。
@property (nonatomic) UIImage *loadingImage;

///开始动画
- (void)startAnimating;

///停止动画
- (void)stopAnimating;
@end

NS_ASSUME_NONNULL_END
