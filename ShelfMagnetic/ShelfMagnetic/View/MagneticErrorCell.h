//
//  MagneticErrorCell.h
//  ShelfMagnetic
//
//  Created by Jenson on 2020/5/31.
//  Copyright © 2020 Jenson. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#import "MagneticController.h"

@interface MagneticErrorCell : UITableViewCell
@property (nonatomic, weak) MagneticController *MagneticController;

///刷新错误视图
- (void)refreshMagneticErrorView;
@end

NS_ASSUME_NONNULL_END
