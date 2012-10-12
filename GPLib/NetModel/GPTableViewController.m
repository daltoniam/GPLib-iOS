//
//  GPTableViewController.m
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

#import "GPTableViewController.h"
#import "GPCenterLabel.h"
#import <objc/runtime.h>
#import "GPTableTextItem.h"
#import "GPTableCell.h"
#import "GPTableImageItem.h"
#import "GPTableImageCell.h"
#import "GPTableBubbleItem.h"
#import "GPBubbleTableCell.h"
#import "GPTableMessageItem.h"
#import "GPTableMessageCell.h"
#import "GPTableViewItem.h"
#import "GPTableViewCell.h"
#import "GPTableHTMLItem.h"
#import "GPTableHtmlItemCell.h"
#import "GPTableMoreItem.h"
#import "GPTableMoreCell.h"
#import "GPTableTextFieldItem.h"
#import "GPTableTextFieldCell.h"
#import "GPTableDeleteItem.h"
#import "GPTableDeleteCell.h"
#import "GPTableFloatingItem.h"
#import "GPTableFloatingCell.h"
#import "GPTableSwitchItem.h"
#import "GPTableSwitchCell.h"
#import "GPTableMailItem.h"
#import "GPTableMailCell.h"
#import "GPTableTextViewItem.h"
#import "GPTableTextViewCell.h"
#import "GPTableSegmentItem.h"
#import "GPTableSegmentCell.h"
#import "GPTableButtonItem.h"
#import "GPTableButtonCell.h"


#import "GPEmptyTableView.h"
#import "GPNavigator.h"

@implementation GPTableViewController

