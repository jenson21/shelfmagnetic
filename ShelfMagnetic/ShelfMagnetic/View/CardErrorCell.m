//
//  CardErrorCell.m
//  YoukuiPhone
//
//  Created by liusx on 15-4-17.
//  Copyright (c) 2015年 Youku.com inc. All rights reserved.
//

#import "CardErrorCell.h"
//#import "BaseLoadingView.h"
//#import "UIView+NetWorkError.h"
//#import "UIColor+Addition.h"

@interface CardErrorCell ()
{
//    BaseLoadingView *_loadingView;
}
@end

@implementation CardErrorCell

- (void)refreshCardErrorView
{
//    CardState state = _cardController.cardContext.state;
//    if (state == CardStateError) { //错误状态
//        NSMutableAttributedString *errorMessage = nil;
//
//        //获取自定义错误描述
//        if ([_cardController respondsToSelector:@selector(cardsController:errorDescriptionWithCode:)]) {
//            NSAttributedString *errorDescription = [_cardController cardsController:_cardController.cardsController
//                                                           errorDescriptionWithCode:_cardController.cardContext.error.code];
//            if ([errorDescription isKindOfClass:[NSMutableAttributedString class]]) {
//                errorMessage = (NSMutableAttributedString *)errorDescription;
//            } else if ([errorDescription isKindOfClass:[NSAttributedString class]]) {
//                errorMessage = [[NSMutableAttributedString alloc] initWithAttributedString:errorDescription];
//            }
//        }
//
//        //默认错误描述
//        if (!errorMessage) {
//            errorMessage = [[NSMutableAttributedString alloc] initWithString:@"获取失败，点击重试"];
//            [errorMessage addAttribute:NSForegroundColorAttributeName
//                                     value:[UIColor ykBlueColor]
//                                     range:NSMakeRange(7, 2)];
//        }
//
//        //字体
//        [errorMessage addAttribute:NSFontAttributeName
//                             value:[UIFont systemFontOfSize:14.0]
//                             range:NSMakeRange(0, errorMessage.length)];
//
//        [self showErrorMessage:errorMessage
//                         image:nil
//                   buttonTitle:nil
//                        target:_cardController
//                      selector:@selector(requestErrorCardData)];
//    } else {
//        [self hideErrorView];
//    }
//
//    if (state == CardStateLoading) { //加载状态
//        if (!_loadingView) {
//            _loadingView = [[BaseLoadingView alloc] initWithFrame:CGRectMake(0.0, 0.0, 100.0, 100.0)]; //给定足够大的尺寸
//            _loadingView.center = self.contentView.center;
//            _loadingView.autoresizingMask = YKViewAutoresizingFlexibleMargin;
//            _loadingView.loadingImage = [UIImage imageNamed:@"card_refresh_loading"];
//        }
//        [self.contentView addSubview:_loadingView];
//
//        [_loadingView startAnimating];
//        [_loadingView setNeedsLayout]; //复用时可能会停止旋转动画，此处强制刷新
//    } else {
//        [_loadingView stopAnimating];
//        [_loadingView removeFromSuperview];
//    }
}

@end
