//
//  GPTableSegmentCell.m
//  test
//
//  Created by Dalton Cherry on 7/30/12.
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

#import "GPTableSegmentCell.h"
#import "GPTableSegmentItem.h"

@implementation GPTableSegmentCell

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) 
    {
        segControl = [[GPSegmentControl alloc] init];
        [self.contentView addSubview:segControl];
        [segControl removeSegmentAtIndex:3];
        //self.backgroundView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    }
    return self;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)layoutSubviews
{
    [super layoutSubviews];
    CGRect frame = self.contentView.frame;
    segControl.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
}
//////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setObject:(id)object 
{
    GPTableSegmentItem* item = (GPTableSegmentItem*)object;
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    [segControl removeAllSegments];
    if(item.startColor)
        segControl.startColor = item.startColor;
    if(item.endColor)
        segControl.endColor = item.endColor;
    if(item.font)
        segControl.font = item.font;
    if(item.textColor)
        segControl.textColor = item.textColor;
    int i = 0;
    for(id obj in item.segments)
    {
        if([obj isKindOfClass:[GPTableSegmentItemProps class]])
        {
            GPTableSegmentItemProps* props = (GPTableSegmentItemProps*)obj;
            if(props.title)
                [segControl addSegmentWithTitle:props.title];
            else
                [segControl addSegmentWithImage:props.image];
            if(props.isSelected)
                [segControl setSelectedSegment:i];
            if(props.buttonTap && item.target)
                [segControl setSelector:props.buttonTap target:item.target AtIndex:i];
        }
        else if([obj isKindOfClass:[UIImage class]])
            [segControl addSegmentWithImage:obj];
        else
            [segControl addSegmentWithTitle:obj];
        i++;
    }
    segControl.segType = item.segType;
    segControl.isMultiSelect = item.isMultiSelect;
    if(!item.isMultiSelect)
        [segControl setSelectedSegment:item.selectedIndex];
}
//////////////////////////////////////////////////////////////////////////////////////////////////
-(void)dealloc
{
    [segControl release];
    [super dealloc];
}
//////////////////////////////////////////////////////////////////////////////////////////////////
@end
