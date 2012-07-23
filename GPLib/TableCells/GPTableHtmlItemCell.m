//
//  GPTableHtmlItemCell.m
//  GPLib
//
//  Created by Dalton Cherry on 12/13/11.
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

#import "GPTableHtmlItemCell.h"
#import "GPNavigator.h"

@implementation GPTableHtmlItemCell

///////////////////////////////////////////////////////////////////////////////////////////////////
+ (CGFloat)tableView:(UITableView*)tableView rowHeightForObject:(id)object 
{
    GPTableHTMLItem* item = (GPTableHTMLItem*)object;
    CGFloat maxWidth = tableView.frame.size.width - 20;
    //CGFloat size = [super tableView:tableView rowHeightForObject:object];
    HTMLTextLabel* view = [[[HTMLTextLabel alloc] initWithHTML:item.text embed:YES frame:CGRectMake(0, 0, maxWidth, 0)] autorelease];
    view.ExtendHeightToFit = YES;
    view.ignoreXAttachment = YES;
    //int pad = 0;
    //if(view.SuggestedHeight > 100)
      //  pad += 15;
    /*if(view.SuggestedHeight > size)
        return view.SuggestedHeight;
    return size + pad;*/
    return [view getTextHeight];
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
        [self.contentView addSubview:HTMLText];
        
    }
    return self;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)layoutSubviews
{
    [super layoutSubviews];
    self.textLabel.frame = CGRectZero;
    HTMLText.frame = CGRectMake(TableCellSmallMargin,TableCellSmallMargin,self.contentView.frame.size.width - TableCellSmallMargin,
                                self.contentView.frame.size.height - TableCellSmallMargin);
}
//////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setObject:(id)object 
{
    [super setObject:object];
    GPTableHTMLItem* item = (GPTableHTMLItem*)object;
    [currentHTMLItem release];
    currentHTMLItem = [item retain];
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
-(void)imageFinished:(NSString *)url height:(int)height width:(int)width
{
    if([currentHTMLItem.delegate respondsToSelector:@selector(imageFinished:height:width:)])
        [currentHTMLItem.delegate imageFinished:url height:height width:width];
}
//////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc 
{
    [currentHTMLItem release];
    [HTMLText release];
    [super dealloc];
}


@end
