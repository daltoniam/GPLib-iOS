//
//  DrawExtras.m
//  GPLib
//
//  Created by Dalton Cherry on 3/27/12.
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

#import "GPDrawExtras.h"
#import <QuartzCore/QuartzCore.h>

@implementation GPDrawExtras

///////////////////////////////////////////////////////////////////////////////////////////////////
+(UIImage*)drawBorderAroundImage:(UIImage*)image color:(UIColor*)color width:(CGFloat)borderWidth
{
    return [GPDrawExtras drawBorderAroundImage:image color:color width:borderWidth rounding:0];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
+(UIImage*)drawBorderAroundImage:(UIImage*)image color:(UIColor*)color width:(CGFloat)borderWidth rounding:(CGFloat)radius
{
    return [GPDrawExtras drawBorderAroundImage:image color:color width:borderWidth rounding:radius outside:NO];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
+(UIImage*)drawBorderAroundImage:(UIImage*)image color:(UIColor*)color width:(CGFloat)borderWidth rounding:(CGFloat)radius outside:(BOOL)outside
{
    CGImageRef bgimage = [image CGImage];
	float width = CGImageGetWidth(bgimage);
	float height = CGImageGetHeight(bgimage);
    
    // Create a temporary texture data buffer
	void *data = malloc(width * height * 4);
    
	// Draw image to buffer
	CGContextRef ctx = CGBitmapContextCreate(data,width,height,8,width * 4,CGImageGetColorSpace(image.CGImage),kCGImageAlphaPremultipliedLast);
    if(!ctx)
    {
        free(data);
        return image;
    }
	CGContextDrawImage(ctx, CGRectMake(0, 0, (CGFloat)width, (CGFloat)height), bgimage);
	//Set the stroke (pen) color
    CGContextSetStrokeColorWithColor(ctx, color.CGColor);
	//Set the width of the pen mark
	CGContextSetLineWidth(ctx, borderWidth);
    CGContextSetShadowWithColor (ctx, CGSizeMake(0.5, 0.5), 1, [UIColor blackColor].CGColor);
    if(outside)
    {
        CGContextMoveToPoint(ctx, 0.0, 0.0);	
        CGContextAddLineToPoint(ctx, 0.0, height);
        CGContextAddLineToPoint(ctx, width, height);
        CGContextAddLineToPoint(ctx, width, 0.0);
        CGContextAddLineToPoint(ctx, 0.0, 0.0);
        CGContextStrokePath(ctx);
    }
    else
        [GPDrawExtras drawRoundRect:ctx width:width height:height rounding:radius stroke:borderWidth mode:kCGPathStroke];
    
    // write it to a new image
	CGImageRef cgimage = CGBitmapContextCreateImage(ctx);
	UIImage* newImage = [UIImage imageWithCGImage:cgimage];
    if(cgimage)
        CFRelease(cgimage);
	CGContextRelease(ctx);
    free(data);
    return newImage;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
+(void)drawLinearGradient:(CGContextRef)ctx start:(UIColor*)startColor end:(UIColor*)endColor rect:(CGRect)frame endLoc:(CGFloat)end
{
    CGContextSaveGState(ctx);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = { 0.0, end }; //1.0 //0.55
    NSArray *colors = [NSArray arrayWithObjects:(id)startColor.CGColor, (id)endColor.CGColor, nil];
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef) colors, locations);
    
    CGPoint startPoint = CGPointMake(CGRectGetMidX(frame),0);
    CGPoint endPoint = CGPointMake(CGRectGetMidX(frame), CGRectGetMaxY(frame));
    //CGContextSaveGState(ctx);
    CGContextDrawLinearGradient(ctx, gradient, startPoint, endPoint, 0);
    //CGContextRestoreGState(ctx);
    
    CGColorSpaceRelease(colorSpace);
    CGGradientRelease(gradient);
    CGContextRestoreGState(ctx);
}
///////////////////////////////////////////////////////////////////////////////////////////////////
+(void)drawRadialGradient:(CGContextRef)ctx start:(UIColor*)startColor end:(UIColor*)endColor point:(CGPoint)point radius:(CGFloat)radius endLoc:(CGFloat)end
{
    CGContextSaveGState(ctx);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = { 0.0, end }; //1.0 //0.55
    NSArray *colors = [NSArray arrayWithObjects:(id)startColor.CGColor, (id)endColor.CGColor, nil];
    
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef) colors, locations);
    //CGContextSaveGState(ctx);
    CGContextDrawRadialGradient(ctx, gradient, point, 0, point, radius, kCGGradientDrawsAfterEndLocation);
    //CGContextRestoreGState(ctx);
    
    CGColorSpaceRelease(colorSpace);
    CGGradientRelease(gradient);
    CGContextRestoreGState(ctx);
}
///////////////////////////////////////////////////////////////////////////////////////////////////
+(void)drawGloss:(CGContextRef)ctx rect:(CGRect)frame
{
    CGRect temp = frame;
    temp.size.height = temp.size.height/2;
    [GPDrawExtras drawLinearGradient:ctx start:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.35] end:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.1] rect:temp endLoc:1];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
