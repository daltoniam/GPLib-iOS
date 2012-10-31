//
//  GPSlideOutViewController.h
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

//show the full left side for searching.
-(void)showFully:(BOOL)fully;

//factory to create slide out controller
+(GPSlideOutViewController*)slideOutController:(UINavigationController*)navBar left:(UIViewController*)left right:(UIViewController*)right;

//get the current slide view controller.
+(GPSlideOutViewController*)currentSlide;

@end
