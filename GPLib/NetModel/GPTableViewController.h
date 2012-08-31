//
//  GPTableViewController.h
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
#import "GPTableDragRefresh.h"
#import "GPLoadingLabel.h"
#import "GPTableAccessory.h"
#import "GPTimeScroller.h"

#define SECTION_HEADER_TAG 125675

@class GPTableDragRefresh;

@interface GPTableViewController : UIViewController<GPModelDelegate,UITableViewDelegate,UITableViewDataSource,GPTimeScrollerDelegate>
{
    GPModel* model;
    GPLoadingLabel* ActLabel;
    GPTableDragRefresh* refresh;
    UITableView* _tableView;
    NSMutableArray* items;
    NSMutableArray* sections;
    UIView* emptyView;
    GPTimeScroller* timeScroller;
    NSMutableArray* imageURLs;
    NSOperationQueue* imageQueue;
}

@property(nonatomic,readonly,retain)GPModel* model;
@property(nonatomic,retain)UITableView* tableView;

-(void)processImageURL:(id)object;
- (Class)tableView:(UITableView*)tableView cellClassForObject:(id)object;
- (id)tableView:(UITableView*)tableView objectForRowAtIndexPath:(NSIndexPath*)indexPath;
- (void)tableView:(UITableView*)tableView removeObjectAtIndexPath:(NSIndexPath*)indexPath; 
- (void)didSelectObject:(id)object atIndexPath:(NSIndexPath*)indexPath;
-(NSString*)loadingText;
-(GPModel*)model:(NSString*)url;
-(BOOL)dragToRefresh;
- (id)initWithURLString:(NSString*)url;
- (id)initWithOutURL;
-(BOOL)grouped;
-(BOOL)checkMarks;
-(BOOL)isMultiCheckMark:(int)section;
-(BOOL)checkMarksExpection:(int)section;
-(BOOL)autoSizeCells;
-(UIColor*)tableBackground;
-(void)setupModel:(NSString*)url;

-(NSString*)emptyTableTitle;
-(NSString*)emptyTableText;
-(UIImage*)emptyTableImage;
-(UIView*)defaultEmptyView;
-(void)showEmptyView;

-(BOOL)useTimeScroller;
-(NSDate*)timeScrollerForObject:(id)object cell:(UITableViewCell*)cell;

-(GPTableAccessory*)customAccessory:(UITableViewCellAccessoryType)type;

-(void)copyRefresh;

-(GPLoadingLabelStyle)actLabelStyle;
-(BOOL)isLastObjectInSection:(id)object section:(int)section;

@end