+(CGFloat)roundRectCornerRounding:(UIRectCorner)corners check:(UIRectCorner)desired rounding:(CGFloat)rounding
{
    if(corners & desired)
        return rounding;
    return 0;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
+(void)drawRoundRect:(CGContextRef)ctx width:(int)width height:(int)height rounding:(CGFloat)radius stroke:(CGFloat)strokeWidth mode:(CGPathDrawingMode)mode corners:(UIRectCorner)corners
{
    int pad = strokeWidth + 0.5f;
    if(strokeWidth <= 0)
        pad = 0;
    int h = height - strokeWidth;
    int w = width - strokeWidth;
    
    CGFloat rounding = radius - strokeWidth;
    CGContextMoveToPoint(ctx,rounding+pad, pad);
    CGContextAddArcToPoint(ctx, w, pad,w,h+pad, [GPDrawExtras roundRectCornerRounding:corners check:UIRectCornerTopRight rounding:rounding]); //top left
    CGContextAddArcToPoint(ctx, w, h, round(w / 2.0f),h,[GPDrawExtras roundRectCornerRounding:corners check:UIRectCornerBottomRight rounding:rounding]); //bottom right
    CGContextAddArcToPoint(ctx,pad,h,pad,pad,[GPDrawExtras roundRectCornerRounding:corners check:UIRectCornerBottomLeft rounding:rounding]); //bottom left
    CGContextAddArcToPoint(ctx,pad,pad,w,pad,[GPDrawExtras roundRectCornerRounding:corners check:UIRectCornerTopLeft rounding:rounding]); //top right
    
    CGContextClosePath(ctx);
    CGContextDrawPath(ctx,mode);
    
    if(!strokeWidth && rounding > 2)
        rounding -= 2;
    
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx,rounding+pad,pad); 
    CGContextAddArcToPoint(ctx, w, pad, w, h+pad, [GPDrawExtras roundRectCornerRounding:corners check:UIRectCornerTopRight rounding:rounding]);//top left
    CGContextAddArcToPoint(ctx, w, h, round(w / 2.0f), h,[GPDrawExtras roundRectCornerRounding:corners check:UIRectCornerBottomRight rounding:rounding]);//bottom right
    CGContextAddArcToPoint(ctx, pad,h, pad, pad, [GPDrawExtras roundRectCornerRounding:corners check:UIRectCornerBottomLeft rounding:rounding]);//bottom left
    CGContextAddArcToPoint(ctx, pad,pad,w, pad, [GPDrawExtras roundRectCornerRounding:corners check:UIRectCornerTopLeft rounding:rounding]);//top right
    CGContextClosePath(ctx);
    CGContextClip(ctx);
}
///////////////////////////////////////////////////////////////////////////////////////////////////
+(void)drawRoundRect:(CGContextRef)ctx width:(int)width height:(int)height rounding:(CGFloat)radius stroke:(CGFloat)strokeWidth mode:(CGPathDrawingMode)mode
{
    return [GPDrawExtras drawRoundRect:ctx width:width height:height rounding:radius stroke:strokeWidth mode:mode corners:UIRectCornerAllCorners];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
+(void)drawRoundRect:(CGContextRef)ctx width:(int)width height:(int)height rounding:(CGFloat)radius stroke:(CGFloat)strokeWidth
{
    CGPathDrawingMode mode = kCGPathFill;
    if(strokeWidth)
        mode = kCGPathFillStroke;
    [self drawRoundRect:ctx width:width height:height rounding:radius stroke:strokeWidth mode:mode];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
+(void)drawInsetShadow:(CGContextRef)ctx rect:(CGRect)frame rounding:(CGFloat)radius color:(UIColor*)color
{
    CGContextSaveGState(ctx);
    CGPathRef roundedRect = [UIBezierPath bezierPathWithRoundedRect:frame cornerRadius:radius].CGPath;
    CGContextAddPath(ctx, roundedRect);
    CGContextClip(ctx);
    
    CGContextAddPath(ctx, roundedRect);
    CGContextSetShadowWithColor(ctx, CGSizeMake(0, 0), 3, color.CGColor);
    CGContextSetStrokeColorWithColor(ctx, color.CGColor);
    CGContextStrokePath(ctx);
    CGContextRestoreGState(ctx);
}
//////////////////////////////////////////////////////////////////////////////////////////////////
+(void)roundCorners:(UIView*)view corner:(UIRectCorner)round rounding:(float)rounding
{
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds
                                                   byRoundingCorners:round
                                                         cornerRadii:CGSizeMake(rounding, rounding)]; //8.0
    
    maskPath.lineWidth = 1;
    CAShapeLayer *maskLayer = [[[CAShapeLayer alloc] init] autorelease];
    maskLayer.frame = view.bounds;
    maskLayer.path = maskPath.CGPath;
    view.layer.mask = maskLayer;
}
///////////////////////////////////////////////////////////////////////////////////////////////////

@end
