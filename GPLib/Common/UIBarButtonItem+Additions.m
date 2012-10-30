//
//  UIBarButtonItem+Additions.m
//  GPLib
//
//  Created by Dalton Cherry on 5/31/12.
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

#import "UIBarButtonItem+Additions.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+Additions.h"
#import "GPButton.h"
#import "GPBarButtonItem.h"

@implementation UIBarButtonItem (Additions)

static UIImage* backArrowImage;
static UIImage* backgroundImage;
///////////////////////////////////////////////////////////////////////////////////////////////////
/*+ (id) customButtonWithBack:(BOOL)isBack image:(UIImage*)image edgeInsets:(UIEdgeInsets)edgeInsets
                      title:(NSString *)title target:(id)target selector:(SEL)selector color:(UIColor*)color
{
    GPButton* customButton = nil;
    if(isBack)
        customButton = [[[GPBackArrowButton alloc] init] autorelease];
    else
        customButton = [[[GPButton alloc] init] autorelease];
    BOOL isJustImage = NO;
    if([color isEqual:[UIColor clearColor]])
        isJustImage = YES;
    [customButton addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    customButton.titleLabel.font = [UIFont boldSystemFontOfSize:12.0f];
    customButton.titleLabel.shadowColor = [UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:0.25f];
    customButton.titleLabel.shadowOffset = CGSizeMake(0.0f, -1.0f);
    customButton.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
    customButton.titleEdgeInsets = edgeInsets;
    [customButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [customButton setTitleColor:[UIColor colorWithWhite:1 alpha:0.3] forState:UIControlStateDisabled];
    customButton.rounding = 8;
    if(!isJustImage)
    {
        customButton.borderWidth = 0.2;
        customButton.borderColor = [UIColor blackColor];
        customButton.drawInsetShadow = !isJustImage;
        customButton.layer.shadowRadius = 0;
        customButton.layer.shadowOpacity = 0.5;
        customButton.layer.shadowOffset = CGSizeMake(0, 0.5);
        customButton.layer.shadowColor = [UIColor whiteColor].CGColor;
    }
    customButton.fillColor = color;
    customButton.layer.shouldRasterize = YES;

    if(!isJustImage)
    {
        UIColor* darkColor = [GPBarButtonItem darkenColor:color point:0.1];
        customButton.gradientLength = 0.85;
        customButton.gradientStartColor = color;
        customButton.gradientEndColor = darkColor;
        UIColor* newColor = [GPBarButtonItem darkenColor:darkColor point:0.1];
        customButton.highlightColor = newColor;
    }
    else
        customButton.showsTouchWhenHighlighted = YES;
    [customButton setTitle:title forState:UIControlStateNormal];

    if(image)
    {
        [customButton setImage:image forState:UIControlStateNormal];
        [customButton setImage:image forState:UIControlStateSelected];
    }
    
    CGSize size = CGSizeMake(30.0f, 30.0f);
    if (title != nil)
        size = [[NSString stringWithString:title] sizeWithFont:customButton.titleLabel.font];
    
    //might need to caculate and scale image here
    float pad = 20.0f;
    if(image)
        pad = 10.0f;
    customButton.frame = CGRectMake(0.0f, 0.0f, size.width + pad, 30.0f);
    customButton.layer.shouldRasterize = YES;
    customButton.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    GPBarButtonItem* item = [[[GPBarButtonItem alloc] initWithCustomView:customButton] autorelease];
    item.enabled = YES;
    return item;
}*/
///////////////////////////////////////////////////////////////////////////////////////////////////
+(void)setSharedBackgroundImage:(UIImage*)image
{
    [backgroundImage release];
    backgroundImage = [image retain];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
+(void)setSharedBackArrowBackgroundImage:(UIImage*)image
{
    [backArrowImage release];
    backArrowImage = [image retain];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
+ (GPBarButtonItem*)customButtonWithBack:(BOOL)isBack image:(UIImage*)image edgeInsets:(UIEdgeInsets)edgeInsets
title:(NSString *)title target:(id)target selector:(SEL)selector noBG:(BOOL)noBG
{
    UIButton* customButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [customButton addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    customButton.titleLabel.font = [UIFont boldSystemFontOfSize:12.0f];
    customButton.titleLabel.shadowColor = [UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:0.25f];
    customButton.titleLabel.shadowOffset = CGSizeMake(0.0f, -1.0f);
    customButton.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
    customButton.titleEdgeInsets = edgeInsets;
    [customButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [customButton setTitleColor:[UIColor colorWithWhite:1 alpha:0.3] forState:UIControlStateDisabled];
    [customButton setTitle:title forState:UIControlStateNormal];
    
    if(isBack)
        [customButton setBackgroundImage:backArrowImage forState:UIControlStateNormal];
    else if(!noBG)
        [customButton setBackgroundImage:backgroundImage forState:UIControlStateNormal];

    
    if(image)
    {
        [customButton setImage:image forState:UIControlStateNormal];
        [customButton setImage:image forState:UIControlStateSelected];
    }
    
    CGSize size = CGSizeMake(30.0f, 30.0f);
    if (title != nil)
        size = [[NSString stringWithString:title] sizeWithFont:customButton.titleLabel.font];
    
    //might need to caculate and scale image here
    float pad = 20.0f;
    if(image)
        pad = 10.0f;
    customButton.frame = CGRectMake(0.0f, 0.0f, size.width + pad, 30.0f);
    //customButton.layer.shouldRasterize = YES;
    //customButton.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    GPBarButtonItem* item = [[[GPBarButtonItem alloc] initWithCustomView:customButton] autorelease];
    item.enabled = YES;
    return item;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
+(id)customButtonWithImage:(UIImage*)image target:(id)target selector:(SEL)selector
{
    return [self customButtonWithBack:NO image:image edgeInsets:UIEdgeInsetsMake(0.0f, 5.0f, 0.0f, 5.0f)  title:nil target:target selector:selector noBG:NO];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
+(id)customButtonWithTitle:(NSString*)title target:(id)target selector:(SEL)selector
{
    return [self customButtonWithBack:NO image:nil edgeInsets:UIEdgeInsetsMake(0.0f, 5.0f, 0.0f, 5.0f)  title:title target:target selector:selector noBG:NO];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
+(id)customImage:(UIImage*)image target:(id)target selector:(SEL)selector
{
    return [self customButtonWithBack:NO image:image edgeInsets:UIEdgeInsetsMake(0.0f, 5.0f, 0.0f, 5.0f)  title:nil target:target selector:selector noBG:YES];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
+(id)customButtonWithBack:(NSString*)title target:(id)target selector:(SEL)selector
{
    return [self customButtonWithBack:YES image:nil edgeInsets:UIEdgeInsetsMake(0.0f, 11.0f, 0.0f, 5.0f)  title:title target:target selector:selector noBG:NO];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
@end
