//
//  GPSlideOutViewController.m
//  TestApp
//
//  Created by Dalton Cherry on 10/26/12.
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

#import "GPSlideOutViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface GPSlideOutViewController ()

@end

@implementation GPSlideOutViewController

@synthesize rightController,leftController,centerController,leftViewIsSlideLength;

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.slideOffset = 265;
        self.canSwipeView = YES;
    }
    return self;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidLoad
{
    [super viewDidLoad];
    isCenterShowing = YES;
    if(self.centerController)
    {
        centerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        centerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.centerController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.centerController.view.frame = centerView.bounds;
        [centerView addSubview:centerController.view];
        [self.view addSubview:centerView];
        UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:centerView.bounds];
        centerView.layer.masksToBounds = NO;
        centerView.layer.shadowColor = [UIColor blackColor].CGColor;
        centerView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
        centerView.layer.shadowOpacity = 1.0f;
        centerView.layer.shadowRadius = 2.5f;
        centerView.layer.shadowPath = shadowPath.CGPath;
        [self addChildViewController:centerController];
    }
    if(self.leftController)
    {
        int width = self.view.frame.size.width;
        if(self.leftViewIsSlideLength)
            width = self.slideOffset;
        leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, self.view.frame.size.height)];
        leftView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        self.leftController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.leftController.view.frame = leftView.bounds;
        [leftView addSubview:leftController.view];
        [self.view insertSubview:leftView belowSubview:centerView];
    }
    if(self.rightController)
    {
        int left = self.view.frame.size.width - self.slideOffset;
        rightView = [[UIView alloc] initWithFrame:CGRectMake(left, 0, self.slideOffset, self.view.frame.size.height)];
        rightView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        self.rightController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.rightController.view.frame = rightView.bounds;
        [rightView addSubview:rightController.view];
        [self.view insertSubview:rightView belowSubview:centerView];
    }
    if(self.canSwipeView)
    {
        if(!swipe)
            swipe = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGesture:)];
        [centerView addGestureRecognizer:swipe];
    }
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)showLeftView
{
    [self slideView:NO];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)showRightView
{
    [self slideView:YES];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)slideView:(BOOL)right
{
    if(!isCenterShowing)
    {
        [self restoreCenterView];
        return;
    }
    isCenterShowing = NO;
    for(UIView* subview in self.centerController.visibleViewController.view.subviews)
        subview.userInteractionEnabled = NO;
    rightView.hidden = !right;
    leftView.hidden = right;
    float offset = self.slideOffset;
    if(right)
        offset = -offset;
    [UIView animateWithDuration:0.35f animations:^{
        centerView.frame = CGRectMake(offset, 0.0f, centerView.frame.size.width, centerView.frame.size.height);
    }completion:NULL];
    if(!closeTap)
        closeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(restoreCenterView)];
    [centerView addGestureRecognizer:closeTap];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)restoreCenterView
{
    [centerView removeGestureRecognizer:closeTap];
    isCenterShowing = YES;
    for(UIView* subview in self.centerController.visibleViewController.view.subviews)
        subview.userInteractionEnabled = YES;
    [UIView animateWithDuration:0.35f animations:^{
        centerView.frame = CGRectMake(0, 0.0f, centerView.frame.size.width, centerView.frame.size.height);
    }completion:NULL];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)restoreWithNewCenterView:(UINavigationController*)navigationController
{
    self.centerController = navigationController;
    [UIView animateWithDuration:0.25f animations:^{
        int offset = self.view.frame.size.width+10;
        if(centerView.frame.origin.x < 0)
            offset = -offset;
        centerView.frame = CGRectMake(offset, 0.0f, centerView.frame.size.width, centerView.frame.size.height);
    }completion:^(BOOL finished){
        [self restoreCenterView];
    }];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)showFully:(BOOL)fully
{
    if(fully)
    {
        [UIView animateWithDuration:0.25 animations:^{
            centerView.frame = CGRectMake(centerView.frame.size.width, 0.0f, centerView.frame.size.width, centerView.frame.size.height);
            leftView.frame = CGRectMake(0, 0, self.view.frame.size.width, leftView.frame.size.height);
        }];
    }
    else
    {
        [UIView animateWithDuration:0.25 animations:^{
            int width = self.view.frame.size.width;
            if(self.leftViewIsSlideLength)
                width = self.slideOffset;
            leftView.frame = CGRectMake(0, 0, width, self.view.frame.size.height);
            centerView.frame = CGRectMake(self.slideOffset, 0.0f, centerView.frame.size.width, centerView.frame.size.height);
        }];

    }
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)swipeGesture:(UIPanGestureRecognizer*)sender
{
    CGPoint location = [sender locationInView:self.view];
    if(sender.state == UIGestureRecognizerStateBegan)
        startSwipe = location.x;
    else if(sender.state == UIGestureRecognizerStateBegan || sender.state == UIGestureRecognizerStateChanged)
    {
        int offset = location.x - startSwipe;
        int total = centerView.frame.origin.x+offset;
        if(total > self.slideOffset)
            return;
        else if(-total > self.slideOffset)
            return;
        if(!self.rightController && total < 0)
            return;
        if(!self.leftController && total > 0)
            return;
        
        [UIView animateWithDuration:0.15f animations:^{
            CGRect frame = centerView.frame;
            frame.origin.x += offset;
            centerView.frame = frame;
        }completion:^(BOOL finished){}];
        
        startSwipe = location.x;
        if(centerView.frame.origin.x > 0)
        {
            rightView.hidden = YES;
            leftView.hidden = NO;
        }
        else
        {
            rightView.hidden = NO;
            leftView.hidden = YES;
        }
    }
    if(sender.state == UIGestureRecognizerStateEnded)
    {
        int offset = 40;
        if(!isCenterShowing)
            offset = self.slideOffset;
        if(centerView.frame.origin.x > offset)
            [self showLeftView];
        else if(centerView.frame.origin.x < -offset)
            [self showRightView];
        else
            [self restoreCenterView];
    }
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setCenterController:(UINavigationController *)center
{
    [centerController.view removeFromSuperview];
    [centerController release];
    centerController = [center retain];
    centerController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    centerController.view.frame = centerView.bounds;
    [centerView addSubview:centerController.view];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//forward this on
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [centerController viewWillAppear:animated];
    [leftController viewWillAppear:animated];
    [rightController viewWillAppear:animated];
}
//////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [centerController viewDidAppear:animated];
    [leftController viewDidAppear:animated];
    [rightController viewDidAppear:animated];
}
//////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [centerController viewWillDisappear:animated];
    [leftController viewWillDisappear:animated];
    [rightController viewWillDisappear:animated];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    [leftController shouldAutorotateToInterfaceOrientation:interfaceOrientation];
    [rightController shouldAutorotateToInterfaceOrientation:interfaceOrientation];
    return [centerController shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [centerController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [leftController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [rightController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [centerController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [leftController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [rightController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [centerController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [leftController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [rightController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)dealloc
{
    [swipe release];
    [rightView release];
    [leftView release];
    [centerView release];
    [super dealloc];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//public methods
///////////////////////////////////////////////////////////////////////////////////////////////////
+(GPSlideOutViewController*)slideOutController:(UINavigationController*)navBar left:(UIViewController*)left right:(UIViewController*)right
{
    GPSlideOutViewController* slideout = [[[GPSlideOutViewController alloc] init] autorelease];
    slideout.centerController = navBar;
    slideout.leftController = left;
    slideout.rightController = right;
    return slideout;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
+(GPSlideOutViewController*)currentSlide
{
    UIWindow* window = [[UIApplication sharedApplication] keyWindow];
    UIViewController* current = window.rootViewController;
    if([current isKindOfClass:[GPSlideOutViewController class]])
        return (GPSlideOutViewController*)current;
    return nil;
}
///////////////////////////////////////////////////////////////////////////////////////////////////


@end
