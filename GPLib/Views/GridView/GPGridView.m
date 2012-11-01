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

@synthesize delegate,rowCount,rowSpacing,columnCount,columnSpacing,gridViewHeader,editing,items,rowHeight,shouldWiggle;
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
    [self updateGrid];
    [self recycleGrid];
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
    self.contentSize = CGSizeMake(self.frame.size.width, (rowHeight*rowCount)+((rowCount+1)*(rowSpacing+4)) + self.gridViewHeader.frame.size.height);
    if(self.contentSize.height < self.frame.size.height && self.gridViewHeader)
        self.contentSize = CGSizeMake(self.frame.size.width,self.frame.size.height+self.gridViewHeader.frame.size.height+10);
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)recycleGrid
{
    CGPoint point = self.contentOffset;
    int firstNeededRow = point.y/rowHeight;
    int lastNeededRow  = (point.y+self.bounds.size.height)/rowHeight;
    firstNeededRow = MAX(firstNeededRow, 0);
    lastNeededRow  = MIN(lastNeededRow, rowCount);
    if(firstNeededRow > 0)
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
    cell.backgroundColor = [UIColor clearColor]; //grayColor
    int width = (self.bounds.size.width/columnCount) - (columnSpacing+(columnSpacing/columnCount));
    int left = columnSpacing*(col+1) + (width*col);
    int top = (rowSpacing*(row+1)) + (rowHeight*row);
    if(top == 0)
        top = rowSpacing;
    if(left == 0)
        left = columnSpacing;
    cell.frame = CGRectMake(left, top, width, rowHeight);
    if(editing)
        [self editMode:cell edit:YES];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(NSInteger)getIndex:(NSInteger)col forRow:(NSInteger)row
{
    int index = 0;
    for(int i = 0; i <= rowCount; i++)
    {
        for(int k =0; k < columnCount; k++)
        {
            if(i == row && k == col)
                return index;
            index++;
        }
    }
    return index;
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
        btn.frame = CGRectMake(-3, -3, 15, 15);
        [btn setImage:[UIImage libraryImageNamed:@"removeButton.png"] forState:UIControlStateNormal];
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
        if([self.delegate respondsToSelector:@selector(didRemoveItemAtIndex:)])
            [self.delegate didRemoveItemAtIndex:index];
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setEditing:(BOOL)edit
{
    editing = edit;
    for(GPGridViewCell* cell in visibleGridItems)
        [self editMode:cell edit:edit];
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
