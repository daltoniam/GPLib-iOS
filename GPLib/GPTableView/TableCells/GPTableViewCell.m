//
//  GPTableViewCell.m
//  GPLib
//
//  Created by Dalton Cherry on 1/27/12.
//  Copyright (c) 2012 Basement Crew/180 Dev Designs. All rights reserved.
//
/*
 http://github.com/daltoniam/GPLib-iOS
 
 Permission is hereby granted, free of charge, to any person
 obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without
 restriction, including without limitation the rights to use,
 copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following
 conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.
 */
//

#import "GPTableViewCell.h"
#import "GPTableViewItem.h"

@implementation GPTableViewCell


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (CGFloat)tableView:(UITableView*)tableView rowHeightForObject:(id)object 
{
    float height = 44;
    if([object isKindOfClass:[GPTableViewItem class]])
    {
        GPTableViewItem* item = object;
        if(item.View.frame.size.height > 44)
            height = item.View.frame.size.height;
    }
    else if([object isKindOfClass:[UIView class]])
    {
        UIView* view = object;
        if(view.frame.size.height > 44)
            height = view.frame.size.height;
    }
    return height;
}
//////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setObject:(id)object 
{
    if([object isKindOfClass:[GPTableViewItem class]])
    {
        GPTableViewItem* item = object;
        if([item.View isKindOfClass:[UISwitch class]])
            [super setObject:object];

        if(View != item.View)
        {
            [View removeFromSuperview];
            View = [item.View retain];
            [self.contentView addSubview:View];
        }
    }
    else if([object isKindOfClass:[UIView class]])
    {
        UIView* view = object;
        if(View != view)
        {
            [View removeFromSuperview];
            View = [view retain];
            [self.contentView addSubview:View];
        }
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////////
-(void)layoutSubviews
{
    [super layoutSubviews];
    if([View isKindOfClass:[UISwitch class]])
    {
        CGRect frame =  self.textLabel.frame;
        frame.size.width -= View.frame.size.width;
        self.textLabel.frame = frame;
        frame = View.frame;
        frame.origin.y = (self.contentView.frame.size.height/2) - (View.frame.size.height/2);
        frame.origin.x = self.contentView.frame.size.width - (View.frame.size.width + TableCellSmallMargin);
        View.frame = frame;
    }
    else if([View isKindOfClass:[UISegmentedControl class]])
        View.frame = CGRectMake(0, 0.5, self.contentView.frame.size.width, self.contentView.frame.size.height-0.1);
    else
        View.frame = CGRectMake(TableCellSmallMargin, TableCellSmallMargin, 
                            self.contentView.bounds.size.width-TableCellSmallMargin*2, self.contentView.bounds.size.height-TableCellSmallMargin*2);
    View.backgroundColor = [UIColor clearColor];
}
//////////////////////////////////////////////////////////////////////////////////////////////////
-(void)dealloc
{
    [View release];
    [super dealloc];
}
//////////////////////////////////////////////////////////////////////////////////////////////////
@end
