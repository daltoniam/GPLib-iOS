//
//  GPTableDragRefresh.m
//  EduTalk
//
//  Created by Dalton Cherry on 10/20/11.
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

#import "GPTableDragRefresh.h"

const CGFloat TransitionDuration  = 0.3;
// The number of pixels the table needs to be pulled down by in order to initiate the refresh.
static const CGFloat RefreshDeltaY = -65.0f;

// The height of the refresh header when it is in its "loading" state.
static const CGFloat HeaderVisibleHeight = 60.0f;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation GPTableDragRefresh

@synthesize headerView = headerView;


///////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithController:(GPOldTableViewController*)control Background:(UIColor*)color
{
    Background = [color retain];
    return [self initWithController:control];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithController:(GPOldTableViewController*)control 
{
    if (self = [super init]) 
    {
        //_tableView = [tableview retain];
        controller = [control retain];
        // Add our refresh header
        headerView = [[GPDragToRefreshView alloc]
                       initWithFrame:CGRectMake(0,
                                                -controller.tableView.bounds.size.height,
                                                controller.tableView.bounds.size.width,
                                                controller.tableView.bounds.size.height)];
        headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        if(!Background)
            headerView.backgroundColor = [UIColor colorWithRed:226/255.0f green:231/255.0f  blue:237/255.0f  alpha:1];
        else
            headerView.backgroundColor = Background;
        [headerView setStatus:GPTableHeaderDragRefreshPullToReload];
        [controller.tableView addSubview:headerView];

        
        // Grab the last refresh date if there is one.
        if ([controller.model respondsToSelector:@selector(loadedTime)]) 
        {
            NSDate* date = [controller.model performSelector:@selector(loadedTime)];
            if (nil != date)
                [headerView setUpdateDate:date];
        }
    }
    return self;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc 
{
    [Background release];
    [headerView release];
    [controller release];
    [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIScrollViewDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewDidScroll:(UIScrollView*)scrollView 
{
    
    if (scrollView.dragging && !controller.model.isLoading) 
    {
        if (scrollView.contentOffset.y > RefreshDeltaY && scrollView.contentOffset.y < 0.0f)
            [headerView setStatus:GPTableHeaderDragRefreshPullToReload];
        
        else if (scrollView.contentOffset.y < RefreshDeltaY) 
            [headerView setStatus:GPTableHeaderDragRefreshReleaseToReload];
    }
    
    // This is to prevent odd behavior with plain table section headers. They are affected by the
    // content inset, so if the table is scrolled such that there might be a section header abutting
    // the top, we need to clear the content inset.
    if (controller.model.isLoading) 
    {
        if (scrollView.contentOffset.y >= 0) 
            controller.tableView.contentInset = UIEdgeInsetsZero;
            
        else if (scrollView.contentOffset.y < 0)
            controller.tableView.contentInset = UIEdgeInsetsMake(HeaderVisibleHeight, 0, 0, 0);
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewDidEndDragging:(UIScrollView*)scrollView willDecelerate:(BOOL)decelerate 
{
    // If dragging ends and we are far enough to be fully showing the header view trigger a
    // load as long as we arent loading already
    if (scrollView.contentOffset.y <= RefreshDeltaY && !controller.model.isLoading) 
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DragRefreshTableReload" object:nil];
        [controller copyRefresh];
        [controller.model loadModel:NO];
        [headerView setStatus:GPTableHeaderDragRefreshLoading];
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.2];
        if (controller.tableView.contentOffset.y < 0)
            controller.tableView.contentInset = UIEdgeInsetsMake(HeaderVisibleHeight, 0.0f, 0.0f, 0.0f);
        [UIView commitAnimations];
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)RequestFinished
{
    [headerView setStatus:GPTableHeaderDragRefreshPullToReload];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:TransitionDuration];
    controller.tableView.contentInset = UIEdgeInsetsZero;
    [UIView commitAnimations];
    
    [headerView setCurrentDate];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)RequestFailed
{
    [headerView setStatus:GPTableHeaderDragRefreshPullToReload];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:TransitionDuration];
    controller.tableView.contentInset = UIEdgeInsetsZero;
    [UIView commitAnimations];
}
///////////////////////////////////////////////////////////////////////////////////////////////////

@end
