//
//  GPTableView.h
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
//This is designed to abstract out the datasource and delegate of UITableView, make it simpler to use.

#import <UIKit/UIKit.h>
#import "GPTableAccessory.h"
#import "GPDragToRefreshView.h"
#import "GPEmptyTableView.h"
#import "GPTimeScroller.h"

#define SECTION_HEADER_TAG 125675

@protocol GPTableViewDelegate <NSObject>

@optional
//this is called with a GPMoreItem is show (if auto load) or tapped.
//Note that this may be called many times(if auto or tapped by user more than once) and you to make sure your model is done, before loading again
-(void)modelShouldLoad:(BOOL)dragRefresh;

//implement this to make custom Accessories.
-(GPTableAccessory*)customAccessory:(UITableViewCellAccessoryType)type;

//implement this to use custom cells for custom GPTableItem objects. return nil to use default
-(Class)classForObject:(id)object tableView:(UITableView*)tableView;

//this is called with a object is selected
- (void)didSelectObject:(id)object atIndexPath:(NSIndexPath*)indexPath;

//this enables the table view to allow multiple checkmarks instead of just. Requires that checkMarks be set to YES.
//return YES if you want the section to allow multi checkMarks
-(BOOL)isMultiCheckMark:(int)section;

//return YES if you want the section to be exclude from check mark. Requires that checkMarks be set to YES.
-(BOOL)checkMarkExpection:(int)section;

//implement this to handle searching
-(void)didRunSearch:(NSString*)string;

//when the search controller is brought up
-(void)willBeginSearch;

//when the search controller is dismissed.
-(void)willStopSearch;

-(void)scrollViewDidScroll:(UIScrollView*)scrollView;

@end

@interface GPTableView : UIView<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UISearchDisplayDelegate>
{
    UITableView* tableView;
    NSMutableArray* imageURLs;
    NSOperationQueue* imageQueue;
    GPTimeScroller* timeScroller;
    BOOL isRefreshing;
    BOOL didBeginUpdate;
    BOOL searchButtonTapped;
    NSMutableDictionary* tableViewTags;
}
//default delegate implementation, nothing special
@property(nonatomic,assign)id<GPTableViewDelegate>delegate;

//returns if the tableview is grouped. Default is no
@property(nonatomic,assign,readonly)BOOL isGrouped;

//this array is already setup and ready to go. You will add NSArray if you use sections or GPTableItems if no sections
@property(nonatomic,retain)NSMutableArray* items;

//you need to init this array if you place to use sections.
@property(nonatomic,retain)NSMutableArray* sections;

//set the color when an item is selected. Default is nil and will use apple default blue
@property(nonatomic,retain)UIColor* selectedColor;

//set if the height of the cells can vary. Default is YES
@property(nonatomic,assign)BOOL variableHeight;

//this is the empty view that will be displayed if the tableview is empty. (if ever)
@property(nonatomic,retain)GPEmptyTableView* emptyView;

//this is enables drag to refresh. Default is NO.
@property(nonatomic,assign)BOOL dragToRefresh;

//this is the drag to refresh header view. This provide for customizations. This is default by nil, and you must set dragToRefresh = YES to make non nil.
@property(nonatomic,retain)GPDragToRefreshView* refreshHeader;

//set this to hide tableView separators if you are going to use custom ones. Default is NO.
@property(nonatomic,assign)BOOL hideSeparator;

//this enables the table view to act as a selection menu with checkmarks.
@property(nonatomic,assign)BOOL checkMarks;

//this is the for the tableView separatorColor
@property(nonatomic,retain)UIColor* separatorColor;

//hide all accessoryViews. Default is NO, but showSearch, set this to YES.
@property(nonatomic,assign)BOOL hideAccessoryViews;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//search properties
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//same as sections, but for searching
@property(nonatomic,assign,readonly)BOOL isSearching;

//set this if you want a # to be shown in the search Titles. Default is NO
@property(nonatomic,assign)BOOL numberIndex;

//set this if you want to hide the searchBar and sections headers if the item count is less than this. Default is 15.
@property(nonatomic,assign)NSInteger truncateCount;

//same as items, but for searching
@property(nonatomic,retain)NSMutableArray* searchItems;

//same as sections, but for searching
@property(nonatomic,retain)NSMutableArray* searchSections;

