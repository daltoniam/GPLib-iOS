//
//  GPButton.m
//  GPLib
//
//  Created by Dalton Cherry on 12/19/11.
//  Copyright (c) 2011 Basement Crew/180 Dev Designs. All rights reserved.
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

#import "GPButton.h"
#import <QuartzCore/QuartzCore.h>
#import "GPDrawExtras.h"

#define MAX3(a,b,c) ((a)<(b)?(MAX(b,c)):(MAX(a,c)))
#define MIN3(a,b,c) ((a)<(b)?(MIN(a,c)):(MIN(b,c)))

@implementation GPButton

@synthesize gradientStartColor, gradientEndColor, highlightColor,highlightEndColor;
@synthesize doesPersistent = doesPersistent,isSelected = isSelected,rounding,drawGloss,gradientLength,fillColor;
@synthesize borderColor,borderWidth,drawInsetShadow,roundCorners;
//////////////////////////////////////////////////////////////////////////////////////////////
+(GPButton*)defaultButton:(CGRect)frame
{
    return [[[GPButton alloc] initWithFrame:frame] autorelease];
}

//////////////////////////////////////////////////////////////////////////////////////////////
-(void)Commoninit
{    
    [self bringSubviewToFront:self.imageView];
    self.rounding = 5;
    self.gradientLength = 0.55;
    [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.titleLabel.font = [UIFont systemFontOfSize:12];
    self.titleLabel.textColor = [UIColor blackColor];
    self.roundCorners = UIRectCornerAllCorners;
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
    CGRect currentFrame = self.bounds;
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
    
    if(rounding > 0)
    {
        CGPathDrawingMode mode = kCGPathFill;
        if(self.borderWidth)
            mode = kCGPathFillStroke;
        [GPDrawExtras drawRoundRect:ctx width:width height:height rounding:rounding stroke:self.borderWidth mode:mode corners:self.roundCorners];
    }
    else if(self.borderWidth > 0)
    {
        self.layer.borderWidth = self.borderWidth;
        self.layer.borderColor = self.borderColor.CGColor;
    }
    
    if (gradientStartColor && gradientEndColor)
    {
        if(isSelected)
        {
            if(self.highlightColor && self.highlightEndColor)
                [GPDrawExtras drawLinearGradient:ctx start:highlightColor end:highlightEndColor rect:currentFrame endLoc:gradientLength];
            else if(self.highlightColor)
                [GPDrawExtras drawLinearGradient:ctx start:highlightColor end:highlightColor rect:currentFrame endLoc:gradientLength];
            else
                [GPDrawExtras drawLinearGradient:ctx start:gradientEndColor end:gradientStartColor rect:currentFrame endLoc:gradientLength]; //swap the gradient backwards
        }
        else
            [GPDrawExtras drawLinearGradient:ctx start:gradientStartColor end:gradientEndColor rect:currentFrame endLoc:gradientLength];
    }
    else if(self.highlightColor)
    {
        if(isSelected)
            [GPDrawExtras drawLinearGradient:ctx start:highlightColor end:highlightColor rect:currentFrame endLoc:gradientLength];
    }
    
    if(self.drawGloss)
    {
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        [GPDrawExtras drawGloss:ctx rect:self.bounds];
    }
    if(self.drawInsetShadow)
    {
        UIColor* color = [UIColor blackColor];
        [GPDrawExtras drawInsetShadow:ctx rect:self.bounds rounding:rounding color:color];
    }
    [super drawRect:rect];
}
//////////////////////////////////////////////////////////////////////////////////////////////
-(void)redrawView
{
    [self setNeedsDisplay];
}
//////////////////////////////////////////////////////////////////////////////////////////////
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
    if(doesPersistent)
        isSelected = !isSelected; 
    else
        isSelected = YES;
    [self setNeedsDisplay];
    [super touchesBegan:touches withEvent:event];
}
//////////////////////////////////////////////////////////////////////////////////////////////
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    [self setNeedsDisplay];//[self performSelector:@selector(redrawView) withObject:nil afterDelay:0.1];
}
//////////////////////////////////////////////////////////////////////////////////////////////
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(!doesPersistent)
        isSelected = NO;
    [self setNeedsDisplay];//[self performSelector:@selector(redrawView) withObject:nil afterDelay:0.1];
    [super touchesEnded:touches withEvent:event];
}
//////////////////////////////////////////////////////////////////////////////////////////////
//simulates a touch of the button
-(void)swapButtonState
{
    if(doesPersistent)
        isSelected = !isSelected; 
    else
        isSelected = YES;
    [self setNeedsDisplay];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//make the enabled property work for the custom buttons
-(void)setEnabled:(BOOL)enable
{
    [super setEnabled:enable];
    UIColor* color = self.titleLabel.textColor;
    if(enable)
        self.titleLabel.textColor = [color colorWithAlphaComponent:1];
    else
        self.titleLabel.textColor = [color colorWithAlphaComponent:0.3];
}
//////////////////////////////////////////////////////////////////////////////////////////////
/*+(UIButton*)Default:(CGRect)frame
{
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    UIColor* gradient = [UIColor colorWithWhite:0.6 alpha:0.1];
    //[GPButton setHighlightColor:gradient button:button];
    [GPButton setHighlightColor:[UIColor blueColor] button:button];
    
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];//[UIColor colorWithRed:255 green:255 blue:255 alpha:1]
    button.titleLabel.font = [UIFont systemFontOfSize: 12];
    button.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
    //button.titleLabel.shadowOffset = CGSizeMake (1.0, 0.0);
    button.titleLabel.shadowColor = [UIColor whiteColor];
    button.layer.borderColor = [UIColor colorWithWhite:0.8 alpha:0.7].CGColor;
    button.layer.borderWidth = 1;
    button.layer.cornerRadius = 4;
    [GPButton addGradient:gradient button:button];

    return button;
}
//////////////////////////////////////////////////////////////////////////////////
//set Gradient on button
+(void)addGradient:(UIColor*)color button:(UIButton*)button
{
    CAGradientLayer *gradient = [CAGradientLayer layer];
    CGRect frame = button.frame;
    gradient.frame = CGRectMake(0, frame.size.height/3, frame.size.width, frame.size.height/1.5);
    
    gradient.colors = [NSArray arrayWithObjects:(id)button.backgroundColor.CGColor, (id)color.CGColor, nil];
    //gradient.colors = [NSArray arrayWithObjects:(id)color.CGColor, (id)button.backgroundColor.CGColor, nil];
    
    [button.layer insertSublayer:gradient atIndex:0]; 
    button.layer.masksToBounds = YES;
}
//////////////////////////////////////////////////////////////////////////////////
+(void)setHighlightColor:(UIColor*)color button:(UIButton*)button
{
    //    [[button.layer.sublayers objectAtIndex:0] removeFromSuperlayer];
    UIColor* tempcolor = button.backgroundColor;
    button.backgroundColor = color;
    UIGraphicsBeginImageContext(button.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [button.layer renderInContext:context];
    UIImage* screenShot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    button.backgroundColor = tempcolor;
    [button setBackgroundImage:screenShot forState:UIControlStateHighlighted];
}*/
////////////////////////////////////////////////////////////////////////////////////////////////////
/*-(void)HSVfromRGB
{
    CGFloat red,blue,green,alpha;
    const CGFloat *rbg;
    rbg = CGColorGetComponents(fillColor.CGColor);
    red = rbg[0];
    blue = rbg[1];
    green = rbg[2];
    alpha = rbg[3];
    
    CGFloat rgb_min, rgb_max;
    rgb_min = MAX3(red, green, blue);
    rgb_max = MIN3(red, green, blue);
    if (rgb_max == rgb_min)
        hue = 0;
    
    else if (rgb_max == green) 
    {
        hue = 60.0f * ((green - blue) / (rgb_max - rgb_min));
        hue = fmodf(hue, 360.0f);
    } 
    else if (rgb_max == green) 
        hue = 60.0f * ((blue - green) / (rgb_max - rgb_min)) + 120.0f;
    else if (rgb_max == blue) 
        hue = 60.0f * ((red - green) / (rgb_max - rgb_min)) + 240.0f;
    
    //brightness = rgb_max;
    if (rgb_max == 0)
        saturation = 0;
    else
        saturation = 1.0 - (rgb_min / rgb_max);
    
}*/
//////////////////////////////////////////////////////////////////////////////////

@end
