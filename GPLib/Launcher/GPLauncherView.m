//
//  GPLauncherView.m
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

#import "GPLauncherView.h"

@implementation GPLauncherView

@synthesize rowCount = rowCount, columnCount = columnCount,pages = pages,delegate = delegate;

#define PADDING 6
/////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        columnCount = 4;
        rowCount = 3;
        ScrollView = [[UIScrollView alloc] init];
        ScrollView.delegate = self;
        ScrollView.pagingEnabled = YES;
        ScrollView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);//[self frameForScrollView];
        ScrollView.showsVerticalScrollIndicator = NO;
        ScrollView.showsHorizontalScrollIndicator = NO;
        [self addSubview:ScrollView];
        pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake((frame.size.width/2) - 20, frame.size.height-72, 40, 36)];
        [self addSubview:pageControl];
        pages = [[NSArray alloc] init];
    }
    return self;
}
/////////////////////////////////////////////////////////////////////////////////////
-(void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super backgroundColor];
    ScrollView.backgroundColor = backgroundColor;
}
/////////////////////////////////////////////////////////////////////////////////////
-(void)setFrame:(CGRect)frame
{
    ScrollView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    [super setFrame:frame];
}
/////////////////////////////////////////////////////////////////////////////////////
-(void)layoutSubviews
{
    [super layoutSubviews];
    ScrollView.contentSize = [self contentSizeForScrollView];
    CGSize size = [self caculateButtonSize];
    int row = 0;
    int col = 0;
    int page = 0;
    int i = 0;
    for(GPLauncherButton* button in pages)
    {
        button.frame = [self caculateButtonFrame:row top:col size:size page:page];
        button.index = i;
        button.delegate = delegate; //forward the delegate on.
        //button.backgroundColor = [UIColor grayColor];
        [ScrollView addSubview:button];
        if(row+1 == rowCount)
        {
            row = 0;
            if(col+1 == columnCount)
            {
                page++;
                col = 0;
            }
            else
                col++;
        }
        else
            row++;
        i++;
    }
    pageControl.numberOfPages = page+1;
}
/////////////////////////////////////////////////////////////////////////////////////
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int page = ScrollView.contentOffset.x/ScrollView.frame.size.width;
    pageControl.currentPage = page;
}
/////////////////////////////////////////////////////////////////////////////////////
-(CGRect)caculateButtonFrame:(int)rowindex top:(int)colindex size:(CGSize)buttonSize page:(int)page
{
    CGRect buttonFrame;
    
    int pad = ScrollView.frame.size.width - (buttonSize.width*rowCount);
    pad = pad/rowCount;
    int left = (pad*rowindex) + pad/2;
    
    pad = ScrollView.frame.size.height - (buttonSize.height*columnCount);
    pad = pad/(columnCount*2); //we add two for the top and bottom of the columns
    int top = (pad*colindex) - pad/2; //+ pad/2
    
    int pageoffset = page*ScrollView.frame.size.width;
    
    buttonFrame = CGRectMake(left + (buttonSize.width*rowindex) + pageoffset,top + (buttonSize.height*colindex), buttonSize.width, buttonSize.height);
    return buttonFrame;
}
/////////////////////////////////////////////////////////////////////////////////////
-(CGSize)caculateButtonSize
{
    CGSize mainSize = ScrollView.frame.size;
    CGSize buttonSize;
    //determine height
    buttonSize.height = (mainSize.height/columnCount) - PADDING*columnCount;
    buttonSize.width = (mainSize.width/rowCount) - PADDING*rowCount;
    return buttonSize;
}
/////////////////////////////////////////////////////////////////////////////////////
//caculate frame size of scrollView
- (CGRect)frameForScrollView 
{
    CGRect frame = [[UIScreen mainScreen] bounds];
    //frame.origin.x -= PADDING;
    //frame.size.width += (2 * PADDING);
    return frame;
}
/////////////////////////////////////////////////////////////////////////////////////
-(CGSize)contentSizeForScrollView
{
    CGSize size;
    int count = rowCount*columnCount;
    int offset = [pages count]/count;
    offset += 1; //because we need at least one page
    size = CGSizeMake(ScrollView.frame.size.width*offset, ScrollView.frame.size.height);
    return size;
}

/////////////////////////////////////////////////////////////////////////////////////
-(void)dealloc
{
    [ScrollView release];
    [pages release];
    [pageControl release];
    [super dealloc];
}

@end
