//
//  GPRevealViewController.h
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
//does the whole slide out left nav thing is designed to be subclassed


//NOTE: if you plan to use GPNavigatior and this GPRevealNavigation class you need to follow a different setup route,
//then using the normal openURL.
//-(UIViewController*)GPRevealNavigation:(NSString*)URL is the function to use
//example below:
/*
 [[GPNavigator navigator] mapViewController:[RevealViewController class] toURL:@"tt://reveal"];
 self.window.rootViewController = [GPNavigator navigator GPRevealNavigation:@"tt:/reveal"];
 self.window.rootViewController
 [self.window makeKeyAndVisible];
 */


///////////////////////////////////////////////////////////////////////////////////////
//your back table view list, use this to swap out your fronttableView, so GPRevealViewController
//implements this (as seen below) and your back tableview controller has a delegate that calles to this.
@protocol GPRevealBackDelegate <NSObject>

//called when a item in the back tableview is selected.
//if you are using GPTableViewController as your back listview, implement this delegate
//in the didSelectObject:(id)object atIndexPath(NSIndexPath*)indexPath method
- (void)didSelectBackRow:(id)object atIndexPath:(NSIndexPath*)indexPath;

//called when a item in the back tableview is selected.
//if you are using GPTableViewController as your back listview, implement this delegate
//call this if you have a search controller comeup
-(void)hideFully:(BOOL)hide;

@end
///////////////////////////////////////////////////////////////////////////////////////
@interface GPRevealViewController : UIViewController<GPRevealBackDelegate>
{
    UIView* frontView;
    UIView* backView;
    UINavigationController* frontNavBar;
    UIViewController* backViewController;
    UIViewController* frontViewController;
    UIPanGestureRecognizer *swipe;
}
@property(nonatomic,retain) UINavigationController* frontNavBar;

-(void)hideFullyAnimation:(BOOL)hide;
-(void)revealAnimation:(BOOL)hide;
-(void)setFrontViewController:(UIViewController*)frontVC;

//this need to be implemented in your subclass!
-(UIViewController*)frontController;
-(UIViewController*)backController;
-(void)swipeGesture;

@end
///////////////////////////////////////////////////////////////////////////////////////
