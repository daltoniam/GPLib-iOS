//
//  GPTabBarItem.m
//  GPLib
//
//  Created by Dalton Cherry on 5/21/12.
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

#import "GPTabBarItem.h"
#import "UIImage+Additions.h"
#import <QuartzCore/QuartzCore.h>
#import "GPDrawExtras.h"

#define MAX3(a,b,c) ((a)<(b)?(MAX(b,c)):(MAX(a,c)))
#define MIN3(a,b,c) ((a)<(b)?(MIN(a,c)):(MIN(b,c)))

#define GLOW_IMAGE_TAG 2394858

@implementation GPTabBarItem

@synthesize gradientStartColor, gradientEndColor, selectedColor;
@synthesize isSelected = isSelected,rounding,drawGloss,gradientLength,fillColor,imageFill;
@synthesize borderColor,borderWidth;
@synthesize selectedImageColor,imageColor,image,titleLabel = titleLabel,tabIndex,delegate,selectedImage,centerImage;
//////////////////////////////////////////////////////////////////////////////////////////////
-(void)Commoninit
{    
    self.gradientLength = 0.55;
    self.userInteractionEnabled = YES;
    self.selectedImageColor = [UIColor colorWithPatternImage:[UIImage libraryImageNamed:@"TabBarItemSelectedBackground.png"]];
    self.imageColor = [UIColor colorWithWhite:0.7 alpha:1];
	//self.layer.borderWidth = 1.0f; 
    //self.highlightColor = [UIColor colorWithRed:1/255.0f green:97/255.0f blue:231/255.0f alpha:1.0];
    //self.gradientStartColor = [UIColor whiteColor];
	//self.gradientEndColor = [UIColor grayColor];
}
//////////////////////////////////////////////////////////////////////////////////////////////
-(id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) 
    {
        [self Commoninit];
    }
    return self;
}
//////////////////////////////////////////////////////////////////////////////////////////////
-(id) initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) 
    {
        [self Commoninit];
    }
    return self;
}
//////////////////////////////////////////////////////////////////////////////////////////////
-(id)init
{
    if ((self = [super init])) 
    {
        [self Commoninit];
    }
    return self;
}
//////////////////////////////////////////////////////////////////////////////////////////////
-(void)layoutSubviews
{
    [super layoutSubviews];
    int top = 2;
    if(image)
    {
        int tpad = 20;
        if(!titleLabel)
        {
            top += 3;
            tpad = 10;
        }
        if(imageFill)
        {
            tpad = 0;
            top = 0;
        }
        if(!imageView)
            [self setupImageView];
        int width = self.frame.size.width;
        imageView.frame = CGRectMake(0, top, width, self.frame.size.height-tpad);
        top += imageView.frame.size.height;
    }
    else
        top = self.frame.size.height-20;
    titleLabel.frame = CGRectMake(0, top, self.frame.size.width, 12);
    UIImageView* glowImageView = (UIImageView*)[self viewWithTag:GLOW_IMAGE_TAG];
    if(glowImageView)
        glowImageView.frame = CGRectMake(self.frame.size.width/2.0 - glowImageView.image.size.width/2.0, 
                                         self.frame.origin.y + self.frame.size.height - glowImageView.image.size.height, 
                                         glowImageView.image.size.width, glowImageView.image.size.height);
}
//////////////////////////////////////////////////////////////////////////////////////////////
- (void)drawRect:(CGRect)rect 
{
    if(self.selectedImage)
    {
        [super drawRect:rect];
        return;
    }
    int width = self.bounds.size.width;
    int height = self.bounds.size.height;
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    if(self.borderWidth)
    {
        CGContextSetLineJoin(ctx, kCGLineJoinRound);
        CGContextSetLineWidth(ctx, self.borderWidth);
        CGContextSetStrokeColorWithColor(ctx, self.borderColor.CGColor);
    }
    
    if(isSelected && self.selectedColor)
        CGContextSetFillColorWithColor(ctx, self.selectedColor.CGColor);
    else
        CGContextSetFillColorWithColor(ctx, self.fillColor.CGColor);
    
    if(rounding > 0)
        [GPDrawExtras drawRoundRect:ctx width:width height:height rounding:rounding stroke:self.borderWidth];
    else
    {
        self.layer.borderWidth = self.borderWidth;
        self.layer.borderColor = self.borderColor.CGColor;
    }
    
    CGRect currentFrame = self.bounds;
    
    if (gradientStartColor && gradientEndColor)
    {
        if(isSelected)
        {
            if(self.selectedColor)
                [GPDrawExtras drawLinearGradient:ctx start:selectedColor end:selectedColor rect:currentFrame endLoc:gradientLength];
            else
                [GPDrawExtras drawLinearGradient:ctx start:gradientEndColor end:gradientStartColor rect:currentFrame endLoc:gradientLength]; //swap the gradient backwards
        }
        else
            [GPDrawExtras drawLinearGradient:ctx start:gradientStartColor end:gradientEndColor rect:currentFrame endLoc:gradientLength];
    }
    else if(self.selectedColor)
    {
        if(isSelected)
            [GPDrawExtras drawLinearGradient:ctx start:selectedColor end:selectedColor rect:currentFrame endLoc:gradientLength];
    }
    
    if(self.drawGloss)
    {
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        [GPDrawExtras drawGloss:ctx rect:self.bounds];
    }
    [super drawRect:rect];
}
//////////////////////////////////////////////////////////////////////////////////////////////
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
    if(!isSelected) //no need to redraw if already selected
    {
        isSelected = YES;
        if(image && !selectedImage)
            imageView.image = [UIImage imageWithOverlayColor:image color:self.selectedImageColor];
        else if(selectedImage)
            imageView.image = selectedImage;
        titleLabel.textColor = [UIColor colorWithWhite:1 alpha:1];
        [self setNeedsDisplay];
        if([self.delegate respondsToSelector:@selector(didSelectTab:)])
            [self.delegate didSelectTab:self];
    }
    [super touchesBegan:touches withEvent:event];
}
//////////////////////////////////////////////////////////////////////////////////////////////
//simulates a touch of the button
-(void)swapState:(BOOL)selected
{
    isSelected = selected;
    if(image)
    {
        if(isSelected)
        {
            if(!self.selectedImage)
                imageView.image = [UIImage imageWithOverlayColor:image color:self.selectedImageColor];
            else
                imageView.image = selectedImage;
            titleLabel.textColor = [UIColor colorWithWhite:1 alpha:1];
        }
        else
        {
            if(!self.selectedImage)
                imageView.image = [UIImage imageWithOverlayColor:image color:self.imageColor];
            else
                imageView.image = image;
            titleLabel.textColor = [UIColor colorWithWhite:0.7 alpha:1];
        }
    }
    [self setNeedsDisplay];
}
//////////////////////////////////////////////////////////////////////////////////////////////
-(void)setGlowState:(BOOL)on
{
    if(on)
    {
        UIImage* glowImage = nil;
        if([self.delegate respondsToSelector:@selector(glowImage)])
            glowImage = [self.delegate glowImage];
        
        if(!glowImage)
            glowImage = [UIImage libraryImageNamed:@"TabBarGlow.png"];
        UIImageView* glowImageView = [[[UIImageView alloc] initWithImage:glowImage] autorelease];
        
        glowImageView.frame = CGRectMake(self.frame.size.width/2.0 - glowImage.size.width/2.0, self.frame.origin.y + self.frame.size.height - glowImage.size.height, 
                                         glowImage.size.width, glowImage.size.height);
        
        glowImageView.tag = GLOW_IMAGE_TAG;
        [self addSubview:glowImageView];
        [self bringSubviewToFront:glowImageView];
    }
    else 
    {
        UIImageView* glowImageView = (UIImageView*)[self viewWithTag:GLOW_IMAGE_TAG];
        [glowImageView removeFromSuperview];
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////
-(void)setupImageView
{
    imageView = [[UIImageView alloc] init];
    if(image)
    {
        if(isSelected)
        {
            if(!self.selectedImage)
                imageView.image = [UIImage imageWithOverlayColor:image color:self.selectedImageColor];
            else
                imageView.image = selectedImage;
        }
        else
        {
            if(!self.selectedImage)
                imageView.image = [UIImage imageWithOverlayColor:image color:self.imageColor];
            else
                imageView.image = image;
        }
    }
    if(!imageFill)
        imageView.contentMode = UIViewContentModeScaleAspectFit; //UIViewContentModeCenter
    if(centerImage)
        imageView.contentMode = UIViewContentModeCenter;
    [self addSubview:imageView];
    [self bringSubviewToFront:imageView];
}
//////////////////////////////////////////////////////////////////////////////////////////////
-(UILabel*)titleLabel
{
    if(!titleLabel)
    {
        titleLabel = [[UILabel alloc] init];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textAlignment = UITextAlignmentCenter;
        if(isSelected)
            titleLabel.textColor = [UIColor colorWithWhite:1 alpha:1];
        else
            titleLabel.textColor = [UIColor colorWithWhite:0.7 alpha:1];
        titleLabel.font = [UIFont boldSystemFontOfSize:12];
        [self addSubview:titleLabel];
    }
    return titleLabel;
}
//////////////////////////////////////////////////////////////////////////////////////////////
-(void)dealloc
{
    [imageView release];
    [titleLabel release];
    [super dealloc];
}
//////////////////////////////////////////////////////////////////////////////////////////////
@end
