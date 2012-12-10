//
//  GPTableGroupButtonCell.m
//  GPLib
//
//  Created by Dalton Cherry on 12/10/12.
//  Copyright (c) 2012 Lightspeed Systems. All rights reserved.
//

#import "GPTableGroupButtonCell.h"
#import "GPTableGroupButtonItem.h"

@implementation GPTableGroupButtonCell

///////////////////////////////////////////////////////////////////////////////////////////////////
+ (CGFloat)tableView:(UITableView*)tableView rowHeightForObject:(id)object
{
    return 54;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        leftButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
        rightButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
        [self.contentView addSubview:leftButton];
        [self.contentView addSubview:rightButton];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.backgroundView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    }
    return self;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)layoutSubviews
{
    //[super layoutSubviews];
    CGRect frame = self.contentView.frame;
    int top = 5;
    int left = TableCellSmallMargin*2;
    int space = 10;
    int width = (frame.size.width/2) - ((space/2) + left);
    int height = 44;
    if([leftButton titleForState:UIControlStateNormal].length > 0)
        leftButton.frame = CGRectMake(left, top, width, height);
    else
        leftButton.frame = CGRectZero;
    
    left += width+space;
    [rightButton titleForState:UIControlStateNormal];
    if([rightButton titleForState:UIControlStateNormal].length > 0)
        rightButton.frame = CGRectMake(left, top, width, height);
    else
        rightButton.frame = CGRectZero;
}
//////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setObject:(id)object
{
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    GPTableGroupButtonItem* item = object;
    leftButton.titleLabel.font = rightButton.titleLabel.font = item.font;
    if(item.color)
    {
        [leftButton setTitleColor:item.color forState:UIControlStateNormal];
        [rightButton setTitleColor:item.color forState:UIControlStateNormal];
    }
    if(item.backgroundColor)
        leftButton.backgroundColor = rightButton.backgroundColor = item.backgroundColor;
    
    [leftButton setTitle:item.leftButtonText forState:UIControlStateNormal];
    [rightButton setTitle:item.rightButtonText forState:UIControlStateNormal];
    
    [leftButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [rightButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    
    [leftButton addTarget:self.delegate action:item.leftSelector forControlEvents:UIControlEventTouchUpInside];
    [rightButton addTarget:self.delegate action:item.rightSelector forControlEvents:UIControlEventTouchUpInside];
    
    leftButton.tag = item.leftTag;
    rightButton.tag = item.rightTag;
}
//////////////////////////////////////////////////////////////////////////////////////////////////
-(void)dealloc
{
    [leftButton release];
    [rightButton release];
    [super dealloc];
}
//////////////////////////////////////////////////////////////////////////////////////////////////

@end
