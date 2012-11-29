//
//  GPLoadingLabel.m
//  GPLib
//
//  Created by Dalton Cherry on 1/25/12.
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

#import "GPLoadingLabel.h"
#import "UIImage+Additions.h"
#import <QuartzCore/QuartzCore.h>

const CGFloat SmallMargin = 6;

@implementation GPLoadingLabel

@synthesize text,customBackgroundColor;
////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame style:(GPLoadingLabelStyle)style text:(NSString *)loadingtext
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        SelectedStyle = style;
        text = loadingtext;
        ContentView = [[UIView alloc] init];
        if(style == GPLoadingLabelWhiteStyle)
        {
            LoadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        }
        else if(style == GPLoadingLabelBlackStyle)
        {
            self.backgroundColor = [UIColor clearColor];
            ContentView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
            LoadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        }
        TextLabel = [[UILabel alloc] init];
        [ContentView addSubview:LoadingView];
        [ContentView addSubview:TextLabel];
        [self addSubview:ContentView];
    }
    return self;
}
////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame
{
    self = [self initWithFrame:frame style:GPLoadingLabelWhiteStyle text:nil];
    if (self) {}
    return self;
}
////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame style:(GPLoadingLabelStyle)style
{
    self = [self initWithFrame:frame style:style text:nil];
    if (self) {}
    return self;
}
////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithStyle:(GPLoadingLabelStyle)style
{
    self = [self initWithFrame:CGRectZero style:style text:nil];
    if (self) {}
    return self;
}
////////////////////////////////////////////////////////////////////////////////////////////
//caculate frame of text by font and text data
-(CGSize)getLabelFrame:(UILabel*)label
{
    //ContentView.frame.size.width
    return [label.text sizeWithFont:label.font constrainedToSize:CGSizeMake( (self.frame.size.width), CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap]; 
}
////////////////////////////////////////////////////////////////////////////////////////////
-(void)layoutSubviews
{
    [super layoutSubviews];
    int left = 0;
    int top = 0;
    if(SelectedStyle == GPLoadingLabelBlackStyle)
    {
        
        TextLabel.font = [UIFont boldSystemFontOfSize:17];
        TextLabel.textColor = [UIColor whiteColor];
        TextLabel.backgroundColor = [UIColor clearColor];
        TextLabel.opaque = NO;
        TextLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.3];
        TextLabel.shadowOffset = CGSizeMake(1, 1);
        TextLabel.text = text;
        TextLabel.textAlignment = UITextAlignmentCenter;
        TextLabel.numberOfLines = 0;
        CGSize size = [self getLabelFrame:TextLabel];
        
        self.backgroundColor = [UIColor clearColor];
        ContentView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
        int cwidth = size.width;
        if(cwidth < 100)
            cwidth = 100;
        if(cwidth >= self.frame.size.width)
            cwidth = self.frame.size.width - SmallMargin*2;
        cwidth += SmallMargin;
        ContentView.frame = CGRectMake((self.frame.size.width/2)-cwidth, SmallMargin, cwidth, 80);
        ContentView.layer.cornerRadius = 10;
        ContentView.center = self.center;
        LoadingView.frame = CGRectMake((cwidth/2)-12, SmallMargin*2, 24, 24);
        
        for(UIView* view in ContentView.subviews)
            if([view isKindOfClass:[UIImageView class]])
                view.frame = LoadingView.frame;
        
        top += LoadingView.frame.size.height + LoadingView.frame.origin.y + SmallMargin;
        
        TextLabel.frame = CGRectMake(0, top, size.width, size.height); //size.width-(cwidth/2)
        TextLabel.center = LoadingView.center;
        CGRect frame = TextLabel.frame;
        frame.origin.y = top+2;
        TextLabel.frame = frame;
        top = frame.size.height + frame.origin.y;
        if(top > ContentView.frame.size.height)
        {
            frame = ContentView.frame;
            frame.size.height = top;
            ContentView.frame = frame;
        }
        if(!text)
        {
            CGRect frame = LoadingView.frame;
            frame.origin.y = ContentView.frame.size.height/2 - frame.size.height/2;
            LoadingView.frame = frame;
        }
    }
    else if(SelectedStyle == GPLoadingLabelWhiteStyle)
    {
        if(!self.customBackgroundColor)
            self.customBackgroundColor = [UIColor whiteColor];
        self.backgroundColor = self.customBackgroundColor;
        ContentView.backgroundColor = self.customBackgroundColor;
        ContentView.frame = self.frame;
        
        TextLabel.backgroundColor = [UIColor clearColor];
        TextLabel.text = text;
        TextLabel.numberOfLines = 1;
        TextLabel.font = [UIFont systemFontOfSize:17];
        TextLabel.textColor = [UIColor grayColor];
        //TextLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.1];
        //TextLabel.shadowOffset = CGSizeMake(0, 1);
        TextLabel.shadowColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
        TextLabel.shadowOffset = CGSizeMake(0, 1);
        CGSize size = [self getLabelFrame:TextLabel];
        TextLabel.frame = CGRectMake(0, 0, size.width, size.height);
        TextLabel.center = ContentView.center;
        left = TextLabel.frame.origin.x;
        top = TextLabel.frame.origin.y + TextLabel.frame.size.height/2;
        left = (left-5)-(SmallMargin+3); //(left-10)-(SmallMargin+3);
        LoadingView.frame = CGRectMake(left, top-4, 10, 10);
        if(size.width + TextLabel.frame.origin.x > self.frame.size.width)
        {
            CGRect frame = LoadingView.frame;
            frame.origin.x = SmallMargin;
            LoadingView.frame = frame;
            
            frame = TextLabel.frame;
            frame.origin.x = LoadingView.frame.origin.x + LoadingView.frame.size.width + SmallMargin;
            TextLabel.frame = frame;
        }
        CGRect frame = TextLabel.frame;
        frame.origin.x += 5;
        TextLabel.frame = frame;
    }
    [LoadingView startAnimating];
}
////////////////////////////////////////////////////////////////////////////////////////////
//shows the complete label then hides the view after a delay
-(void)hideComplete:(NSString*)completeText withDelay:(float)delay
{
    [self showComplete:completeText];
    [self performSelector:@selector(hideLabel) withObject:completeText afterDelay:delay];
}
////////////////////////////////////////////////////////////////////////////////////////////
-(void)hideLabel
{
    self.hidden = YES;
}
////////////////////////////////////////////////////////////////////////////////////////////
-(void)showComplete:(NSString*)completeText
{
    [LoadingView stopAnimating];
    [LoadingView removeFromSuperview];
    UIImageView* imageview = [[UIImageView alloc] initWithImage:[UIImage libraryImageNamed:@"37x-Checkmark.png"]];
    imageview.tag = 123;
    imageview.frame = LoadingView.frame;
    [ContentView addSubview:imageview];
    [imageview release];
    text = completeText;
    TextLabel.text = completeText;
    [self setNeedsLayout];
    //[self performSelector:@selector(hideDelayed:) withObject:[NSNumber numberWithBool:animated] afterDelay:delay];
}
////////////////////////////////////////////////////////////////////////////////////////////
-(void)setHidden:(BOOL)hidden
{
    [super setHidden:hidden];
    if(!hidden)
    {
        for(UIView* view in ContentView.subviews)
            if([view isKindOfClass:[UIImageView class]])
                [view removeFromSuperview];
        [LoadingView startAnimating];
        [ContentView addSubview:LoadingView];
    }
}
////////////////////////////////////////////////////////////////////////////////////////////
-(BOOL)isAnimating
{
    return LoadingView.isAnimating;
}
////////////////////////////////////////////////////////////////////////////////////////////
-(void)setText:(NSString *)textdata
{
    [[ContentView viewWithTag:123] removeFromSuperview];
    [LoadingView startAnimating];
    if(![LoadingView superview])
        [ContentView addSubview:LoadingView];
    text = textdata;
    TextLabel.text = textdata;
}
////////////////////////////////////////////////////////////////////////////////////////////
-(void)dealloc
{
    [LoadingView release];
    [TextLabel release];
    [ContentView release];
    [super dealloc];
}
////////////////////////////////////////////////////////////////////////////////////////////
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
