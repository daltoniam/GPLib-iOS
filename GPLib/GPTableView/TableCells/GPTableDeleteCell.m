//
//  GPTableDeleteCell.m
//  GPLib
//
//  Created by Dalton Cherry on 4/26/12.
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

#import "GPTableDeleteCell.h"
#import "GPTableDeleteItem.h"

@implementation GPTableDeleteCell

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) 
    {
        deleteLabel = [[GPPillLabel alloc] init];
        deleteLabel.textColor = [UIColor whiteColor];
        deleteLabel.textShadowBlur = 1;
        deleteLabel.textShadowOffset = CGSizeMake(0, 0.5);
        deleteLabel.textShadowColor = [UIColor blackColor];
        deleteLabel.rounding = 8;
        deleteLabel.textAlignment = UITextAlignmentCenter;
        deleteLabel.drawGloss = YES;
        deleteLabel.fillColor = [UIColor redColor];
        deleteLabel.highlightColor = [UIColor colorWithRed:170/255.0f green:0/255.0f blue:3/255.0f alpha:1];
        deleteLabel.borderColor = [UIColor blackColor];
        deleteLabel.borderWidth = 0.6;
        deleteLabel.font = [UIFont boldSystemFontOfSize:24];
        [self.contentView addSubview:deleteLabel];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.backgroundView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    }
    return self;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)layoutSubviews
{
    [super layoutSubviews];
    CGRect frame = self.contentView.frame;
    deleteLabel.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
}
//////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setObject:(id)object 
{
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    GPTableDeleteItem* item = object;
    deleteLabel.text = item.text;
    if(item.font)
        deleteLabel.font = item.font;
    if(item.color)
        deleteLabel.textColor = item.color;
    if(item.backgroundColor)
        deleteLabel.fillColor = item.backgroundColor;
    if(item.gradientStartColor && item.gradientEndColor)
    {
        deleteLabel.gradientStartColor = item.gradientStartColor;
        deleteLabel.gradientEndColor = item.gradientEndColor;
        deleteLabel.gradientLength = item.gradientLength;
    }
    if(item.textShadowColor)
        deleteLabel.textShadowColor = item.textShadowColor;
    deleteLabel.drawGloss = item.drawGloss;
    if(item.hightlightColor)
        deleteLabel.highlightColor = item.hightlightColor;
    
}
//////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    deleteLabel.isHighlighted = highlighted;
    [deleteLabel setNeedsDisplay];
}
//////////////////////////////////////////////////////////////////////////////////////////////////
-(void)dealloc
{
    [deleteLabel release];
    [super dealloc];
}

@end
