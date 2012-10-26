//
//  GPSlideOutViewController.h
//  TestApp
//
//  Created by Dalton Cherry on 10/26/12.
//  Copyright (c) 2012 Basement Krew. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GPSlideOutViewController : UIViewController
{
    UIView* centerView;
    UIView* leftView;
    UIView* rightView;
    UIPanGestureRecognizer *swipe;
    CGFloat startSwipe;
    BOOL isCenterShowing;
    UITapGestureRecognizer* closeTap;
}

//your center controller that handles everything
@property(nonatomic,retain)UINavigationController* centerController;

//your left controller behind the center one
@property(nonatomic,retain)UIViewController* leftController;

//your right controller behind the center one
@property(nonatomic,retain)UIViewController* rightController;

//the amount you want the view to slide. Default is 265.
@property(nonatomic,assign)CGFloat slideOffset;

//this make the back left slide view only be as long as the slideOffset. Default is NO.
@property(nonatomic,assign)BOOL leftViewIsSlideLength;

//this allows if the view can be swipe open and closed. Default is YES.
@property(nonatomic,assign)BOOL canSwipeView;

//show the left view
-(void)showLeftView;

//show the right view
-(void)showRightView;

//restore the center view postition
-(void)restoreCenterView;

//make the center view a new controller.
-(void)restoreWithNewCenterView:(UINavigationController*)navigationController;

//factory to create slide out controller
+(GPSlideOutViewController*)slideOutController:(UINavigationController*)navBar left:(UIViewController*)left right:(UIViewController*)right;

//get the current slide view controller.
+(GPSlideOutViewController*)currentSlide;

@end
