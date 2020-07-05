//
//  MagneticErrorCell.h
//  ShelfMagnetic
//
//  Created by Jenson on 2020/5/31.
//  Copyright © 2020 Jenson. All rights reserved.
//

#import "MagneticController.h"
#import "UIView+NetWorkError.h"

NS_ASSUME_NONNULL_BEGIN

@interface MagneticErrorCell : UITableViewCell

@property (nonatomic, weak) MagneticController *magneticController;

///刷新错误视图
- (void)refreshMagneticErrorView;

@end

NS_ASSUME_NONNULL_END
