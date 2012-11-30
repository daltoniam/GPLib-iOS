//
//  GPSideBarViewController.h
//  TestApp
//
//  Created by Dalton Cherry on 9/25/12.
//  Copyright (c) 2012 Basement Krew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPTabBarItem.h"

@interface GPSideBarViewController : UIViewController<GPTabBarItemDelegate>
{
    UIView* containerView;
    UIView* sideMenu;
    UIScrollView* sideScroll;
    UIView* smokeView;
}

@property(nonatomic,retain)NSArray* viewControllers; //for setting view controllers
@property(nonatomic,retain)NSArray* barButtons; //for setting custom buttons
@property(nonatomic,assign)BOOL menuDoesHide;
@property(nonatomic,assign)BOOL persistNavigation;

-(UIBarButtonItem*)menuButton:(UIViewController*)vc index:(int)index;

+(GPSideBarViewController*)sideBarNavigation:(NSArray*)urls;

@end
