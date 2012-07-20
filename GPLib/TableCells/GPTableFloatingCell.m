//
//  GPTableFloatingCell.m
//  GPLib
//
//  Created by Dalton Cherry on 5/17/12.
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

#import "GPTableFloatingCell.h"
#import "GPTableFloatingItem.h"
#import <QuartzCore/QuartzCore.h>

@implementation GPTableFloatingCell

///////////////////////////////////////////////////////////////////////////////////////////////////
+ (CGFloat)tableView:(UITableView*)tableView rowHeightForObject:(id)object
{
    CGFloat height = [super tableView:tableView rowHeightForObject:object];
    
    GPTableFloatingItem* item = (GPTableFloatingItem*)object;
    int attach = 0;
    if(item.attachmentsURLs)
        attach = 210;
    
    int header = 65;
    return height + header + attach;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) 
    {
        headerView = [[UIView alloc] init];
        headerView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.5];
        [self.contentView addSubview:headerView];
        
        bodyView = [[GPView alloc] init];
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
        //NSLog(@"height: %f",self.contentView.frame.size.height);
        
    }
    return self;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setupTitleLabel
{
    titleLabel = [[GPLabel alloc] init];
    titleLabel.textShadowColor = [UIColor blackColor];
    titleLabel.textShadowBlur = 8;
    titleLabel.textShadowOffset = CGSizeMake(1, 4);
    titleLabel.font = [UIFont systemFontOfSize:18];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    [headerView addSubview:titleLabel];
}
//////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setupAttachmentView
{
    attachmentView = [[GPAttachmentView alloc] init];
    attachmentView.delegate = self;
    attachmentView.isGridStyle = GPIsPad();
    [bodyView addSubview:attachmentView];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)layoutSubviews
{
    [super layoutSubviews];
    self.contentView.layer.shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, self.contentView.frame.size.height, self.contentView.frame.size.width, 7)].CGPath;
    self.textLabel.frame = CGRectZero;
    CGRect fullFrame = self.contentView.frame;
    if(GPIsPad())
    {
        fullFrame.origin.x += TableCellSmallMargin*2;
        fullFrame.size.width -= TableCellSmallMargin*4;
    }
    self.contentView.layer.shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(fullFrame.origin.x, fullFrame.size.height, fullFrame.size.width, 7)].CGPath;
    int offset = 0;
    if(GPIsPad())
        offset += TableCellSmallMargin*2;
    
    int top = 25;
    headerView.frame = CGRectMake(offset, top, fullFrame.size.width, 40);
    top += headerView.frame.size.height;
    bodyView.frame = CGRectMake(offset, top, fullFrame.size.width, fullFrame.size.height-top);
    
    titleLabel.frame = CGRectMake(TableCellSmallMargin, 0, headerView.frame.size.width-(TableCellSmallMargin*2), headerView.frame.size.height);
    
    if(imageView.URL || imageView.image)
    {
        imageView.frame = CGRectMake(TableCellSmallMargin, -10, imageBounds.width, imageBounds.height);
        CGRect frame = titleLabel.frame;
        frame.origin.x += imageBounds.width + TableCellSmallMargin;
        frame.size.width -= imageBounds.width;
        titleLabel.frame = frame;
    }
    
    if(isAttach)
        attachmentView.frame = CGRectMake(0, 0, bodyView.frame.size.width, 200);
    else
        attachmentView.frame = CGRectZero;
    int left =TableCellSmallMargin*4;
    top = TableCellSmallMargin*2;
    if(isAttach)
        top += attachmentView.frame.size.height;
    int h = bodyView.frame.size.height - top;//bodyView.frame.size.height - TableCellSmallMargin;
    HTMLText.frame = CGRectMake(left, top, bodyView.frame.size.width - (left*2), h);
    top += HTMLText.frame.size.height + 10;
    
}
//////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setObject:(id)object 
{
    [super setObject:object];
    GPTableFloatingItem* item = (GPTableFloatingItem*)object;
    if(item.title)
    {
        if(!titleLabel)
            [self setupTitleLabel];
        titleLabel.text = item.title;
    }
    if(item.attachmentsURLs)
    {
        if(!attachmentView)
            [self setupAttachmentView];
        [attachmentView removeAllItems];
        for(NSString* url in item.attachmentsURLs)
            [attachmentView addAttachment:url text:nil];
        isAttach = YES;
    }
    else
    {
        [attachmentView removeAllItems];
        isAttach = NO;
    }
        
    imageView.layer.cornerRadius = 0;
    imageView.layer.masksToBounds = NO;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)didTapView:(GPAttachmentView*)view index:(int)index
{
    NSLog(@"view tapped! index: %d",index);
    //do what you want
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)dealloc
{
    [headerView release];
    [bodyView release];
    [titleLabel release];
    [attachmentView release];
    [super dealloc];
}
///////////////////////////////////////////////////////////////////////////////////////////////////


@end