//hide Section Titles
@property(nonatomic,assign)BOOL hideSectionTitles;

//set this to show the searchBar
@property(nonatomic,assign)BOOL showSearch;

//set this to make get search query from every key and not just the search button
@property(nonatomic,assign)BOOL isAutoSearch;

//this is the searchController used for searching, (the searchBar)
@property(nonatomic,retain)UISearchDisplayController* searchController;

//set if you want the ScrollIndicator to show. Default is YES.
@property(nonatomic,assign)BOOL showsHorizontalScrollIndicator;

//set if you want the ScrollIndicator to show. Default is YES.
@property(nonatomic,assign)BOOL showsVerticalScrollIndicator;

//the content offset of the tableview
@property(nonatomic)CGPoint contentOffset;

//check the contentSize
@property(nonatomic,assign,readonly)CGSize contentSize;

-(id)initWithFrame:(CGRect)frame isGrouped:(BOOL)grouped;
-(id)init:(BOOL)grouped;

//works just like UITableview, need to call after changing datasource (items or sections arrays)
-(void)reloadData;

//register a class to a Nib. 
-(void)registerNibForClass:(Class)objClass nibName:(NSString*)name;

//run this once a pull to refresh reload is done.
-(void)refreshComplete;

//flash the scrollBars
-(void)flashScrollIndicators;

//add a search item to the correct A-Z index. Only recommend to be used for tableviews with a searchBar
-(void)addSortedObject:(id)object;

//remove unused sections from the tableView
-(void)clearEmptySections;


//I am exposing this for now. I want to think of a better way around not have searchController.
-(void)setupSearchController;

//this will show the drag to refresh header and put it in a refresh state.
-(void)showRefreshHeader;

//returns the table item at that point
-(id)objectAtPoint:(CGPoint)point;

//returns the item by tag
-(id)findItemByTag:(int)tag;

//returns the index of an object
-(NSIndexPath*)indexPathOfObject:(id)object;

//scroll to a indexPath
-(void)scrollToIndexPath:(NSIndexPath*)path scrollPostition:(UITableViewScrollPosition)pos animated:(BOOL)animated;

//adding/removing to tableView with animation

//these start are useful if you want to chain multiple animations together
-(void)beginUpdate;
-(void)endUpdate;

//add an object to the tableView
-(void)addObject:(id)object;
-(void)addObject:(id)object atSection:(int)section;
-(void)addObject:(id)object animation:(UITableViewRowAnimation)animation;
-(void)addObject:(id)object atSection:(int)section animation:(UITableViewRowAnimation)animation;

//add objects to the end of the table view.
-(void)addObjects:(NSArray*)objects;
-(void)addObjects:(NSArray*)objects atSection:(int)section;
-(void)addObjects:(NSArray*)objects atSection:(int)section animation:(UITableViewRowAnimation)animation;

-(void)insertObject:(id)object atIndexPath:(NSIndexPath*)indexPath;
-(void)insertObject:(id)object atIndexPath:(NSIndexPath*)indexPath animation:(UITableViewRowAnimation)animation;
-(void)insertObjects:(NSArray*)objects atIndexPath:(NSIndexPath*)indexPath;
-(void)insertObjects:(NSArray*)objects atIndexPath:(NSIndexPath*)indexPath animation:(UITableViewRowAnimation)animation;

//remove any Object you want.
-(void)removeObject:(id)object;
-(void)removeObject:(id)object animation:(UITableViewRowAnimation)animation;
-(void)removeObjectAtIndex:(NSIndexPath*)indexPath;
-(void)removeObjectAtIndex:(NSIndexPath*)indexPath animation:(UITableViewRowAnimation)animation;

//reload a section
-(void)reloadSection:(int)section animation:(UITableViewRowAnimation)animation;

//remove a section
-(void)removeSection:(int)section;
-(void)removeSection:(int)section animation:(UITableViewRowAnimation)animation;

//add sections
-(void)addSection:(NSArray*)objects;
-(void)addSection:(NSArray*)objects animation:(UITableViewRowAnimation)animation;

//insert a section
-(void)insertSection:(int)section objects:(NSArray*)objects;
-(void)insertSection:(int)section objects:(NSArray*)objects animation:(UITableViewRowAnimation)animation;

@end
