//
//  GPGridViewController.m
//  GPLib
//
//  Created by Dalton Cherry on 4/11/12.
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

#import "GPGridViewController.h"
#import "GPGridViewItem.h"
#import <objc/runtime.h>
#import "GPNavigator.h"
#import "ASIDownloadCache.h"
#import "ASIHTTPRequest.h"
#import "GPCenterLabel.h"
#import "GPGridMoreCell.h"
#import "GPGridMoreItem.h"

#import "GPTableMoreItem.h" //because GPModel returns a tablemoreitem by default

@interface GPGridViewController ()

-(void)processImageURL:(id)object;

@end

@implementation GPGridViewController

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        items = [[NSMutableArray alloc] init];
        gridView = [[GPGridView alloc] init];
        gridView.delegate = self;
        gridView.dataSource = self;
    }
    return self;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithURLString:(NSString*)url 
{
    if ((self = [super init])) 
    {
        [self fetchData:url];
    }
    return self;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)fetchData:(NSString*)url
{
    [model release];
    model = [[self model:url] retain];
    model.delegate = self;
    [model loadModel:NO];
    ActLabel.hidden = NO;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidLoad
{
    [super viewDidLoad];
    gridView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    gridView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:gridView];
    self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    
    ActLabel = [[GPLoadingLabel alloc] initWithStyle:GPLoadingLabelWhiteStyle];
    ActLabel.frame = gridView.frame;
    ActLabel.autoresizingMask =  UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    ActLabel.text = [self loadingText];
    [self.view addSubview:ActLabel];
    
    if(!model.URL || !model.isLoading)
        ActLabel.hidden = YES;

}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidUnload
{
    [super viewDidUnload];
    for(ASIHTTPRequest* request in queue.operations)
        [request clearDelegatesAndCancel];
    model.delegate = nil;
    gridView.delegate = nil;
    gridView.dataSource = nil;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)numberOfRowsInGridView:(GPGridView*)gridview
{
    float rows = [items count]/(float)gridview.columnCount;
    int rowCal = rows;
    if(rows > rowCal && rows < rowCal+1)
        rowCal += 1;
    return rowCal;//[items count]/gridview.columnCount;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)numberOfColumnsInGridView:(GPGridView*)gridview orientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if(GPIsPad() && UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
            return 4;
    return 3;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(CGFloat)heightForRows:(GPGridView *)gridView;
{
    if(GPIsPad())
        return 240;
    return 120;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//where the gridview magic happens. return the cell class for the object class that comes through
- (Class)gridView:(GPGridView*)gridview cellClassForObject:(id)object
{
    if([object isKindOfClass:[GPGridMoreItem class]])
        return [GPGridMoreCell class];
    else if([object isKindOfClass:[GPGridViewItem class]])
        return [GPGridViewCell class];
    return [GPGridViewCell class];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (GPGridViewCell*)gridView:(GPGridView *)gridview viewAtIndex:(NSInteger)index
{
    if(index < items.count)
    {
        id object = [items objectAtIndex:index];
        if([object isKindOfClass:[GPTableMoreItem class]])
        {
            GPTableMoreItem* moreItem = (GPTableMoreItem*)object;
            GPGridMoreItem* item = [GPGridMoreItem itemWithLoading:moreItem.text isAutoLoad:moreItem.isAutoLoad];
            [items replaceObjectAtIndex:index withObject:item];
            object = item;
        }
        Class cellClass = [self gridView:gridView cellClassForObject:object];
        const char* className = class_getName(cellClass);
        NSString* identifier = [[NSString alloc] initWithBytesNoCopy:(char*)className
                                                              length:strlen(className)
                                                            encoding:NSASCIIStringEncoding freeWhenDone:NO];
        GPGridViewCell* cell = [gridView dequeueGrid:identifier];
        if(!cell)
            cell = [[[cellClass alloc] initWithIdentifer:identifier] autorelease];
        [identifier release];
        
        [cell setObject:object];
        if(![object isKindOfClass:[GPGridMoreItem class]])
            [self processImageURL:object];
        
        if(!model.isFinished && [model autoLoad])
        {
            if ([object isKindOfClass:[GPGridMoreItem class]])
            {
                GPGridMoreItem* item = (GPGridMoreItem*)object;
                item.isLoading = YES;
                [(GPGridMoreCell *)cell setAnimating:YES];
                [model loadModel:YES];
            }
        }
        
        return cell;
    }
    return nil;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//using gpnavigator to navigate. Does nothing if GPNavigator is not used and will have to subclass to provide navigation
-(void)gridViewDidSelectItem:(GPGridView*)gridview item:(GPGridViewCell*)cell index:(NSInteger)index
{
    id object = [items objectAtIndex:index];
    
    if ([object isKindOfClass:[GPTableMoreItem class]])
    {
        if(!model.isLoading)
        {
            GPGridMoreItem* item = (GPGridMoreItem*)object;
            item.isLoading = YES;
            [(GPGridMoreCell*)cell setAnimating:YES];
            [model loadModel:YES];
        }
        return;
    }
    [self didSelectObject:object gridview:gridview item:cell index:index];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)didSelectObject:(id)object gridview:(GPGridView*)gridview item:(GPGridViewCell*)cell index:(NSInteger)index
{
    if ([object respondsToSelector:@selector(NavURL)]) 
    {
        NSString* URL = [object NavURL];
        if([object isKindOfClass:[GPGridViewItem class]])
        {
            GPGridViewItem* item = (GPGridViewItem*)object;
            NSString* theURL = item.NavURL;
            if (theURL)
            {
                dismissView = [[cell expandView] retain];
                dismissIndex = index;
                for(UIView* subview in gridview.subviews)
                    if(subview != cell)
                        subview.hidden = YES;
                [[GPNavigator navigator] openURL:theURL view:[cell expandView] query:item.Properties];
            }
        }
        else if (URL)
            [[GPNavigator navigator] openURL:URL];
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)dismissGridCell:(BOOL)saveImage
{
    id object = [items objectAtIndex:dismissIndex];
    if(saveImage && [object isKindOfClass:[GPGridViewItem class]])
    {
        UIGraphicsBeginImageContext(self.navigationController.visibleViewController.view.frame.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        [self.navigationController.visibleViewController.view.layer renderInContext:context];
        UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        GPGridViewItem* item = (GPGridViewItem*)object;
        item.image = viewImage;
        
        if([dismissView isKindOfClass:[UIImageView class]])
        {
            UIImageView* view = (UIImageView*)dismissView;
            view.image = viewImage;
        }
        else
        {
            GPGridViewCell* cell = [gridView findCellAtIndex:dismissIndex];
            [cell setObject:item];
            [dismissView release];
            dismissView = [cell.imageView retain];
        }
    }
    [[GPNavigator navigator] dismissGridView:dismissView];
    [self performSelector:@selector(showSubs) withObject:nil afterDelay:0.3];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)showSubs
{
    for(UIView* subview in gridView.subviews)
        subview.hidden = NO;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(ASIHTTPRequest*)imageRequest:(NSString*)URL
{
    ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:URL]];
    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    [request setCachePolicy:ASIAskServerIfModifiedCachePolicy];
    [request setDownloadCache:[ASIDownloadCache sharedCache]];
    [[ASIDownloadCache sharedCache] setShouldRespectCacheControlHeaders:NO];
    [request setSecondsToCache:60*60*1]; // Cache for 1 hour
    [request setDelegate:self];
    return request;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)processImageURL:(id)object
{
    if([object isKindOfClass:[GPGridViewItem class]])
    {
        if(!imageQueue)
            imageQueue = [[NSMutableArray alloc] initWithCapacity:items.count];
        if(!queue)
        {
            queue = [[NSOperationQueue alloc] init];
            queue.maxConcurrentOperationCount = 4;
        }
        GPGridViewItem* item = (GPGridViewItem*)object;
        if(!item.image && item.imageURL && ![imageQueue containsObject:item.imageURL])
        {
            [imageQueue addObject:item.imageURL];
            [queue addOperation:[self imageRequest:item.imageURL]];
        }
            
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)requestFinished:(ASIHTTPRequest *)request
{
    int i = 0;
    NSMutableArray* indexes = [NSMutableArray array];
    for(id object in items)
    {
        if([object isKindOfClass:[GPGridViewItem class]] && ![object isKindOfClass:[GPGridMoreItem class]])
        {
            GPGridViewItem* item = (GPGridViewItem*)object;
            if([item.imageURL isEqualToString:request.url.absoluteString])
            {
                item.image = [UIImage imageWithData:[request responseData]];
                [indexes addObject:[NSNumber numberWithInt:i]];
            }
        }
        i++;
    }
    [imageQueue removeObject:request.url.absoluteString];
    [gridView reloadCellsAtIndexes:indexes];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)modelFinished:(ASIHTTPRequest *)request
{
    ActLabel.hidden = YES;
    [items release];
    items = [model.items retain]; 
    [gridView reloadData];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)modelFailed:(ASIHTTPRequest *)request
{
    ActLabel.hidden = YES;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)noConnection
{
    ActLabel.hidden = YES;
    GPCenterLabel* label = [[GPCenterLabel alloc] initWithFrame:self.view.frame];
    [self.view addSubview:label];
    [label release];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    //handle rotation
    [gridView didRotate:toInterfaceOrientation];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Sub Class section!!!!
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//subclass this to load a different model.
-(GPModel*)model:(NSString*)url
{
    return [[[GPModel alloc] initWithURLString:url] autorelease];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//set loading text.
-(NSString*)loadingText;
{
    return @"Loading...";
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)dealloc
{
    [model release];
    [ActLabel release];
    [imageQueue release];
    [queue release];
    [dismissView release];
    gridView.delegate = nil;
    gridView.dataSource = nil;
    [gridView release];
    [items release];
    [super dealloc];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@end
