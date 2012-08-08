//
//  GPTableMessageCell.m
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

#import "GPTableMessageCell.h"
#import "GPNavigator.h"

@implementation GPTableMessageCell

@synthesize delegate;
///////////////////////////////////////////////////////////////////////////////////////////////////
+ (CGFloat)tableView:(UITableView*)tableView rowHeightForObject:(id)object 
{
    GPTableMessageItem* item = (GPTableMessageItem*)object;
    CGFloat maxWidth = tableView.frame.size.width - 80;
    //CGFloat ImageSize = [super tableView:tableView rowHeightForObject:object];
    HTMLTextLabel* view = [[[HTMLTextLabel alloc] initWithHTML:item.text embed:YES frame:CGRectMake(0, 0, maxWidth, 0)] autorelease];
    view.ExtendHeightToFit = YES;
    view.ignoreXAttachment = YES;
    //NSLog(@"view text: %@",item.text);
    //NSLog(@"suggested height: %f",view.SuggestedHeight);
    //int pad = 25;
    //if(GPIsPad())
    //    pad = 15;
    int height = [view getTextHeight];
    int offset = TableCellDefaultImageSize + TableCellSmallMargin*2;
    if(height < offset)
        return offset;
    
    return height;
    
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) 
    {
        HTMLText = [[HTMLTextLabel alloc] init];
        HTMLText.delegate = self;
        HTMLText.ignoreXAttachment = YES;
        HTMLText.autoSizeImages = YES;
        HTMLText.userInteractionEnabled = YES;
        [self.contentView addSubview:HTMLText];
        
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
    HTMLText.frame = CGRectMake(left, top, self.contentView.frame.size.width - left - TableCellSmallMargin, self.contentView.frame.size.height - TableCellSmallMargin*2);
}
//////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setObject:(id)object 
{
    [super setObject:object];
    GPTableMessageItem* item = (GPTableMessageItem*)object;
    self.textLabel.text = nil;
    if(item.text)
        [HTMLText setHTML:item.text embed:YES];
    
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//touched a link
- (void)didSelectLink:(NSString*)link
{
    [[GPNavigator navigator] openURL:link];//NSLog(@"boom headshot!!!!");
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//touched an image
- (void)didSelectImage:(NSString*)imageURL
{
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)imageFinished:(NSString *)url height:(int)height width:(int)width
{
    if([self.delegate respondsToSelector:@selector(imageFinished:height:width:)])
        [self.delegate imageFinished:url height:height width:width];
}
//////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc 
{
    [HTMLText release];
    [super dealloc];
}

@end
