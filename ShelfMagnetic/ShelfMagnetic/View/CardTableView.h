//
//  CardTableView.h
//  YoukuiPhone
//
//  Created by liusx on 15/5/18.
//  Copyright (c) 2015年 Youku.com inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CardsController;
@interface CardTableView : UITableView

@property (nonatomic, weak) NSArray *cardControllersArray;

@property (nonatomic, weak) CardsController *cardsController;


///更新指定section缓存并刷新
- (void)reloadSection:(NSInteger)section;

///更新指定section组缓存并刷新
- (void)reloadSections:(NSArray *)sections;

@end



@interface NSIndexPath (CardTableView)

///列
@property (nonatomic) NSInteger column;

@end
