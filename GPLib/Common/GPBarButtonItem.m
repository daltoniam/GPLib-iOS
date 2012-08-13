//
//  GPBarButtonItem.m
//  GPLib
//
//  Created by Dalton Cherry on 6/11/12.
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

#import "GPBarButtonItem.h"
#import "GPButton.h"

@implementation GPBarButtonItem

///////////////////////////////////////////////////////////////////////////////////////////////////
//make the enabled property work for the custom buttons
-(void)setEnabled:(BOOL)enable
{
    if([self.customView isKindOfClass:[UIButton class]])
    {
        UIButton* button = (UIButton*)self.customView;
        button.enabled = enable;
    }
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setTitle:(NSString *)title
{
    if([self.customView isKindOfClass:[UIButton class]])
    {
        UIButton* button = (UIButton*)self.customView;
        CGSize size = CGSizeMake(30.0f, 30.0f);
        if (title != nil)
            size = [[NSString stringWithString:title] sizeWithFont:button.titleLabel.font];
        float pad = 20.0f;
        button.frame = CGRectMake(0.0f, 0.0f, size.width + pad, 30.0f);
        [button setTitle:title forState:UIControlStateNormal];
    }
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setTintColor:(UIColor *)tintColor
{
    if([self.customView isKindOfClass:[GPButton class]])
    {
        GPButton* button = (GPButton*)self.customView;
        UIColor* darkColor = [GPBarButtonItem darkenColor:tintColor point:0.1];
        button.gradientLength = 0.85;
        button.gradientStartColor = tintColor;
        button.gradientEndColor = darkColor;
        UIColor* newColor = [GPBarButtonItem darkenColor:darkColor point:0.1];
        button.highlightColor = newColor;
        [button setNeedsDisplay];
    }
}
///////////////////////////////////////////////////////////////////////////////////////////////////
+(UIColor*)adjustColor:(UIColor*)color point:(CGFloat)val lighten:(BOOL)light
{
    CGFloat hue;
    CGFloat sat;
    CGFloat bright;
    CGFloat alpha;
    if([color respondsToSelector:@selector(getHue:saturation:brightness:alpha:)])
    {
        [color getHue:&hue saturation:&sat brightness:&bright alpha:&alpha]; //ios5 only
        if(light)
        {
            if(bright+val < 1)
                bright += val;
        }
        else
        {
            if(bright > val)
                bright -= val;
        }
        return [UIColor colorWithHue:hue saturation:sat brightness:bright alpha:alpha];
    }
    return color; //not what you want, but better than a crash....
}
///////////////////////////////////////////////////////////////////////////////////////////////////
+(UIColor*)darkenColor:(UIColor*)color point:(CGFloat)val
{
    return [GPBarButtonItem adjustColor:color point:val lighten:NO];
}
///////////////////////////////////////////////////////////////////////////////////////////////////

@end

