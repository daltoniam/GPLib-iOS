//
//  GPBubbleView.m
//  GPLib
//
//  Created by Dalton Cherry on 12/7/11.
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

#import "GPBubbleView.h"
#import <QuartzCore/QuartzCore.h>
#import "GPDrawExtras.h"

@implementation GPBubbleView

@synthesize BorderColor,BorderWidth,BorderRadius,TriangleSize,FillColor,GradientColor,adjustSubviews,textLabel,drawGloss,drawInsetShadow;

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)Setup
{
    self.BorderColor = [UIColor blackColor];
    self.BorderRadius = 8;
    self.FillColor = [UIColor whiteColor];
    self.BorderWidth = 0.5;
    self.TriangleSize = CGSizeMake(8, 8);
    self.backgroundColor = [UIColor clearColor];
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(0, 1);
    self.layer.shadowOpacity = 0.5;
    self.layer.shadowRadius = 1.0;
    self.layer.shouldRasterize = YES;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+(GPBubbleView*)textItem:(UIColor*)fill text:(NSString*)text
{
    GPBubbleView* view = [[[GPBubbleView alloc] initWithFrame:CGRectZero] autorelease];
    view.BorderColor = fill;
    view.BorderRadius = 8;
    view.FillColor = fill;
    view.BorderWidth = 0.2;
    view.adjustSubviews = YES;
    view.TriangleSize = CGSizeMake(0, 0);
    view.backgroundColor = [UIColor clearColor];
    UILabel* label = [[UILabel alloc] init];
    label.text = text;
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = UITextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:14];
    [view addSubview:label];
    view.textLabel = label;
    [label release];
    view.layer.shadowOffset = CGSizeMake(0, 0);
    view.layer.shadowOpacity = 0;
    view.layer.shadowRadius = 0;
    return view;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+(GPBubbleView*)badgeItem:(NSString*)text
{
    GPBubbleView* view = [[[GPBubbleView alloc] initWithFrame:CGRectZero] autorelease];
    view.BorderColor = [UIColor whiteColor];
    view.BorderRadius = 14; //14
    view.FillColor = [UIColor redColor];
    view.BorderWidth = 5;
    view.GradientColor = [UIColor whiteColor];
    view.TriangleSize = CGSizeMake(0, 0);
    view.drawGloss = YES;
    int width = 30;
    if(text.length > 2)
    {
        text = [text substringToIndex:2];
        text = [text stringByAppendingString:@"+"];
        width = 40;
    }
    view.frame = CGRectMake(0, 0, width, 30);
    view.backgroundColor = [UIColor clearColor];
    UILabel* label = [[UILabel alloc] init];
    label.text = text;
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = UITextAlignmentCenter; 
    label.font = [UIFont boldSystemFontOfSize:17]; //17
    label.textColor = [UIColor whiteColor];
    label.frame = CGRectMake(0, 0, width, 29);
    [view addSubview:label];
    view.textLabel = label;
    [label release];
    view.layer.shadowOffset = CGSizeMake(0, 0);
    view.layer.shadowOpacity = 0;
    view.layer.shadowRadius = 0;
    return view;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(id)init
{
    if((self= [super init]))
    {
        [self Setup];
    }
    return self;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(id)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        [self Setup];
    }
    return self;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)layoutSubviews
{
    [super layoutSubviews];
    if(self.adjustSubviews)
    {
        for(UIView* view in self.subviews)
            view.frame = CGRectMake(self.BorderRadius, self.BorderRadius/2, self.frame.size.width-self.BorderRadius*2, self.frame.size.height-self.BorderRadius);
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)updateBadgeText:(NSString*)text
{
    int width = 30;
    if(text.length > 2)
    {
        text = [text substringToIndex:2];
        text = [text stringByAppendingString:@"+"];
        width = 40;
    }
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
    
    frame = textLabel.frame;
    frame.size.width = width;
    textLabel.frame = frame;
    textLabel.text = text;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect currentFrame = self.bounds;

    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextSetLineWidth(context, self.BorderWidth);
    CGContextSetStrokeColorWithColor(context, self.BorderColor.CGColor); 
    CGContextSetFillColorWithColor(context, self.FillColor.CGColor);
    
    
    float pad = BorderWidth + 0.5f;
    float width = currentFrame.size.width - BorderWidth - 0.5f;
    float height = currentFrame.size.height - BorderWidth - 0.5f;
    float rounding = BorderRadius - BorderWidth;
    float pos = TriangleSize.height*2 + TriangleSize.width;//(height/4) + TriangleSize.width; //height/2
    
    CGContextMoveToPoint(context,pad+ TriangleSize.width + rounding, pad);

    CGContextAddArcToPoint(context, 
                           width, 
                           pad, 
                           width, 
                           height, 
                           rounding);
    //right
    CGContextAddArcToPoint(context, 
                           width, 
                           height, 
                           round(width / 2.0f), 
                           height, 
                           rounding);
    //bottom
    CGContextAddArcToPoint(context, 
                           pad + TriangleSize.width,
                           height, 
                           pad, 
                           pad , 
                           rounding);
    if(TriangleSize.height > 0)
    {
        CGContextAddLineToPoint(context, TriangleSize.width,pos + TriangleSize.height);
        CGContextAddLineToPoint(context, 0,pos);
        CGContextAddLineToPoint(context, TriangleSize.width,pos - TriangleSize.height);
    }
    //left
    CGContextAddArcToPoint(context, 
                           pad + TriangleSize.width,
                           pad,
                           width, 
                           pad, 
                           rounding);
    
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathFillStroke);
    
    
    // Draw a clipping path for the fill
    CGContextBeginPath(context);
    CGContextMoveToPoint(context,pad*3 + TriangleSize.width, pad);
    CGContextAddArcToPoint(context, width, pad, width, height, rounding);
    CGContextAddArcToPoint(context, width, height, round(width / 2.0f), height,rounding);
    CGContextAddArcToPoint(context, pad + TriangleSize.width,height, pad, pad, rounding);
    if(TriangleSize.height > 0)
    {
        CGContextAddLineToPoint(context, TriangleSize.width,pos + TriangleSize.height);
        CGContextAddLineToPoint(context, 0,pos);
        CGContextAddLineToPoint(context, TriangleSize.width,pos - TriangleSize.height);
    }
    CGContextAddArcToPoint(context, pad + TriangleSize.width,pad,width, pad, rounding);
    
    CGContextClosePath(context);
    CGContextClip(context);
    
    if(self.GradientColor)
        [GPDrawExtras drawLinearGradient:context start:self.GradientColor end:self.FillColor rect:currentFrame endLoc:0.55];
    
    if(self.drawGloss)
        [GPDrawExtras drawGloss:context rect:currentFrame];
    
    if(self.drawInsetShadow)
    {
        UIColor* color = [UIColor blackColor];
        for(int i = 0; i < 3; i++) //draw 3 times, as this will darken to the correct need
        [GPDrawExtras drawInsetShadow:context rect:currentFrame rounding:rounding color:color];
    }

}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@end

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//draw arrow on top code
/*
 CGContextRef context = UIGraphicsGetCurrentContext();
 CGRect currentFrame = self.bounds;
 
 CGContextSetLineJoin(context, kCGLineJoinRound);
 CGContextSetLineWidth(context, self.BorderWidth);
 CGContextSetStrokeColorWithColor(context, self.BorderColor.CGColor); 
 CGContextSetFillColorWithColor(context, self.FillColor.CGColor);
 
 // Draw and fill the bubble
 CGContextBeginPath(context);
 CGContextMoveToPoint(context, BorderRadius + BorderWidth + 0.5f, BorderWidth + TriangleSize.height + 0.5f);
 CGContextAddLineToPoint(context, round(currentFrame.size.width / 2.0f - TriangleSize.width / 2.0f) + 0.5f, TriangleSize.height + BorderWidth + 0.5f);
 CGContextAddLineToPoint(context, round(currentFrame.size.width / 2.0f) + 0.5f, BorderWidth + 0.5f);
 CGContextAddLineToPoint(context, round(currentFrame.size.width / 2.0f + TriangleSize.width / 2.0f) + 0.5f, TriangleSize.height + BorderWidth + 0.5f);
 CGContextAddArcToPoint(context, currentFrame.size.width - BorderWidth - 0.5f, BorderWidth + TriangleSize.height + 0.5f, currentFrame.size.width - BorderWidth - 0.5f, currentFrame.size.height - BorderWidth - 0.5f, BorderRadius - BorderWidth);
 CGContextAddArcToPoint(context, currentFrame.size.width - BorderWidth - 0.5f, currentFrame.size.height - BorderWidth - 0.5f, round(currentFrame.size.width / 2.0f + TriangleSize.width / 2.0f) - BorderWidth + 0.5f, currentFrame.size.height - BorderWidth - 0.5f, BorderRadius - BorderWidth);
 CGContextAddArcToPoint(context, BorderWidth + 0.5f, currentFrame.size.height - BorderWidth - 0.5f, BorderWidth + 0.5f, TriangleSize.height + self.BorderWidth + 0.5f, BorderRadius - BorderWidth);
 CGContextAddArcToPoint(context, BorderWidth + 0.5f, BorderWidth + TriangleSize.height + 0.5f, currentFrame.size.width - self.BorderWidth - 0.5f, TriangleSize.height + BorderWidth + 0.5f, BorderRadius - BorderWidth);
 CGContextClosePath(context);
 CGContextDrawPath(context, kCGPathFillStroke);
 
 // Draw a clipping path for the fill
 CGContextBeginPath(context);
 CGContextMoveToPoint(context, BorderRadius + BorderWidth + 0.5f, round((currentFrame.size.height + TriangleSize.height) * 0.50f) + 0.5f);
 CGContextAddArcToPoint(context, currentFrame.size.width - BorderWidth - 0.5f, round((currentFrame.size.height + TriangleSize.height) * 0.50f) + 0.5f, currentFrame.size.width - BorderWidth - 0.5f, currentFrame.size.height - BorderWidth - 0.5f, BorderRadius - BorderWidth);
 CGContextAddArcToPoint(context, currentFrame.size.width - BorderWidth - 0.5f, currentFrame.size.height - BorderWidth - 0.5f, round(currentFrame.size.width / 2.0f + TriangleSize.width / 2.0f) - BorderWidth + 0.5f, currentFrame.size.height - BorderWidth - 0.5f, BorderRadius - BorderWidth);
 CGContextAddArcToPoint(context, BorderWidth + 0.5f, currentFrame.size.height - BorderWidth - 0.5f, BorderWidth + 0.5f, TriangleSize.height + BorderWidth + 0.5f, BorderRadius - BorderWidth);
 CGContextAddArcToPoint(context, BorderWidth + 0.5f, round((currentFrame.size.height + TriangleSize.height) * 0.50f) + 0.5f, currentFrame.size.width - BorderWidth - 0.5f, round((currentFrame.size.height + TriangleSize.height) * 0.50f) + 0.5f, BorderRadius - BorderWidth);
 CGContextClosePath(context);
 CGContextClip(context); */