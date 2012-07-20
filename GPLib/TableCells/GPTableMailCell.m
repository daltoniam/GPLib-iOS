//
//  GPTableMailCell.m
//  GPLib
//
//  Created by Dalton Cherry on 6/28/12.
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

#import "GPTableMailCell.h"
#import "GPTableMailItem.h"
#import <QuartzCore/QuartzCore.h>

@implementation GPTableMailCell

///////////////////////////////////////////////////////////////////////////////////////////////////
+ (CGFloat)tableView:(UITableView*)tableView rowHeightForObject:(id)object
{
    CGFloat maxWidth = tableView.frame.size.width - 80;
    CGFloat height = [super tableView:tableView rowHeightForObject:object];
    
    GPTableMailItem* item = (GPTableMailItem*)object;

    HTMLTextLabel* view = [[[HTMLTextLabel alloc] initWithHTML:item.title embed:YES frame:CGRectMake(0, 0, maxWidth, 0)] autorelease];
    view.ExtendHeightToFit = YES;
    height += [view getTextHeight];
    int imgHeight = 0;
    if(item.imageSize.height)
        imgHeight = item.imageSize.height;
    else
        imgHeight = TableCellDefaultImageSize;
    height += imgHeight - 10;
    return height;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) 
    {
        headerView = [[UIView alloc] init];
        headerView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:headerView];
        
        bodyView = [[UIView alloc] init];
        bodyView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:bodyView];
        
        
        [HTMLText removeFromSuperview];
        [bodyView addSubview:HTMLText];
        
        [imageView removeFromSuperview];
        [headerView addSubview:imageView];
        
        self.contentView.backgroundColor = [UIColor clearColor];
        self.contentView.layer.shadowColor = [UIColor blackColor].CGColor;
        self.contentView.layer.shadowOffset = CGSizeMake(0, 1);
        self.contentView.layer.shadowOpacity = 0.5;
        self.contentView.layer.shadowRadius = 7;
        
    }
    return self;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setupTitleLabel
{
    titleLabel = [[HTMLTextLabel alloc] init];
    titleLabel.delegate = self;
    titleLabel.extendHeightToFit = YES;
    [headerView addSubview:titleLabel];
    
    lineView = [[UIView alloc] init];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [headerView addSubview:lineView];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)layoutSubviews
{
    [super layoutSubviews];
    self.textLabel.frame = CGRectZero;
    CGRect fullFrame = self.contentView.frame;
    int offset = TableCellSmallMargin;
    if(GPIsPad())
        offset = TableCellSmallMargin*2;
    
    fullFrame.origin.x += offset;
    fullFrame.size.width -= offset*2;
     self.contentView.layer.shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(fullFrame.origin.x, fullFrame.size.height, fullFrame.size.width, 7)].CGPath;
    
    int start = 25;
    int top = start;
    int height = imageBounds.height+TableCellSmallMargin*2;
    if(!imageView.URL && !imageView.image)
        height = [titleLabel getTextHeight];
    
    headerView.frame = CGRectMake(offset, top, fullFrame.size.width, height);
    top += headerView.frame.size.height;
    bodyView.frame = CGRectMake(offset, top, fullFrame.size.width, fullFrame.size.height-top);
    
    titleLabel.frame = CGRectMake(TableCellSmallMargin, TableCellSmallMargin, headerView.frame.size.width-(TableCellSmallMargin*2), headerView.frame.size.height-(TableCellSmallMargin+1));
    lineView.frame = CGRectMake(TableCellSmallMargin,top-(start+1),headerView.frame.size.width-(TableCellSmallMargin*2),1);
    
    if(imageView.URL || imageView.image)
    {
        imageView.frame = CGRectMake(TableCellSmallMargin, TableCellSmallMargin, imageBounds.width, imageBounds.height);
        CGRect frame = titleLabel.frame;
        frame.origin.x += imageBounds.width + TableCellSmallMargin;
        frame.size.width -= imageBounds.width;
        titleLabel.frame = frame;
        
        frame = HTMLText.frame;
        frame.origin.x -= imageBounds.width+TableCellSmallMargin;
        HTMLText.frame = frame;
    }
    
}
//////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setObject:(id)object 
{
    [super setObject:object];
    GPTableMailItem* item = (GPTableMailItem*)object;
    if(item.title)
    {
        if(!titleLabel)
            [self setupTitleLabel];
        [titleLabel setHTML:item.title embed:YES];
    }
    
    //imageView.layer.cornerRadius = 2;
    //imageView.layer.masksToBounds = YES;
    imageBounds = CGSizeMake(35, 35);
}
///////////////////////////////////////////////////////////////////////////////////////////////
-(void)dealloc
{
    [headerView release];
    [bodyView release];
    [titleLabel release];
    [lineView release];
    [super dealloc];
}
///////////////////////////////////////////////////////////////////////////////////////////////

@end
