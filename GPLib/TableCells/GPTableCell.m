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
    [self.contentView addSubview:infoLabel];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setupBadgeLabel
{
    notificationLabel = [[GPPillLabel alloc] init];
    [notificationLabel setLineBreakMode:UILineBreakModeCharacterWrap];
    [self.contentView addSubview:notificationLabel];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)layoutSubviews
{
    [super layoutSubviews];
    if(infoLabel)
    {
        CGRect frame = self.textLabel.frame;
        CGSize textSize = [self.textLabel.text sizeWithFont:self.textLabel.font constrainedToSize:CGSizeMake(frame.size.width, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
        int width = frame.size.width - textSize.width;
        frame.size.width = textSize.width;
        self.textLabel.frame = frame;
        
        int left = frame.origin.x + textSize.width + TableCellSmallMargin;
        infoLabel.frame = CGRectMake(left, frame.origin.y-1, width, frame.size.height);
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
    }
    if(item.color)
        self.textLabel.textColor = item.color;
    self.textLabel.textAlignment = item.TextAlignment;
    if(item.font)
        self.textLabel.font = item.font;
    else
        self.textLabel.font = [UIFont boldSystemFontOfSize:17];
    if(item.isChecked)
        self.accessoryType = UITableViewCellAccessoryCheckmark;
    else
        self.accessoryType = UITableViewCellAccessoryNone;
    if(item.NavURL)
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    else
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    if(item.Properties)
        Properties = [item.Properties retain];
    if(item.backgroundColor)
    {
        self.backgroundColor = item.backgroundColor;
        //self.contentView.backgroundColor = item.backgroundColor;
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
    }
    else
        notificationLabel.text = nil;
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
    notificationTextColor = nil;
    notificationHighlightTextColor = nil;
    [Properties release];
    [infoLabel release];
    [super dealloc];
}

@end
