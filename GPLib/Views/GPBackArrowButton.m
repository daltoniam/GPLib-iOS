//
//  GPBackArrowButton.m
//  GPLib
//
//  Created by Dalton Cherry on 5/31/12.
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

#import "GPBackArrowButton.h"
#import <QuartzCore/QuartzCore.h>
#import "GPDrawExtras.h"

@implementation GPBackArrowButton

@synthesize arrowWidth;

//////////////////////////////////////////////////////////////////////////////////////////////
-(void)Commoninit
{    
    [self bringSubviewToFront:self.imageView];
    self.rounding = 5;
    self.gradientLength = 0.55;
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.titleLabel.font = [UIFont systemFontOfSize:12];
    self.titleLabel.textColor = [UIColor blackColor];
    self.fillColor = [UIColor blackColor];
    self.arrowWidth = 10;
    self.drawInsetShadow = YES;
	//self.layer.borderWidth = 1.0f; 
    //self.highlightColor = [UIColor colorWithRed:1/255.0f green:97/255.0f blue:231/255.0f alpha:1.0];
    //self.gradientStartColor = [UIColor whiteColor];
	//self.gradientEndColor = [UIColor grayColor];
}
//////////////////////////////////////////////////////////////////////////////////////////////
-(id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) 
    {
        [self Commoninit];
    }
    return self;
}
//////////////////////////////////////////////////////////////////////////////////////////////
-(id) initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) 
    {
        [self Commoninit];
    }
    return self;
}
//////////////////////////////////////////////////////////////////////////////////////////////
-(id)init
{
    if ((self = [super init])) 
    {
        [self Commoninit];
    }
    return self;
}
//////////////////////////////////////////////////////////////////////////////////////////////
- (void)drawRect:(CGRect)rect 
{
    int width = self.bounds.size.width;
    int height = self.bounds.size.height;
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    if(self.borderWidth)
    {
        CGContextSetLineJoin(ctx, kCGLineJoinRound);
        CGContextSetLineWidth(ctx, self.borderWidth);
        CGContextSetStrokeColorWithColor(ctx, self.borderColor.CGColor);
    }
    
    if(isSelected && self.highlightColor)
        CGContextSetFillColorWithColor(ctx, self.highlightColor.CGColor);
    else
        CGContextSetFillColorWithColor(ctx, self.fillColor.CGColor);
    
    /*if(self.rounding > 0)
        [GPDrawExtras drawRoundRect:ctx width:width height:height rounding:self.rounding stroke:self.borderWidth];
    else
    {
        self.layer.borderWidth = self.borderWidth;
        self.layer.borderColor = self.borderColor.CGColor;
    }*/
    //new code
    
    //[GPDrawExtras drawRoundRect:ctx width:width height:height rounding:self.rounding stroke:self.borderWidth];
    int pad = self.borderWidth + 0.5f;
    if(self.borderWidth <= 0)
        pad = 0;
    CGFloat rounding = self.rounding - self.borderWidth;
    CGContextMoveToPoint(ctx, pad, self.frame.size.height/2);
    CGContextAddLineToPoint(ctx, arrowWidth,pad);
    CGContextAddArcToPoint(ctx, width, pad,width,height+pad, rounding);
    CGContextAddArcToPoint(ctx, width-pad, height, round((width-pad) / 2.0f),height,rounding);
    CGContextAddArcToPoint(ctx,pad+arrowWidth,height,pad,pad+arrowWidth,0);
    CGContextAddLineToPoint(ctx, pad,self.frame.size.height/2);
    
    CGContextClosePath(ctx);
    if(self.borderWidth)
        CGContextDrawPath(ctx, kCGPathFillStroke);
    else
        CGContextDrawPath(ctx, kCGPathFill);
    
    if(!self.borderWidth && rounding > 2)
        rounding -= 2;
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, pad, self.frame.size.height/2);
    CGContextAddLineToPoint(ctx, arrowWidth,pad);
    CGContextAddArcToPoint(ctx, width, pad,width,height+pad, rounding);
    CGContextAddArcToPoint(ctx, width-pad, height, round((width-pad) / 2.0f),height,rounding);
    CGContextAddArcToPoint(ctx,pad+arrowWidth,height,pad,pad+arrowWidth,0);
    CGContextAddLineToPoint(ctx, pad,self.frame.size.height/2);
    CGContextClosePath(ctx);
    CGContextClip(ctx);
    
    CGRect currentFrame = self.bounds;
    
    if (self.gradientStartColor && self.gradientEndColor)
    {
        if(isSelected)
        {
            if(self.highlightColor)
                [GPDrawExtras drawLinearGradient:ctx start:self.highlightColor end:self.highlightColor rect:currentFrame endLoc:self.gradientLength];
            else
                [GPDrawExtras drawLinearGradient:ctx start:self.gradientEndColor end:self.gradientStartColor rect:currentFrame endLoc:self.gradientLength]; //swap the gradient backwards
        }
        else
            [GPDrawExtras drawLinearGradient:ctx start:self.gradientStartColor end:self.gradientEndColor rect:currentFrame endLoc:self.gradientLength];
    }
    else if(self.highlightColor)
    {
        if(isSelected)
            [GPDrawExtras drawLinearGradient:ctx start:self.highlightColor end:self.highlightColor rect:currentFrame endLoc:self.gradientLength];
    }
    
    if(self.drawGloss)
    {
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        [GPDrawExtras drawGloss:ctx rect:self.bounds];
    }
    if(self.drawInsetShadow)
    {
        UIColor* color = [UIColor blackColor];
        [GPDrawExtras drawInsetShadow:ctx rect:self.bounds rounding:self.rounding color:color];
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////

@end
