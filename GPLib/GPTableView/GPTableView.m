//
//  GPTableView.m
//  GPLib
//
//  Created by Dalton Cherry on 10/15/12.
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

#import "GPTableView.h"
#import <objc/runtime.h>
#import "GPTableTextItem.h"
#import "GPTableCell.h"
#import "GPTableImageItem.h"
#import "GPTableImageCell.h"
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
#import "GPTableSwitchItem.h"
#import "GPTableSwitchCell.h"
#import "GPTableTextViewItem.h"
#import "GPTableTextViewCell.h"
#import "GPTableButtonItem.h"
#import "GPTableButtonCell.h"
#import "GPTablePadCell.h"
#import "GPTablePadItem.h"
#import "GPTableInfoCell.h"
#import "GPTableInfoItem.h"


@implementation GPTableView

static const CGFloat TransitionDuration  = 0.3;
// The number of pixels the table needs to be pulled down by in order to initiate the refresh.
static const CGFloat RefreshDeltaY = -65.0f;

// The height of the refresh header when it is in its "loading" state.
static const CGFloat HeaderVisibleHeight = 60.0f;

@synthesize items,sections,isGrouped,selectedColor,variableHeight,emptyView,dragToRefresh,refreshHeader,hideSeparator,stayActive;
@synthesize checkMarks,numberIndex,truncateCount,searchItems,searchSections,isSearching,hideSectionTitles,isAutoSearch,searchController;
@synthesize hideAccessoryViews;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)commonInit:(BOOL)grouped
{
    self.showsHorizontalScrollIndicator = YES;
    self.showsVerticalScrollIndicator = YES;
    UITableViewStyle style = UITableViewStylePlain;
    if(grouped)
        style = UITableViewStyleGrouped;
    isGrouped = grouped;
    tableView = [[UITableView alloc] initWithFrame:CGRectZero style:style];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:tableView];
    self.items = [[NSMutableArray alloc] init];
    self.variableHeight = YES;
    //set the tableview background color to clear, so it will just be the color of GPTableView background
    UIColor* color = [UIColor clearColor];
    UIView* view = [[[UIView alloc] init] autorelease];
    view.backgroundColor = color;
    [tableView setBackgroundView:nil];
    [tableView setBackgroundView:view];
    [tableView setBackgroundColor:color];
    emptyView = [[[GPEmptyTableView alloc] init] autorelease];
    emptyView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    emptyView.mainText = NSLocalizedString(@"No Results", @"the view has no items in it");
    [tableView addSubview:emptyView];
    [tableView bringSubviewToFront:emptyView];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.backgroundColor = [UIColor whiteColor];
    self.truncateCount = 15;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self commonInit:NO];
        tableView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    }
    return self;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame isGrouped:(BOOL)grouped
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self commonInit:grouped];
        tableView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    }
    return self;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(id)init:(BOOL)grouped
{
    if(self = [super init])
        [self commonInit:grouped];
    return self;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(id)init
{
    if(self = [super init])
        [self commonInit:NO];
    return self;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    tableView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)layoutSubviews
{
    [super layoutSubviews];
    tableView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    emptyView.frame = tableView.frame;
    [self setupRefreshView];
    if(self.showSearch)
        [self setupSearchController];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)showEmptyView
{
    if(items.count == 0)
    {
        emptyView.hidden = NO;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        hideSectionTitles = YES;
    }
    else
    {
        emptyView.hidden = YES;
        if(self.hideSeparator)
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        else
            tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//main methods
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//notify the tableview that the datasource has changed and needs to be reload, just like UITableview
-(void)reloadData
{
    [self showEmptyView];
    if(self.showSearch)
        [self clearEmptySections];
    if(isSearching)
        [self.searchController.searchResultsTableView reloadData];
    else
        [tableView reloadData];
    [tableViewTags removeAllObjects];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)refreshComplete
{
    isRefreshing = NO;
    [refreshHeader setStatus:GPTableHeaderDragRefreshPullToReload];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:TransitionDuration];
    tableView.contentInset = UIEdgeInsetsZero;
    [UIView commitAnimations];
    [refreshHeader setCurrentDate];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)flashScrollIndicators
{
    [tableView flashScrollIndicators];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//modifing the datasource with animation
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)beginUpdate
{
    didBeginUpdate = YES;
    [tableView beginUpdates];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)endUpdate
{
    didBeginUpdate = NO;
    [tableView endUpdates];
    //[tableViewTags removeAllObjects];
    [self showEmptyView];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)addObject:(id)object
{
    [self addObject:object animation:UITableViewRowAnimationNone];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)addObject:(id)object atSection:(int)section
{
    [self addObject:object atSection:section animation:UITableViewRowAnimationNone];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)addObject:(id)object animation:(UITableViewRowAnimation)animation
{
    int section = 0;
    if(sections)
        section = [sections count]-1;
    [self addObject:object atSection:section animation:animation];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)addObject:(id)object atSection:(int)section animation:(UITableViewRowAnimation)animation
{
    if(object)
    {
        if(!didBeginUpdate)
            [tableView beginUpdates];
        NSMutableArray* array = nil;
        if(sections)
            array = [items objectAtIndex:section];
        else
            array = items;
        [array addObject:object];
        int index = [array indexOfObject:[array lastObject]];
        [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:section]] withRowAnimation:animation];
        if(!didBeginUpdate)
            [self endUpdate];
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)addObjects:(NSArray*)objects
{
    int section = 0;
    if(sections)
        section = [sections count]-1;
    [self addObjects:objects atSection:section];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)addObjects:(NSArray*)objects atSection:(int)section
{
    [self addObjects:objects atSection:section animation:UITableViewRowAnimationNone];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)addObjects:(NSArray*)objects atSection:(int)section animation:(UITableViewRowAnimation)animation
{
    if(objects.count > 0)
    {
        if(!didBeginUpdate)
            [tableView beginUpdates];
        NSMutableArray* array = nil;
        if(sections)
            array = [items objectAtIndex:section];
        else
            array = items;
        [array addObjectsFromArray:objects];
        int index = [array indexOfObject:[objects objectAtIndex:0]];
        NSMutableArray* gather = [NSMutableArray arrayWithCapacity:objects.count];
        for(int i = 0; i < objects.count; i++)
            [gather addObject:[NSIndexPath indexPathForRow:index+i inSection:section]];
        [tableView insertRowsAtIndexPaths:gather withRowAnimation:animation];
        if(!didBeginUpdate)
            [self endUpdate];
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)insertObject:(id)object atIndexPath:(NSIndexPath*)indexPath
{
    [self insertObject:object atIndexPath:indexPath animation:UITableViewRowAnimationNone];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)insertObject:(id)object atIndexPath:(NSIndexPath*)indexPath animation:(UITableViewRowAnimation)animation
{
    if(object)
    {
        if(!didBeginUpdate)
            [tableView beginUpdates];
        NSMutableArray* array = nil;
        if(sections)
            array = [items objectAtIndex:indexPath.section];
        else
            array = items;
        [array insertObject:object atIndex:indexPath.row];
        [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:animation];
        if(!didBeginUpdate)
            [self endUpdate];
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)insertObjects:(NSArray*)objects atIndexPath:(NSIndexPath*)indexPath
{
    [self insertObjects:objects atIndexPath:indexPath animation:UITableViewRowAnimationNone];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)insertObjects:(NSArray*)objects atIndexPath:(NSIndexPath*)indexPath animation:(UITableViewRowAnimation)animation
{
    if(objects.count > 0)
    {
        if(!didBeginUpdate)
            [tableView beginUpdates];
        NSMutableArray* array = nil;
        if(sections)
            array = [items objectAtIndex:indexPath.section];
        else
            array = items;
        [array addObjectsFromArray:objects];
        int index = indexPath.row;
        NSMutableArray* gather = [NSMutableArray arrayWithCapacity:objects.count];
        for(int i = 0; i < objects.count; i++)
            [gather addObject:[NSIndexPath indexPathForRow:index+i inSection:indexPath.section]];
        [tableView insertRowsAtIndexPaths:gather withRowAnimation:animation];
        if(!didBeginUpdate)
            [self endUpdate];
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)removeObject:(id)object
{
    [self removeObject:object animation:UITableViewRowAnimationNone];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)removeObject:(id)object animation:(UITableViewRowAnimation)animation
{
    if(object)
    {
        if(!didBeginUpdate)
            [tableView beginUpdates];
        NSIndexPath* indexPath = nil;
        NSMutableArray* removeArray = nil;
        if(sections)
        {
            int section = 0;
            for(NSMutableArray* array in items)
            {
                if([array containsObject:object])
                {
                    indexPath = [NSIndexPath indexPathForRow:[array indexOfObject:object] inSection:section];
                    removeArray = array;
                    break;
                }
                section++;
            }
            
        }
        else
        {
            indexPath = [NSIndexPath indexPathForRow:[items indexOfObject:object] inSection:0];
            removeArray = items;
        }
        [removeArray removeObject:object];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:animation];
        if(!didBeginUpdate)
            [self endUpdate];
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)removeObjectAtIndex:(NSIndexPath*)indexPath
{
    [self removeObjectAtIndex:indexPath animation:UITableViewRowAnimationNone];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)removeObjectAtIndex:(NSIndexPath*)indexPath animation:(UITableViewRowAnimation)animation
{
    if(indexPath)
    {
        if(!didBeginUpdate)
            [tableView beginUpdates];
        
        NSMutableArray* array = nil;
        if(sections)
            array = [items objectAtIndex:indexPath.section];
        else
            array = items;
        
        [array removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:animation];
        if(!didBeginUpdate)
            [self endUpdate];
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)reloadRowsAtIndexPaths:(NSArray *)indexPathArray withRowAnimation:(UITableViewRowAnimation)animation
{
    if(!didBeginUpdate)
        [tableView beginUpdates];
    [tableView reloadRowsAtIndexPaths:indexPathArray withRowAnimation:animation];
    if(!didBeginUpdate)
        [self endUpdate];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)removeSection:(int)section
{
    [self removeSection:section animation:UITableViewRowAnimationNone];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)removeSection:(int)section animation:(UITableViewRowAnimation)animation
{
    if(!didBeginUpdate)
        [tableView beginUpdates];
    NSMutableArray* array = nil;
    if(sections)
        array = [items objectAtIndex:section];
    else
        array = items;
    [array removeAllObjects];
    [tableView deleteSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:animation];
    if(!didBeginUpdate)
        [self endUpdate];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)addSection:(NSArray*)objects
{
    [self addSection:objects animation:UITableViewRowAnimationNone];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)addSection:(NSArray*)objects animation:(UITableViewRowAnimation)animation
{
    if(!didBeginUpdate)
        [tableView beginUpdates];
    [items addObject:[NSMutableArray arrayWithArray:objects]];
    int sectionCount = items.count-1;
    if(sectionCount != sections.count-1)
        [sections addObject:@""];
    [tableView insertSections:[NSIndexSet indexSetWithIndex:sectionCount] withRowAnimation:animation];
    if(!didBeginUpdate)
        [self endUpdate];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)reloadSection:(int)section animation:(UITableViewRowAnimation)animation
{
    if(!didBeginUpdate)
        [tableView beginUpdates];
    [tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:animation];
    if(!didBeginUpdate)
        [self endUpdate];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)insertSection:(int)section objects:(NSArray*)objects
{
    [self insertSection:section objects:objects animation:UITableViewRowAnimationNone];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)insertSection:(int)section objects:(NSArray*)objects animation:(UITableViewRowAnimation)animation
{
    if(!didBeginUpdate)
        [tableView beginUpdates];
    [items insertObject:[NSMutableArray arrayWithArray:objects] atIndex:section];
    int sectionCount = items.count-1;
    if(sectionCount != sections.count-1)
        [sections insertObject:@"" atIndex:section];
    [tableView insertSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:animation];
    if(!didBeginUpdate)
        [self endUpdate];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setupRefreshView
{
    if(dragToRefresh)
    {
        if(!refreshHeader)
        {
            refreshHeader = [[GPDragToRefreshView alloc] initWithFrame:CGRectMake(0,
                                                                                  -tableView.bounds.size.height,
                                                                                  tableView.bounds.size.width,
                                                                                  tableView.bounds.size.height)];
            refreshHeader.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            refreshHeader.backgroundColor = [UIColor colorWithRed:226/255.0f green:231/255.0f  blue:237/255.0f  alpha:1];
            [refreshHeader setStatus:GPTableHeaderDragRefreshPullToReload];
            [tableView addSubview:refreshHeader];
        }
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//datasource abstraction
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(isSearching)
    {
        if (searchSections && searchItems.count > 0)
        {
            NSArray* itemArray = [searchItems objectAtIndex:section];
            return itemArray.count;
        }
        return searchItems.count;
    }
    if (sections && items.count > 0)
    {
        NSArray* itemArray = [items objectAtIndex:section];
        return itemArray.count;
    }
    return items.count;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id object = [self tableView:table objectForRowAtIndexPath:indexPath];
    
    if([object respondsToSelector:@selector(tag)])
    {
        int tag = [(GPTableTextItem*)object tag];
        if(tag > 0)
        {
            if(!tableViewTags)
                tableViewTags = [[NSMutableDictionary alloc] init];
            [tableViewTags setValue:object forKey:[NSString stringWithFormat:@"%d",tag]];
        }
    }
    
    Class cellClass = [self tableView:table cellClassForObject:object];
    const char* className = class_getName(cellClass);
    NSString* identifier = [[NSString alloc] initWithBytesNoCopy:(char*)className
                                                          length:strlen(className)
                                                        encoding:NSASCIIStringEncoding freeWhenDone:NO];
    
    UITableViewCell* cell =
    (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[[cellClass alloc] initWithStyle:UITableViewCellStyleDefault
                                 reuseIdentifier:identifier] autorelease];
    }
    [identifier release];
    
    if ([cell isKindOfClass:[GPTableCell class]])
        [(GPTableCell*)cell setAutoSize:self.variableHeight];
    
    if([object isKindOfClass:[GPTableTextItem class]])
        [(GPTableTextItem*)object setIsGrouped:self.isGrouped];
    
    if ([cell isKindOfClass:[GPTableCell class]])
        [(GPTableCell*)cell setObject:object];
    
    if([object isKindOfClass:[GPTableImageItem class]])
        [self processImageURL:object];
    
    if([cell respondsToSelector:@selector(setDelegate:)] && self.delegate)
        [cell performSelector:@selector(setDelegate:) withObject:self.delegate];
    
    if([self.delegate respondsToSelector:@selector(customAccessory:)])
    {
        GPTableAccessory* view = [self.delegate customAccessory:cell.accessoryType];
        if(view)
            cell.accessoryView = view;
    }
    if(self.hideAccessoryViews)
        cell.accessoryType = UITableViewCellAccessoryNone;
    if(self.selectedColor)
    {
        UIView* bgView = cell.backgroundView;
        if(!bgView)
        {
            bgView = [[UIView alloc] init];
            bgView.backgroundColor = self.selectedColor;
            cell.selectedBackgroundView = bgView;
            [bgView release];
        }
        else
            bgView.backgroundColor = self.selectedColor;
    }
    
    if ([object isKindOfClass:[GPTableMoreItem class]])
    {
        GPTableMoreItem* item = (GPTableMoreItem*)object;
        if(item.isAutoLoad)
        {
            item.isLoading = YES;
            [(GPTableMoreCell *)cell setAnimating:YES];
            if(!self.stayActive)
                [table deselectRowAtIndexPath:indexPath animated:YES];
            if([self.delegate respondsToSelector:@selector(modelShouldLoad:)])
                [self.delegate modelShouldLoad:NO];
        }
    }
    return cell;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(isSearching)
        return searchSections ? searchSections.count : 1;
    return sections ? sections.count : 1;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    id object = nil;
    if(isSearching)
        object = [searchSections objectAtIndex:section];
    else
        object = [sections objectAtIndex:section];
    if([object isKindOfClass:[NSString class]])
    {
        if([object isEqualToString:UITableViewIndexSearch])
            return nil;
        return object;
    }
    return nil;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (UIView *)tableView:(UITableView *)table viewForHeaderInSection:(NSInteger)section
{
    NSMutableArray* useSection = nil;
    if(isSearching)
        useSection = searchSections;
    else
        useSection = sections;
    
    id object = [useSection objectAtIndex:section];
    if([object isKindOfClass:[NSString class]] && [object isEqualToString:UITableViewIndexSearch])
        return searchController.searchBar;
    
    if([object isKindOfClass:[UIView class]])
    {
        UIView* view = (UIView*)[useSection objectAtIndex:section];
        if(self.isGrouped && view.tag != SECTION_HEADER_TAG)
        {
            //because tableview is not a team player and does not respect the frame
            int left = table.frame.size.width/14;//15;
            if(table.frame.size.width > 480) //must not be an iphone or a popover view
                left = 48;
            UIView* temp = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, table.frame.size.width, view.frame.size.height)] autorelease];
            temp.userInteractionEnabled = YES;
            temp.tag = SECTION_HEADER_TAG;
            [temp addSubview:view];
            view.frame = CGRectMake(left, 0, tableView.frame.size.width-(left*2), view.frame.size.height);
            [useSection replaceObjectAtIndex:section withObject:temp];
            return temp;
        }
        return view;
    }
    return nil;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    id object = nil;
    if(isSearching)
        object = [searchSections objectAtIndex:section];
    else
        object = [sections objectAtIndex:section];
    if([object isKindOfClass:[UIView class]])
    {
        UIView* view = (UIView*)object;
        return view.frame.size.height;
    }
    if([object isKindOfClass:[NSString class]])
    {
        NSString* string = (NSString*)object;
        if([string isEqualToString:UITableViewIndexSearch])
            return 44;
        if(string.length > 0)
        {
            if(self.isGrouped)
                return 44;
            else
                return 24;
        }
    }
    return 0;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//simple way to query the our items/sections array for the correct item
- (id)tableView:(UITableView*)table objectForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if(isSearching || table == searchController.searchResultsTableView)
    {
        if (searchSections)
        {
            NSArray* itemArray = [searchItems objectAtIndex:indexPath.section];
            if(indexPath.row < itemArray.count)
                return [itemArray objectAtIndex:indexPath.row];
        }
        if(indexPath.row < searchItems.count)
            return [searchItems objectAtIndex:indexPath.row];
    }
    
    if (sections)
    {
        NSArray* itemArray = [items objectAtIndex:indexPath.section];
        return [itemArray objectAtIndex:indexPath.row];
    }
    return [items objectAtIndex:indexPath.row];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//where the tableview magic happens. return the cell class for the object class that comes through
- (Class)tableView:(UITableView*)table cellClassForObject:(id)object
{
    if([self.delegate respondsToSelector:@selector(classForObject:tableView:)])
    {
        Class class = [self.delegate classForObject:object tableView:table];
        if(class)
            return class;
    }
    if ([object isKindOfClass:[GPTableMessageItem class]])
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
    else if ([object isKindOfClass:[GPTableDeleteItem class]])
        return [GPTableDeleteCell class];
    else if ([object isKindOfClass:[GPTableSwitchItem class]])
        return [GPTableSwitchCell class];
    else if ([object isKindOfClass:[GPTableButtonItem class]])
        return [GPTableButtonCell class];
    else if ([object isKindOfClass:[GPTablePadItem class]])
        return [GPTablePadCell class];
    else if ([object isKindOfClass:[GPTableInfoItem class]])
        return [GPTableInfoCell class];
    else if ([object isKindOfClass:[GPTableTextItem class]])
        return [GPTableCell class];
    
    // This will display an empty white table cell - probably not what you want, but it
    // is better than crashing, which is what happens if you return nil here
    return [GPTableCell class];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)registerNibForClass:(Class)objClass nibName:(NSString*)name
{
    UINib *nib = [UINib nibWithNibName:name bundle:nil];
    const char* className = class_getName(objClass);
    NSString* identifier = [[NSString alloc] initWithBytesNoCopy:(char*)className
                                                          length:strlen(className)
                                                        encoding:NSASCIIStringEncoding freeWhenDone:NO];
    [tableView registerNib:nib forCellReuseIdentifier:identifier];
    [identifier release];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//return height
- (CGFloat)tableView:(UITableView*)table heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if(self.variableHeight)
    {
        id object = [self tableView:table objectForRowAtIndexPath:indexPath];
        Class cls = [self tableView:table cellClassForObject:object];
        CGFloat height = [cls tableView:table rowHeightForObject:object];
        if([object respondsToSelector:@selector(rowHeight)])
            [object setRowHeight:height];
        return height;
    }
    return 44;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//just allows the cell to turn blue when we are using checkmarks
- (NSIndexPath *)tableView:(UITableView *)table willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL exclude = NO;
    if([self.delegate respondsToSelector:@selector(checkMarkExpection:)])
        exclude = [self.delegate checkMarkExpection:indexPath.section];
    if(self.checkMarks && !exclude)
    {
        UITableViewCell* touchcell = [tableView cellForRowAtIndexPath:indexPath];
        [touchcell setSelectionStyle:UITableViewCellSelectionStyleBlue]; //since your URL is probably nil.
    }
    return indexPath;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//does the custom checkmark and GPLoadMore actions. Use didselect object below to get type
- (void)tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    BOOL exclude = NO;
    if([self.delegate respondsToSelector:@selector(checkMarkExpection:)])
        exclude = [self.delegate checkMarkExpection:indexPath.section];
    if(self.checkMarks && !exclude)
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
                BOOL isMulti = NO;
                if([self.delegate respondsToSelector:@selector(isMultiCheckMark:)])
                    isMulti = [self.delegate isMultiCheckMark:indexPath.section];
                GPTableTextItem* item = (GPTableTextItem*)object;
                if(indexPath.row == i)
                {
                    if(isMulti) //if we are not multi check, then we are not allowed to disable
                        item.isChecked = !item.isChecked;
                    else
                        item.isChecked = YES;
                }
                else if(!isMulti) //we are not multi so disable the rest
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
    
    id object = [self tableView:table objectForRowAtIndexPath:indexPath];
    if ([object isKindOfClass:[GPTableMoreItem class]])
    {
        GPTableMoreItem* item = (GPTableMoreItem*)object;
        item.isLoading = YES;
        [(GPTableMoreCell *)cell setAnimating:YES];
        [table deselectRowAtIndexPath:indexPath animated:YES];
        if([self.delegate respondsToSelector:@selector(modelShouldLoad:)])
            [self.delegate modelShouldLoad:NO];
        return;
    }
    if(!self.stayActive)
        [table deselectRowAtIndexPath:indexPath animated:YES];
    
    if([self.delegate respondsToSelector:@selector(didSelectObject:atIndexPath:)])
        [self.delegate didSelectObject:object atIndexPath:indexPath];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//image queue processing
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(GPHTTPRequest*)fetchImage:(NSString*)url
{
    __block GPHTTPRequest* request = [GPHTTPRequest requestWithString:url];
    [request setCacheModel:GPHTTPCacheCustomTime];
    [request setTimeout:60*60*1]; // Cache for 1 hour
    [request setFinishBlock:^{
        
        NSMutableArray* sectionArray = nil;
        if(isSearching)
            sectionArray = searchSections;
        else
            sectionArray = sections;
        
        NSMutableArray* mainItemsArray = nil;
        if(isSearching)
            mainItemsArray = searchItems;
        else
            mainItemsArray = items;
        if(sectionArray)
        {
            int section = 0;
            for(NSArray* itemArray in items)
            {
                [self reloadImageItems:itemArray url:request section:section];
                section++;
            }
        }
        else
            [self reloadImageItems:mainItemsArray url:request section:0];
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
            if([item.imageURL isEqualToString:request.URL.absoluteString])
            {
                item.imageData = [UIImage imageWithData:[request responseData]];
                UITableViewCell* cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:section]];
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
        if(!item.imageData && item.imageURL && ![imageURLs containsObject:item.imageURL])
        {
            [imageURLs addObject:item.imageURL];
            [imageQueue addOperation:[self fetchImage:item.imageURL]];
        }
        
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)showRefreshHeader
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DragRefreshTableReload" object:nil];
    
    [refreshHeader setStatus:GPTableHeaderDragRefreshLoading];
    isRefreshing = YES;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    if (tableView.contentOffset.y < 0)
        tableView.contentInset = UIEdgeInsetsMake(HeaderVisibleHeight, 0.0f, 0.0f, 0.0f);
    [UIView commitAnimations];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//scrollView delegate
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewDidScroll:(UIScrollView*)scrollView
{
    if([self.delegate respondsToSelector:@selector(scrollViewDidScroll:)])
        [self.delegate scrollViewDidScroll:scrollView];
    [timeScroller scrollViewDidScroll];
    if (scrollView.dragging && !isRefreshing && self.dragToRefresh) //&& !controller.model.isLoading
    {
        if (scrollView.contentOffset.y > RefreshDeltaY && scrollView.contentOffset.y < 0.0f)
            [refreshHeader setStatus:GPTableHeaderDragRefreshPullToReload];
        
        else if (scrollView.contentOffset.y < RefreshDeltaY)
            [refreshHeader setStatus:GPTableHeaderDragRefreshReleaseToReload];
    }
    
    // This is to prevent odd behavior with plain table section headers. They are affected by the
    // content inset, so if the table is scrolled such that there might be a section header abutting
    // the top, we need to clear the content inset.
    if (isRefreshing && self.dragToRefresh) //controller.model.isLoading
    {
        if (scrollView.contentOffset.y >= 0)
            tableView.contentInset = UIEdgeInsetsZero;
        
        else if (scrollView.contentOffset.y < 0)
            tableView.contentInset = UIEdgeInsetsMake(HeaderVisibleHeight, 0, 0, 0);
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [timeScroller scrollViewWillBeginDragging];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewDidEndDragging:(UIScrollView*)scrollView willDecelerate:(BOOL)decelerate
{
    // If dragging ends and we are far enough to be fully showing the header view trigger a
    // load as long as we arent loading already
    if (scrollView.contentOffset.y <= RefreshDeltaY && !isRefreshing && self.dragToRefresh) //&& !controller.model.isLoading
    {
        [self showRefreshHeader];
        if([self.delegate respondsToSelector:@selector(modelShouldLoad:)])
            [self.delegate modelShouldLoad:YES];
    }
    if(!decelerate)
        [timeScroller scrollViewDidEndDecelerating];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//deleting rows
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(BOOL)tableView:(UITableView *)table canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL canEdit = NO;
    if([self.delegate respondsToSelector:@selector(canDeleteObject:atIndexPath:)])
        canEdit = [self.delegate canDeleteObject:[self tableView:table objectForRowAtIndexPath:indexPath] atIndexPath:indexPath];
    return canEdit;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)tableView:(UITableView *)table commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        if([self.delegate respondsToSelector:@selector(didDeleteObject:atIndexPath:)])
            [self.delegate didDeleteObject:[self tableView:table objectForRowAtIndexPath:indexPath] atIndexPath:indexPath];
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(id)objectAtPoint:(CGPoint)point
{
    UIView *view = [tableView hitTest:point withEvent:UIEventTypeTouches];
    
    if ([view.superview isKindOfClass:[UITableViewCell class]])
    {
        UITableViewCell* cell = (UITableViewCell*)view.superview;
        NSIndexPath* path = [tableView indexPathForCell:cell];
        return [self tableView:tableView objectForRowAtIndexPath:path];
    }
    return nil;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(NSIndexPath*)indexPathOfObject:(id)object
{
    NSArray* searchArray = items;
    BOOL hasSections = NO;
    if(isSearching)
    {
        if (searchSections)
            hasSections = YES;
        searchArray = searchItems;
    }
    else if(sections)
        hasSections = YES;
    if(hasSections)
    {
        int i = 0; // i is object index
        int k = 0; //k is section index
        for(NSArray* array in items)
        {
            i = 0;
            for(id arrayObject in array)
            {
                if(arrayObject == object)
                    return [NSIndexPath indexPathForRow:i inSection:k];
                i++;
            }
            k++;
        }
    }
    else
    {
        int i = 0;
        for(id arrayObject in searchArray)
        {
            if(arrayObject == object)
                return [NSIndexPath indexPathForRow:i inSection:0];
            i++;
        }
    }
    return nil;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(id)findItemByTag:(int)tag
{
    NSString* key = [NSString stringWithFormat:@"%d",tag];
    return [tableViewTags objectForKey:key];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)scrollToIndexPath:(NSIndexPath*)path scrollPostition:(UITableViewScrollPosition)pos animated:(BOOL)animated
{
    [tableView scrollToRowAtIndexPath:path atScrollPosition:pos animated:animated];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setFirstResponder:(id)object
{
    NSIndexPath* path = [self indexPathOfObject:object];
    if(path)
    {
        UITableViewCell* cell = [tableView cellForRowAtIndexPath:path];
        if([cell respondsToSelector:@selector(becomeFirstResponder)])
            [cell becomeFirstResponder];
    }
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)dismissKeyboard
{
    for(GPTableCell* cell in tableView.visibleCells)
        if([cell isKindOfClass:[GPTableTextFieldCell class]])
            [[(GPTableTextFieldCell*)cell textField] resignFirstResponder];
        else if([cell isKindOfClass:[GPTableTextViewCell class]])
            [[(GPTableTextViewCell*)cell textView] resignFirstResponder];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(CGFloat)heightForObject:(id)object
{
    Class cls = [self tableView:tableView cellClassForObject:object];
    CGFloat height = [cls tableView:tableView rowHeightForObject:object];
    return height;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//methods use for searching
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//setup the tableview to be a search TableView
-(void)setupSearchSections
{
    [sections release];
    [items removeAllObjects];
    sections = [[NSMutableArray alloc] initWithCapacity:27];
    [sections addObject:UITableViewIndexSearch];
    [items addObject: [NSMutableArray array]];
    NSString* alpha = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    for(int i = 0; i < 26; i++)
    {
        [sections addObject:[NSString stringWithFormat:@"%c",[alpha characterAtIndex:i] ]];
        [items addObject: [NSMutableArray array]];
    }
    if(numberIndex)
    {
        [sections addObject:@"#"];
        [items addObject: [NSMutableArray array]];
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setupSearchController
{
    if(!searchController)
    {
        UISearchBar* search = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 44)];
        search.delegate = self;
        searchController = [[UISearchDisplayController alloc] initWithSearchBar:search contentsController:(UIViewController*)self.delegate];
        searchController.delegate = self;
        searchController.searchResultsDataSource = self;
        searchController.searchResultsDelegate = self;
        [search release];
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(NSArray*)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if(isSearching)
        return nil;
    if(hideSectionTitles)
        return nil;
    if(!self.showSearch)
        return nil;
    NSInteger truncate = self.truncateCount;
    if(truncate <= 0)
        truncate = items.count + 1;
    if(items.count == 1 && items.count <= truncate )
        return nil;
    NSMutableArray* array = [NSMutableArray arrayWithCapacity:27];
    
    [array addObject:UITableViewIndexSearch];
    NSString* alpha = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    for(int i = 0; i < 26; i++)
        [array addObject:[NSString stringWithFormat:@"%c",[alpha characterAtIndex:i] ]];
    
    if([self numberIndex])
        [array addObject:@"#"];
    
    return array;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)addSortedObject:(id)object
{
    if([object isKindOfClass:[GPTableTextItem class]] && self.showSearch)
    {
        GPTableTextItem* item = (GPTableTextItem*)object;
        NSString* text = [item.text stringByStrippingHTML];
        if(text.length > 0)
        {
            char character = [[text lowercaseString] characterAtIndex:0];
            NSString* c = [NSString stringWithFormat:@"%c",character];
            c = [c uppercaseString];
            for(int i = 1; i < sections.count; i++)
            {
                NSString* title = [sections objectAtIndex:i];
                if([title isEqualToString:c])
                {
                    NSMutableArray* array = [items objectAtIndex:i];
                    [array addObject:item];
                    return;
                }
            }
            //we did not find the section, but it appear to be a char, so we will add it as the section it was apart was probably removed.
            if(isalpha(character))
            {
                NSString* alpha = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
                NSRange range = [alpha rangeOfString:c];
                if(range.location != NSNotFound)
                {
                    int index = sections.count;
                    int alphaIndex = range.location; //because we have a search index
                    for(int i = 1; i < sections.count; i++)
                    {
                        NSString* title = [sections objectAtIndex:i];
                        NSRange range = [alpha rangeOfString:title];
                        if(range.location != NSNotFound)
                        {
                            if(alphaIndex <= range.location)
                            {
                                index = i;
                                break;
                            }
                        }
                        i++;
                    }
                    [sections insertObject:c atIndex:index];
                    [items insertObject:[NSMutableArray arrayWithObject:object] atIndex:index];
                }
            }
        }
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)clearEmptySections
{
    NSMutableArray* gatherSections = [NSMutableArray arrayWithCapacity:sections.count];
    NSMutableArray* gatherItems = [NSMutableArray arrayWithCapacity:sections.count];
    for(int i = 1; i < items.count; i++)
    {
        NSMutableArray* array = [items objectAtIndex:i];
        if(array.count == 0)
        {
            [gatherSections addObject:[sections objectAtIndex:i]];
            [gatherItems addObject:array];
        }
    }
    int total = 0;
    for(NSArray* array in gatherItems)
        total += array.count;
    if(total < self.truncateCount)
    {
        [sections removeAllObjects];
        [sections addObject:@""];
        NSMutableArray* gatherItems = [NSMutableArray arrayWithCapacity:total];
        for(NSArray* array in items)
            [gatherItems addObjectsFromArray:array];
        [items removeAllObjects];
        [items addObject:gatherItems];
    }
    else
    {
        for(id object in gatherItems)
            [items removeObject:object];
        for(id object in gatherSections)
            [sections removeObject:object];
        if(items.count != sections.count)
            [items insertObject:[NSMutableArray array] atIndex:0];
    }
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    isSearching = YES;
    if([self.delegate respondsToSelector:@selector(willBeginSearch)])
        [self.delegate willBeginSearch];
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    isSearching = NO;
    if([self.delegate respondsToSelector:@selector(willStopSearch)])
        [self.delegate willStopSearch];
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)runSearch:(NSString*)string
{
    if([self.delegate respondsToSelector:@selector(didRunSearch:)])
        [self.delegate didRunSearch:string];
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)searchBarSearchButtonClicked:(UISearchBar*)searchBar
{
    [self runSearch:searchBar.text];
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    if([self.delegate respondsToSelector:@selector(willHideSearchKeyboard:)])
        [self.delegate willHideSearchKeyboard:searchBar];
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    if(self.isAutoSearch)
        [self runSearch:searchString];
    return YES;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setShowSearch:(BOOL)show
{
    if(show)
    {
        if(!_showSearch)
        {
            searchItems = [[NSMutableArray alloc] init];
            [self setupSearchSections];
            self.hideAccessoryViews = YES;
        }
    }
    _showSearch = show;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setShowsHorizontalScrollIndicator:(BOOL)shows
{
    tableView.showsHorizontalScrollIndicator = shows;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(BOOL)showsHorizontalScrollIndicator
{
    return tableView.showsHorizontalScrollIndicator;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setShowsVerticalScrollIndicator:(BOOL)shows
{
    tableView.showsVerticalScrollIndicator = shows;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(BOOL)showsVerticalScrollIndicator
{
    return tableView.showsVerticalScrollIndicator;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setScrollEnabled:(BOOL)scroll
{
    tableView.scrollEnabled = scroll;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(BOOL)scrollEnabled
{
    return tableView.scrollEnabled;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setSeparatorColor:(UIColor *)color
{
    tableView.separatorColor = color;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(UIColor*)separatorColor
{
    return tableView.separatorColor;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setContentOffset:(CGPoint)contentOffset
{
    tableView.contentOffset = contentOffset;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(CGPoint)contentOffset
{
    return tableView.contentOffset;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(CGSize)contentSize
{
    return tableView.contentSize;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setTableHeaderView:(UIView *)header
{
    tableView.tableHeaderView = header;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(UIView*)tableHeaderView
{
    return tableView.tableHeaderView;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setTableFooterView:(UIView *)footer
{
    tableView.tableFooterView = footer;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(UIView*)tableFooterView
{
    return tableView.tableFooterView;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setSelectedRow:(NSIndexPath *)indexPath
{
    [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(NSIndexPath*)selectedRow
{
    return [tableView.indexPathsForSelectedRows lastObject];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)dealloc
{
    [tableViewTags release];
    [searchController release];
    [timeScroller release];
    [imageQueue release];
    [imageURLs release];
    [tableView release];
    [super dealloc];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


@end
