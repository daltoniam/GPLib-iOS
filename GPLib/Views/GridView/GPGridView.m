//
//  GridView.m
//  TestApp
//
//  Created by Dalton Cherry on 10/30/12.
//  Copyright (c) 2012 Basement Krew. All rights reserved.
//

#import "GPGridView.h"
#import <objc/runtime.h>
#import "GPTableMoreItem.h"
#import "GPGridMoreItem.h"
#import "GPGridMoreCell.h"
#import "GPHTTPRequest.h"
#import "UIImage+Additions.h"

#define REMOVE_BTN_TAG 12345

@implementation GPGridView

@synthesize delegate,rowCount,rowSpacing,columnCount,columnSpacing,gridViewHeader,editing,items,rowHeight,shouldWiggle,tileLayout;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)commonInit
{
    visibleGridItems = [[NSMutableSet alloc] init];
    recycledGridItems = [[NSMutableSet alloc] init];
    columnCount = 3;
    rowSpacing = columnSpacing = 10;
    rowHeight = 100;
    self.items = [[NSMutableArray alloc] init];
    self.backgroundColor = [UIColor clearColor];
    self.shouldWiggle = YES;
    highestRow = shortestRow = rowHeight;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(id)init
{
    if(self = [super init])
    {
        [self commonInit];
    }
    return self;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)reloadData
{
    if(self.tileLayout)
        [self shuffleDataSource];
    for(GPGridViewCell* cell in visibleGridItems)
    {
        [recycledGridItems addObject:cell];
        [self editMode:cell edit:NO];
        [cell removeFromSuperview];
    }
    [self recycleGrid];
    [self updateGrid];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//private stuff
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    if(items)
        [self reloadData];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setContentOffset:(CGPoint)contentOffset
{
    [super setContentOffset:contentOffset];
    if(items)
        [self recycleGrid];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)updateGrid
{
    rowCount = items.count/columnCount;
    if(items.count % columnCount)
        rowCount++;
    int count = self.items.count-1;
    int total = 0;
    if(self.tileLayout)
        total = totalTileHeight;

    for(int i = count; count-columnCount < i; i--)
    {
        int height = 0;
        int col = 0;
        int row = 0;
        [self convertIndexToGrid:i col:&col row:&row];
        int offset = [self getTotalHeight:col row:row cellHeight:&height];
        int overall = offset + height;
        if(overall > total)
            total = overall;
    }
    //(highestRow*rowCount)
    self.contentSize = CGSizeMake(self.frame.size.width, total+((rowCount+1)*(rowSpacing+3)) + self.gridViewHeader.frame.size.height);
    if(self.contentSize.height < self.frame.size.height && self.gridViewHeader)
        self.contentSize = CGSizeMake(self.frame.size.width,self.frame.size.height+self.gridViewHeader.frame.size.height+10);
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)recycleGrid
{
    CGPoint point = self.contentOffset;
    int firstNeededRow = point.y/highestRow;
    int lastNeededRow  = (point.y+self.bounds.size.height)/shortestRow;
    firstNeededRow = MAX(firstNeededRow, 0);
    lastNeededRow  = MIN(lastNeededRow, rowCount);
    if(firstNeededRow > 2)
        firstNeededRow -= 2;
    else if(firstNeededRow > 0)
        firstNeededRow--;
    for(GPGridViewCell* cell in visibleGridItems)
    {
        if (cell.rowIndex < firstNeededRow || cell.rowIndex > lastNeededRow || cell.columnIndex > columnCount)
        {
            [recycledGridItems addObject:cell];
            [self editMode:cell edit:NO];
            [cell removeFromSuperview];
        }
    }
    [visibleGridItems minusSet:recycledGridItems];
    
    for (int i = firstNeededRow; i <= lastNeededRow; i++)
    {
        for(int k = 0; k < columnCount; k++)
        {
            
            if(![self isDisplayColumnForIndex:k forRow:i])
            {
                int index = [self getIndex:k forRow:i];
                if(index < items.count)
                {
                    GPGridViewCell* cell = [self cellForIndex:index];
                    if(cell)
                    {
                        [self configureCell:cell column:k row:i];
                        [self addSubview:cell];
                        [visibleGridItems addObject:cell];
                    }
                }
            }
        }
    }
    
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(GPGridViewCell*)dequeueGrid:(NSString*)identifier
{
    for(GPGridViewCell* cell in recycledGridItems)
    {
        if ([cell.identifier isEqualToString:identifier])
        {
            [cell retain];
            [recycledGridItems removeObject:cell];
            return [cell autorelease];
        }
    }
    return nil;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(BOOL)isDisplayColumnForIndex:(NSInteger)index forRow:(NSInteger)row
{
    BOOL foundPage = NO;
    for (GPGridViewCell *cell in visibleGridItems)
    {
        if (cell.columnIndex == index && cell.rowIndex == row)
        {
            foundPage = YES;
            break;
        }
    }
    return foundPage;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)configureCell:(GPGridViewCell*)cell column:(NSInteger)col row:(NSInteger)row
{
    cell.rowIndex = row;
    cell.columnIndex = col;
    cell.delegate = self;
    cell.backgroundColor = [UIColor clearColor];
    if(self.tileLayout)
        cell.frame = [self frameForTile:col row:row];
    else
    {
        int height = 0;
        int offset = [self getTotalHeight:cell.columnIndex row:cell.rowIndex cellHeight:&height];
        int width = (self.bounds.size.width/columnCount) - (columnSpacing+(columnSpacing/columnCount));
        int left = columnSpacing*(col+1) + (width*col);
        int top = (rowSpacing*(row+1)) + offset;//(rowHeight*row);
        if(top == 0)
            top = rowSpacing;
        if(left == 0)
            left = columnSpacing;
        cell.frame = CGRectMake(left, top, width, height);
    }
    
    if(editing)
        [self editMode:cell edit:YES];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(int)getTotalHeight:(int)columnIndex row:(int)rowIndex cellHeight:(int*)height
{
    int index = [self getIndex:columnIndex forRow:rowIndex];
    int i = columnIndex;
    int total = 0;
    if(self.items.count > 0)
    {
        while(i < index)
        {
            GPGridViewItem* item = [self.items objectAtIndex:i];
            if(item.rowHeight <= 0)
                item.rowHeight = rowHeight;
            total += item.rowHeight;
            i += columnCount;
        }
        GPGridViewItem* currentItem = [self.items objectAtIndex:index];
        if(currentItem.rowHeight <= 0)
            currentItem.rowHeight = rowHeight;
        *height = currentItem.rowHeight;
        if(currentItem.rowHeight > highestRow)
            highestRow = currentItem.rowHeight;
        if(currentItem.rowHeight < shortestRow)
            shortestRow = currentItem.rowHeight;
    }
    return total;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)shuffleDataSource
{
    for(GPGridViewItem* item in self.items)
    {
        if(item.columnCount <= 1)
            item.columnCount = 1;
        if(item.rowCount <= 1)
            item.rowCount = 1;
    }
    int width = (self.bounds.size.width/columnCount) - (columnSpacing+(columnSpacing/columnCount));
    NSMutableArray* layoutArray = [NSMutableArray arrayWithCapacity:self.items.count];
    NSMutableArray* dataSource = [self.items mutableCopy];
    int top = rowSpacing;
    while(dataSource.count > 0)
    {
        NSMutableArray* rowArray = [NSMutableArray arrayWithCapacity:rowCount*columnCount];
        int columnLeft = columnCount;
        GPGridViewItem* mainItem = [dataSource objectAtIndex:0];
        [rowArray addObject:mainItem];
        [dataSource removeObject:mainItem];
        columnLeft -= mainItem.columnCount;
        if(columnLeft > 0)
        {
            int rowLeft = mainItem.rowCount;
            NSMutableArray* findArray = [NSMutableArray arrayWithCapacity:rowLeft*columnLeft];
            for(GPGridViewItem* item in dataSource)
            {
                if(item.columnCount <= columnLeft && item.rowCount <= rowLeft)
                {
                    [findArray addObject:item];
                    rowLeft -= item.rowCount;
                    if(rowLeft <= 0)
                    {
                        columnLeft -= item.columnCount;
                        if(columnLeft > 0)
                            rowLeft = mainItem.rowCount;
                        else
                            break;
                    }
                }
            }
            for(GPGridViewItem* item in findArray)
            {
                [dataSource removeObject:item];
                [rowArray addObject:item];
            }
        }
        int left = columnSpacing;
        int offset = 0;
        for(GPGridViewItem* item in rowArray)
        {
            int itemWidth = width*item.columnCount;
            int height = rowHeight*item.rowCount;
            if(item.columnCount > 1)
                itemWidth += columnSpacing*(item.columnCount-1);
            if(item.rowCount > 1)
                height += rowSpacing*(item.rowCount-1);
            item.frame = CGRectMake(left, top+offset, itemWidth, height);
            left += itemWidth+columnSpacing;
            if(left+columnSpacing >= self.frame.size.width)
            {
                offset += rowHeight + rowSpacing;
                left =  columnSpacing;
                for(GPGridViewItem* checkItem in rowArray)
                {
                    if(checkItem.rowCount > item.rowCount)
                    {
                        int itemWidth = (width*checkItem.columnCount);
                        if(checkItem.columnCount > 1)
                            itemWidth += columnSpacing*(checkItem.columnCount);
                        else
                            itemWidth += (columnSpacing);
                        left += itemWidth;
                    }
                    else if(checkItem.rowCount == item.rowCount)
                    {
                        itemWidth += (columnSpacing);
                        break;
                    }
                }
                itemWidth += (columnSpacing);
            }
        }
        int height = rowHeight*mainItem.rowCount;
        if(mainItem.rowCount > 1)
            height += rowSpacing*(mainItem.rowCount-1);
        top += height+rowSpacing;
        [layoutArray addObjectsFromArray:rowArray];
    }
    totalTileHeight = top/1.5;
    self.items = layoutArray;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(CGRect)frameForTile:(int)columnIndex row:(int)rowIndex
{
    int index = [self getIndex:columnIndex forRow:rowIndex];
    if(index < self.items.count)
    {
        GPGridViewItem* item = [self.items objectAtIndex:index];
        int height = item.frame.size.height;
        if(height > highestRow)
            highestRow = height;
        if(height < shortestRow)
            shortestRow = height;
        return item.frame;
    }
    return CGRectZero;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(Class)classForObject:(id)object gridView:(GPGridView*)gridView
{
    if([self.delegate respondsToSelector:@selector(classForObject:tableView:)])
    {
        Class class = [self.delegate classForObject:object gridView:gridView];
        if(class)
            return class;
    }
    if([object isKindOfClass:[GPGridMoreItem class]])
        return [GPGridMoreCell class];
    else if([object isKindOfClass:[GPGridViewItem class]])
        return [GPGridViewCell class];
    return [GPGridViewCell class];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(GPGridViewCell*)cellForIndex:(int)index
{
    id object = [self.items objectAtIndex:index];
    
    if([object isKindOfClass:[GPTableMoreItem class]])
    {
        GPTableMoreItem* moreItem = (GPTableMoreItem*)object;
        GPGridMoreItem* item = [GPGridMoreItem itemWithLoading:moreItem.text isAutoLoad:moreItem.isAutoLoad];
        [self.items replaceObjectAtIndex:index withObject:item];
        object = item;
    }
    Class cellClass = [self classForObject:object gridView:self];
    const char* className = class_getName(cellClass);
    NSString* identifier = [[NSString alloc] initWithBytesNoCopy:(char*)className
                                                          length:strlen(className)
                                                        encoding:NSASCIIStringEncoding freeWhenDone:NO];
    GPGridViewCell* cell = [self dequeueGrid:identifier];
    if(!cell)
        cell = [[[cellClass alloc] initWithIdentifer:identifier] autorelease];
    [identifier release];
    
    [cell setObject:object];
    if(![object isKindOfClass:[GPGridMoreItem class]])
        [self processImageURL:object];
    
    if ([object isKindOfClass:[GPGridMoreItem class]])
    {
        GPGridMoreItem* item = (GPGridMoreItem*)object;
        if(item.isAutoLoad)
        {
            item.isLoading = YES;
            [(GPGridMoreCell*)cell setAnimating:YES];
            if([self.delegate respondsToSelector:@selector(modelShouldLoad)])
                [self.delegate modelShouldLoad];
        }
    }
    return cell;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(GPGridViewCell*)findCellAtIndex:(NSInteger)index
{
    for(GPGridViewCell* cell in visibleGridItems)
    {
        int i = [self getIndex:cell.columnIndex forRow:cell.rowIndex];
        if(i == index)
            return cell;
    }
    return nil;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(NSInteger)getIndex:(NSInteger)col forRow:(NSInteger)row
{
    int index = 0;
    int skip = 0;
    int lastIndex = 0;
    for(int i = 0; i <= rowCount; i++)
    {
        for(int k =0; k < columnCount; k++)
        {
            if(i == row && k == col)
                return index;
            if(index < self.items.count && self.tileLayout)
            {
                GPGridViewItem* currentItem = [self.items objectAtIndex:index];
                if(currentItem.columnCount > 1 && lastIndex != index)
                {
                    lastIndex = index;
                    skip += currentItem.columnCount-1;
                }
                if(skip <= 0)
                    index++;
                else
                    skip--;
            }
            else
                index++;
        }
    }
    return index;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)convertIndexToGrid:(NSInteger)index col:(NSInteger*)col row:(NSInteger*)row
{
    int increment = 0;
    for(int i = 0; i <= rowCount; i++)
    {
        for(int k =0; k < columnCount; k++)
        {
            if(increment == index)
            {
                *col = k;
                *row = i;
                return;
            }
            increment++;
        }
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)insertObject:(id)object index:(int)index
{
    for(GPGridViewCell* cell in visibleGridItems)
    {
        int i = [self getIndex:cell.columnIndex forRow:cell.rowIndex];
        if(i >= index)
        {
            int col = 0;
            int row = 0;
            [self convertIndexToGrid:i+1 col:&col row:&row];
            [UIView animateWithDuration:0.25 animations:^{
                [self configureCell:cell column:col row:row];
            }];
        }
    }
    [self.items insertObject:object atIndex:index];
    
    GPGridViewCell* newCell = [self cellForIndex:index];
    newCell.alpha = 0;
    int col = 0;
    int row = 0;
    [self convertIndexToGrid:index col:&col row:&row];
    [self configureCell:newCell column:col row:row];
    
    [UIView animateWithDuration:0.25 delay:0.15 options:0 animations:^{
        [self addSubview:newCell];
        [visibleGridItems addObject:newCell];
        newCell.alpha = 1;
    } completion:^(BOOL finished){
        [self updateGrid];
    }];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)addObject:(id)object
{
    [self insertObject:object index:items.count];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)removeObjectsAtIndexes:(NSArray*)indexes
{
    for(NSNumber* number in indexes)
        [self removeObjectAtIndex:number.intValue multi:YES];
    int i = 0;
    for(NSNumber* number in indexes)
    {
        [self.items removeObjectAtIndex:number.intValue-i];
        i++;
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)removeObjectAtIndex:(int)index
{
    [self removeObjectAtIndex:index multi:NO];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)removeObject:(id)object
{
    int index = [self.items indexOfObject:object];
    if(index != NSNotFound)
        [self removeObjectAtIndex:index];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)removeObjectAtIndex:(int)index multi:(BOOL)multi
{
    if(!multi)
        [self.items removeObjectAtIndex:index];
    GPGridViewCell* findCell = [self findCellAtIndex:index];
    [UIView animateWithDuration:0.25 animations:^{
        findCell.alpha = 0;
    } completion:^(BOOL finished){
        [visibleGridItems removeObject:findCell];
        [findCell removeFromSuperview];
        for(GPGridViewCell* cell in visibleGridItems)
        {
            int i = [self getIndex:cell.columnIndex forRow:cell.rowIndex];
            if(i > index)
            {
                int col = 0;
                int row = 0;
                [self convertIndexToGrid:i-1 col:&col row:&row];
                [UIView animateWithDuration:0.25 animations:^{
                    [self configureCell:cell column:col row:row];
                }];
            }
        }
        [self updateGrid];
    }];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//image queue processing
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(GPHTTPRequest*)imageRequest:(NSString*)URL
{
    __block GPHTTPRequest* request = [GPHTTPRequest requestWithURL:[NSURL URLWithString:URL]];
    [request setCacheModel:GPHTTPCacheCustomTime];
    [request setTimeout:60*60*1]; // Cache for 1 hour
    [request setFinishBlock:^{
        
        int i = 0;
        for(id object in items)
        {
            if([object isKindOfClass:[GPGridViewItem class]] && ![object isKindOfClass:[GPGridMoreItem class]])
            {
                GPGridViewItem* item = (GPGridViewItem*)object;
                if([item.imageURL isEqualToString:request.URL.absoluteString])
                {
                    item.image = [UIImage imageWithData:[request responseData]];
                    GPGridViewCell* cell = [self findCellAtIndex:i];
                    [cell setImage:item.image];
                }
            }
            i++;
        }
        [imageQueue removeObject:request.URL.absoluteString];
        
    }];
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
-(void)editMode:(UIView*)view edit:(BOOL)edit
{
    if(edit)
    {
        [self wiggleAnimation:view];
        [self addRemoveButton:view];
    }
    else
    {
        UIView* btnView = [view viewWithTag:REMOVE_BTN_TAG];
        [btnView removeFromSuperview];
        [view.layer removeAnimationForKey:@"wobble"];
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)addRemoveButton:(UIView*)view
{
    UIView* btnView = [view viewWithTag:REMOVE_BTN_TAG];
    if(!btnView)
    {
        UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = REMOVE_BTN_TAG;
        btn.frame = CGRectMake(-5, -5, 20, 20);
        [btn setImage:[UIImage libraryImageNamed:@"close-small.png"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(removeCell:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:btn];
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)wiggleAnimation:(UIView*)view
{
    if(self.shouldWiggle)
    {
        view.layer.shouldRasterize = YES;
        CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
        
        CGFloat wobbleAngle = 0.02f;
        
        NSValue* valLeft = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(wobbleAngle, 0.0f, 0.0f, 1.0f)];
        NSValue* valRight = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(-wobbleAngle, 0.0f, 0.0f, 1.0f)];
        animation.values = [NSArray arrayWithObjects:valLeft, valRight, nil];
        
        animation.autoreverses = YES;
        animation.duration = 0.15;
        animation.repeatCount = HUGE_VALF;
        
        [view.layer addAnimation:animation forKey:@"wobble"];
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)removeCell:(UIButton*)btn
{
    GPGridViewCell* cell = (GPGridViewCell*)btn.superview;
    int index = [self getIndex:cell.columnIndex forRow:cell.rowIndex];
    if(index != NSNotFound)
    {
        [self removeObjectAtIndex:index];
        if([self.delegate respondsToSelector:@selector(gridViewDidRemoveItem:index:)])
            [self.delegate gridViewDidRemoveItem:self index:index];
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setEditing:(BOOL)edit
{
    if(self.tileLayout) //edit is not avalible in tile mode.
        return;
    editing = edit;
    for(GPGridViewCell* cell in visibleGridItems)
        [self editMode:cell edit:edit];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setTileLayout:(BOOL)tile
{
    tileLayout = tile;
    if(editing)
        editing = NO;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//cell delegates
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)gridCellWasSelected:(GPGridViewCell*)cell
{
    if ([cell isKindOfClass:[GPGridMoreCell class]])
    {
        int index = [self getIndex:cell.columnIndex forRow:cell.rowIndex];
        GPGridMoreItem* item = [self.items objectAtIndex:index];
        item.isLoading = YES;
        [(GPGridMoreCell*)cell setAnimating:YES];
        if([self.delegate respondsToSelector:@selector(modelShouldLoad)])
            [self.delegate modelShouldLoad];
        return;
    }
    if([self.delegate respondsToSelector:@selector(gridViewDidSelectObject:object:index:)])
    {
        int index = [self getIndex:cell.columnIndex forRow:cell.rowIndex];
        id object = [self.items objectAtIndex:index];
        [self.delegate gridViewDidSelectObject:self object:object index:index];
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)gridTextLabelWasSelected:(UIButton*)textLabel cell:(GPGridViewCell*)cell
{
    if([self.delegate respondsToSelector:@selector(gridViewDidSelectLabel:object:index:)])
    {
        int index = [self getIndex:cell.columnIndex forRow:cell.rowIndex];
        id object = [self.items objectAtIndex:index];
        [self.delegate gridViewDidSelectLabel:self object:object index:index];
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)dealloc
{
    [visibleGridItems release];
    [recycledGridItems release];
    [imageQueue release];
    [queue release];
    [super dealloc];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


@end
