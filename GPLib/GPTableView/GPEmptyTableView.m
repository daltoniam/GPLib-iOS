//
//  GPEmptyTableView.m
//  GPLib
//
//  Created by Dalton Cherry on 5/2/12.
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

#import "GPEmptyTableView.h"

@implementation GPEmptyTableView

@synthesize mainText,subText,image;
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        self.backgroundColor = [UIColor whiteColor];
        mainTextLabel = [[UILabel alloc] init];
        mainTextLabel.autoresizingMask =  UIViewAutoresizingFlexibleWidth;
        mainTextLabel.textAlignment = UITextAlignmentCenter;
        mainTextLabel.text = @"";
        mainTextLabel.textColor = [UIColor colorWithWhite:0.3 alpha:1];
        mainTextLabel.shadowColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
        mainTextLabel.font = [UIFont boldSystemFontOfSize:18];
        mainTextLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
        mainTextLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:mainTextLabel];
        
    }
    return self;
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setMainText:(NSString*)text
{
    mainTextLabel.text = text;
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setSubText:(NSString*)text
{
    if(text)
    {
        if(!subTextLabel)
        {
            subTextLabel = [[UILabel alloc] init];
            subTextLabel.autoresizingMask =  UIViewAutoresizingFlexibleWidth;
            subTextLabel.textAlignment = UITextAlignmentCenter;
            subTextLabel.textColor = [UIColor lightGrayColor];
            subTextLabel.shadowColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
            subTextLabel.font = [UIFont systemFontOfSize:14];
            subTextLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
            subTextLabel.numberOfLines = 2;
            subTextLabel.backgroundColor = [UIColor clearColor];
            [self addSubview:subTextLabel];
        }
        subTextLabel.text = text;
    }
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setImage:(UIImage*)img
{
    if(img)
    {
        if(!imageView)
        {
            imageView = [[UIImageView alloc] init];
            imageView.autoresizingMask =  UIViewAutoresizingFlexibleWidth;
            imageView.contentMode = UIViewContentModeCenter;
            [self addSubview:imageView];
        }
        imageView.image = img;
    }
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)layoutSubviews
{
    [super layoutSubviews];
    int top = self.frame.size.height/4;
    if(imageView)
    {
        imageView.frame = CGRectMake(0, top, self.frame.size.width, 100);
        top += imageView.frame.size.height;
    }
    mainTextLabel.frame = CGRectMake(0, top, self.frame.size.width, 25);
    top += mainTextLabel.frame.size.height;
    if(subTextLabel)
        subTextLabel.frame = CGRectMake(0, top, self.frame.size.width, 20);
    
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)dealloc
{
    [mainTextLabel release];
    [subTextLabel release];
    [imageView release];
    [super dealloc];
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@end
