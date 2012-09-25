///////////////////////////////////////////////////////////////////////////////////////////////////
//
//  GPSlideView.m
//  GPLib
//
//  Created by Dalton Cherry on 9/25/12.
//  Copyright (c) 2012 Basement Krew. All rights reserved.
//
///////////////////////////////////////////////////////////////////////////////////////////////////

#import "GPSlideView.h"
#import <QuartzCore/QuartzCore.h>

@implementation GPSlideView

@synthesize displayView = displayView;
///////////////////////////////////////////////////////////////////////////////////////////////////
-(id)initWithView:(UIView*)slideView
{
    if(self = [super init])
    {
        self.displayView = slideView;
    }
    return self;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setDisplayView:(UIView *)view
{
    displayView = view;
    oFrame = displayView.frame;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)show:(GPSlideViewDirection)direction;
{
    slideD = direction;
    UIWindow* window = [[UIApplication sharedApplication] keyWindow];
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.75];
    self.frame = CGRectMake(0, 0, window.frame.size.width, window.frame.size.height);
    [self addSubview:self.displayView];
    CGRect frame = self.displayView.frame;
    if(slideD == GPSlideViewRight)
        frame.origin.x = window.frame.size.width;
    else if(slideD == GPSlideViewLeft)
        frame.origin.x = -window.frame.size.width;
    else if(slideD == GPSlideViewTop)
        frame.origin.y = -window.frame.size.width;
    else
        frame.origin.y = window.frame.size.width;

    self.displayView.frame = frame;
    self.alpha = 0;
    [window addSubview:self];
    [UIView animateWithDuration:0.25f animations:^{
        self.alpha = 1;
        CGRect frame = self.displayView.frame;
        if(slideD == GPSlideViewRight || slideD == GPSlideViewLeft)
            frame.origin.x = oFrame.origin.x;
        else
            frame.origin.y = oFrame.origin.y;
        self.displayView.frame = frame;
    }completion:^(BOOL finished){
    }];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)dismiss
{
    [self dismiss:slideD];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)dismiss:(GPSlideViewDirection)direction
{
    UIWindow* window = [[UIApplication sharedApplication] keyWindow];
    [UIView animateWithDuration:0.25f animations:^{
        self.alpha = 0;
        CGRect frame = self.displayView.frame;
        if(slideD == GPSlideViewRight)
            frame.origin.x = window.frame.size.width;
        else if(slideD == GPSlideViewLeft)
            frame.origin.x = -(window.frame.size.width);
        else if(slideD == GPSlideViewTop)
            frame.origin.y = -(window.frame.size.height);
        else
            frame.origin.y = window.frame.size.height;
        self.displayView.frame = frame;
    }completion:^(BOOL finished){
        [self removeFromSuperview];
        [displayView removeFromSuperview];
        self.displayView.frame = oFrame;
    }];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject];
	CGPoint pt = [touch locationInView:self];
    if(![self.displayView pointInside:pt withEvent:event])
        [self dismiss];
    else
        [self.nextResponder touchesEnded:touches withEvent:event];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
+(CGRect)windowBounds
{
    return [[[UIApplication sharedApplication] keyWindow] bounds];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//adds a simple shadow to your view
+(void)addViewShadow:(UIView*)view
{
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:view.bounds];
    view.layer.masksToBounds = NO;
    view.layer.shadowColor = [UIColor blackColor].CGColor;
    view.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    view.layer.shadowOpacity = 1.0f;
    view.layer.shadowRadius = 2.5f;
    view.layer.shadowPath = shadowPath.CGPath;
}
///////////////////////////////////////////////////////////////////////////////////////////////////

@end
