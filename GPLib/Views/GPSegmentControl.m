//
//  GPSegmentControl.m
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

#import "GPSegmentControl.h"
#import "GPButton.h"
#import <QuartzCore/QuartzCore.h>

@implementation GPSegmentControl

@synthesize startColor,endColor,isMultiSelect,font,textColor,selectedIndex = selectedIndex,segType;
//////////////////////////////////////////////////////////////////////////////////////////////////
-(void)commonInit
{
    self.startColor = [UIColor colorWithWhite:0.9 alpha:1];
    self.endColor = [UIColor colorWithWhite:0.8 alpha:1];
    self.font = [UIFont boldSystemFontOfSize:17];
    self.textColor = [UIColor blackColor];
    self.segType = GPSegmentMiddle;
}
//////////////////////////////////////////////////////////////////////////////////////////////////
-(id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder])
    {
        [self commonInit];
    }
    return self;
}
//////////////////////////////////////////////////////////////////////////////////////////////////
-(id)init
{
    if(self = [super init])
    {
        [self commonInit];
    }
    return self;
}
//////////////////////////////////////////////////////////////////////////////////////////////////
-(id)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        [self commonInit];
    }
    return self;
}
//////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setTarget:(id)target selector:(SEL)selector
{
    [localTarget release];
    localTarget = [target retain];
    localSelector = selector;
}
//////////////////////////////////////////////////////////////////////////////////////////////////
-(void)addSegmentWithTitle:(NSString*)title
{
    [self insertSegmentWithTitle:title atIndex:segItems.count];
}
//////////////////////////////////////////////////////////////////////////////////////////////////
-(void)addSegmentWithImage:(UIImage *)image
{
    [self insertSegmentWithImage:image atIndex:segItems.count];
}
//////////////////////////////////////////////////////////////////////////////////////////////////
-(void)insertSegmentWithTitle:(NSString*)title atIndex:(int)index
{
    [self insertSegment:title image:nil atIndex:index];
}
//////////////////////////////////////////////////////////////////////////////////////////////////
-(void)insertSegmentWithImage:(UIImage *)image atIndex:(int)index
{
    [self insertSegment:nil image:image atIndex:index];
}
//////////////////////////////////////////////////////////////////////////////////////////////////
-(void)removeSegmentAtIndex:(int)index
{
    if(index > 0 && index < [segItems count])
    {
        if(index > 1)
        {
            UIView* view = [lineViews objectAtIndex:index-1];
            [view removeFromSuperview];
            [lineViews removeObject:view];
        }
        GPButton* button = [segItems objectAtIndex:index];
        [button removeFromSuperview];
        [segItems removeObject:button];
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setTitle:(NSString*)title AtIndex:(int)index
{
    if(index >= 0 && index < [segItems count])
    {
        GPButton* button = [segItems objectAtIndex:index];
        [button setImage:nil forState:UIControlStateNormal];
        [button setTitle:title forState:UIControlStateNormal];
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setImage:(UIImage*)image AtIndex:(int)index
{
    if(index >= 0 && index < [segItems count])
    {
        GPButton* button = [segItems objectAtIndex:index];
        [button setImage:image forState:UIControlStateNormal];
        [button setTitle:nil forState:UIControlStateNormal];
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setSelector:(SEL)selector target:(id)target AtIndex:(int)index
{
    if(index >= 0 && index < [segItems count])
    {
        GPButton* button = [segItems objectAtIndex:index];
        if([target respondsToSelector:selector])
            [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////////
-(void)layoutSubviews
{
    [super layoutSubviews];
    int count = segItems.count;
    int width = self.frame.size.width/count;
    int left = 0;
    int i = 0;
    for(UIButton* button in segItems)
    {
        button.frame = CGRectMake(left, 0,width, self.frame.size.height);
        if(i == 0)
        {
            if(self.segType == GPSegmentTop)
                button.layer.mask = [self roundCorner:button corner:UIRectCornerTopLeft];
            else if(self.segType == GPSegmentBottom)
                button.layer.mask = [self roundCorner:button corner:UIRectCornerBottomLeft];
            else if(self.segType == GPSegmentOnly)
                button.layer.mask = [self roundCorner:button corner:UIRectCornerTopLeft|UIRectCornerBottomLeft];
            else
                button.layer.mask = nil;
        }
        else if(i == count-1)
        {
            if(self.segType == GPSegmentTop)
                button.layer.mask = [self roundCorner:button corner:UIRectCornerTopRight];
            else if(self.segType == GPSegmentBottom)
                button.layer.mask = [self roundCorner:button corner:UIRectCornerBottomRight];
            else if(self.segType == GPSegmentOnly)
                button.layer.mask = [self roundCorner:button corner:UIRectCornerTopRight|UIRectCornerBottomRight];
            else
                button.layer.mask = nil;
        }
        
        if(i != 0)
        {
            UIView* line = [lineViews objectAtIndex:i-1];
            line.frame = CGRectMake(left, 0, 1, self.frame.size.height);
            [self bringSubviewToFront:line];
        }
            
        left += width;
        i++;
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setSelectedSegment:(NSInteger)index
{
    if(index >= 0 && index < [segItems count])
    {
        GPButton* button = [segItems objectAtIndex:index];
        if(self.isMultiSelect)
            [button swapButtonState];
        else
            [self swapButton:button];
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////////
-(void)removeAllSegments
{
    [segItems removeAllObjects];
    [lineViews removeAllObjects];
}
//////////////////////////////////////////////////////////////////////////////////////////////////
-(BOOL)isSegmentSelected:(int)index
{
    if(index >= 0 && index < [segItems count])
    {
        GPButton* button = [segItems objectAtIndex:index];
        return button.isSelected;
    }
    return NO;
}
//////////////////////////////////////////////////////////////////////////////////////////////////
//private
//////////////////////////////////////////////////////////////////////////////////////////////////
-(void)insertSegment:(NSString*)title image:(UIImage*)image atIndex:(int)index
{
    if(!segItems)
        segItems = [[NSMutableArray alloc] init];
    GPButton* button = [[[GPButton alloc] init] autorelease];
    button.rounding = 0;
    [button setTitle:title forState:UIControlStateNormal];
    [button setImage:image forState:UIControlStateNormal];
    button.gradientLength = 0.75;
    button.gradientStartColor = self.startColor;
    button.gradientEndColor = self.endColor;
    button.highlightColor = [UIColor colorWithRed:1/255.0f green:95/255.0f blue:230/255.0f alpha:1];
    button.highlightEndColor = [UIColor colorWithRed:5/255.0f green:155/255.0f blue:300/255.0f alpha:1];
    button.titleLabel.font = self.font;
    button.doesPersistent = YES;
    [button setTitleColor:self.textColor forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    button.tag = [segItems count];
    [segItems insertObject:button atIndex:index];
    [self addSubview:button];
    if(!lineViews && segItems.count > 1)
        lineViews = [[NSMutableArray alloc] init];
    if(segItems.count > 1)
        [lineViews addObject:[self lineView]];
}
//////////////////////////////////////////////////////////////////////////////////////////////////
-(void)buttonTapped:(GPButton*)tapButton
{
    [self swapButton:tapButton];
    if([localTarget respondsToSelector:localSelector])
        [localTarget performSelector:localSelector];
}
//////////////////////////////////////////////////////////////////////////////////////////////////
-(void)swapButton:(GPButton*)tapButton
{
    if(self.isMultiSelect)
        return;

    if(selectedIndex == tapButton.tag && !tapButton.isSelected)
        [tapButton swapButtonState];
    
    selectedIndex = tapButton.tag;
    for(GPButton* button in segItems)
    {
        if(button != tapButton && button.isSelected)
            [button swapButtonState];
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////////
-(UIView*)lineView
{
    UIView* view = [[[UIView alloc] init] autorelease];
    view.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:view];
    return view;
}
//////////////////////////////////////////////////////////////////////////////////////////////////
-(CAShapeLayer*)roundCorner:(UIView*)view corner:(UIRectCorner)round
{
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds 
                                                   byRoundingCorners:round
                                                         cornerRadii:CGSizeMake(8.0, 8.0)]; //8.0
    
    maskPath.lineWidth = 1;
    CAShapeLayer *maskLayer = [[[CAShapeLayer alloc] init] autorelease];
    maskLayer.frame = view.bounds;
    maskLayer.path = maskPath.CGPath;
    return maskLayer;
}
//////////////////////////////////////////////////////////////////////////////////////////////////
-(void)dealloc
{
    [segItems release];
    [lineViews release];
    [localTarget release];
    [super dealloc];
}
//////////////////////////////////////////////////////////////////////////////////////////////////

@end
