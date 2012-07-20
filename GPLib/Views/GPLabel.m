//
//  GPLabel.m
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

#import "GPLabel.h"
#import "GPDrawExtras.h"

@implementation GPLabel

@synthesize textShadowColor,textShadowBlur,textShadowOffset,gradientStartColor,gradientEndColor,gradientLength,radialRadius,drawGloss;
@synthesize isHighlighted,highlightColor;
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)commonInit
{
    textShadowBlur = 4;
    textShadowOffset = CGSizeMake(0, 0);
    gradientLength = 0.55;
    //startGlossColor = [[UIColor colorWithWhite:1.0 alpha:0.5] retain];
    //endGlossColor = [[UIColor clearColor] retain];
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
-(void) drawTextInRect:(CGRect)rect 
{
    if(textShadowColor)
    {
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextSaveGState(ctx);
        
        CGContextSetShadow(ctx, textShadowOffset, textShadowBlur);
        CGContextSetShadowWithColor(ctx, textShadowOffset, textShadowBlur, textShadowColor.CGColor);
        
        [super drawTextInRect:rect];
        CGContextRestoreGState(ctx);
    }
    else
        [super drawTextInRect:rect];
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)drawRect:(CGRect)rect
{
    if(gradientStartColor && gradientEndColor)
    {
        CGRect currentFrame = self.bounds;
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        //CGContextTranslateCTM(ctx, 0, rect.size.height);
        //CGContextScaleCTM(ctx, 1.0, -1.0);
        if(gradientLength > 1)
            gradientLength = 1;
        if(gradientLength < 0)
            gradientLength = 0;
        if(radialRadius > 0)
        {
            CGPoint center = CGPointMake(CGRectGetMidX(currentFrame), CGRectGetMidY(currentFrame));
            [GPDrawExtras drawRadialGradient:ctx start:gradientStartColor end:gradientEndColor point:center radius:radialRadius endLoc:gradientLength];
        }
        else
        {
            if(self.highlighted && self.highlightColor)
                [GPDrawExtras drawLinearGradient:ctx start:highlightColor end:highlightColor rect:currentFrame endLoc:gradientLength];
            else
                [GPDrawExtras drawLinearGradient:ctx start:gradientStartColor end:gradientEndColor rect:currentFrame endLoc:gradientLength];
        }
    }
    if(self.drawGloss)
    {
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        [GPDrawExtras drawGloss:ctx rect:self.bounds];
    }

    [super drawRect:rect];
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)dealloc
{
    [startGlossColor release];
    [endGlossColor release];
    [super dealloc];
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//handy way to make a cool incrementing label (for stats or something)
-(void)incrementToValue:(int)endValue speed:(float)speed
{
    incrementValue = endValue;
    self.text = [NSString stringWithFormat:@"0"];
    [NSTimer scheduledTimerWithTimeInterval:speed
                                     target:self
                                   selector:@selector(incrementNow:)
                                   userInfo:nil
                                    repeats:YES];
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)incrementNow:(NSTimer*)timer
{
    int value = [self.text intValue];
    value++;
    self.text = [NSString stringWithFormat:@"%d",value];
    if(value == incrementValue)
    {
        [timer invalidate];
        incrementValue = 0;
    }
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setAppearanceFont:(UIFont *)appearanceFont
{
    if([self.font isEqual:[UIFont systemFontOfSize:17]])
        self.font = appearanceFont;
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(UIFont*)appearanceFont
{
    return self.font;
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@end
