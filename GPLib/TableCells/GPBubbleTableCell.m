//
//  GPBubbleTableCell.m
//  GPLib
//
//  Created by Dalton Cherry on 12/8/11.
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

#import "GPUtils.h"
#import "GPBubbleTableCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation GPBubbleTableCell

@synthesize delegate;
///////////////////////////////////////////////////////////////////////////////////////////////////
+ (CGFloat)tableView:(UITableView*)tableView rowHeightForObject:(id)object 
{
    GPTableBubbleItem* item = (GPTableBubbleItem*)object;
    if(item.rowHeight) //we cache rowHeight for preformance reasons
        return item.rowHeight;
    CGFloat maxWidth = tableView.frame.size.width - 80;
    //CGFloat ImageSize = [super tableView:tableView rowHeightForObject:object];
    HTMLTextLabel* view = [[[HTMLTextLabel alloc] initWithHTML:item.text embed:YES frame:CGRectMake(0, 0, maxWidth, 0)] autorelease];
    view.ExtendHeightToFit = YES;
    view.ignoreXAttachment = YES;
    //NSLog(@"view text: %@",item.text);
    //NSLog(@"suggested height: %f",view.SuggestedHeight);
    int pad = 25;
    if(GPIsPad())
        pad = 15;
    return [view getTextHeight] + pad;
    
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) 
    {
        BubbleView = [[GPBubbleView alloc] init];
        BubbleView.BorderColor = [UIColor colorWithCSS:@"#CECECE"];
        /*BubbleView.layer.shadowColor = [UIColor blackColor].CGColor;
        BubbleView.layer.shadowOffset = CGSizeMake(0, 1);
        BubbleView.layer.shadowOpacity = 0.5;
        BubbleView.layer.shadowRadius = 1.0;*/
        BubbleView.layer.shadowColor = [UIColor blackColor].CGColor;
        BubbleView.layer.shadowOffset = CGSizeMake(0, 1);
        BubbleView.layer.shadowOpacity = 0.3;
        BubbleView.layer.shadowRadius = 1;
        [self.contentView addSubview:BubbleView];
        //self.contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tbbackground.jpg"]];//[UIColor colorWithRed:238 green:238 blue:238 alpha:1];
        HTMLText = [[HTMLTextLabel alloc] init];
        HTMLText.delegate = self;
        HTMLText.ignoreXAttachment = YES;
        HTMLText.autoSizeImages = YES;
        [BubbleView addSubview:HTMLText];
        
    }
    return self;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)layoutSubviews
{
    [super layoutSubviews];
    self.textLabel.frame = CGRectZero;
    int left = imageView.frame.origin.x + imageView.frame.size.width + TableCellSmallMargin;
    int top = TableCellSmallMargin;
    BubbleView.frame = CGRectMake(left, top, self.contentView.frame.size.width - left - TableCellSmallMargin, self.contentView.frame.size.height - TableCellSmallMargin*2);
    [self bubbleShadow];
    int offset = TableCellSmallMargin*3;
    HTMLText.frame = CGRectMake(offset,top,
                                BubbleView.frame.size.width - (offset + TableCellSmallMargin),BubbleView.frame.size.height - TableCellSmallMargin*2);
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)bubbleShadow
{
    BubbleView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(BubbleView.TriangleSize.height,0, 
                                                                                     BubbleView.frame.size.width-(BubbleView.TriangleSize.height), BubbleView.frame.size.height+1) 
                                                             cornerRadius:BubbleView.BorderRadius].CGPath;
}
//////////////////////////////////////////////////////////////////////////////////////////////////
-(void)prepareForReuse
{
    [super prepareForReuse];
    [BubbleView setNeedsDisplay];
}
//////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setObject:(id)object 
{
    [super setObject:object];
    GPTableBubbleItem* item = (GPTableBubbleItem*)object;
    self.textLabel.text = nil;
    if(item.cachedAttribString && item.cachedFramesetter) //if you are smart, you will calculate and cache this in your model.
        [HTMLText setAttributedString:item.cachedAttribString height:item.rowHeight frame:item.cachedFramesetter];
    else if(item.text)
        [HTMLText setHTML:item.text embed:YES];
    
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)imageFinished:(NSString *)url height:(int)height width:(int)width
{
    if([self.delegate respondsToSelector:@selector(imageFinished:height:width:)])
        [self.delegate imageFinished:url height:height width:width];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//touched a link
- (void)didSelectLink:(NSString*)link
{
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//touched an image
- (void)didSelectImage:(NSString*)imageURL
{
}
//////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc 
{
    [BubbleView release];
    [HTMLText release];
    [super dealloc];
}
@end
