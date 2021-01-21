//
//  MagneticTableView.h
//  ShelfMagnetic
//
//  Created by Jenson on 2020/5/31.
//  Copyright © 2020 Jenson. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MagneticsController;
@interface MagneticTableView : UITableView

@property (nonatomic, weak) NSArray *magneticControllersArray;
@property (nonatomic, weak) MagneticsController *magneticsController;

///更新指定section缓存并刷新
- (void)reloadSection:(NSInteger)section;

///更新指定section组缓存并刷新
- (void)reloadSections:(NSArray *)sections;

@end

@interface NSIndexPath (MagneticTableView)
///列
@property (nonatomic, assign) NSInteger column;

@end
NS_ASSUME_NONNULL_END
