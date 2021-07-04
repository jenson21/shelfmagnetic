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
        _labelTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, 200)];
        _labelTitle.textAlignment = NSTextAlignmentCenter;
        _labelTitle.backgroundColor = [UIColor magentaColor];
        [self.contentView addSubview:_labelTitle];
    }
    return self;
}

- (void)setContent:(NSString *)content{
    _content = content;
    _labelTitle.text = _content;
}

@end
