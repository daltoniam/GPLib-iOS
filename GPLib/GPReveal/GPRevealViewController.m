//
//  GPRevealViewController.m
//  GPLib
//
//  Created by Dalton Cherry on 4/23/12.
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

#import "GPRevealViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface GPRevealViewController ()

-(void)commonInit;

@end

@implementation GPRevealViewController

@synthesize frontNavBar = frontNavBar;

static int REVEAL_OFFSET;
///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        [self commonInit];
    }
    return self;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)commonInit
{
    [self setFrontViewController:[self frontController]];
    backViewController = [[self backController] retain];
    if([backViewController respondsToSelector:@selector(setDelegate:)])
        [backViewController performSelector:@selector(setDelegate:) withObject:self];
    //if([frontViewController respondsToSelector:@selector(setDelegate:)])
    //    [frontViewController performSelector:@selector(setDelegate:) withObject:self];
    
    //if(GPIsPad())
    //    REVEAL_OFFSET = 680;
    //else
        REVEAL_OFFSET = 260;
}
//////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setFrontViewController:(UIViewController*)frontVC
{
    UIViewController* temp = frontVC;
    [frontNavBar.view removeFromSuperview];
    [frontNavBar release];
    frontNavBar = nil;
    if([temp isKindOfClass:[UINavigationController class]])
    {
        UINavigationController* navBar = (UINavigationController*)temp;
        frontNavBar = [navBar retain];
        frontViewController = [navBar.topViewController retain];
    }
    else
    {
        frontNavBar = [[UINavigationController alloc] initWithRootViewController:temp];
        frontViewController = [temp retain];
    }
    frontNavBar.view.frame = CGRectMake(0.0f, 0.0f, frontView.frame.size.width, frontView.frame.size.height);
    [frontView addSubview:frontNavBar.view];
    //use this line in your subclass if you are using gpnavigator
    //[[GPNavigator navigator] navigationControllerChange:frontNavBar];
}
//////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [frontNavBar viewWillAppear:animated];
    [backViewController viewWillAppear:animated];
}
//////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [frontNavBar viewDidAppear:animated];
    [backViewController viewDidAppear:animated];
}
//////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [frontNavBar viewWillDisappear:animated];
    [backViewController viewWillDisappear:animated];
}
//////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    //[frontNavBar viewDidDisappear:animated];
    //[backViewController viewDidDisappear:animated];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    [backViewController shouldAutorotateToInterfaceOrientation:interfaceOrientation];
    return [frontNavBar shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [frontNavBar willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [backViewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [frontNavBar didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [backViewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [frontNavBar willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [backViewController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    frontView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    frontView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    frontNavBar.view.frame = CGRectMake(0.0f, 0.0f, frontView.frame.size.width, frontView.frame.size.height);
    //frontNavBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:frontView];
    [frontView addSubview:frontNavBar.view];
    
    backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, REVEAL_OFFSET, self.view.frame.size.height)];
    backViewController.view.frame = CGRectMake(0.0f, 0.0f, backView.frame.size.width, backView.frame.size.height);
    [self.view addSubview:backView];
    [backView addSubview:backViewController.view];
    
    [self addChildViewController:frontNavBar];
    [self addChildViewController:backViewController];
    [self.view bringSubviewToFront:frontView];
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:frontView.bounds];
	frontView.layer.masksToBounds = NO;
	frontView.layer.shadowColor = [UIColor blackColor].CGColor;
	frontView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
	frontView.layer.shadowOpacity = 1.0f;
	frontView.layer.shadowRadius = 2.5f;
	frontView.layer.shadowPath = shadowPath.CGPath;
    if([self menuSwipeEnabled])
    {
        UIPanGestureRecognizer* showMenuSwipe = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGesture:)];
        showMenuSwipe.delegate = self;
        [self.view addGestureRecognizer:showMenuSwipe];
        [showMenuSwipe release];
    }
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//set hide to true to bring front back
- (void)revealAnimation:(BOOL)hide
{	
    int reveal = REVEAL_OFFSET;
    if(hide)
        reveal = 0;
    if(!hide)
    {
        [backViewController viewWillAppear:YES];
        [self addSwipeGesture];
    }
    else
    {
        [frontViewController.view removeGestureRecognizer:swipe];
        for(UIView* view in frontViewController.view.subviews)
            view.userInteractionEnabled = YES;
    }
	
    
    [UIView animateWithDuration:0.25f animations:^
     {
         frontView.frame = CGRectMake(reveal, 0.0f, frontView.frame.size.width, frontView.frame.size.height);
     }
                     completion:^(BOOL finished){
                     }];
}
//////////////////////////////////////////////////////////////////////////////////////////////////
//set hide to true to move front out of sight
-(void)hideFullyAnimation:(BOOL)hide
{
    int reveal = REVEAL_OFFSET;
    if(hide)
        reveal = self.view.frame.size.width;
    [UIView animateWithDuration:0.25f animations:^
     {
         frontView.frame = CGRectMake(reveal, 0.0f, frontView.frame.size.width, frontView.frame.size.height);
         backView.frame = CGRectMake(0, 0, reveal, backView.frame.size.height);
     }
                     completion:^(BOOL finished){
                     }];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)addSwipeGesture
{
    if(!swipe)
        swipe = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGesture:)];
    [frontViewController.view addGestureRecognizer:swipe];
    for(UIView* view in frontViewController.view.subviews)
        view.userInteractionEnabled = NO;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//subclass
///////////////////////////////////////////////////////////////////////////////////////////////////
//you NEED to subclass this, in order to get this class to do anything. return the desired
//view controller to use in the front. Navigation Controller will be created for you if not provided.
-(UIViewController*)frontController
{
    return nil;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//you NEED to subclass this, in order to get this class to do anything. return the desired
//view controller to use in the back. Navigation Controller will NOT be created for you by default.
-(UIViewController*)backController
{
    return nil;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didSelectBackRow:(id)object atIndexPath:(NSIndexPath*)indexPath
{
    //do your swap here.
    [self revealAnimation:YES];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)hideFully:(BOOL)hide
{
    [self hideFullyAnimation:hide];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)swipeGesture:(UIPanGestureRecognizer*)sender
{
    CGPoint location = [sender locationInView:self.view];
    if(sender.state == UIGestureRecognizerStateEnded)
    {
        int offset = REVEAL_OFFSET/2;
        if(location.x < offset)
            [self revealAnimation:YES];
        else
            [self revealAnimation:NO];
    }
    else if(sender.state == UIGestureRecognizerStateBegan || sender.state == UIGestureRecognizerStateChanged)
    {
        if(location.x < REVEAL_OFFSET)
        {
            [UIView animateWithDuration:0.25f animations:^{
                frontView.frame = CGRectMake(location.x, 0.0f, frontView.frame.size.width, frontView.frame.size.height);
            }completion:^(BOOL finished){}];
        }
    }
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//add a gesture to show the menu from any view
-(BOOL)menuSwipeEnabled
{
    return NO;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)dealloc
{
    [frontView release];
    [backView release];
    [frontNavBar release];
    //[backViewController release];
    [frontViewController release];
    [swipe release];
    [super dealloc];
}

@end


/*
 [UIView transitionWithView:frontView
 duration:0.25f
 options:UIViewAnimationOptionTransitionFlipFromRight
 animations:^{
 frontView.frame = CGRectMake(reveal, 0.0f, frontView.frame.size.width, frontView.frame.size.height);
 }
 completion:^(BOOL finished){
 }];*/
 
 
 
