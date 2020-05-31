//
//  CardErrorCell.h
//  YoukuiPhone
//
//  Created by liusx on 15-4-17.
//  Copyright (c) 2015年 Youku.com inc. All rights reserved.
//

#import "CardController.h"

@interface CardErrorCell : UITableViewCell

@property (nonatomic, weak) CardController *cardController;

///刷新错误视图
- (void)refreshCardErrorView;

@end
