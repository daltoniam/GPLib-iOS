//
//  GPTableSwitchCell.m
//  GPLib
//
//  Created by Austin Cherry on 5/28/12.
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

#import "GPTableSwitchCell.h"

@implementation GPTableSwitchCell


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
        switchControl = [[UISwitch alloc] init];
        [switchControl addTarget:self action:@selector(didSwitch:) forControlEvents:UIControlEventValueChanged];
        [self.contentView addSubview:switchControl];
    }
    return self;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)layoutSubviews
{
    [super layoutSubviews];
    CGRect frame =  self.textLabel.frame;
    frame.size.width -= switchControl.frame.size.width;
    self.textLabel.frame = frame;
    frame = switchControl.frame;
    frame.origin.y = (self.contentView.frame.size.height/2) - (switchControl.frame.size.height/2);
    frame.origin.x = self.contentView.frame.size.width - (switchControl.frame.size.width + TableCellSmallMargin);
    switchControl.frame = frame;
}
//////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setObject:(id)object 
{
    [super setObject:object];
    GPTableSwitchItem* item = object;
    switchControl.on = item.isOn;
    tableObject = item;
    switchControl.enabled = !item.disabled;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)didSwitch:(UISwitch*)sender
{
    tableObject.isOn = sender.on;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)dealloc
{
    [switchControl release];
    [super dealloc];
}
///////////////////////////////////////////////////////////////////////////////////////////////////

@end
