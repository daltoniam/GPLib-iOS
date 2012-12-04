//
//  GPTableInfoCell.m
//  GPLib
//
//  Created by Dalton Cherry on 12/4/12.
//  Copyright (c) 2012 Lightspeed Systems. All rights reserved.
//

#import "GPTableInfoCell.h"

@implementation GPTableInfoCell

///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setupInfoLabel
{
    infoLabel = [[UILabel alloc] init];
    infoLabel.textColor = [UIColor colorWithRed:56/255.0 green:84/255.0 blue:135/255.0 alpha:1];
    infoLabel.font = [UIFont boldSystemFontOfSize:14];
    infoLabel.textAlignment = UITextAlignmentRight;
    infoLabel.backgroundColor = [UIColor clearColor];
    infoLabel.numberOfLines = 1;
    //[self.contentView addSubview:infoLabel];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setupBadgeLabel
{
    //left blank to disable badges
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)layoutSubviews
{
    [super layoutSubviews];
    int left = TableCellSmallMargin;
    infoLabel.frame = CGRectMake(left, TableCellSmallMargin, 60, self.contentView.frame.size.height-(TableCellSmallMargin*2));
    left += infoLabel.frame.size.width+5;
    self.textLabel.frame = CGRectMake(left, TableCellSmallMargin, self.contentView.frame.size.width-left, self.contentView.frame.size.height-(TableCellSmallMargin*2));
}
//////////////////////////////////////////////////////////////////////////////////////////////////
-(int)infoLabelSpace:(CGRect)textFrame
{
    return textFrame.size.width;
}
//////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setObject:(id)object
{
    [super setObject:object];
    if(!infoLabel)
        [self setupInfoLabel];
    //GPTableTextItem* item = object;
}


@end
