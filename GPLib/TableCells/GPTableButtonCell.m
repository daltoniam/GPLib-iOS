//
//  GPTableButtonCell.m
//  GPLib
//
//  Created by Austin Cherry on 10/11/12.
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

#import "GPTableButtonCell.h"

@implementation GPTableButtonCell

///////////////////////////////////////////////////////////////////////////////////////////////////
+ (CGFloat)tableView:(UITableView*)tableView rowHeightForObject:(id)object
{
    GPTableTextItem* item = object;
    CGFloat width = tableView.frame.size.width - (TableCellSmallMargin+125); //only change is the padding for the switch
    UIFont* font = nil;
    if(item.font)
        font = item.font;
    else
        font = [UIFont systemFontOfSize:17];
    CGSize textSize = [item.text sizeWithFont:font
                            constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
                                lineBreakMode:UILineBreakModeWordWrap];
    
    if(textSize.height > 40)
        return textSize.height + 14;
    return 44;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        buttonControl = [GPButton defaultButton:CGRectMake(0, 0, 60, 30)];
        //[buttonControl addTarget:self action:@selector(didSwitch:) forControlEvents:UIControlEventValueChanged];
        [self.contentView addSubview:buttonControl];
    }
    return self;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)layoutSubviews
{
    [super layoutSubviews];
    CGRect frame =  self.textLabel.frame;
    frame.size.width -= buttonControl.frame.size.width;
    self.textLabel.frame = frame;
    frame = buttonControl.frame;
    frame.origin.y = (self.contentView.frame.size.height/2) - (buttonControl.frame.size.height/2);
    frame.origin.x = self.contentView.frame.size.width - (buttonControl.frame.size.width + TableCellSmallMargin);
    buttonControl.frame = frame;
}
//////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setObject:(id)object
{
    [super setObject:object];
    GPTableButtonItem* item = object;
    tableObject = item;
    buttonControl.enabled = !item.disabled;
    if(!item.button)
        buttonControl = item.button;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)dealloc
{
    [buttonControl release];
    [super dealloc];
}
///////////////////////////////////////////////////////////////////////////////////////////////////

@end
