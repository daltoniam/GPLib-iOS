//
//  GPTablePadCell.m
//  GPLib
//
//  Created by Dalton Cherry on 11/8/12.
//  Copyright (c) 2012 Lightspeed Systems. All rights reserved.
//

#import "GPTablePadCell.h"
#import "GPTablePadItem.h"

@implementation GPTablePadCell

///////////////////////////////////////////////////////////////////////////////////////////////////
+ (CGFloat)tableView:(UITableView*)tableView rowHeightForObject:(id)object
{
    GPTablePadItem* item = object;
    return item.padHeight;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.contentView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)layoutSubviews
{
    [super layoutSubviews];
    self.textLabel.frame = CGRectZero;
}
//////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setObject:(id)object
{
    self.accessoryType = UITableViewCellAccessoryNone;
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
}
//////////////////////////////////////////////////////////////////////////////////////////////////


@end