@synthesize model = model;
@synthesize tableView = _tableView;

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) 
    {
        items = [[NSMutableArray alloc] init];
        model = [[self model:nil] retain];
        model.delegate = self;
    }
    
    return self;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:YES];
    self.tableView.scrollsToTop = YES;
    //[self.tableView reloadData];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //	The scrollbars won't flash unless the tableview is long enough.
    [self.tableView flashScrollIndicators];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.tableView flashScrollIndicators];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setupModel:(NSString*)url
{
    [model release];
    model = [[self model:url] retain];
    model.delegate = self;
    [model loadModel:NO];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithURLString:(NSString*)url 
{
    if ((self = [super init])) 
    {
        [self setupModel:url];
    }
    
    return self;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithOutURL
{
    if ((self = [super init])) 
    {
        //model = [[self Model:nil] retain];
        //model.delegate = self;
    }
    
    return self;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidLoad
{
    if(![self grouped])
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    else
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    
    UIView* view = [[[UIView alloc] init] autorelease];
    view.backgroundColor = [self tableBackground];
    [_tableView setBackgroundView:nil];
    [_tableView setBackgroundView:view];
    [_tableView setBackgroundColor:[self tableBackground]];
    
    _tableView.autoresizingMask =  UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    GPLoadingLabelStyle style = [self actLabelStyle];
    ActLabel = [[GPLoadingLabel alloc] initWithStyle:style];
    ActLabel.frame = _tableView.frame;
    ActLabel.autoresizingMask =  UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    ActLabel.text = [self loadingText];
    [self.view addSubview:_tableView];
    [self.view addSubview:ActLabel];
    if(!model.URL || !model.isLoading)
        ActLabel.hidden = YES;
    for(UIView* view in self.view.subviews)
    {
        if([view isKindOfClass:[GPCenterLabel class]])
        {
            ActLabel.hidden = YES;
            [self.view bringSubviewToFront:view];
            break;
        }
    }
    self.tableView.frame = _tableView.frame;
    if([self dragToRefresh])
        refresh = [[GPTableDragRefresh alloc] initWithController:self];
    emptyView.frame = ActLabel.frame; //normally emptyView is nil here, but if the model loads fast could be visible
    
    if([self useTimeScroller])
    {
        timeScroller = [[GPTimeScroller alloc] init];
        timeScroller.delegate = self;
    }
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    if (sections && items.count > 0) 
    {
        NSArray* itemArray = [items objectAtIndex:section];
        return itemArray.count;
        
    }
    return items.count;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return sections ? sections.count : 1;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
    id object = [sections objectAtIndex:section];
    if([object isKindOfClass:[NSString class]])
    {
        if([object isEqualToString:UITableViewIndexSearch])
            return nil;
        return [sections objectAtIndex:section];
    }
    return nil;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    id object = [sections objectAtIndex:section];
    if([object isKindOfClass:[UIView class]])
    {
        UIView* view = (UIView*)[sections objectAtIndex:section];
        if([self grouped] && view.tag != SECTION_HEADER_TAG) 
        {
            //because tableview is not a team player and does not respect the frame
            int left = self.tableView.frame.size.width/14;//15;
            if(self.tableView.frame.size.width > 480) //must not be an iphone or a popover view
                left = 48;
            UIView* temp = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, view.frame.size.height)] autorelease];
            temp.userInteractionEnabled = YES;
            temp.tag = SECTION_HEADER_TAG;
            [temp addSubview:view];
            view.frame = CGRectMake(left, 0, tableView.frame.size.width-(left*2), view.frame.size.height);
            [sections replaceObjectAtIndex:section withObject:temp];
            return temp;
        }
        return view;
    }
    return nil;

}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    id object = [sections objectAtIndex:section];
    if([object isKindOfClass:[UIView class]])
    {
        UIView* view = (UIView*)object;
        return view.frame.size.height;
    }
    if([object isKindOfClass:[NSString class]])
    {
        NSString* string = (NSString*)object;
        if(string.length > 0)
        {
            if([self grouped])
                return 44;
            else
                return 24;
        }
    }
    return 0;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//customize cells as they come through and do the set object call.
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    id object = [self tableView:tableView objectForRowAtIndexPath:indexPath];
    
    Class cellClass = [self tableView:tableView cellClassForObject:object];
    const char* className = class_getName(cellClass);
    NSString* identifier = [[NSString alloc] initWithBytesNoCopy:(char*)className
                                                          length:strlen(className)
                                                        encoding:NSASCIIStringEncoding freeWhenDone:NO];
    
    UITableViewCell* cell =
    (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[[cellClass alloc] initWithStyle:UITableViewCellStyleDefault
                                 reuseIdentifier:identifier] autorelease];
        if ([cell isKindOfClass:[GPTableCell class]])
            [(GPTableCell*)cell setAutoSize:[self autoSizeCells]];
    }
    [identifier release];
    
    if([object isKindOfClass:[GPTableSegmentItem class]])
    {
        GPTableSegmentItem* item = (GPTableSegmentItem*)object;
        if(item.segType == GPTableSegmentAuto)
        {
            BOOL isLast = [self isLastObjectInSection:object section:indexPath.section];
            if(indexPath.row == 0)
            {
                item.segType = GPTableSegmentTop;
                if(isLast)
                    item.segType = GPTableSegmentOnly;
            }
            else if(isLast)
                item.segType = GPTableSegmentBottom;
            else
                item.segType = GPTableSegmentMiddle;
        }
    }
    
    if([object isKindOfClass:[GPTableTextItem class]])
        [(GPTableTextItem*)object setIsGrouped:[self grouped]];
    
    if ([cell isKindOfClass:[GPTableCell class]])
        [(GPTableCell*)cell setObject:object];
    
    if([object isKindOfClass:[GPTableImageItem class]])
        [self processImageURL:object];
    
    if([cell respondsToSelector:@selector(setDelegate:)])
        [cell performSelector:@selector(setDelegate:) withObject:self];
    
    GPTableAccessory* view = [self customAccessory:cell.accessoryType];
    if(view)
        cell.accessoryView = view;
    UIColor* selectColor = [self selectedColor];
    if(selectColor)
    {
        UIView* bgView = cell.backgroundView;
        if(!bgView)
        {
            bgView = [[UIView alloc] init];
            bgView.backgroundColor = selectColor;
            cell.selectedBackgroundView = bgView;
            [bgView release];
        }
        else
            bgView.backgroundColor = selectColor;
    }
    
    if(!model.isFinished && [model autoLoad])
    {
        id object = [self tableView:tableView objectForRowAtIndexPath:indexPath];
        if ([object isKindOfClass:[GPTableMoreItem class]])
        {
            GPTableMoreItem* item = (GPTableMoreItem*)object;
            item.isLoading = YES;
            [(GPTableMoreCell *)cell setAnimating:YES];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [model loadModel:YES];
        }
    }
    return cell;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//return height
- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath 
{
    if([self autoSizeCells])
    {
        id object = [self tableView:tableView objectForRowAtIndexPath:indexPath];
        Class cls = [self tableView:tableView cellClassForObject:object];
        CGFloat height = [cls tableView:tableView rowHeightForObject:object];
        if([object respondsToSelector:@selector(rowHeight)])
            [object setRowHeight:height];
        return height;
    }
    return 44;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//simple way to get proper object for index path. Mostly this is a private helper function.
- (id)tableView:(UITableView*)tableView objectForRowAtIndexPath:(NSIndexPath*)indexPath 
{
    if (sections) 
    {
        NSArray* itemArray = [items objectAtIndex:indexPath.section];
        return [itemArray objectAtIndex:indexPath.row];
        
    }
    //NSLog(@"items count: %d",[items count]);
    //NSLog(@"indexPath: %@",indexPath);
    return [items objectAtIndex:indexPath.row];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(BOOL)isLastObjectInSection:(id)object section:(int)section
{
    if (sections) 
    {
        NSArray* itemArray = [items objectAtIndex:section];
        if(object == [itemArray lastObject])
            return YES;
        
    }
    if(object == [items lastObject])
        return YES;
    return NO;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//just allows the cell to turn blue when we are using checkmarks
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self checkMarks] && ![self checkMarksExpection:indexPath.section])
    {
        UITableViewCell* touchcell = [tableView cellForRowAtIndexPath:indexPath];
        [touchcell setSelectionStyle:UITableViewCellSelectionStyleBlue]; //since your URL is probably nil.
    }
    return indexPath;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//does the custom checkmark and GPLoadMore actions. Use didselect object below to get type
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id object = [self tableView:tableView objectForRowAtIndexPath:indexPath];
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    if([self checkMarks] && ![self checkMarksExpection:indexPath.section])
    {
        for(int i = 0; i < [tableView numberOfRowsInSection:indexPath.section]; i++)
        {
            id object = nil;
            if(sections)
                object = [[items objectAtIndex:indexPath.section] objectAtIndex:i];
            else
                object = [items objectAtIndex:i];
            if([object isKindOfClass:[GPTableTextItem class]])
            {
                GPTableTextItem* item = (GPTableTextItem*)object;
                if(indexPath.row == i)
                {
                    if([self isMultiCheckMark:indexPath.section]) //if we are not multi check, then we are not allowed to disable
                        item.isChecked = !item.isChecked;
                    else
                        item.isChecked = YES;
                }
                else if(![self isMultiCheckMark:indexPath.section]) //we are not multi so disable the rest
                    item.isChecked = NO;
                
                NSIndexPath* path = [NSIndexPath indexPathForRow:i inSection:indexPath.section];
                UITableViewCell* cell = [tableView cellForRowAtIndexPath:path];
                if(item.isChecked)
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                else
                    cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
        //cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    if ([object isKindOfClass:[GPTableMoreItem class]])
    {
        if(!model.isLoading)
        {
            GPTableMoreItem* item = (GPTableMoreItem*)object;
            item.isLoading = YES;
            [(GPTableMoreCell *)cell setAnimating:YES];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [model loadModel:YES];
        }
        return;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES]; 
    
    [self didSelectObject:object atIndexPath:indexPath];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//using gpnavigator to navigate. Does nothing if GPNavigator is not used and will have to subclass
//to provide navigation
- (void)didSelectObject:(id)object atIndexPath:(NSIndexPath*)indexPath 
{
    if ([object respondsToSelector:@selector(NavURL)]) 
    {
        NSString* URL = [object NavURL];
        if([object isKindOfClass:[GPTableTextItem class]])
        {
            GPTableTextItem* item = (GPTableTextItem*)object;
            NSString* theURL = item.NavURL;
            if (theURL)
            {
                if(item.Properties)
                    [[GPNavigator navigator] openURL:theURL NavType:GPNavTypeNormal query:item.Properties];
                else
                    [[GPNavigator navigator] openURL:URL];
            }
        }
        else if (URL)
            [[GPNavigator navigator] openURL:URL];
    }
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//where the tableview magic happens. return the cell class for the object class that comes through
- (Class)tableView:(UITableView*)tableView cellClassForObject:(id)object 
{
    if ([object isKindOfClass:[GPTableBubbleItem class]]) 
        return [GPBubbleTableCell class];
    else if ([object isKindOfClass:[GPTableFloatingItem class]]) 
        return [GPTableFloatingCell class];
    else if ([object isKindOfClass:[GPTableMailItem class]]) 
        return [GPTableMailCell class];
    else if ([object isKindOfClass:[GPTableMessageItem class]]) 
        return [GPTableMessageCell class];
    else if ([object isKindOfClass:[GPTableHTMLItem class]]) 
        return [GPTableHtmlItemCell class];
    else if ([object isKindOfClass:[GPTableImageItem class]]) 
        return [GPTableImageCell class]; 
    else if ([object isKindOfClass:[GPTableViewItem class]] || [object isKindOfClass:[UIView class]]) 
        return [GPTableViewCell class];
    else if ([object isKindOfClass:[GPTableMoreItem class]]) 
        return [GPTableMoreCell class];
    else if ([object isKindOfClass:[GPTableTextFieldItem class]]) 
        return [GPTableTextFieldCell class];
    else if ([object isKindOfClass:[GPTableTextViewItem class]]) 
        return [GPTableTextViewCell class];
    else if ([object isKindOfClass:[GPTableSegmentItem class]]) 
        return [GPTableSegmentCell class];
    else if ([object isKindOfClass:[GPTableDeleteItem class]]) 
        return [GPTableDeleteCell class];
    else if ([object isKindOfClass:[GPTableSwitchItem class]])
        return [GPTableSwitchCell class];
    else if ([object isKindOfClass:[GPTableButtonItem class]])
        return [GPTableButtonCell class];
    else if ([object isKindOfClass:[GPTableTextItem class]])
        return [GPTableCell class]; 
    
    // This will display an empty white table cell - probably not what you want, but it
    // is better than crashing, which is what happens if you return nil here
    return [GPTableCell class];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)modelFinished:(GPHTTPRequest *)request
{
    /*ActLabel.hidden = YES;
    if([self DragToRefresh])
        [refresh RequestFinished:request];
    [items release];
    items = [model.items mutableCopy];
    [sections release];
    sections = [model.sections mutableCopy];
    [_tableView reloadData];*/
    
    ActLabel.hidden = YES;
    if([self dragToRefresh])
        [refresh RequestFinished];
    [items release];
    items = [model.items retain]; //[model.items mutableCopy];
    [sections release];
    sections =  [model.sections retain];// [model.sections mutableCopy];
    [_tableView reloadData];
    if(items.count > 0)
        emptyView.hidden = YES;
    else
        [self showEmptyView];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)modelFailed:(GPHTTPRequest *)request
{
    ActLabel.hidden = YES;
    if([self dragToRefresh])
        [refresh RequestFailed];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)noConnection
{
    CGRect frame;
    if(self.view.frame.size.width == 320 && GPIsPad()) //adding this, as when loaded from a nib, it gets IPhone frame size
        frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    else
        frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    ActLabel.hidden = YES;
    GPCenterLabel* label = [[GPCenterLabel alloc] initWithFrame:frame];
    [self.view addSubview:label];
    [self.view bringSubviewToFront:label];
    [label release];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)copyRefresh
{
    [items release];
    items = [model.items mutableCopy]; //temp copy with drag to refresh reloads the data.
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(GPHTTPRequest*)fetchImage:(NSString*)url
{
    __block GPHTTPRequest* request = [GPHTTPRequest requestWithString:url];
    [request setCacheModel:GPHTTPCacheCustomTime];
    [request setTimeout:60*60*1]; // Cache for 1 hour
    [request setFinishBlock:^{
        
        if(sections)
        {
            int section = 0;
            for(NSArray* itemArray in items)
            {
                [self reloadImageItems:itemArray url:request section:section];
                section++;
            }
        }
        else
            [self reloadImageItems:items url:request section:0];

        
    }];
    return request;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)reloadImageItems:(NSArray*)arrayItems url:(GPHTTPRequest*)request section:(int)section
{
    int i = 0;
    for(id object in arrayItems)
    {
        if([object isKindOfClass:[GPTableImageItem class]])
        {
            GPTableImageItem* item = (GPTableImageItem*)object;
            if([item.ImageURL isEqualToString:request.URL.absoluteString])
            {
                item.imageData = [UIImage imageWithData:[request responseData]];
                UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:section]];
                if([cell isKindOfClass:[GPTableImageCell class]])
                    [(GPTableImageCell*)cell setImageView:item.imageData];
            }
        }
        i++;
    }
    [imageURLs removeObject:request.URL.absoluteString];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)processImageURL:(id)object
{
    if([object isKindOfClass:[GPTableImageItem class]])
    {
        if(!imageQueue)
            imageURLs = [[NSMutableArray alloc] initWithCapacity:items.count];
        if(!imageQueue)
        {
            imageQueue = [[NSOperationQueue alloc] init];
            imageQueue.maxConcurrentOperationCount = 4;
        }
        GPTableImageItem* item = (GPTableImageItem*)object;
        if(!item.imageData && item.ImageURL && ![imageURLs containsObject:item.ImageURL])
        {
            [imageURLs addObject:item.ImageURL];
            [imageQueue addOperation:[self fetchImage:item.ImageURL]];
        }
        
    }
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//html text label delegate to reformat photos
-(void)imageFinished:(NSString*)url height:(int)height width:(int)width
{
    BOOL reload = NO;
    NSString* imgURL = [url HTMLImg];
    NSString* newImg = [url HTMLImg:height width:width];
    if(sections)
    {
        for(NSArray* array in items)
        {
            if([array isKindOfClass:[NSArray class]])
            {
                for(GPTableTextItem* item in array)
                {
                    NSString* newText = [item.text stringByReplacingOccurrencesOfString:imgURL withString:newImg];
                    if(![newText isEqualToString:item.text])
                    {
                        reload = YES;
                        item.text = newText;
                    }
                }
            }
        }
    }
    else
    {
        for(GPTableTextItem* item in items)
        {
            NSString* newText = [item.text stringByReplacingOccurrencesOfString:imgURL withString:newImg];
            if(![newText isEqualToString:item.text])
            {
                reload = YES;
                item.text = newText;
                if([item respondsToSelector:@selector(setRowHeight:)])
                    [(GPTableMessageItem*)item setRowHeight:0];
            }
        }
    }
    if(model.isLoading)
        reload = NO;
    if(reload)
    {
        [self.tableView beginUpdates];
        NSMutableArray* collect = [NSMutableArray arrayWithCapacity:self.tableView.visibleCells.count];
        for(UITableViewCell* cell in self.tableView.visibleCells)
            [collect addObject:[self.tableView indexPathForCell:cell]];
        [self.tableView reloadRowsAtIndexPaths:collect withRowAnimation:UITableViewRowAnimationFade]; //UITableViewRowAnimationFade
        [self.tableView endUpdates];
    }
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidUnload
{
    [super viewDidUnload];
    int section = [self.tableView numberOfSections];
    for(int i = 0; i <= section; i++)
    {
        for(int j = 0; j < [self.tableView numberOfRowsInSection:i]; j++)
        {
            UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i]];
            if([cell respondsToSelector:@selector(setDelegate:)])
                [cell performSelector:@selector(setDelegate:) withObject:nil];
        }
    }
    model.delegate = nil;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)dealloc
{
    model.delegate = nil;
    [model release];
    [items release];
    [_tableView release];
    [ActLabel release];
    [sections release];
    [refresh release];
    [emptyView release];
    [timeScroller release];
    [imageQueue release];
    [imageURLs release];
    [super dealloc];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewDidScroll:(UIScrollView*)scrollView
{
    [timeScroller scrollViewDidScroll];
    if([self dragToRefresh])
        [refresh scrollViewDidScroll:scrollView];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView 
{    
    [timeScroller scrollViewWillBeginDragging];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewDidEndDragging:(UIScrollView*)scrollView willDecelerate:(BOOL)decelerate 
{
    if([self dragToRefresh])
        [refresh scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    
    if(!decelerate)
        [timeScroller scrollViewDidEndDecelerating];
    
    if(_tableView.contentOffset.y<0)
        return;
    else if(self.tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.bounds.size.height) && !model.isLoading) 
    {
        /*if([self DragToRefresh] && !model.isFinished)
         {
         //[items addObject:[TTTableActivityItem itemWithText:@""]];
         [model LoadModel:YES];
         }*/
    }
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//simple way to delete proper object for index path. Mostly this is a private helper function.
- (void)tableView:(UITableView*)tableView removeObjectAtIndexPath:(NSIndexPath*)indexPath 
{
    if (sections) 
    {
        if([[items objectAtIndex:indexPath.section] isKindOfClass:[NSMutableArray class]])
        {
            NSMutableArray* itemArray = [items objectAtIndex:indexPath.section];
            [itemArray removeObjectAtIndex:indexPath.row];
        }
        else if([[items objectAtIndex:indexPath.section] isKindOfClass:[NSArray class]])
        {
            NSArray* itemArray = [items objectAtIndex:indexPath.section];
            NSMutableArray* array = [NSMutableArray arrayWithArray:itemArray];
            [array removeObjectAtIndex:indexPath.row];
            [items replaceObjectAtIndex:indexPath.section withObject:array];
        }
    }
    else
        [items removeObjectAtIndex:indexPath.row];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//simple way to get index path of object. Mostly this is a private helper function.
- (NSIndexPath*)tableView:(UITableView*)tableView indexPathOfObject:(id)object
{
    if (sections)
    {
        int i = 0;
        for(NSArray* array in items)
        {
            int k = 0;
            for(id obj in array)
            {
                if(obj == object)
                    return [NSIndexPath indexPathForRow:k inSection:i];
                k++;
            }
            i++;
        }
    }
    else
    {
        int i = 0;
        for(id obj in items)
        {
            if(obj == object)
                return [NSIndexPath indexPathForRow:i inSection:0];
            i++;
        }
    }
    return nil;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//empty tableview methods
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)showEmptyView
{
    if(!emptyView)
    {
        emptyView = [[self defaultEmptyView] retain];
        emptyView.autoresizingMask =  UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:emptyView];
    }
    emptyView.hidden = NO;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(UIView*)defaultEmptyView
{
    GPEmptyTableView* view = [[[GPEmptyTableView alloc] initWithFrame:ActLabel.frame] autorelease];
    view.autoresizingMask =  UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [view setMainText:[self emptyTableTitle]];
    [view setSubText:[self emptyTableText]];
    [view setImage:[self emptyTableImage]];
    return view;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//Sub Class section!!!!
///////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////
//subclass this to load a different model.
-(GPModel*)model:(NSString*)url
{
    return [[[GPModel alloc] initWithURLString:url] autorelease];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//set loading text.
-(NSString*)loadingText;
{
    return @"Loading...";
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//subclass this to enable drag to refresh.
-(BOOL)dragToRefresh
{
    return NO;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//subclass this to enable set to grouped style.
-(BOOL)grouped
{
    return NO;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//subclass this to disable auto cell height.
-(BOOL)autoSizeCells
{
    return YES;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//checkmarks
///////////////////////////////////////////////////////////////////////////////////////////////////
//subclass this to enable the checkmark selection.
-(BOOL)checkMarks
{
    return NO;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//subclass this to create an exclude a section from the checkmark selection. Return YES to exclude
-(BOOL)checkMarksExpection:(int)section
{
    return NO;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//subclass this to set if checkmark style is multi selection
-(BOOL)isMultiCheckMark:(int)section
{
    return NO;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//empty tableview
///////////////////////////////////////////////////////////////////////////////////////////////////
//override to set title of empty tableview
-(NSString*)emptyTableTitle
{
    return @"No Results";
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//override to set text of empty tableview
-(NSString*)emptyTableText
{
    return nil;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//override to set image of empty tableview
-(UIImage*)emptyTableImage
{
    return nil;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//return nil to use default
-(GPTableAccessory*)customAccessory:(UITableViewCellAccessoryType)type
{
    return nil;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//time scroller
///////////////////////////////////////////////////////////////////////////////////////////////////
//set to yes, in order to use time scroller
-(BOOL)useTimeScroller
{
    return NO;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(NSDate*)timeScrollerForObject:(id)object cell:(UITableViewCell*)cell
{
    return nil;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (UITableView *)tableViewForTimeScroller:(GPTimeScroller*)timeScroller
{
    return _tableView;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//you need to implement this.
- (NSDate *)dateForCell:(UITableViewCell*)cell
{
    if([cell isKindOfClass:[GPTableMoreCell class]])
        return nil;
    NSIndexPath* path = [_tableView indexPathForCell:cell];
    id object = [self tableView:_tableView objectForRowAtIndexPath:path];
    return [self timeScrollerForObject:object cell:cell];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//set tableview background color
-(UIColor*)tableBackground
{
    if([self grouped])
    {
        if(GPIsPad())
            return [UIColor underPageBackgroundColor];
        else
            return [UIColor groupTableViewBackgroundColor];
    }
    return [UIColor whiteColor];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//set the tableviewcells selection color. Default is nil (the blue background)
-(UIColor*)selectedColor
{
    return nil;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//set the ActLabel style
-(GPLoadingLabelStyle)actLabelStyle
{
    return GPLoadingLabelWhiteStyle;
}
///////////////////////////////////////////////////////////////////////////////////////////////////

@end
