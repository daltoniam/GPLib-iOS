//
//  GPTabBarController.m
//  GPLib
//
//  Created by Dalton Cherry on 5/18/12.
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

#import "GPTabBarController.h"

@interface GPTabBarController ()

-(void)layoutButtons;
-(void)customizeButton:(GPTabBarItem*)button index:(int)index;

@end

@implementation GPTabBarController

@synthesize gradientStart,gradientEnd,viewControllers,barButtons,tabBarBackgroundImage,drawGloss,persistNavigation;
///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        //self.gradientStart = [UIColor colorWithWhite:0.9 alpha:0.1];
        //self.gradientEnd = [UIColor colorWithWhite:0 alpha:1];
        
        self.gradientStart = [UIColor colorWithWhite:0.30 alpha:1];
        self.gradientEnd = [UIColor colorWithWhite:0.05 alpha:1];
        //drawGloss = YES;
    }
    return self;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidLoad
{
    [super viewDidLoad];
    int top = 0;
    int width = self.view.frame.size.width;
    int height = self.view.frame.size.height;
    CGRect frame;
    
    int barHeight = 45;
    if(self.navigationController)
        frame = CGRectMake(0, top, width, height- (barHeight + 44));
    else
        frame = CGRectMake(0, top, width, height-barHeight);
    containerView = [[UIView alloc] initWithFrame:frame];
    containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:containerView];
    top += containerView.frame.size.height;
    
    tabBar = [[GPView alloc] initWithFrame:CGRectMake(0, top, width, barHeight)];
    tabBar.backgroundColor = [UIColor blackColor];
    tabBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    if(self.tabBarBackgroundImage)
        tabBar.backgroundColor = [UIColor colorWithPatternImage:self.tabBarBackgroundImage];
    else if(self.gradientStart || self.gradientEnd)
    {
        tabBar.gradientStartColor = self.gradientStart;
        tabBar.gradientEndColor = self.gradientEnd;
        tabBar.gradientLength = 1;
    }
    tabBar.drawGloss = drawGloss;
    [self.view addSubview:tabBar];
    [self layoutButtons];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)layoutButtons
{
    int buttonCount = 0;
    if(self.barButtons)
        buttonCount = [self.barButtons count];
    else
        buttonCount = [self.viewControllers count];
    
    if(buttonCount > 5)
        buttonCount = 5;
    float buttonWidth = tabBar.frame.size.width/buttonCount;
    
    float left = 0;
    for(int i = 0; i < buttonCount; i++)
    {
        GPTabBarItem* current = nil;
        if(self.barButtons)
            current = [self.barButtons objectAtIndex:i];
        else
            current = [self defaultButton:i];
        [self customizeButton:current index:i];
        current.frame = CGRectMake(left, 0, buttonWidth, tabBar.frame.size.height);
        current.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [tabBar addSubview:current];
        left += current.frame.size.width;
        if(i == 0)
        {
            [current swapState:YES];
            [self swapController:0];
        }
    }
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
    //button.delegate = self;
    //button.fillColor = [UIColor clearColor];
    //button.rounding = 4;
    button.rounding = 0;
    button.selectedColor = [UIColor blackColor];//[UIColor colorWithWhite:0.8 alpha:0.15];
    button.gradientLength = 1;
    UIViewController* vc = [self.viewControllers objectAtIndex:index];
    if([vc isKindOfClass:[UINavigationController class]])
        vc = [(UINavigationController*)vc topViewController];
    if(vc.title)
        button.titleLabel.text = vc.title;
    button.image = vc.tabBarItem.image;
    return button;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//tab delegate
-(void)didSelectTab:(GPTabBarItem*)tabItem
{
    for(GPTabBarItem* tab in tabBar.subviews)
    {
        if(tab.tabIndex != tabItem.tabIndex)
            [tab swapState:NO];
    }
    UIViewController* vc = [viewControllers objectAtIndex:tabItem.tabIndex];
    if([vc isKindOfClass:[UINavigationController class]] && !self.persistNavigation)
        [(UINavigationController*)vc popToRootViewControllerAnimated:YES];
    [self swapController:tabItem.tabIndex];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)swapController:(int)index
{
    for(UIView* sub in containerView.subviews)
        [sub removeFromSuperview];
    
    UIViewController* vc = [viewControllers objectAtIndex:index];
    if([vc isKindOfClass:[UINavigationController class]])
        
    {
        
        vc.view.frame = CGRectMake(0, 0, containerView.frame.size.width, containerView.frame.size.height);
        [[GPNavigator navigator] navigationControllerChange:(UINavigationController*)vc];
        [containerView addSubview:vc.view];
    }
  	
    else
      	
    {
        
        UINavigationController* controller = [[UINavigationController alloc] initWithRootViewController:vc];
        [[GPNavigator navigator] navigationControllerChange:controller];

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
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidUnload
{
    [super viewDidUnload];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)dealloc
{
    [containerView release];
    [tabBar release];
    [super dealloc];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//quick hack for GPNavigator so I do not have to import the header
-(BOOL)isGPNavBar
{
    return YES;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//public
///////////////////////////////////////////////////////////////////////////////////////////////////
//modally open a view controller
+(void)modalOpen:(UIViewController*)vc
{
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:vc]; 
    //[navigationController setModalPresentationStyle:UIModalPresentationPageSheet];
    if([[[UIApplication sharedApplication].delegate window].rootViewController isKindOfClass:[GPTabBarController class]])
        [[[UIApplication sharedApplication].delegate window].rootViewController presentModalViewController:navigationController animated:YES];
    [navigationController release];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//dismiss a modal view
+(void)modalDismiss
{
    if([[[UIApplication sharedApplication].delegate window].rootViewController isKindOfClass:[GPTabBarController class]])
        [[[UIApplication sharedApplication].delegate window].rootViewController dismissModalViewControllerAnimated:YES];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//add this for tabBar navigation
+(GPTabBarController*)tabBarNavigation:(NSArray*)urls
{
    GPTabBarController* tabBar = [[[GPTabBarController alloc] init] autorelease];
    NSMutableArray* array = [NSMutableArray arrayWithCapacity:urls.count];
    for(NSString* url in urls)
    {
        
        UIViewController* vc = [[GPNavigator navigator] viewControllerFromURL:url];
        UINavigationController* controller = [[UINavigationController alloc] initWithRootViewController:vc];
        [array addObject:controller];
        [controller release];
    }
    tabBar.viewControllers = array;
    return tabBar;
}
///////////////////////////////////////////////////////////////////////////////////////////////////

@end
