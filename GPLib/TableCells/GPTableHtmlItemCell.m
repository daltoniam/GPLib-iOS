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

@synthesize delegate;
///////////////////////////////////////////////////////////////////////////////////////////////////
+ (CGFloat)tableView:(UITableView*)tableView rowHeightForObject:(id)object 
{
    GPTableHTMLItem* item = (GPTableHTMLItem*)object;
    //if(item.rowHeight) //we cache rowHeight for preformance reasons
    //    return item.rowHeight;
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
    
    if(infoLabel)
    {
        CGRect frame = HTMLText.frame;
        CGSize textSize = [infoLabel.text sizeWithFont:infoLabel.font constrainedToSize:CGSizeMake(frame.size.width, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
        if(textSize.width > self.contentView.frame.size.width/2)
            textSize.width = self.contentView.frame.size.width/2;
        frame.size.width -= textSize.width+TableCellSmallMargin;
        HTMLText.frame = frame;
        
        int left = frame.origin.x + frame.size.width + TableCellSmallMargin;
        infoLabel.frame = CGRectMake(left, 1, textSize.width, frame.size.height);
    }
    else if(notificationLabel) //you can only have info or notification, not both
    {
        if(!notificationLabel.text)
            notificationLabel.frame = CGRectZero;
        else
        {
            CGRect frame = HTMLText.frame;
            int height = 20;
            //int width = 35;
            int width = self.contentView.frame.size.width - (TableCellSmallMargin*2);
            CGSize infoSize = [notificationLabel.text sizeWithFont:notificationLabel.font constrainedToSize:CGSizeMake(width, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
            infoSize.width += 12;
            if(infoSize.width < 35)
                infoSize.width = 35;
            frame.size.width -= infoSize.width;
            HTMLText.frame = frame;
            notificationLabel.frame = CGRectMake(frame.size.width, (frame.size.height/2)-(height/2)-1, infoSize.width, height); //TableCellSmallMargin*2
        }
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setObject:(id)object 
{
    [super setObject:object];
    GPTableHTMLItem* item = (GPTableHTMLItem*)object;
    if(item.cachedAttribString && item.cachedFramesetter) //if you are smart, you will calculate and cache this in your model.
        [HTMLText setAttributedString:item.cachedAttribString height:item.rowHeight frame:item.cachedFramesetter];
    else if(item.text)
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
