//
//  GPGridView.m
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

#import "GPGridView.h"

#define RADIANS(degrees) ((degrees * M_PI) / 180.0)

@interface GPGridView()

-(void)updateGrid:(BOOL)rotate;
-(BOOL)isDisplayColumnForIndex:(NSInteger)index forRow:(NSInteger)row;
-(void)configureCell:(GPGridViewCell*)cell column:(NSInteger)col row:(NSInteger)row isRotate:(BOOL)rotate;
-(CGRect)cellFrameFor:(NSInteger)col atRow:(NSInteger)row isRotate:(BOOL)rotate;
-(NSInteger)getIndex:(NSInteger)col forRow:(NSInteger)row;
-(GPGridViewCell*)findCell:(NSInteger)column row:(NSInteger)row;

-(void)convertIndexToGrid:(NSInteger)index col:(NSInteger*)col row:(NSInteger*)row;

@end

@implementation GPGridView

@synthesize dataSource;
@dynamic delegate;
@synthesize rowCount = rowCount,columnCount = columnCount, isEditing,visibleItems = visibleGridItems,gridViewHeader = gridViewHeader;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(id)init
{
    if(self = [super init])
    {
        visibleGridItems = [[NSMutableSet alloc] init];
        recycledGridItems = [[NSMutableSet alloc] init];
        rowCount = 0;
        columnCount = 0;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    if(CGRectIsEmpty(originalFrame))
        originalFrame = frame;
    [self reloadData];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setContentOffset:(CGPoint)contentOffset
{
    [super setContentOffset:contentOffset];
    [self updateGrid:NO];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)reloadData
{
    //for(GPGridViewCell* cell in visibleGridItems)
    //    [cell removeFromSuperview];
    for(UIView* view in self.subviews)
        if([view isKindOfClass:[GPGridViewCell class]])
            [view removeFromSuperview];
    //[recycledGridItems removeAllObjects];
    [visibleGridItems removeAllObjects];
    UIInterfaceOrientation o = (UIInterfaceOrientation)[[UIApplication sharedApplication] statusBarOrientation];
    columnCount = [self.dataSource numberOfColumnsInGridView:self orientation:o];
    rowCount = [self.dataSource numberOfRowsInGridView:self];
    rowHeight = [self.dataSource heightForRows:self];
    topPadding = 20;
    if([self.dataSource respondsToSelector:@selector(spacingBetweenRowsInGridView:)])
        topPadding = [self.dataSource spacingBetweenRowsInGridView:self];
    //self.contentSize = CGSizeMake(self.frame.size.width, (rowHeight*(rowCount+1))+(rowCount+topPadding) + topPadding*2 );
    self.contentSize = CGSizeMake(self.frame.size.width, (rowHeight*rowCount)+(rowCount*topPadding) + topPadding + self.gridViewHeader.frame.size.height);
    if(self.contentSize.height < self.frame.size.height && self.gridViewHeader)
        self.contentSize = CGSizeMake(self.frame.size.width,self.frame.size.height+self.gridViewHeader.frame.size.height+10);

    [self updateGrid:NO];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)didRotate:(UIInterfaceOrientation)toInterfaceOrientation
{
    for(UIView* view in self.subviews)
        if([view isKindOfClass:[GPGridViewCell class]])
            [view removeFromSuperview];
    //[recycledGridItems removeAllObjects];
    [visibleGridItems removeAllObjects];
    columnCount = [self.dataSource numberOfColumnsInGridView:self orientation:toInterfaceOrientation];
    rowCount = [self.dataSource numberOfRowsInGridView:self];
    rowHeight = [self.dataSource heightForRows:self];
    topPadding = 20;
    if([self.dataSource respondsToSelector:@selector(spacingBetweenRowsInGridView:)])
        topPadding = [self.dataSource spacingBetweenRowsInGridView:self];
    [self updateGrid:YES];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)updateGrid:(BOOL)rotate
{
    [recycledGridItems minusSet:visibleGridItems];
    //self.contentSize = CGSizeMake(self.frame.size.width, (rowHeight*rowCount) + ((rowCount+1)*topPadding));
    // Calculate which rows and columns are visible
    CGRect visibleBounds = self.bounds;
    visibleBounds.origin.y -= rowHeight/2;
    visibleBounds.size.height += rowHeight/2;
    int firstRow = floorf(CGRectGetMinY(visibleBounds) / rowHeight);
    int lastRow = floorf((CGRectGetMaxY(visibleBounds)) / rowHeight); //-1
    firstRow = MAX(firstRow, 0);
    lastRow  = MIN(lastRow, rowCount); //- 1
    
    if(firstRow > 0)
    firstRow--;
    //remove no longer visable pages
    for(GPGridViewCell* cell in visibleGridItems)
    {
        if (cell.rowIndex < firstRow || cell.rowIndex > lastRow || cell.columnIndex > columnCount) 
        {
            [recycledGridItems addObject:cell];
            [cell.layer removeAnimationForKey:@"wobble"];
            [cell removeFromSuperview];
        }
    }
    [visibleGridItems minusSet:recycledGridItems];
    
    // add missing pages
    for (int i = firstRow; i <= lastRow; i++) 
    {
        for(int k = 0; k < columnCount; k++)
        {
            
            if(![self isDisplayColumnForIndex:k forRow:i])
            {
                int index = [self getIndex:k forRow:i];
                if(index < columnCount*rowCount)
                {
                    GPGridViewCell* cell = [self.dataSource gridView:self viewAtIndex:index];
                    if(cell)
                    {
                        [self configureCell:cell column:k row:i isRotate:rotate];
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
        if ([cell.identifier isEqualToString:identifier] && ![self isDisplayColumnForIndex:cell.columnIndex forRow:cell.rowIndex]) 
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
-(void)configureCell:(GPGridViewCell*)cell column:(NSInteger)col row:(NSInteger)row isRotate:(BOOL)rotate
{
    cell.rowIndex = row;
    cell.columnIndex = col;
    cell.delegate = self;
    cell.backgroundColor = [UIColor clearColor]; //grayColor
    cell.frame = [self cellFrameFor:col atRow:row isRotate:rotate];
    if(isEditing)
        [self wiggleAnimation:cell];
    //else
    //    [cell.layer removeAnimationForKey:@"wobble"];
    //cell.imageView.frame = CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height);
    //[cell setNeedsLayout];

    
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(GPGridViewCell*)findCell:(NSInteger)column row:(NSInteger)row
{
    for(GPGridViewCell* cell in visibleGridItems)
    {
        if(column == cell.columnIndex && row == cell.rowIndex)
            return cell;
    }
    return nil;
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
-(CGRect)cellFrameFor:(NSInteger)col atRow:(NSInteger)row isRotate:(BOOL)rotate
{
    int width = 0;
    if(rotate)
    {
        UIInterfaceOrientation o = (UIInterfaceOrientation)[[UIApplication sharedApplication] statusBarOrientation];
        if(o == UIInterfaceOrientationLandscapeLeft || o == UIInterfaceOrientationLandscapeRight)
            width = originalFrame.size.width/columnCount;
        else
        {
            width = originalFrame.size.height/columnCount;
            width+= 5;
        }
    }
    else
        width = self.frame.size.width/columnCount;
    int leftpad = 30;
    int toppad = 20;
    if([self.dataSource respondsToSelector:@selector(spacingBetweenColumnsInGridView:)])
        leftpad = [self.dataSource spacingBetweenColumnsInGridView:self];
    if([self.dataSource respondsToSelector:@selector(spacingBetweenRowsInGridView:)])
        toppad = [self.dataSource spacingBetweenRowsInGridView:self];

    width -= leftpad + (leftpad/columnCount);
    int left = col*width;
    int top = row*rowHeight;
    left += leftpad*(col+1);
    top += toppad*(row+1);

    if(self.gridViewHeader)
        top += self.gridViewHeader.frame.size.height + 5;
    
    return CGRectMake(left, top, width, rowHeight);
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
-(void)gridCellWasSelected:(GPGridViewCell*)gridCell
{
    if([self.delegate respondsToSelector:@selector(gridViewDidSelectItem:item:index:)])
        [self.delegate gridViewDidSelectItem:self item:gridCell index:[self getIndex:gridCell.columnIndex forRow:gridCell.rowIndex]];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)gridTextLabelWasSelected:(UIButton*)button cell:(GPGridViewCell*)cell
{
    if([self.delegate respondsToSelector:@selector(gridViewDidSelectLabel:item:index:)])
        [self.delegate gridViewDidSelectLabel:self item:cell index:[self getIndex:cell.columnIndex forRow:cell.rowIndex]];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)reloadCellsAtIndexes:(NSArray*)array
{
    for(NSNumber* index in array)
    {
        GPGridViewCell* cell = [self findCellAtIndex:index.intValue];
        if(cell)
        {
            [cell removeFromSuperview];
            [visibleGridItems removeObject:cell];
            GPGridViewCell* newcell = [self.dataSource gridView:self viewAtIndex:index.intValue];
            int col = 0;
            int row = 0;
            [self convertIndexToGrid:index.integerValue col:&col row:&row];
            [self configureCell:newcell column:col row:row isRotate:NO];
            [self addSubview:newcell];
            [visibleGridItems addObject:newcell];
        }
        
    }

}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)editMode:(BOOL)state
{
    isEditing = state;
    if(state)
    {
        for(GPGridViewCell* cell in visibleGridItems)
            [self wiggleAnimation:cell];
    }
    else
    {
        for(GPGridViewCell* cell in visibleGridItems)
            [cell.layer removeAnimationForKey:@"wobble"];//cell.transform = CGAffineTransformIdentity;
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)wiggleAnimation:(UIView*)view
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
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//helper function for adding and deleting grid items
-(void)rowModify:(NSInteger)check new:(NSInteger)nIndex frame:(BOOL)f
{
    GPGridViewCell* cell = [self findCellAtIndex:check];
    int col = 0;
    int row = 0;
    [self convertIndexToGrid:nIndex col:&col row:&row];
    if(f)
        cell.frame = [self cellFrameFor:col atRow:row isRotate:NO];
    else
    {
        cell.rowIndex = row;
        cell.columnIndex = col;
        cell.delegate = self;
        cell.backgroundColor = [UIColor clearColor];
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//animated add to grid view, make sure you datasource stays inline as well
-(void)addItemAtIndex:(NSInteger)index
{
    int total = rowCount*columnCount;
    [UIView animateWithDuration:0.2 animations:^{
        for(int i = index; i <= total; i++)
            [self rowModify:i new:i+1 frame:YES];
        
        GPGridViewCell* cell = [self.dataSource gridView:self viewAtIndex:index];
        if(cell)
        {
            int col = 0;
            int row = 0;
            [self convertIndexToGrid:index col:&col row:&row];
            [self configureCell:cell column:col row:row isRotate:NO];
            [self addSubview:cell];
            [visibleGridItems addObject:cell];
            
        }
    }completion:^(BOOL finished){
        
        for(int i = index-1; i <= total; i++)
            [self rowModify:i new:i+1 frame:NO];
    }];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//remove an item from the grid view. make sure you datasource stays inline as well
-(void)removeItemAtIndex:(NSInteger)index
{
    int total = rowCount*columnCount;
    [UIView animateWithDuration:0.2 animations:^{
        
        GPGridViewCell* cell = [self findCellAtIndex:index];
        if(cell)
        {
            [cell removeFromSuperview];
            [visibleGridItems removeObject:cell];
        }
        for(int i = index; i <= total; i++)
            [self rowModify:i+1 new:i frame:YES];
    }completion:^(BOOL finished){
        
        for(int i = index; i <= total; i++)
            [self rowModify:i+1 new:i frame:NO];
        rowCount = [self.dataSource numberOfRowsInGridView:self];
    }];
    NSLog(@"subviews: %@",self.subviews);
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(GPGridViewCell*)cellAtIndex:(NSInteger)index
{
    return [self.dataSource gridView:self viewAtIndex:index];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setGridViewHeader:(UIView *)header
{
    [gridViewHeader removeFromSuperview];
    [gridViewHeader release];
    gridViewHeader = [header retain];
    CGRect frame = gridViewHeader.frame;
    frame.origin.y = 10;
    gridViewHeader.frame = frame;
    [self addSubview:gridViewHeader];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)dealloc
{
    self.delegate = nil;
    self.dataSource = nil;
    [gridViewHeader release];
    [recycledGridItems release];
    [visibleGridItems release];
    [super dealloc];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@end
