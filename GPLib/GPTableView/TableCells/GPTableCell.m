//
//  GPTableCell.m
//  GPLib
//
//  Created by Dalton Cherry on 12/6/11.
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

#import "GPTableCell.h"
#import "GPTableTextItem.h"

@implementation GPTableCell

const CGFloat TableCellSmallMargin = 6;
//const CGFloat   kTableCellSpacing     = 8;
//const CGFloat   kTableCellMargin      = 10;
//const CGFloat   kTableCellHPadding    = 10;
//const CGFloat   kTableCellVPadding    = 10;

@synthesize notificationTextColor,notificationHighlightTextColor,notificationLabel = notificationLabel,infoLabel = infoLabel;
///////////////////////////////////////////////////////////////////////////////////////////////////
+ (CGFloat)tableView:(UITableView*)tableView rowHeightForObject:(id)object 
{
    GPTableTextItem* item = object;
    CGFloat width = tableView.frame.size.width - (TableCellSmallMargin+25);
    UIFont* font = nil;
    if(item.font)
        font = item.font;
    else
        font = [UIFont systemFontOfSize:17];
    CGSize textSize = [item.text sizeWithFont:font
                            constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)  
                                lineBreakMode:UILineBreakModeWordWrap];
    
    CGSize infoSize = [item.infoText sizeWithFont:font constrainedToSize:CGSizeMake(width-textSize.width, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
    
    int height = textSize.height;
    if(infoSize.height > height)
        height = infoSize.height;

    if(height > 40)
        return height + 14;
    return 44;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        //self.textLabel.numberOfLines = 0;
        self.notificationHighlightTextColor = [UIColor colorWithRed:3/255.0f green:124/255.0f blue:241/255.0f alpha:1];
    }
    return self;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setupInfoLabel
{
    infoLabel = [[UILabel alloc] init];
    infoLabel.textColor = [UIColor colorWithRed:56/255.0 green:84/255.0 blue:135/255.0 alpha:1];
    infoLabel.font = [UIFont systemFontOfSize:17];
    infoLabel.textAlignment = UITextAlignmentRight;
    infoLabel.backgroundColor = [UIColor clearColor];
    infoLabel.numberOfLines = 0;
    //[self.contentView addSubview:infoLabel];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setupBadgeLabel
{
    notificationLabel = [[GPPillLabel alloc] init];
    [notificationLabel setLineBreakMode:UILineBreakModeCharacterWrap];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)layoutSubviews
{
    [super layoutSubviews];
    if(customGroup)
    {
        CGRect frame = self.contentView.frame;
        frame.origin.x = 8;
        frame.size.width -= 16;
        self.contentView.frame = frame;
    }
    if(infoLabel)
    {
        CGRect frame = self.textLabel.frame;
        CGSize textSize = [self.textLabel.text sizeWithFont:self.textLabel.font constrainedToSize:CGSizeMake(frame.size.width, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
        CGSize infoSize = [self.infoLabel.text sizeWithFont:self.infoLabel.font constrainedToSize:CGSizeMake(frame.size.width, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
        int half = [self infoLabelSpace:frame]/2;
        if(textSize.width > half || infoSize.width > half)
        {
            int offset = half;
            if(textSize.width > half)
                textSize = [self.textLabel.text sizeWithFont:self.textLabel.font constrainedToSize:CGSizeMake(half, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
            else
                offset += half - textSize.width;
            infoSize = [self.infoLabel.text sizeWithFont:self.infoLabel.font constrainedToSize:CGSizeMake(offset, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
        }
        frame.size.width = textSize.width;
        self.textLabel.frame = frame;
        
        int left = (half*2) - (infoSize.width - (TableCellSmallMargin*2));
        infoLabel.frame = CGRectMake(left, frame.origin.y-1, infoSize.width, frame.size.height);
    }
    else if(notificationLabel) //you can only have info or notification, not both
    {
        if(!notificationLabel.text)
            notificationLabel.frame = CGRectZero;
        else
        {
            CGRect frame = self.textLabel.frame;
            int height = 20;
            //int width = 35;
            int width = self.contentView.frame.size.width - (TableCellSmallMargin*2);
            CGSize infoSize = [notificationLabel.text sizeWithFont:notificationLabel.font constrainedToSize:CGSizeMake(width, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
            infoSize.width += 12;
            if(infoSize.width < 35)
                infoSize.width = 35;
            frame.size.width -= infoSize.width;
            self.textLabel.frame = frame;
            notificationLabel.frame = CGRectMake(frame.size.width+ TableCellSmallMargin*2, (frame.size.height/2)-(height/2)-1, infoSize.width, height);
        }
    }
    bevelLine.frame = CGRectMake(0, 0.2, self.contentView.frame.size.width, 1);
    
}
//////////////////////////////////////////////////////////////////////////////////////////////////
-(int)infoLabelSpace:(CGRect)textFrame
{
    return textFrame.size.width;
}
//////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setObject:(id)object 
{
    GPTableTextItem* item = object;
    self.textLabel.text = item.text;
    if(item.infoText)
    {
        if(!infoLabel)
            [self setupInfoLabel];
        infoLabel.text = item.infoText;
        [self.contentView addSubview:infoLabel];
    }
    else
        [infoLabel removeFromSuperview];
    if(item.color)
        self.textLabel.textColor = item.color;
    self.textLabel.textAlignment = item.textAlignment;
    self.textLabel.font = item.font;
    if(item.navURL)
    {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [self setSelectionStyle:UITableViewCellSelectionStyleBlue];
    }
    else
    {
        self.accessoryType = UITableViewCellAccessoryNone;
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    if(item.isChecked)
        self.accessoryType = UITableViewCellAccessoryCheckmark;

    if(item.properties)
        Properties = [item.properties retain];
    if(item.backgroundColor)
    {
        self.backgroundColor = item.backgroundColor;
        self.accessoryView.backgroundColor = item.backgroundColor;
        if(!item.isGrouped)
            self.contentView.backgroundColor = item.backgroundColor;
    }
    if(item.notificationText)
    {
        if(!notificationLabel)
            [self setupBadgeLabel];
        NSString* text = item.notificationText;
        //if(text.length > 3)
        //text = [NSString stringWithFormat:@"99+"];
        notificationLabel.text = text;
        if(item.notificationTextColor)
        {
            self.notificationTextColor = item.notificationTextColor;
            notificationLabel.textColor = item.notificationTextColor;
        }
        if(item.notificationFillColor)
            notificationLabel.fillColor = item.notificationFillColor;
        [self.contentView addSubview:notificationLabel];
    }
    else
    {
        notificationLabel.text = nil;
        [notificationLabel removeFromSuperview];
    }
    if(item.bevelLineColor)
    {
        if(!bevelLine)
            bevelLine = [[UIView alloc] init];
        bevelLine.backgroundColor = item.bevelLineColor;
        [self.contentView addSubview:bevelLine];
    }
    else
        [bevelLine removeFromSuperview];
}
//////////////////////////////////////////////////////////////////////////////////////////////////
//experimental feature
-(void)isCustomGroup:(BOOL)custom
{
    customGroup = custom;
}
//////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    notificationLabel.isHighlighted = highlighted;
    if(highlighted)
        notificationLabel.textColor = self.notificationHighlightTextColor;
    else if(notificationTextColor)
        notificationLabel.textColor = self.notificationTextColor;
    else
    {
        notificationTextColor = [[UIColor whiteColor] retain];
        notificationLabel.textColor = notificationTextColor;
    }

    
    [notificationLabel setNeedsDisplay];
}
//////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}
//////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setAutoSize:(BOOL)size
{
    if(size)
        self.textLabel.numberOfLines = 0;
}
//////////////////////////////////////////////////////////////////////////////////////////////////
-(void)dealloc
{
    [bevelLine release];
    notificationTextColor = nil;
    notificationHighlightTextColor = nil;
    [Properties release];
    [infoLabel release];
    [super dealloc];
}

@end
