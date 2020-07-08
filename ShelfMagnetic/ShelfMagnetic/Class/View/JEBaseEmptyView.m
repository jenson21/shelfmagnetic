//
//  JEBaseEmptyView.m
//  ShelfMagnetic
//
//  Created by Jenson on 2020/7/5.
//  Copyright © 2020 Jenson. All rights reserved.
//

#import "JEBaseEmptyView.h"

@interface JEBaseEmptyView ()
@property (nonatomic, strong) id target;
@property (nonatomic) SEL selector;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong, readwrite) UIImageView *errorIconView;
@property (nonatomic, strong, readwrite) UILabel *errorDescLabel;
@property (nonatomic, strong) UIButton *retryButton;
@end

@implementation JEBaseEmptyView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor whiteColor];
        self.contentView = [[UIView alloc] initWithFrame:CGRectZero];

        self.errorIconView = [[UIImageView alloc] initWithFrame:CGRectZero];

        self.errorDescLabel = [[UILabel alloc] init];
        self.errorDescLabel.font = [UIFont systemFontOfSize:13];
        self.errorDescLabel.textColor = [UIColor grayColor];
        self.errorDescLabel.textAlignment = NSTextAlignmentCenter;

        self.retryButton = [[UIButton alloc] init];
        [self.retryButton setTitle:@"点击重试" forState:UIControlStateNormal];
        [self.retryButton addTarget:self action:@selector(retryButtonActionClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.retryButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        self.retryButton.titleLabel.font = [UIFont systemFontOfSize:13];
        self.retryButton.layer.cornerRadius = 16;
        self.retryButton.layer.borderColor = [UIColor grayColor].CGColor;
        self.retryButton.layer.borderWidth = 0.8;

        [self.contentView addSubview:self.errorIconView];
        [self.contentView addSubview:self.errorDescLabel];
        [self.contentView addSubview:self.retryButton];
        [self addSubview:self.contentView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat contentW = self.bounds.size.width;
    CGFloat contentH = self.errorIconView.image.size.height + 18 + (!self.retryButton.hidden ? 41 + 31 : 0);
    self.contentView.frame = CGRectMake((self.bounds.size.width - contentW)/2.0, (self.bounds.size.height - contentH)/2.0, contentW, contentH);
    if (self.errorIconView.image) {
        CGSize iconSize = self.errorIconView.image.size;
        self.errorIconView.frame = CGRectMake((contentW - iconSize.width)/2.0, 0, iconSize.width, iconSize.height);
    }
    self.errorDescLabel.frame = CGRectMake(0, self.errorIconView.frame.origin.y + self.errorIconView.frame.size.height, self.contentView.bounds.size.width, 18);
    self.retryButton.frame = CGRectMake((contentW - 85)/2.0, self.errorDescLabel.frame.origin.y + self.errorDescLabel.frame.size.height + 41, 85, 31);

}

- (void)setErrorType:(EErrorType)errorType {
    switch (errorType) {
        case EErrorTypeFailed: {
            self.retryButton.hidden = NO;
            self.errorIconView.image = [UIImage imageNamed:@"common_failed_icon"];
            self.errorDescLabel.text = @"数据获取失败，请重试";
        }
            break;
        case EErrorTypeNoData: {
            self.retryButton.hidden = YES;
            self.errorIconView.image = [UIImage imageNamed:@"common_failed_icon"];
            self.errorDescLabel.text = @"暂无数据";
        }
            break;
        case EErrorTypeNoNetwork: {
            self.retryButton.hidden = NO;
            self.errorIconView.image = [UIImage imageNamed:@"common_neterror_icon"];
            self.errorDescLabel.text = @"数据获取失败，请重试";
        }
            break;

        default:
            break;
    }
    [self setNeedsLayout];
}

- (void)addTarget:(id)target retrySelector:(SEL)selector {
    _target = target;
    _selector = selector;
}

- (void)retryButtonActionClick:(UIButton *)sender {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if ([_target respondsToSelector:_selector]) {
        [_target performSelector:_selector withObject:sender];
    }
#pragma clang diagnostic pop
}

@end
