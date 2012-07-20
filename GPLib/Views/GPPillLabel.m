//
//  GPPillLabel.m
//  GPLib
//
//  Created by Dalton Cherry on 4/25/12.
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

#import "GPPillLabel.h"
#import "GPDrawExtras.h"
#import <QuartzCore/QuartzCore.h>

@implementation GPPillLabel

@synthesize isHighlighted,highlightColor,fillColor,rounding,borderColor,borderWidth;
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)commonInit
{
    self.backgroundColor = [UIColor clearColor];
    //[UIColor colorWithRed:2/255.0f green:110/255.0f blue:236/255.0f alpha:1];
    self.highlightColor = [UIColor whiteColor];
    self.textColor = [UIColor whiteColor];//[UIColor colorWithRed:143/255.0f green:178/255.0f blue:203/255.0f alpha:1];
    self.rounding = 9;
    self.textAlignment = UITextAlignmentCenter;
    //self.font = [UIFont boldSystemFontOfSize:17];
    self.borderWidth = 0;
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        [self commonInit];
    }
    return self;
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) 
    {
        [self commonInit];
    }
    return self;
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)drawRect:(CGRect)rect
{
    if(!self.fillColor)
        self.fillColor = [UIColor colorWithRed:127/255.0f green:127/255.0f blue:127/255.0f alpha:1];
    int width = self.bounds.size.width;
    int height = self.bounds.size.height;
    //float border = 0.5; // 0.5
    //int pad =0;
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    //CGContextSetLineJoin(ctx, kCGLineJoinRound);
    //CGContextSetLineWidth(ctx, 0);
    //CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
    
    if(self.borderWidth)
    {
        CGContextSetLineJoin(ctx, kCGLineJoinRound);
        CGContextSetLineWidth(ctx, self.borderWidth);
        CGContextSetStrokeColorWithColor(ctx, self.borderColor.CGColor);
    }
    if(self.highlighted)
        CGContextSetFillColorWithColor(ctx, self.highlightColor.CGColor);
    else
        CGContextSetFillColorWithColor(ctx, self.fillColor.CGColor);
    
    if(rounding > 0)
        [GPDrawExtras drawRoundRect:ctx width:width height:height rounding:rounding stroke:self.borderWidth];
    else
    {
        self.layer.borderWidth = self.borderWidth;
        self.layer.borderColor = self.borderColor.CGColor;
    }
    /*CGContextMoveToPoint(ctx,rounding, 0);
    
    CGContextAddArcToPoint(ctx, width, pad,width,height, rounding);
    CGContextAddArcToPoint(ctx, width, height-pad, round(width / 2.0f),height,rounding);
    CGContextAddArcToPoint(ctx,pad,height,pad,pad,rounding);
    CGContextAddArcToPoint(ctx,pad,pad,width,pad,rounding);
    
    CGContextClosePath(ctx);
    CGContextDrawPath(ctx, kCGPathFillStroke);
    
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx,0,0);
    CGContextAddArcToPoint(ctx, width, pad, width, height, rounding);
    CGContextAddArcToPoint(ctx, width, height-pad, round(width / 2.0f), height,rounding);
    CGContextAddArcToPoint(ctx, pad,height, pad, pad, rounding);
    CGContextAddArcToPoint(ctx, pad,pad,width, pad, rounding);
    CGContextClosePath(ctx);
    CGContextClip(ctx);*/
    
    if(pillGloss)
    {
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        [GPDrawExtras drawGloss:ctx rect:self.bounds];
    }
    
    [super drawRect:rect];
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setDrawGloss:(BOOL)drawGloss
{
    pillGloss = drawGloss;
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//factories
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+(GPPillLabel*)mailBubble
{
    GPPillLabel* bubbleItem = [[[GPPillLabel alloc] initWithFrame:CGRectZero] autorelease];
    bubbleItem.fillColor = [UIColor colorWithRed:221/255.0f green:231/255.0f blue:248/255.0f alpha:1];
    //bubbleItem.gradientStartColor = [UIColor colorFromRGB:221 green:231 blue:248 alpha:1];
    //bubbleItem.gradientEndColor = [UIColor colorFromRGB:211 green:221 blue:238 alpha:1];
    bubbleItem.gradientLength = 0.5;
    bubbleItem.font = [UIFont systemFontOfSize:14];
    bubbleItem.textColor = [UIColor blackColor];
    bubbleItem.borderWidth = 0.3;
    bubbleItem.borderColor = [UIColor colorWithRed:57/255.0f green:107/255.0f blue:194/255.0f alpha:1];
    return bubbleItem;
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@end
