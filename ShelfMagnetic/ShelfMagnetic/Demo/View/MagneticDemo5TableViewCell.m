//
//  MagneticDemo5TableViewCell.m
//  ShelfMagnetic
//
//  Created by Jenson on 2021/7/4.
//  Copyright © 2021 Jenson. All rights reserved.
//

#import "MagneticDemo5TableViewCell.h"

@interface MagneticDemo5TableViewCell()
@property (nonatomic) UILabel *labelTitle;
@end

@implementation MagneticDemo5TableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _labelTitle = [[UILabel alloc] init];
        _labelTitle.textAlignment = NSTextAlignmentCenter;
        _labelTitle.backgroundColor = UIColor.magentaColor;
        [self.magneticBackground addSubview:_labelTitle];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    _labelTitle.frame = CGRectMake(15, 15, self.magneticBackground.bounds.size.width - 30, self.magneticBackground.bounds.size.height - 30);
}

- (void)setContent:(NSString *)content{
    _content = content;
    _labelTitle.text = _content;
}

@end
