//
//  GPNav.h
//  TestApp
//
//  Created by Dalton Cherry on 10/25/12.
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
    GPModalNormalType,
    GPModalFormType,
    GPModalPageType
} GPModalType;

typedef enum {
    GPModalTranTypeNormal,
    GPModalTranTypeDissolve,
    GPModalTranTypeFlip,
    GPModalTranTypeCurl
} GPModalTranType;


#import <Foundation/Foundation.h>

@interface GPNav : NSObject<UINavigationControllerDelegate>
{
    NSMutableDictionary* URLs;
}
//all of the URLs currently mapped.
@property(nonatomic,retain)NSDictionary* URLs;

//the currently visibleViewController.
@property(nonatomic,readonly)UIViewController* visibleViewController;

//the most recent NavController used by any of the open methods.
@property(nonatomic,retain)UINavigationController* currentNavController;

//popover used for by openPopover methods.
@property(nonatomic, retain)UIPopoverController* popover;

//the shared GPNav instance (singleton)
+(GPNav*)sharedNav;

//map a viewcontroller to a url.
-(void)mapVC:(NSString*)url from:(Class)navC selector:(SEL)selector;

//create a viewcontroller from a url you have mapped
-(UIViewController*)viewControllerFromURL:(NSString*)url;

//create a viewcontroller from a url you have mapped
-(UIViewController*)viewControllerFromURL:(NSString*)url query:(NSDictionary*)query;

//map a viewcontroller to a scheme. This is mainly use to map http urls to a webViewController
//you must implement the selector of: -(id)initWithSchemeURL:(NSString*)url for this to work properly.
-(void)mapScheme:(NSString*)scheme from:(Class)navC;

//open a URL with normal slide navigation
-(void)openURL:(NSString*)url navController:(UINavigationController*)navBar;

//open a URL with normal slide navigation
-(void)openURL:(NSString*)url navController:(UINavigationController*)navBar query:(NSDictionary*)query;

//open a view controller modal style. returns the new view controller created from the url
-(UIViewController*)openModal:(NSString*)url vc:(UIViewController*)vc;

//open a view controller modal style. returns the new view controller created from the url
-(UIViewController*)openModal:(NSString*)url vc:(UIViewController*)vc query:(NSDictionary*)query;

//open a view controller modal style. returns the new view controller created from the url
-(UIViewController*)openModal:(NSString*)url vc:(UIViewController*)vc style:(GPModalType)type;

//open a view controller modal style. returns the new view controller created from the url
-(UIViewController*)openModal:(NSString*)url vc:(UIViewController*)vc style:(GPModalType)type transition:(GPModalTranType)tranType;

//open a view controller modal style. returns the new view controller created from the url
-(UIViewController*)openModal:(NSString*)url vc:(UIViewController*)vc style:(GPModalType)type transition:(GPModalTranType)tranType query:(NSDictionary*)query;

//open a popover view. returns the new view controller created from the url
-(UIViewController*)openPopover:(NSString*)url vc:(UIViewController*)vc barItem:(UIBarButtonItem*)item;

//open popover view. returns the new view controller created from the url
-(UIViewController*)openPopover:(NSString*)url vc:(UIViewController*)vc frame:(CGRect)rect view:(UIView*)view;

//open a popover view. Opens modal if iPhone. baritem is what button to display from.
//Frame and view are the popover frame and view if no button is specified. returns the new view controller created from the url
-(UIViewController*)openPopover:(NSString*)url vc:(UIViewController*)vc barItem:(UIBarButtonItem*)item frame:(CGRect)rect view:(UIView*)view;

@end
