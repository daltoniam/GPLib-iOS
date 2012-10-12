//
//  GPSideBarView.m
//  GPLib
//
//  Created by Dalton Cherry on 10/4/12.
//  Copyright (c) 2012 Lightspeed Systems. All rights reserved.
//

#import "GPSideBarView.h"
#import <QuartzCore/QuartzCore.h>

#define SIDE_MENU_WIDTH 66

@implementation GPSideBarView

@synthesize showFromRight;
///////////////////////////////////////////////////////////////////////////////////////////////////
-(id)init
{
    if(self = [super init])
    {
        [self commonInit];
    }
    return self;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(id)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        [self commonInit];
    }
    return self;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)commonInit
{
    UIWindow* window = [[UIApplication sharedApplication] keyWindow];
    int left = window.frame.size.width;
    if(showFromRight)
        left = -SIDE_MENU_WIDTH;
    sideMenu = [[UIView alloc] init];
    sideMenu.backgroundColor = [UIColor blackColor];
    sideMenu.frame = CGRectMake(left, 0, SIDE_MENU_WIDTH, window.frame.size.height);
    sideMenu.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    sideMenu.hidden = YES;
    [self addSubview:sideMenu];
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:sideMenu.bounds];
    sideMenu.layer.masksToBounds = NO;
    sideMenu.layer.shadowColor = [UIColor blackColor].CGColor;
    sideMenu.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    sideMenu.layer.shadowOpacity = 1.0f;
    sideMenu.layer.shadowRadius = 2.5f;
    sideMenu.layer.shadowPath = shadowPath.CGPath;
    
    
    sideScroll = [[UIScrollView alloc] init];
    sideScroll.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    sideScroll.frame = CGRectMake(0, 0, sideMenu.frame.size.width, sideMenu.frame.size.height);
    sideScroll.showsVerticalScrollIndicator = NO;
    sideScroll.backgroundColor = [UIColor clearColor];
    [sideMenu addSubview:sideScroll];
    
    smokeView = [[UIView alloc] init];
    smokeView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.75];
    smokeView.frame = CGRectMake(0, 0, window.frame.size.width, window.frame.size.height);
    
    //UIPanGestureRecognizer* pan = [[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(hideMenu)] autorelease];
    //[smokeView addGestureRecognizer:pan];
    UITapGestureRecognizer* tap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)] autorelease];
    [smokeView addGestureRecognizer:tap];
    [self addSubview:smokeView];
    smokeView.hidden = YES;
    smokeView.alpha = 0;
    [window addSubview:self];
    [window bringSubviewToFront:self];
    //[self layoutButtons];

}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)show
{
    if(!isShowing)
    {
        isShowing = YES;
        smokeView.hidden = NO;
        sideMenu.hidden = NO;
        [UIView animateWithDuration:0.25f animations:^{
            CGRect frame = sideMenu.frame;
            if(showFromRight)
                frame.origin.x = 0;
            else
                frame.origin.x = [[UIApplication sharedApplication] keyWindow].frame.size.width - SIDE_MENU_WIDTH;
            sideMenu.frame = frame;
            smokeView.alpha = 1;
        }completion:^(BOOL finished){
        }];
    }
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)hide
{
    if(isShowing)
    {
        [UIView animateWithDuration:0.25f animations:^{
            CGRect frame = sideMenu.frame;
            if(showFromRight)
                frame.origin.x = -SIDE_MENU_WIDTH;
            else
                frame.origin.x = [[UIApplication sharedApplication] keyWindow].frame.size.width;
            sideMenu.frame = frame;
            smokeView.alpha = 0;
        }completion:^(BOOL finished){
            smokeView.hidden = YES;
            sideMenu.hidden = YES;
        }];
    }
}
///////////////////////////////////////////////////////////////////////////////////////////////////

@end
