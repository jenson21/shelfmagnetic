//
//  MagneticTableViewCell.m
//  ShelfMagnetic
//
//  Created by Jenson on 2021/7/4.
//  Copyright © 2021 Jenson. All rights reserved.
//

#import "MagneticTableViewCell.h"

@implementation MagneticTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.magneticCellBackground];
    }
    return self;
}

- (UIView *)magneticCellBackground{
    if (!_magneticCellBackground) {
        _magneticCellBackground = [[UIView alloc] init];
        _magneticCellBackground.hidden = YES;
    }
    return _magneticCellBackground;
}

@end
