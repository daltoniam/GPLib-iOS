//
//  GPGridView.h
//  GPLib
//
//  Created by Dalton Cherry on 4/5/12.
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

#import "GPGridViewCell.h"

@class GPGridView;

@protocol GPGridViewDelegate <UIScrollViewDelegate>

@optional
/*!
 Called when the grid view loads.
 */
-(void)gridViewDidSelectItem:(GPGridView*)gridView item:(GPGridViewCell*)cell index:(NSInteger)index;
-(void)gridViewDidSelectLabel:(GPGridView*)gridView item:(GPGridViewCell*)cell index:(NSInteger)index;
@end

#pragma mark -
@protocol GPGridViewDataSource<NSObject>

- (NSInteger)numberOfRowsInGridView:(GPGridView*)gridView;
- (NSInteger)numberOfColumnsInGridView:(GPGridView*)gridView orientation:(UIInterfaceOrientation)toInterfaceOrientation;
- (CGFloat)heightForRows:(GPGridView *)gridView;
- (GPGridViewCell*)gridView:(GPGridView *)gridView viewAtIndex:(NSInteger)index;

@optional
- (NSInteger)spacingBetweenRowsInGridView:(GPGridView*)gridView;
- (NSInteger)spacingBetweenColumnsInGridView:(GPGridView*)gridView;

@end

@interface GPGridView : UIScrollView<GPGridCellDelegate>
{
    NSMutableSet* visibleGridItems;
    NSMutableSet* recycledGridItems;
    int rowCount;
    int columnCount;
    CGFloat rowHeight;
    CGRect originalFrame;
    int topPadding;
    UIView* gridViewHeader;
}
@property(nonatomic,assign)id<GPGridViewDataSource>dataSource;
@property(nonatomic,assign)id<GPGridViewDelegate> delegate;
@property(nonatomic,assign,readonly)int rowCount;
@property(nonatomic,assign,readonly)int columnCount;
@property(nonatomic,assign,readonly)BOOL isEditing;
@property(nonatomic,retain,readonly)NSSet* visibleItems;

@property(nonatomic,retain)UIView* gridViewHeader;

-(GPGridViewCell*)dequeueGrid:(NSString*)identifier;
-(void)reloadData;
-(void)didRotate:(UIInterfaceOrientation)toInterfaceOrientation;
-(void)reloadCellsAtIndexes:(NSArray*)array;

-(void)editMode:(BOOL)state; //make the cells wiggle or not
//editing gridview
-(void)addItemAtIndex:(NSInteger)index;
-(void)removeItemAtIndex:(NSInteger)index;

//convience at grabbing a cell. Just queries datasource for the cell
-(GPGridViewCell*)cellAtIndex:(NSInteger)index;

//checks the visable items and returns cell if found
-(GPGridViewCell*)findCellAtIndex:(NSInteger)index;

@end
