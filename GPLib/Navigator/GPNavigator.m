//
//  GPNavigator.m
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

#import "GPNavigator.h"
#import "UIViewController+Additions.h"
#import "UIBarButtonItem+Additions.h"

@interface GPNavigator()

-(void)navOpenPopOver:(UIViewController*)temp rightbtn:(UIBarButtonItem*)right leftbtn:(UIBarButtonItem*)left frame:(CGRect)frame;
-(void)navOpenModal:(UIViewController*)temp rightbtn:(UIBarButtonItem*)right leftbtn:(UIBarButtonItem*)left type:(GPNavType)type useRoot:(BOOL)root;
-(NSString*)determineSelURL:(NSString*)URLString query:(NSDictionary*)query;
-(id)runSelector:(SEL)sel class:(Class)class params:(NSArray*)params;
-(NSString*)pathFromURL:(NSURL*)URL;

@end

@implementation GPNavigator

@synthesize navigationController = Navigation,URLs = URLs,popOver,useCustomBackButton;

NSString* GPHTTPLINKSURL = @"http"; //use to map your http links to a view controller (probably with a webview)

static GPNavigator* GlobalNavigator; //store this here, so we can call the public functions and not have to recreate a new navigator for each url call.
//this will leak once this object, but because it is suppose to live for the lifetime of the app, should not be a problem. For peace of mine that memory is cleaned
//up properly, just call release on the function below and that should free the memory. This release statment should be place in the app delegate. Example:
//[[GPNavigator navigator] release] //now memory is free.
/////////////////////////////////////////////////////////////
+(GPNavigator*)navigator
{
    if(!GlobalNavigator)
        GlobalNavigator = [[GPNavigator alloc] init];
    return GlobalNavigator;
}
/////////////////////////////////////////////////////////////
-(id)init
{
    if(self = [super init])
    {
        URLs = [[NSMutableDictionary alloc] init];
    }
    return self;
}
/////////////////////////////////////////////////////////////
//map a viewController class to a URL
-(void)mapViewController:(Class)ViewClass toURL:(NSString*)URL
{
    [URLs setObject:ViewClass forKey:URL];
}
/////////////////////////////////////////////////////////////
//open a URL normally
-(BOOL)openURL:(NSString*)URL
{
    return [self openURL:URL NavType:GPNavTypeNormal];
}
/////////////////////////////////////////////////////////////
//Open a URL and specify the way it will be displayed.
-(BOOL)openURL:(NSString*)URL NavType:(GPNavType)type
{
    return [self openURL:URL NavType:type query:nil];
}
/////////////////////////////////////////////////////////////.
-(BOOL)openURL:(NSString*)URL view:(UIView*)gridView query:(NSDictionary*)query
{
    return [self openURL:URL NavType:GPNavTypeGrid query:query rightbtn:nil leftbtn:nil frame:CGRectZero view:gridView useRoot:NO];
}
/////////////////////////////////////////////////////////////
-(BOOL)openURL:(NSString*)URL NavType:(GPNavType)type query:(NSDictionary*)query
{
    return [self openURL:URL NavType:type query:query rightbtn:nil leftbtn:nil frame:CGRectZero view:nil useRoot:NO];
}
/////////////////////////////////////////////////////////////
-(BOOL)openURL:(NSString*)URL NavType:(GPNavType)type query:(NSDictionary*)query useRoot:(BOOL)root
{
    return [self openURL:URL NavType:type query:query rightbtn:nil leftbtn:nil frame:CGRectZero view:nil useRoot:root];
}
/////////////////////////////////////////////////////////////
-(BOOL)openURL:(NSString*)URL query:(NSDictionary*)query frame:(CGRect)frame
{
    return [self openURL:URL NavType:GPNavTypePopOver query:query rightbtn:nil leftbtn:nil frame:frame view:nil useRoot:NO];
}
/////////////////////////////////////////////////////////////
-(BOOL)openURL:(NSString*)URL NavType:(GPNavType)type query:(NSDictionary*)query rightbtn:(UIBarButtonItem*)right leftbtn:(UIBarButtonItem*)left
{
    return [self openURL:URL NavType:type query:query rightbtn:right leftbtn:left frame:CGRectZero view:nil useRoot:NO];
}
/////////////////////////////////////////////////////////////
//open a URL and send a url along too. This will override whatever URL init you had
//and use the initWithNavigatorURL:query: if query is not nil. 
-(BOOL)openURL:(NSString*)URL NavType:(GPNavType)type query:(NSDictionary*)query rightbtn:(UIBarButtonItem*)right leftbtn:(UIBarButtonItem*)left frame:(CGRect)frame view:(UIView*)gridView useRoot:(BOOL)root
{
    if(type == GPNavTypeGrid && !gridView)
        type = GPNavTypeModal;
    if(!GPIsPad() && type == GPNavTypePopOver)
        type = GPNavTypeModal;
    
    id object = [self createViewControllerFromURL:URL type:type query:query];

    if([object isKindOfClass:[UIViewController class]])
    {
        UIViewController* temp = object;
        if(!Navigation)
        {
            if(temp.navigationController)
            {
                Navigation = [temp.navigationController retain];
                Navigation.delegate = self;
            }
            else
                Navigation = [[UINavigationController alloc] initWithRootViewController:temp];
        }
        else
        {
            if(type == GPNavTypeModal || type == GPNavTypeFlip || type == GPNavTypeDissolve || type == GPNavTypeCurl ||
               type == GPNavTypeModalForm || type == GPNavTypeModalPage)
                [self navOpenModal:temp rightbtn:right leftbtn:left type:type useRoot:root];
            
            else if(type == GPNavTypePopOver)
                [self navOpenPopOver:temp rightbtn:right leftbtn:left frame:frame];
            
            else if(type == GPNavTypeGrid)
            {
                if([temp respondsToSelector:@selector(setDelegate:)])
                    [temp performSelector:@selector(setDelegate:) withObject:Navigation.visibleViewController];
                [self.navigationController.visibleViewController expandView:gridView toViewController:temp];
            }
            else
            {
                [self.popOver dismissPopoverAnimated:YES];
                if(currentViewController && currentViewController != Navigation)
                {
                    UINavigationController* navBar = (UINavigationController*)currentViewController;
                    if([temp respondsToSelector:@selector(setDelegate:)])
                        [temp performSelector:@selector(setDelegate:) withObject:navBar.visibleViewController];
                    [navBar pushViewController:temp animated:YES];
                }
                else
                {
                    if([temp respondsToSelector:@selector(setDelegate:)])
                        [temp performSelector:@selector(setDelegate:) withObject:Navigation.visibleViewController];
                    [Navigation pushViewController:temp animated:YES];
                }
            }
        }
        return YES;
    }
    return NO;
}
/////////////////////////////////////////////////////////////
//open a URL to another application
-(BOOL)openExternalURL:(NSString*)URL
{
    return [self openExternalURL:URL searchString:nil];
}
/////////////////////////////////////////////////////////////
//open a URL to another application and search appstore
-(BOOL)openExternalURL:(NSString*)URL searchString:(NSString*)search
{
    NSURL* interURL = [NSURL URLWithString:URL];
    if([[UIApplication sharedApplication] canOpenURL:interURL])
        return [[UIApplication sharedApplication] openURL:interURL];
    if(search)
    {
        interURL = [NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://itunes.com/apps/%@",search]];
        if([[UIApplication sharedApplication] canOpenURL:interURL])
            return [[UIApplication sharedApplication] openURL:interURL];
    }
    return NO;
}
/////////////////////////////////////////////////////////////
-(id)createViewControllerFromURL:(NSString*)URL type:(GPNavType)type query:(NSDictionary*)query
{   
    NSURL* paramsURL = [NSURL URLWithString:URL];
    
    NSString* path = [self pathFromURL:paramsURL];
    NSArray* params = [path componentsSeparatedByString:@"/"];
    
    if([params count] > 1)
    {
        NSMutableArray* array = [[[NSMutableArray alloc] initWithArray:params] autorelease];
        [array removeObjectAtIndex:0];
        params = array;
    }
    else
        params = nil;
    
    int paramscount = [params count];
    NSString* selURL = [self determineSelURL:URL query:query];
    if([selURL isEqualToString:GPHTTPLINKSURL])
        params = [NSArray arrayWithObjects:[NSURL URLWithString:URL],query,nil];
    Class class = [URLs objectForKey:selURL];
    SEL sel = [self selectorFromURL:selURL];
    
    if([selURL isEqualToString:@""] && query)
        params = [NSArray arrayWithObjects:paramsURL,query,nil];
    else if(params && query && paramscount != params.count)
        params = [params arrayByAddingObject:query];
    else if(!params && query)
        params = [NSArray arrayWithObjects:paramsURL,query,nil];
    else if([NSStringFromSelector(sel) isEqualToString:@"initWithNavigatorURL:query:"] && params && !query && ![selURL isEqualToString:GPHTTPLINKSURL])
        params = [NSArray arrayWithObject:[NSURL URLWithString:[params objectAtIndex:0]]];
    
    if(![class instancesRespondToSelector:sel])
    {
        sel = @selector(init);
        params = nil;
    }
    /*if(params.count > paramscount && paramscount > 0)
    {
        NSMutableArray* temp = [NSMutableArray arrayWithCapacity:paramscount];
        for(int i = 0; i < paramscount; i++)
            [temp addObject:[params objectAtIndex:i]];
        [params release];
        params = [NSArray arrayWithArray:temp];
            
    }*/
    id object = [[self runSelector:sel class:class params:params] retain];
    return [object autorelease];
}
/////////////////////////////////////////////////////////////
-(void)navOpenModal:(UIViewController*)temp rightbtn:(UIBarButtonItem*)right leftbtn:(UIBarButtonItem*)left type:(GPNavType)type useRoot:(BOOL)root
{
    if(type == GPNavTypeCurl)
        temp.modalTransitionStyle = UIModalTransitionStylePartialCurl;
    if(type == GPNavTypeDissolve)
        temp.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    if(type == GPNavTypeFlip)
        temp.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self.popOver dismissPopoverAnimated:YES];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:temp];
    navigationController.delegate = self;
    if([temp respondsToSelector:@selector(setDelegate:)])
        [temp performSelector:@selector(setDelegate:) withObject:Navigation.visibleViewController];
    if(type == GPNavTypeModalForm)
        [navigationController setModalPresentationStyle:UIModalPresentationFormSheet];
    else if(type == GPNavTypeModalPage)
        [navigationController setModalPresentationStyle:UIModalPresentationPageSheet];
    else
        [navigationController setModalPresentationStyle:UIModalPresentationFullScreen];
    if(right)
        temp.navigationItem.rightBarButtonItem = right;
    if(left)
        temp.navigationItem.leftBarButtonItem = left;
    if([[[UIApplication sharedApplication].delegate window].rootViewController respondsToSelector:@selector(isGPNavBar)] || root)
        [[[UIApplication sharedApplication].delegate window].rootViewController presentModalViewController:navigationController animated:YES];
    else
        [Navigation.visibleViewController presentModalViewController:navigationController animated:YES];
        
    currentViewController = navigationController;
    if(!modalArray)
        modalArray = [[NSMutableArray alloc] init];
    [modalArray addObject:Navigation];
    [Navigation release];
    Navigation = [navigationController retain];
    [navigationController release];
}
/////////////////////////////////////////////////////////////
-(void)navOpenPopOver:(UIViewController*)temp rightbtn:(UIBarButtonItem*)right leftbtn:(UIBarButtonItem*)left frame:(CGRect)frame
{
    int arrowDirection = UIPopoverArrowDirectionAny;
    if([self.popOver.contentViewController isKindOfClass:[UINavigationController class]] && self.popOver.isPopoverVisible)
        [(UINavigationController*)self.popOver.contentViewController pushViewController:temp animated:YES];
    else
    {
        [self.popOver dismissPopoverAnimated:YES];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:temp];
        UIPopoverController* pop = [[UIPopoverController alloc] initWithContentViewController:navigationController];
        pop.delegate = (id<UIPopoverControllerDelegate>)Navigation.visibleViewController;
        if([temp respondsToSelector:@selector(setDelegate:)])
            [temp performSelector:@selector(setDelegate:) withObject:Navigation.visibleViewController];
        self.PopOver = pop;
        [pop release];
        [navigationController release];
        if(right)
            [self.popOver presentPopoverFromBarButtonItem:right permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        else if(left)
            [self.popOver presentPopoverFromBarButtonItem:left permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        else
        {
            if(CGRectEqualToRect(frame,CGRectZero))
            {
                frame = CGRectMake(Navigation.visibleViewController.view.frame.size.width/2, Navigation.visibleViewController.view.frame.size.height/2, 1, 1);
                arrowDirection = 0;
            }
            if(frame.size.width == 0 || frame.size.height == 0)
            {
                frame.size.width = Navigation.visibleViewController.view.frame.size.width;
                frame.size.height = Navigation.visibleViewController.view.frame.size.height;
                frame.origin.x = Navigation.visibleViewController.view.frame.size.width/2;
                frame.origin.y = Navigation.visibleViewController.view.frame.size.height/2;
            }
            [self.popOver presentPopoverFromRect:frame inView:Navigation.visibleViewController.view permittedArrowDirections:arrowDirection animated:YES]; 
        }
    }
}
/////////////////////////////////////////////////////////////
//create a Selector off the URL
-(SEL)selectorFromURL:(NSString*)URLstring
{
    NSURL* URL = [NSURL URLWithString:URLstring];
    URLstring = [NSString stringWithFormat:@"%@%@",URL.host,URL.path];
    NSArray* params = [URLstring componentsSeparatedByString:@"/"];
    if([params count] > 1)
    {
        NSMutableString* selmethod = [[[NSMutableString alloc] init] autorelease];
        for(int i = 1; i < [params count]; i++) //skip the root just the params
            [selmethod appendString:[params objectAtIndex:i]];
        //NSLog(@"sel method: %@",selmethod);
        return NSSelectorFromString(selmethod);
    }
    return  @selector(initWithNavigatorURL:query:); //@selector(init);
}
/////////////////////////////////////////////////////////////
//determine the proper url to class map from our request URL 
-(NSString*)determineSelURL:(NSString*)URLString query:(NSDictionary*)query
{
    NSURL* URL = [NSURL URLWithString:URLString];
    if([URLString hasPrefix:GPHTTPLINKSURL])
        return GPHTTPLINKSURL;
    NSString* baseURL = @"";
    for(NSString* string in URLs)
    {
        NSURL* cURL = [NSURL URLWithString:string];
        if([cURL.host isEqualToString:URL.host])
        {
            baseURL = [NSString stringWithFormat:@"%@://%@",cURL.scheme,cURL.host];
            if([[ [self pathFromURL:cURL] componentsSeparatedByString:@"/"] count] == [[ [self pathFromURL:URL] componentsSeparatedByString:@"/"] count])
                return cURL.absoluteString;
            else if(query && [[ [self pathFromURL:cURL] componentsSeparatedByString:@"/"] count] == [[ [self pathFromURL:URL] componentsSeparatedByString:@"/"] count]+1
                    && [cURL.absoluteString rangeOfString:@"query:"].location != NSNotFound)
                return cURL.absoluteString;
        }
    }
    return baseURL;
}
/////////////////////////////////////////////////////////////
//returns a object based off the return of the NSInvocation,
//mostly likely this will be a View Controller.
-(id)runSelector:(SEL)sel class:(Class)class params:(NSArray*)params
{
    id vc = nil;
    if([class instancesRespondToSelector:sel])
    {
        id object = [class alloc];
        NSMethodSignature *sig = [object methodSignatureForSelector:sel];
        if (sig) 
        {
            NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:sig];
            [invocation setTarget:object];
            int i = 2;
            for(id object in params)
            {
                if([object isKindOfClass:[NSString class]])
                    object = [object decodeURL];
                [invocation setArgument:&object atIndex:i];
                i++;
            }
            [invocation setSelector:sel];
            [invocation invoke];
            [invocation getReturnValue:&vc];
        }
        else
            [object release];
    }
    if(!vc)
        return nil;
    return [vc autorelease];
}
/////////////////////////////////////////////////////////////
//NSURL.path decodes the URL, not what I want, so do manually
-(NSString*)pathFromURL:(NSURL*)URL
{
    NSString* path = URL.absoluteString; 
    if(!URL.host)
        return path;
    NSRange range = [path rangeOfString:URL.host];
    if(range.location != NSNotFound)
        path = [path substringFromIndex:range.location+range.length]; //substringFromIndex
    else
        path = URL.path;
    return path;
}
/////////////////////////////////////////////////////////////
-(void)dismissGridView:(UIView*)view
{
    [Navigation.visibleViewController dismissExpandViewController:view];
}
/////////////////////////////////////////////////////////////
//dimissModal view
-(void)dismissModal
{
    [self dismissModal:NO];
}
/////////////////////////////////////////////////////////////
//dismiss modal view with root
-(void)dismissModal:(BOOL)root
{
    if(self.popOver)
    {
        [self.popOver dismissPopoverAnimated:YES];
        self.popOver = nil;
        currentViewController = nil;
        return;
    }
    else if([[[UIApplication sharedApplication].delegate window].rootViewController respondsToSelector:@selector(isGPNavBar)] || root)
        [[[UIApplication sharedApplication].delegate window].rootViewController dismissModalViewControllerAnimated:YES];
    else
        [Navigation.visibleViewController dismissModalViewControllerAnimated:YES];
    
    [Navigation release];
    Navigation = [[modalArray lastObject] retain];
    [modalArray removeLastObject];
    currentViewController = nil;
}
/////////////////////////////////////////////////////////////
//popNavController view
-(void)popNavigation
{
    [Navigation popViewControllerAnimated:YES];
}
/////////////////////////////////////////////////////////////
//update gpnavigator you change the navigationController.
-(void)navigationControllerChange:(UINavigationController*)navBar
{
    [Navigation release];
    Navigation = [navBar retain];
    Navigation.delegate = self;
}
/////////////////////////////////////////////////////////////
//property implementation
-(UIViewController*)visibleViewController
{
    return Navigation.visibleViewController;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//simple view controller addition
-(UIViewController*)viewControllerFromURL:(NSString*)URL
{
    return [[GPNavigator navigator] createViewControllerFromURL:URL type:GPNavTypeNormal query:nil];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//simple view controller addition
-(UIViewController*)viewControllerFromURL:(NSString*)URL query:(NSDictionary*)query
{
    return [[GPNavigator navigator] createViewControllerFromURL:URL type:GPNavTypeNormal query:query];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//add this for GPRevealViewController
-(UIViewController*)GPRevealNavigation:(NSString*)URL
{
    UIViewController* temp = [self viewControllerFromURL:URL];
    if([temp respondsToSelector:@selector(frontNavBar)]) 
        Navigation = [[temp performSelector:@selector(frontNavBar)] retain];
    return temp;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(UISplitViewController*)splitController:(NSString*)leftURL right:(NSString*)rightURL
{
    UIViewController* rightVC = [self viewControllerFromURL:rightURL];
    Navigation = [[UINavigationController alloc] initWithRootViewController:rightVC];
    UISplitViewController* split = [[[UISplitViewController alloc] init] autorelease];
    split.viewControllers = [NSArray arrayWithObjects:[self viewControllerFromURL:leftURL],Navigation, nil];
    return split;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)dealloc
{
    [URLs release];
    [Navigation release];
    [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated 
{
    if(self.useCustomBackButton)
    {
        if([navigationController.viewControllers count ] > 1) 
        {
            UIViewController* backViewController = [navigationController.viewControllers objectAtIndex:(navigationController.viewControllers.count - 2)];
            NSString* backText = backViewController.title;
            UIBarButtonItem* newBackButton = [UIBarButtonItem customBackButtonWithTitle:backText target:navigationController selector:@selector(popViewControllerAnimated:)];
            viewController.navigationItem.leftBarButtonItem = newBackButton;
            viewController.navigationItem.hidesBackButton = YES;
        }
    }
}
///////////////////////////////////////////////////////////////////////////////////////////////////
@end
