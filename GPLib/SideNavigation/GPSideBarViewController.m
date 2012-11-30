//
//  GPSideBarViewController.m
//  TestApp
//
//  Created by Dalton Cherry on 9/25/12.
//  Copyright (c) 2012 Basement Krew. All rights reserved.
//

#import "GPSideBarViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "GPNav.h"

#define SIDE_MENU_WIDTH 66//49

@interface GPSideBarViewController ()

@end

@implementation GPSideBarViewController

@synthesize viewControllers,menuDoesHide,barButtons,persistNavigation;
///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidLoad
{
    [super viewDidLoad];
    int left = SIDE_MENU_WIDTH;
    if(menuDoesHide)
        left = 0;
    containerView = [[UIView alloc] init];
    containerView.frame = CGRectMake(left, 0, self.view.frame.size.width, self.view.frame.size.height);
    containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:containerView];
    
    left = 0;
    if(menuDoesHide)
        left = -SIDE_MENU_WIDTH;
    sideMenu = [[UIView alloc] init];
    sideMenu.backgroundColor = [UIColor blackColor];
    sideMenu.frame = CGRectMake(left, 0, SIDE_MENU_WIDTH, self.view.frame.size.height);
    sideMenu.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    sideMenu.hidden = menuDoesHide;
    
    if(menuDoesHide)
    {
        UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:sideMenu.bounds];
        sideMenu.layer.masksToBounds = NO;
        sideMenu.layer.shadowColor = [UIColor blackColor].CGColor;
        sideMenu.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
        sideMenu.layer.shadowOpacity = 1.0f;
        sideMenu.layer.shadowRadius = 2.5f;
        sideMenu.layer.shadowPath = shadowPath.CGPath;
    }
    sideScroll = [[UIScrollView alloc] init];
    sideScroll.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    sideScroll.frame = CGRectMake(0, 0, sideMenu.frame.size.width, sideMenu.frame.size.height);
    sideScroll.showsVerticalScrollIndicator = NO;
    sideScroll.backgroundColor = [UIColor clearColor];
    [sideMenu addSubview:sideScroll];
    
    if(menuDoesHide)
    {
        smokeView = [[UIView alloc] init];
        smokeView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.75];
        smokeView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        
        //UIPanGestureRecognizer* pan = [[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(hideMenu)] autorelease];
        //[smokeView addGestureRecognizer:pan];
        UITapGestureRecognizer* tap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideMenu)] autorelease];
        [smokeView addGestureRecognizer:tap];
        [self.view addSubview:smokeView];
        smokeView.hidden = YES;
        smokeView.alpha = 0;
    }
    [self.view addSubview:sideMenu];
    [self layoutButtons];
    [self swapController:0];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)layoutButtons
{
    int buttonCount = self.viewControllers.count;
    int pad = 5;
    int top = pad;
    for(int i = 0; i < buttonCount; i++)
    {
        GPTabBarItem* current = nil;
        if(self.barButtons)
            current = [self.barButtons objectAtIndex:i];
        else
            current = [self defaultButton:i];
        [self customizeButton:current index:i];
        current.frame = CGRectMake(0, top, SIDE_MENU_WIDTH, SIDE_MENU_WIDTH);
        [sideScroll addSubview:current];
        top += current.frame.size.height+pad;
        if(i == 0)
            [current swapState:YES];
    }
    sideScroll.contentSize = CGSizeMake(sideMenu.frame.size.width, top);
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)customizeButton:(GPTabBarItem*)button index:(int)index
{
    button.delegate = self;
    button.tabIndex = index;
    button.backgroundColor =[UIColor clearColor];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(GPTabBarItem*)defaultButton:(int)index
{
    GPTabBarItem* button = [[[GPTabBarItem alloc] init] autorelease];
    button.rounding = 0;
    UIViewController* vc = [self.viewControllers objectAtIndex:index];
    if([vc isKindOfClass:[UINavigationController class]])
        vc = [(UINavigationController*)vc topViewController];
    if(vc.title)
        button.titleLabel.text = vc.title;
    button.centerImage = YES;
    button.image = vc.tabBarItem.image;
    return button;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//tab delegate
-(void)didSelectTab:(GPTabBarItem*)tabItem
{
    for(UIView* view in sideScroll.subviews)
    {
        if([view isKindOfClass:[GPTabBarItem class]])
        {
            GPTabBarItem* tab = (GPTabBarItem*)view;
            if(tab.tabIndex != tabItem.tabIndex)
                [tab swapState:NO];
        }
    }
    UIViewController* vc = [viewControllers objectAtIndex:tabItem.tabIndex];
    if([vc isKindOfClass:[UINavigationController class]] && !self.persistNavigation)
        [(UINavigationController*)vc popToRootViewControllerAnimated:YES];
    [self swapController:tabItem.tabIndex];
    if(menuDoesHide)
        [self hideMenu];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)swapController:(int)index
{
    for(UIView* sub in containerView.subviews)
        [sub removeFromSuperview];
    
    UIViewController* vc = [viewControllers objectAtIndex:index];
    if(menuDoesHide && ![vc isKindOfClass:[UINavigationController class]])
    {
        UINavigationController* controller = [[[UINavigationController alloc] initWithRootViewController:vc] autorelease];
        
        controller.view.frame = CGRectMake(0, 0, containerView.frame.size.width, containerView.frame.size.height);
        int index = [viewControllers indexOfObject:vc];
        NSMutableArray* array = [NSMutableArray arrayWithCapacity:viewControllers.count];
        for(int i = 0; i < viewControllers.count; i++)
        {
            if(index == i)
                [array addObject:controller];
            else
                [array addObject:[viewControllers objectAtIndex:i]];
        }
        self.viewControllers = array;
        [containerView addSubview:controller.view];
        [self.view bringSubviewToFront:containerView];
    }
    
    UINavigationController* navController = (UINavigationController*)[viewControllers objectAtIndex:index];
    if(menuDoesHide)
        navController.view.frame = CGRectMake(0, 0, containerView.frame.size.width, containerView.frame.size.height);
    else
        navController.view.frame = CGRectMake(0, 0, containerView.frame.size.width-SIDE_MENU_WIDTH, containerView.frame.size.height);
    [containerView addSubview:vc.view];
    if(menuDoesHide)
    {
        UIViewController* vc = [navController topViewController];
        vc.navigationItem.leftBarButtonItem = [self menuButton:vc index:index];
    }

}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)showMenu
{
    smokeView.hidden = NO;
    sideMenu.hidden = NO;
    [UIView animateWithDuration:0.25f animations:^{
        CGRect frame = sideMenu.frame;
        frame.origin.x = 0;
        sideMenu.frame = frame;
        smokeView.alpha = 1;
     }completion:^(BOOL finished){
                     }];

}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)hideMenu
{
    [UIView animateWithDuration:0.25f animations:^{
        CGRect frame = sideMenu.frame;
        frame.origin.x = -SIDE_MENU_WIDTH;
        sideMenu.frame = frame;
        smokeView.alpha = 0;
    }completion:^(BOOL finished){
        smokeView.hidden = YES;
        sideMenu.hidden = YES;
    }];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    int height = 10;
    for(UIView* view in sideScroll.subviews)
    {
        if([view isKindOfClass:[GPTabBarItem class]])
            height += view.frame.size.height+10;
    }
    sideScroll.contentSize = CGSizeMake(sideMenu.frame.size.width, height);
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//override to customize
-(UIBarButtonItem*)menuButton:(UIViewController*)vc index:(int)index
{
    return [[[UIBarButtonItem alloc] initWithImage:vc.tabBarItem.image
                                             style:UIBarButtonItemStyleBordered
                                            target:self
                                            action:@selector(showMenu)] autorelease];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)dealloc
{
    [sideScroll release];
    [sideMenu release];
    [smokeView release];
    [containerView release];
    [sideScroll release];
    [super dealloc];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//add this for sideBar navigation
+(GPSideBarViewController*)sideBarNavigation:(NSArray*)urls
{
    GPSideBarViewController* sideBar = [[[GPSideBarViewController alloc] init] autorelease];
    NSMutableArray* array = [NSMutableArray arrayWithCapacity:urls.count];
    for(NSString* url in urls)
    {
        
        UIViewController* vc = [[GPNav sharedNav] viewControllerFromURL:url];
        UINavigationController* controller = [[UINavigationController alloc] initWithRootViewController:vc];
        [array addObject:controller];
        [controller release];
    }
    sideBar.viewControllers = array;
    return sideBar;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
@end
