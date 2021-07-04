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
        [self.contentView addSubview:self.magneticBackground];
    }
    return self;
}

- (UIView *)magneticBackground{
    if (!_magneticBackground) {
        _magneticBackground = [[UIView alloc] init];
        _magneticBackground.hidden = YES;
    }
    return _magneticBackground;
}

@end
