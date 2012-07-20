//
//  GPGridMoreCell.m
//  GPLib
//
//  Created by Dalton Cherry on 5/23/12.
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

#import "GPGridMoreItem.h"
#import "GPGridMoreCell.h"

@implementation GPGridMoreCell


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setupImageView
{
    //[super setupImageView];
    //[ActivityView removeFromSuperview];
    //[imageView addSubview:ActivityView];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setupTextLabel
{
    textLabel = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    [textLabel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    //[textLabel addTarget:self action:@selector(labelTapped) forControlEvents:UIControlEventTouchUpInside];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setupBlankView
{
    [super setupBlankView];
    [blankView addSubview:textLabel];
    [blankView addSubview:ActivityView];
    [blankView bringSubviewToFront:ActivityView];
    if(isAuto)
        blankView.backgroundColor = [UIColor clearColor];
    else
        blankView.backgroundColor = [UIColor lightTextColor];
    
    blankView.layer.borderColor = [UIColor lightTextColor].CGColor;
    blankView.layer.borderWidth = 1;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)layoutSubviews
{
    [super layoutSubviews];
    if(imageView)
    {
        imageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    }
    else if(textLabel)
    {
        if(!blankView)
            [self setupBlankView];
        blankView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    }
    
    if(isAuto)
    {    
        int actSize = 50;
        ActivityView.frame = CGRectMake(self.frame.size.width/2 - (actSize/2), self.frame.size.height/2 - (actSize/2), actSize, actSize);
        //ActivityView.frame = CGRectMake(10, 10, 50, 50);
        textLabel.frame = CGRectZero;
    }
    else
    {
        int actSize = 24;
        CGSize textSize = [self getTextSize:actSize+6];
        
        int pad = actSize + 6;
        int top = self.frame.size.height/2 - (actSize/2);
        int left = (self.frame.size.width/2) - (textSize.width/2 + actSize);
        ActivityView.frame = CGRectMake(left, top, actSize, actSize);
        left += pad;
        textLabel.frame = CGRectMake(left, top, textSize.width, actSize);
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(CGSize)getTextSize:(int)actOffset
{
    return [textLabel.titleLabel.text sizeWithFont:textLabel.titleLabel.font constrainedToSize:CGSizeMake( (self.frame.size.width-actOffset), CGFLOAT_MAX) lineBreakMode:UILineBreakModeTailTruncation]; 
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setObject:(id)object 
{
    [super setObject:object];
    GPGridMoreItem* item = object;
    isAuto = item.isAutoLoad;
    [self setAnimating:item.isLoading];
    
    if(!ActivityView)
    {
        if(isAuto)
            ActivityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        else
            ActivityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    if(!blankView)
        [self setupBlankView];
    
    if(item.backgroundColor)
        blankView.backgroundColor = item.backgroundColor;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setAnimating:(BOOL)swap
{
    if(swap)
        [ActivityView startAnimating];
    else
        [ActivityView stopAnimating];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)dealloc
{
    [ActivityView release];
    [super dealloc];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@end
