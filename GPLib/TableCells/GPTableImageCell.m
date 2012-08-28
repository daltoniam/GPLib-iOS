//
//  GPTableImageCell.m
//  GPLib
//
//  Created by Dalton Cherry on 12/7/11.
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

#import "GPTableImageCell.h"
#import <QuartzCore/QuartzCore.h>

#import "HTMLColors.h"

@implementation GPTableImageCell

CGFloat TableCellDefaultImageSize = 50;


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (CGFloat)tableView:(UITableView*)tableView rowHeightForObject:(id)object 
{
    GPTableImageItem* item = object;
    CGSize imageBounds;
    if(item.imageSize.height)
        imageBounds = item.imageSize;
    else
        imageBounds = CGSizeMake(TableCellDefaultImageSize, TableCellDefaultImageSize);
    
    CGSize imageSize = CGSizeMake(imageBounds.width+TableCellSmallMargin, imageBounds.height+(TableCellSmallMargin*2));
    CGFloat width = tableView.frame.size.width - imageSize.width;
    UIFont* font = nil;
    if(item.font)
        font = item.font;
    else
        font = [UIFont systemFontOfSize:17];
    CGSize textSize = [item.text sizeWithFont:font
                            constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)  
                                lineBreakMode:UILineBreakModeWordWrap];
    if(textSize.height < 44 && imageSize.height < 44)
        return 44;
    if(textSize.height > imageSize.height)
        return textSize.height+5;
    return imageSize.height;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) 
    {
        defaultSize = CGSizeMake(TableCellDefaultImageSize, TableCellDefaultImageSize);
        imageView =[[GPImageView alloc] init];
        imageView.delegate = self;
        //CALayer * l = [imageView layer];
        //[l setMasksToBounds:YES];
        //[l setCornerRadius:10.0];
        //[l setBorderWidth:0.2];
        //[l setBorderColor:[UIColor lightGrayColor].CGColor];
        [self.contentView addSubview:imageView];
    }
    return self;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)prepareForReuse
{
    [super prepareForReuse];
    //imageView.image = nil;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)layoutSubviews
{
    [super layoutSubviews];
    if(imageView.URL || imageView.image)
    {    
        int top = self.contentView.frame.size.height - imageBounds.height;
        top = top/2;
        if(top < TableCellSmallMargin || topJustify)
            top = TableCellSmallMargin;
        imageView.frame = CGRectMake(TableCellSmallMargin, top, imageBounds.width, imageBounds.height);
        CGRect frame = self.textLabel.frame;
        frame.origin.x += TableCellSmallMargin + imageBounds.width;
        if(infoLabel.text)
        {
            int width = frame.origin.x + frame.size.width;
            if(width > self.frame.size.width)
                frame.size.width -= TableCellSmallMargin + imageBounds.width;
        }
        else
            frame.size.width -= TableCellSmallMargin + imageBounds.width;
        self.textLabel.frame = frame;
    }
    else
    {
        imageView.frame = CGRectZero;
        CGRect frame = self.textLabel.frame;
        frame.origin.x = TableCellSmallMargin;
        frame.size.width = self.contentView.frame.size.width - TableCellSmallMargin*2;
        frame.origin.y = TableCellSmallMargin*2;
        self.textLabel.frame = frame;
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setImageView:(UIImage*)image
{
    imageView.image = image;
}
//////////////////////////////////////////////////////////////////////////////////////////////////
-(NSString*)imageURL
{
    return imageView.URL;
}
//////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setObject:(id)object 
{
    [super setObject:object];
    GPTableImageItem* item = object;
    [currentObject release];
    currentObject = [object retain];
    
    imageView.URL = item.ImageURL;
    if(item.imageData)
        imageView.image = item.imageData;
    else
        imageView.image = item.DefaultImage;
    /*if(!item.imageData)
    {
        [imageView stopImage];
        [imageView fetchImage]; //these are cached so no worries on making a bunch of network request.
    }
    else
        imageView.image = item.imageData;*/
    
    imageView.layer.cornerRadius = item.imageRounding;
    if(item.imageRounding <= 0) 
    {
        imageView.layer.cornerRadius = 0;
        imageView.layer.masksToBounds = NO;
    }
    else
        imageView.layer.masksToBounds = YES;
    
    if(item.imageSize.height)
        imageBounds = item.imageSize;
    else
        imageBounds = defaultSize;
    
    if(item.contentMode)
        imageView.contentMode = item.contentMode;
    if(item.imageBorderWidth && item.imageBorderColor)
    {
        imageView.layer.borderWidth = item.imageBorderWidth;
        imageView.borderColor = item.imageBorderColor;
        imageView.borderWidth = item.imageBorderWidth;
    }
    
    topJustify = item.topJustifyImage;
}
//////////////////////////////////////////////////////////////////////////////////////////////////
/*-(void)imageDidFinish:(GPImageView*)view
{
    if([view.URL isEqualToString:currentObject.ImageURL])
        currentObject.imageData = [view.image retain];
        
}*/
//////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc 
{
    [currentObject release];
    [imageView stopImage];
    imageView.delegate = nil;
    [imageView release];
    [super dealloc];
}
//////////////////////////////////////////////////////////////////////////////////////////////////
@end
