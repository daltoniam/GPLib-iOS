//
//  GPNav.m
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

#import "GPNav.h"
#import <objc/runtime.h>

typedef enum {
    GPArgTypeNone,
    GPArgTypePointer,
    GPArgTypeBool,
    GPArgTypeInteger,
    GPArgTypeLongLong,
    GPArgTypeFloat,
    GPArgTypeDouble,
} GPArgType;

///////////////////////////////////////////////////////////////////////////////////////////////////
//simple object to hold content of GPNav
///////////////////////////////////////////////////////////////////////////////////////////////////
@interface NavObject : NSObject

@property(nonatomic,assign)SEL selector;
@property(nonatomic,assign)Class navClass;
@property(nonatomic,copy)NSString* scheme;

+(NavObject*)navObject:(NSString*)url navClass:(Class)navC selector:(SEL)selector;

@end
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation GPNav

@synthesize URLs = URLs,currentNavController,popover;

static GPNav* sharedNav;
GPArgType argTypeAsChar(char argType);
///////////////////////////////////////////////////////////////////////////////////////////////////
+(GPNav*)sharedNav
{
    if(!sharedNav)
        sharedNav = [[GPNav alloc] init];
    return sharedNav;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)mapVC:(NSString*)url from:(Class)navC selector:(SEL)selector
{
    if(!URLs)
        URLs = [[NSMutableDictionary alloc] init];
    NSURL* fullURL = [NSURL URLWithString:url];
    NSString* host = [fullURL host];
    NSMutableArray* array = [URLs objectForKey:host];
    if(!array)
        array = [NSMutableArray array];
    NavObject* object = [NavObject navObject:[fullURL scheme] navClass:navC selector:selector];
    [array addObject:object];
    [URLs setValue:array forKey:host];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)mapScheme:(NSString*)scheme from:(Class)navC
{
    NavObject* object = [NavObject navObject:scheme navClass:navC selector:@selector(initWithSchemeURL:)];
    [URLs setValue:object forKey:scheme];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)openURL:(NSString*)url navController:(UINavigationController*)navBar
{
    return [self openURL:url navController:navBar query:nil];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)openURL:(NSString*)url navController:(UINavigationController*)navBar query:(NSDictionary*)query
{
    UIViewController* vc = [self viewControllerFromURL:url query:query];
    if(vc)
    {
        [navBar pushViewController:vc animated:YES];
        self.currentNavController = [navBar retain];
    }
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(UIViewController*)viewControllerFromURL:(NSString*)url query:(NSDictionary*)query
{
    NSURL* fullURL = [NSURL URLWithString:url];
    NSString* host = [fullURL host];
    NSMutableArray* matchURLs = [URLs objectForKey:host];
    if(!matchURLs)
    {
        NavObject* matchObj = [URLs objectForKey:fullURL.scheme];
        return [self openObject:matchObj query:nil params:[NSArray arrayWithObject:url]];
    }
    if(matchURLs)
    {
        NSString* path = [self pathFromURL:[NSURL URLWithString:url]];
        NSArray* params = nil;
        int paramCount = 0;
        if(![path isEqualToString:@""])
        {
            params = [path componentsSeparatedByString:@"/"];
            NSMutableArray* array = [NSMutableArray arrayWithArray:params];
            [array removeObjectAtIndex:0];
            params = array;
            paramCount = params.count;
        }
        BOOL useQuery = NO;
        NavObject* matchObj = [self findObject:matchURLs query:query count:paramCount scheme:fullURL.scheme useQuery:&useQuery];
        NSDictionary* dict = query;
        if(!useQuery)
            dict = nil;
        return [self openObject:matchObj query:dict params:params];
    }
    return nil;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(UIViewController*)viewControllerFromURL:(NSString*)url
{
    return [self viewControllerFromURL:url query:nil];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//modal methods
///////////////////////////////////////////////////////////////////////////////////////////////////
-(UIViewController*)openModal:(NSString*)url vc:(UIViewController*)vc
{
    return [self openModal:url vc:vc query:nil];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(UIViewController*)openModal:(NSString*)url vc:(UIViewController*)vc query:(NSDictionary*)query
{
    return [self openModal:url vc:vc style:GPModalNormalType transition:GPModalTranTypeNormal query:query];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(UIViewController*)openModal:(NSString*)url vc:(UIViewController*)vc style:(GPModalType)type
{
    return [self openModal:url vc:vc style:type transition:GPModalTranTypeNormal query:nil];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(UIViewController*)openModal:(NSString*)url vc:(UIViewController*)vc style:(GPModalType)type transition:(GPModalTranType)tranType
{
    return [self openModal:url vc:vc style:type transition:tranType query:nil];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(UIViewController*)openModal:(NSString*)url vc:(UIViewController*)vc style:(GPModalType)type transition:(GPModalTranType)tranType query:(NSDictionary*)query
{
    UIViewController* newVC = [self viewControllerFromURL:url];
    if(newVC)
    {
        if(tranType == GPModalTranTypeCurl)
            newVC.modalTransitionStyle = UIModalTransitionStylePartialCurl;
        if(tranType == GPModalTranTypeDissolve)
            newVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        if(tranType == GPModalTranTypeFlip)
            newVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:newVC];
        navigationController.delegate = self;
        if([newVC respondsToSelector:@selector(setDelegate:)])
            [newVC performSelector:@selector(setDelegate:) withObject:vc];
        if(type == GPModalFormType)
            [navigationController setModalPresentationStyle:UIModalPresentationFormSheet];
        else if(type == GPModalPageType)
            [navigationController setModalPresentationStyle:UIModalPresentationPageSheet];
        else
            [navigationController setModalPresentationStyle:UIModalPresentationFullScreen];
        self.currentNavController = [navigationController retain];
        [vc presentViewController:navigationController animated:YES completion:NULL];
        [navigationController release];
        return newVC;
    }
    return nil;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(UIViewController*)openPopover:(NSString*)url vc:(UIViewController*)vc barItem:(UIBarButtonItem*)item
{
    return [self openPopover:url vc:vc barItem:item frame:CGRectZero view:nil];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(UIViewController*)openPopover:(NSString*)url vc:(UIViewController*)vc frame:(CGRect)rect view:(UIView*)view
{
    return [self openPopover:url vc:vc barItem:nil frame:rect view:view];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(UIViewController*)openPopover:(NSString*)url vc:(UIViewController*)vc barItem:(UIBarButtonItem*)item frame:(CGRect)rect view:(UIView*)view
{
    if(!GPIsPad())
        return [self openModal:url vc:vc];
    
    UIViewController* newVC = [self viewControllerFromURL:url];
    if(newVC)
    {
        [self.popover dismissPopoverAnimated:YES];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:newVC];
        UIPopoverController* pop = [[UIPopoverController alloc] initWithContentViewController:navigationController];
        pop.delegate = (id<UIPopoverControllerDelegate>)vc;
        if([newVC respondsToSelector:@selector(setDelegate:)])
            [newVC performSelector:@selector(setDelegate:) withObject:vc];
        self.Popover = pop;
        [pop release];
        self.currentNavController = [navigationController retain];
        [navigationController release];
        
        if(item)
            [self.popover presentPopoverFromBarButtonItem:item permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        else if(view && !CGRectEqualToRect(rect, CGRectZero))
            [self.popover presentPopoverFromRect:rect inView:view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        return newVC;
    }
    return nil;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//private methods
///////////////////////////////////////////////////////////////////////////////////////////////////
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
///////////////////////////////////////////////////////////////////////////////////////////////////
-(int)selectorParaCount:(SEL)selector
{
    NSString* selString = NSStringFromSelector(selector);
    NSArray* params = [selString componentsSeparatedByString:@":"];
    NSMutableArray* array = [NSMutableArray arrayWithArray:params];
    [array removeObjectAtIndex:0];
    params = array;
    int count = params.count;
    if(count == 1)
        if([selString rangeOfString:@":"].location == NSNotFound)
            count--;
    return count;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(NavObject*)findObject:(NSArray*)matchURLs query:(NSDictionary*)query count:(int)paramCount scheme:(NSString*)scheme useQuery:(BOOL*)useQuery
{
    NavObject* matchObj = nil;
    for(NavObject* object in matchURLs)
    {
        if([object.scheme isEqualToString:scheme])
        {
            int count = [self selectorParaCount:object.selector];
            if(paramCount == count)
            {
                *useQuery = NO;
                matchObj = object;
                break;
            }
            else if(query && paramCount == count+1)
            {
                *useQuery = YES;
                matchObj = object;
                break;
            }
        }
    }
    return matchObj;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(UIViewController*)openObject:(NavObject*)matchObj query:(NSDictionary*)query params:(NSArray*)params
{
    if(matchObj)
    {
        if([matchObj.navClass instancesRespondToSelector:matchObj.selector])
        {
            id object = [[matchObj.navClass alloc] autorelease];
            NSMethodSignature* sig = [object methodSignatureForSelector:matchObj.selector];
            NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:sig];
            [invocation setTarget:object];
            [invocation setSelector:matchObj.selector];
            [self setArgumentsFromValues:params forInvocation:invocation];
            if(query)
                [invocation setArgument:&query atIndex:params.count+2];
            [invocation invoke];
            id vc = nil;
            if (sig.methodReturnLength)
                [invocation getReturnValue:&vc];
            return vc;
        }
    }
    return nil;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setArgument:(NSString*)text withType:(GPArgType)type atIndex:(NSInteger)index forInvocation:(NSInvocation*)invocation
{
    index+=2;// There are two implicit arguments with an invocation.
    
    if(type == GPArgTypeNone)
        return;
    else if(type == GPArgTypeInteger)
    {
        int val = [text intValue];
        [invocation setArgument:&val atIndex:index];
    }
    else if(type == GPArgTypeLongLong)
    {
        long long val = [text longLongValue];
        [invocation setArgument:&val atIndex:index];
    }
    else if(type == GPArgTypeFloat)
    {
        float val = [text floatValue];
        [invocation setArgument:&val atIndex:index];
    }
    else if(type == GPArgTypeInteger)
    {
        int val = [text intValue];
        [invocation setArgument:&val atIndex:index];
    }
    else if(type == GPArgTypeDouble)
    {
        double val = [text doubleValue];
        [invocation setArgument:&val atIndex:index];
    }
    else if(type == GPArgTypeBool)
    {
        BOOL val = [text boolValue];
        [invocation setArgument:&val atIndex:index];
    }
    else
    {
        if([text isKindOfClass:[NSString class]])
            text = [text decodeURL];
        [invocation setArgument:&text atIndex:index];
    }
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setArgumentsFromValues:(NSArray *)values forInvocation:(NSInvocation *)invocation {
    Method method = class_getInstanceMethod([invocation.target class], invocation.selector);
    if(method)
    {
        for (NSInteger ix = 0; ix < [values count]; ++ix)
        {
            NSString* value = [values objectAtIndex:ix];
            char argType[4];
            method_getArgumentType(method, (unsigned int) ix + 2, argType, sizeof(argType) / sizeof(argType[0]));
            GPArgType type = argTypeAsChar(argType[0]);
            [self setArgument:value withType:type atIndex:ix forInvocation:invocation];
        }
    }
}
///////////////////////////////////////////////////////////////////////////////////////////////////
GPArgType argTypeAsChar(char argType)
{
    if (argType == 'c' || argType == 'i' || argType == 's' || argType == 'l' || argType == 'C'
        || argType == 'I' || argType == 'S' || argType == 'L') 
        return GPArgTypeInteger;
    else if (argType == 'q' || argType == 'Q')
        return GPArgTypeLongLong;
    else if (argType == 'f') 
        return GPArgTypeFloat;
    else if (argType == 'd') 
        return GPArgTypeDouble;
    else if (argType == 'B')
        return GPArgTypeBool;
    else
        return GPArgTypePointer;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(UIViewController*)visibleViewController
{
    return currentNavController.visibleViewController;
}
///////////////////////////////////////////////////////////////////////////////////////////////////

@end

///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NavObject

@synthesize selector,navClass,scheme;
///////////////////////////////////////////////////////////////////////////////////////////////////
+(NavObject*)navObject:(NSString*)scheme navClass:(Class)navC selector:(SEL)selector
{
    NavObject* object = [[[NavObject alloc] init] autorelease];
    object.scheme = scheme;
    object.navClass = navC;
    object.selector = selector;
    return object;
}
///////////////////////////////////////////////////////////////////////////////////////////////////

@end
///////////////////////////////////////////////////////////////////////////////////////////////////
