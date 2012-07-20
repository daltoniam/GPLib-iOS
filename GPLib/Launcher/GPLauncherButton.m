//
//  GPLauncherButton.m
//  GPLib
//
//  Created by Dalton Cherry on 2/6/12.
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

#import "GPLauncherButton.h"

@implementation GPLauncherButton

@synthesize textLabel = textLabel,delegate = delegate,URL,index,badgeNumber = badgeNumber;
/////////////////////////////////////////////////////////////////////////////////////
//factory methods.
+(GPLauncherButton*)buttonWithTitle:(NSString*)text image:(UIImage*)image url:(NSString*)url
{
    GPLauncherButton* temp = [[[GPLauncherButton alloc] initWithFrame:CGRectZero] autorelease];
    [temp setImage:image];
    temp.textLabel.text = text;
    temp.URL = url;
    return temp;
}
/////////////////////////////////////////////////////////////////////////////////////
+(GPLauncherButton*)buttonWithTitle:(NSString*)text image:(UIImage*)image
{
    return [GPLauncherButton buttonWithTitle:text image:image url:nil];
}

/////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        self.userInteractionEnabled = YES;
        imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeCenter;
        [self addSubview:imageView];
        textLabel = [[UILabel alloc] init]; 
        textLabel.text = @"";
        textLabel.textAlignment = UITextAlignmentCenter;
        textLabel.backgroundColor = [UIColor clearColor]; //
        textLabel.numberOfLines = 1;
        int size = 12;
        if(GPIsPad())
            size = 14;
        textLabel.font = [UIFont boldSystemFontOfSize:size];
        [imageView addSubview:textLabel];
        badgeNumber = 0;
    }
    return self;
}
/////////////////////////////////////////////////////////////////////////////////////
-(void)layoutSubviews
{
    [super layoutSubviews];
    BOOL first = NO;
    if(textLabel.frame.size.height == 0)
        first = YES;
    imageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    CGSize size = imageView.image.size;
    textLabel.center = imageView.center;
    CGRect frame = textLabel.frame;
    if(first)
        frame.origin.y += (size.height/2)+5; //2
    else
        frame.origin.y += (size.height/2)+12;
    frame.origin.x = 0;//(size.width/2);
    frame.size.width = self.frame.size.width;//size.width;
    frame.size.height = textLabel.font.lineHeight;
    textLabel.frame = frame;
    if(badgeNumber > 0)
    {
        if(!badgeView)
        {
            badgeView = [[GPBubbleView badgeItem:[NSString stringWithFormat: @"%d", badgeNumber]] retain];
            [self addSubview:badgeView];
        }
        badgeView.hidden = NO;
        badgeView.center = imageView.center;
        frame = badgeView.frame;
        int overlay = 5; //we want to overlay the corner of the image
        frame.origin.y -= (size.height/2)-overlay;
        frame.origin.x += (size.width/2)-overlay;
        badgeView.frame = frame;
    }
    else
        badgeView.hidden = YES;
    
}
/////////////////////////////////////////////////////////////////////////////////////
//I create two images, one is your image and the other is a darken (selected) version of your image.
-(void)setImage:(UIImage*)image
{
    imageView.image = image;
    [normalImage release];
    normalImage = [image retain];
    [selectedImage release];
    selectedImage = [[self imageWithOverlayColor:image color:[UIColor colorWithWhite:0 alpha:0.5] ] retain];
}
/////////////////////////////////////////////////////////////////////////////////////
-(UIImage *)imageWithOverlayColor:(UIImage *)baseImage color:(UIColor *)color 
{        
    CGRect rect = CGRectMake(0.0f, 0.0f, baseImage.size.width, baseImage.size.height);
    
    if (UIGraphicsBeginImageContextWithOptions) 
    {
        CGFloat imageScale = 1.0f;
        if ([self respondsToSelector:@selector(scale)])  // The scale property is new with iOS4.
            imageScale = baseImage.scale;
        UIGraphicsBeginImageContextWithOptions(baseImage.size, NO, imageScale);
    }
    else
        UIGraphicsBeginImageContext(baseImage.size);
    
    [baseImage drawInRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    //CGContextSetBlendMode(context, kCGBlendModeSourceIn);
    CGContextSetBlendMode(context, kCGBlendModeSourceAtop);
    
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

//////////////////////////////////////////////////////////////////////////////////////////////
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
    [super touchesBegan:touches withEvent:event];
    imageView.image = selectedImage;
}
//////////////////////////////////////////////////////////////////////////////////////////////
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    imageView.image = selectedImage;
}
//////////////////////////////////////////////////////////////////////////////////////////////
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event 
{
    [super touchesCancelled:touches withEvent:event];
    imageView.image = normalImage;
}
//////////////////////////////////////////////////////////////////////////////////////////////
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    imageView.image = normalImage;
    if([delegate respondsToSelector:@selector(didSelectButton:)])
        [delegate didSelectButton:self];
}
//////////////////////////////////////////////////////////////////////////////////////////////
-(NSInteger)badgeNumber
{
    return badgeNumber;
}
//////////////////////////////////////////////////////////////////////////////////////////////
-(void)setBadgeNumber:(NSInteger)number
{
    badgeNumber = number;
    if(!badgeView)
    {
        badgeView = [[GPBubbleView badgeItem:[NSString stringWithFormat: @"%d", badgeNumber]] retain];
        [self addSubview:badgeView];
    }
    [badgeView updateBadgeText:[NSString stringWithFormat: @"%d", badgeNumber]];
    if(number == 0)
        badgeView.hidden = YES;
    else
        badgeView.hidden = NO;
}
//////////////////////////////////////////////////////////////////////////////////////////////
-(void)dealloc
{
    [imageView release];
    [textLabel release];
    [font release];
    [selectedImage release];
    [normalImage release];
    [badgeView release];
    [super dealloc];
}
//////////////////////////////////////////////////////////////////////////////////////////////
@end
