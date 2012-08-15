//
//  GPNavigator.h
//  GPLib
//
//  Created by Dalton Cherry on 1/9/12.
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

typedef enum {
    GPNavTypeModal,
    GPNavTypeFlip,
    GPNavTypeCurl,
    GPNavTypeDissolve,
    GPNavTypeModalForm,
    GPNavTypeModalPage,
    GPNavTypeNormal,
    GPNavTypePopOver,
    GPNavTypeGrid
} GPNavType;

@interface GPNavigator : NSObject<UINavigationControllerDelegate>
{
    NSMutableDictionary* URLs;
    UINavigationController* Navigation;
    UIViewController* currentViewController;
}
@property(nonatomic, readonly, retain)UINavigationController* navigationController;
@property(nonatomic, readonly)UIViewController* visibleViewController;
@property(nonatomic, readonly)NSMutableDictionary* URLs;
@property(nonatomic, assign)BOOL useCustomBackButton;
@property(nonatomic, assign)BOOL searchAppStore;

@property(nonatomic, retain)UIPopoverController* popOver;
+(GPNavigator*)navigator;

-(SEL)selectorFromURL:(NSString*)URLstring;
-(void)mapViewController:(Class)ViewClass toURL:(NSString*)URL;
-(void)openURL:(NSString*)URL;
-(void)openURL:(NSString*)URL NavType:(GPNavType)type;
-(void)openURL:(NSString*)URL NavType:(GPNavType)type query:(NSDictionary*)query;
-(void)openURL:(NSString*)URL view:(UIView*)gridView query:(NSDictionary*)query;
-(void)openURL:(NSString*)URL query:(NSDictionary*)query frame:(CGRect)frame;
-(void)openURL:(NSString*)URL NavType:(GPNavType)type query:(NSDictionary*)query rightbtn:(UIBarButtonItem*)right leftbtn:(UIBarButtonItem*)left;
-(void)openURL:(NSString*)URL NavType:(GPNavType)type query:(NSDictionary*)query rightbtn:(UIBarButtonItem*)right leftbtn:(UIBarButtonItem*)left frame:(CGRect)frame view:(UIView*)gridView;

-(id)createViewControllerFromURL:(NSString*)URL type:(GPNavType)type query:(NSDictionary*)query;
-(void)dismissModal;
-(void)popNavigation;
-(void)dismissGridView:(UIView*)view;
-(UIViewController*)viewControllerFromURL:(NSString*)URL;
-(UIViewController*)viewControllerFromURL:(NSString*)URL query:(NSDictionary*)query;

//add this for GPRevealViewController
-(UIViewController*)GPRevealNavigation:(NSString*)URL;
-(void)navigationControllerChange:(UINavigationController*)navBar;
-(UISplitViewController*)splitController:(NSString*)leftURL right:(NSString*)rightURL;

@end
