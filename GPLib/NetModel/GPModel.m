//
//  GPModel.m
//  GPLib
//
//  Created by Dalton Cherry on 12/22/11.
//  Copyright (c) 2011 Basement Crew/180 Dev Designs. All rights reserved.
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

#import "GPModel.h"
//#import "Reachability.h"
#import "GPTableMoreItem.h"
#import "GPReachability.h"

@implementation GPModel

@synthesize URL, delegate = _delegate,items = items,sections = sections,isLoading = isLoading, isFinished = isFinished;

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init
{
    if ((self = [super init])) 
    {
        items = [[NSMutableArray alloc] init];
        sections = [[NSMutableArray alloc] init];
        page = 1;
        isLoading = NO;
        isFinished = NO;
        [self setupinit];
        killBackgroundThread = NO;
    }
    
    return self;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithURLString:(NSString*)url 
{
    if ((self = [super init])) 
    {
        self.URL = url;
        items = [[NSMutableArray alloc] init];
        page = 1;
        isLoading = NO;
        isFinished = NO;
        [self setupinit];
    }
    
    return self;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)loadModel:(BOOL)more
{
    //if(isLoading)
    //    return;
    isLoading = YES;
    if(more)
    {
        page++;
        if(sections) //my best guess, could be wrong
            [[items lastObject] removeLastObject];
        else
            [items removeLastObject];
    }
    else
    {
        [items removeAllObjects];
        page = 1;
    }
    
    if(![GPReachability isHostReachable:[self reachURL]])
    {
        page = 1;
        [items removeAllObjects];
        [self noConnect];
        return;
    }
    
    NSString* baseURL = @"";
    NSString* param = @"&";
    if([self.URL rangeOfString:@"?"].location == NSNotFound)
        param = @"?";
    if([self enablePaging])
        baseURL = [NSString stringWithFormat:@"%@%@page=%d",self.URL,param,page];
    else
        baseURL = self.URL;
    NSURL *theurl = [NSURL URLWithString:baseURL];
    if(theurl)
    {
        backgroundThread = [[NSThread alloc] initWithTarget:self selector:@selector(sendRequestBackground:) object:theurl];
        [backgroundThread start];
    }
    else
        [self failed:nil];
    
    //[self performSelectorInBackground:@selector(SendRequestBackground:) withObject:theurl];
    //[NSThread detachNewThreadSelector:@selector(SendRequestBackground:) toTarget:[GPModel class] withObject:theurl];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)quitModel
{
    [backgroundThread cancel];
    [backgroundThread release];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)sendRequestBackground:(NSURL*)url
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    GPHTTPRequest *request = [GPHTTPRequest requestWithURL:url];
    [self cachePolicy:request];
    if(killBackgroundThread) 
    {
        [pool drain];
        return;
    }
    [request startSync];
    if([request statusCode] != 200)
        isFinished = YES;
    if(killBackgroundThread) 
    {
        [pool drain];
        return;
    }
    [self requestFinished:request];
    [pool drain];
    [backgroundThread release];
    backgroundThread = nil;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)requestFinished:(GPHTTPRequest *)request
{
    if(!self.URL || [request.URL.absoluteString hasPrefix:self.URL])
    {
        //if([NSThread isMainThread])
        if([self enablePaging])
            if(!isFinished)
            {
                if(sections)
                    [[items lastObject] addObject:[GPTableMoreItem itemWithLoading:@"Load More..." isAutoLoad:[self autoLoad]]];
                else
                    [items addObject:[GPTableMoreItem itemWithLoading:@"Load More..." isAutoLoad:[self autoLoad]]];
            }
        [self performSelectorOnMainThread:@selector(finished:) withObject:request waitUntilDone:NO];
    }
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)finished:(GPHTTPRequest *)request
{
    isLoading = NO;
    if ([self.delegate respondsToSelector:@selector(modelFinished:)])
        [self.delegate modelFinished:request];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)requestFailed:(GPHTTPRequest *)request
{
    //NSError *error = [request error];
    [self performSelectorOnMainThread:@selector(Failed:) withObject:request waitUntilDone:NO];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)failed:(GPHTTPRequest *)request
{
    isLoading = NO;
    if ([self.delegate respondsToSelector:@selector(modelFailed:)])
        [self.delegate modelFailed:request];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)noConnect
{
    isLoading = NO;
    if ([self.delegate respondsToSelector:@selector(noConnection)])
        [self.delegate noConnection];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)dealloc
{
    [backgroundThread cancel];
    [backgroundThread release];
    killBackgroundThread = YES;
    self.delegate = nil;
    [items release];
    items = nil;
    [sections release];
    sections = nil;
    [super dealloc];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//Sub Class section!!!!
///////////////////////////////////////////////////////////////////////////////////////////////////
//use this to setup your own init variables if you are not using a custom init
-(void)setupinit
{
    
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//subclass this to enable paging on model.
-(BOOL)enablePaging
{
    return YES;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//subclass this to enable AutoLoading of Data.
-(BOOL)autoLoad
{
    return YES;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//subclass this to pick what you use for reachablity check
-(NSString*)reachURL
{
    return @"www.google.com";
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//subclass this to set what happens on a post
-(void)onPost:(NSDictionary*)entries
{
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//subclass to set custom ASI caching policy
-(void)cachePolicy:(GPHTTPRequest*)request
{
    [request setCacheTimeout:5];
    [request setCacheModel:GPHTTPCacheCustomTime];
    //[request setCachePolicy:ASIDoNotWriteToCacheCachePolicy|ASIDoNotReadFromCacheCachePolicy];
}
///////////////////////////////////////////////////////////////////////////////////////////////////

@end
