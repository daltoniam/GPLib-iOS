//
//  GridView.h
//  TestApp
//
//  Created by Dalton Cherry on 10/30/12.
//  Copyright (c) 2012 Basement Krew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPGridViewCell.h"

@class GPGridView;

@protocol GPGridViewDelegate <UIScrollViewDelegate>

@optional
/*!
 Called when the grid view loads.
 */
-(void)gridViewDidSelectObject:(GPGridView*)gridView object:(id)object index:(NSInteger)index;
-(void)gridViewDidSelectLabel:(GPGridView*)gridView object:(id)object index:(NSInteger)index;

//this is called with a GPMoreItem is show (if auto load) or tapped.
//Note that this may be called many times(if auto or tapped by user more than once) and you to make sure your model is done, before loading again
-(void)modelShouldLoad;

//implement this to use custom cells for custom GPTableItem objects. return nil to use default
-(Class)classForObject:(id)object gridView:(GPGridView*)gridView;

//a item was remove from the grid while editing
-(void)gridViewDidRemoveItem:(GPGridView*)gridView index:(int)index;

@end


@interface GPGridView : UIScrollView<GPGridCellDelegate>
{
    NSMutableSet* visibleGridItems;
    NSMutableSet* recycledGridItems;
    int rowCount;
    int columnCount;
    CGFloat rowHeight;
    NSMutableArray* imageQueue;
    NSOperationQueue* queue;
    int highestRow; //used for recycling
    int shortestRow; //used for recycling
    int totalTileHeight;
}

//this array is already setup and ready to go. You will add GPGridItems to it
@property(nonatomic,retain)NSMutableArray* items;

//standard delegate implmention
@property(nonatomic,assign)id<GPGridViewDelegate> delegate;

//see how many rows you have
@property(nonatomic,assign,readonly)int rowCount;

//set how many columns you want. Default is 3. Based on the row and column count the size of the grid Items will be determined.
@property(nonatomic,assign)int columnCount;

//set the space in between each row. Defalult is 10.
@property(nonatomic,assign)CGFloat rowSpacing;

//set the space between each column. Default is 10.
@property(nonatomic,assign)CGFloat columnSpacing;

//set the height of each row. Default is 100.
@property(nonatomic,assign)CGFloat rowHeight;

//set if in editing mode or not
@property(nonatomic,assign)BOOL editing;

//set if in editing mode the views should wiggle. Default is YES
@property(nonatomic,assign)BOOL shouldWiggle;

//set if you want to layout to be tile. Default is NO. Please note editing is not avalible in tile mode
@property(nonatomic,assign)BOOL tileLayout; //still an experimental feature

//set a gridView header.
@property(nonatomic,retain)UIView* gridViewHeader;

//reload the gridview items
-(void)reloadData;

//animation adding/deleting
-(void)removeObjectAtIndex:(int)index;
-(void)removeObjectsAtIndexes:(NSArray*)indexes;
-(void)removeObject:(id)object;
-(void)insertObject:(id)object index:(int)index;
-(void)addObject:(id)object;

@end
