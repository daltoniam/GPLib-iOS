//
//  GPAttachmentView.m
//  GPLib
//
//  Created by Dalton Cherry on 5/30/12.
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

#import "GPAttachmentView.h"
#import "GPImageView.h"
#import <QuartzCore/QuartzCore.h>

@implementation GPAttachmentView

@synthesize delegate,isGridStyle,gridPageCount;
////////////////////////////////////////////////////////////////////////////////////////////
-(void)commonInit
{
    contentView = [[UIScrollView alloc] init];
    contentView.pagingEnabled = YES;
    contentView.delegate = self;
    contentView.backgroundColor = [UIColor blackColor];
    contentView.showsVerticalScrollIndicator = NO;
    contentView.showsHorizontalScrollIndicator = NO;
    [self addSubview:contentView];
    attachmentViews = [[NSMutableArray alloc] init];
    self.gridPageCount = 3;
}
////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        [self commonInit];
    }
    return self;
}
////////////////////////////////////////////////////////////////////////////////////////////
-(id)init
{
    self = [super init];
    if (self) 
    {
        [self commonInit];
    }
    return self;
}
////////////////////////////////////////////////////////////////////////////////////////////
-(void)setupPager
{
    pageControl = [[UIPageControl alloc] init];
    [self addSubview:pageControl];
    [self bringSubviewToFront:pageControl];
}
////////////////////////////////////////////////////////////////////////////////////////////
-(void)layoutSubviews
{
    [super layoutSubviews];
    contentView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    if(self.isGridStyle)
        [self gridLayout];
    else
        [self pageLayout];
    for(UIView* view in attachmentViews)
    {
        for(UIView* label in view.subviews)
            label.frame = CGRectMake(0, 0, view.frame.size.width, 20);
    }
    pageControl.currentPage = 0;
}
////////////////////////////////////////////////////////////////////////////////////////////
-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    contentView.frame = frame;
    if(self.isGridStyle)
        [self gridLayout];
    else
        [self pageLayout];
}
////////////////////////////////////////////////////////////////////////////////////////////
-(void)pageLayout
{
    pagePad = 0;
    int left = 0;
    for(UIView* view in attachmentViews)
    {
        view.frame = CGRectMake(left, 0,self.frame.size.width, self.frame.size.height);
        left += view.frame.size.width;
    }
    CGRect bounds = contentView.bounds;
    contentView.contentSize = CGSizeMake((bounds.size.width * [attachmentViews count]), bounds.size.height);
    if(attachmentViews.count > 0 && !pageControl)
        [self setupPager];
    pageControl.frame = CGRectMake(0, self.frame.size.height-30, self.frame.size.width, 36);
    int count = [attachmentViews count];
    if(count > 1)
        pageControl.numberOfPages = count;
    else
        pageControl.numberOfPages = 0;
    pageControl.currentPage = 0;
    contentView.backgroundColor = [UIColor blackColor];
}
////////////////////////////////////////////////////////////////////////////////////////////
-(void)gridLayout
{
    int pad = 10;
    pagePad = pad;
    int left = pad;
    int width = self.frame.size.width/gridPageCount;
    for(UIView* view in attachmentViews)
    {
        view.frame = CGRectMake(left, pad,width-(pad + pad/gridPageCount), self.frame.size.height-(pad*2));
        left += view.frame.size.width + pad;
        //for(UIView* label in view.subviews)
        //    label.frame = CGRectMake(0, -pad, view.frame.size.width, 20);
    }
    CGRect bounds = contentView.bounds;
    int size = [attachmentViews count];
    if(size % gridPageCount != 0)
        size += gridPageCount;
    size = size/gridPageCount;
    //CGSizeMake((bounds.size.width - pad/gridPageCount) * size, bounds.size.height);
    contentView.contentSize = CGSizeMake(( (bounds.size.width-pad/2) /gridPageCount) * size, bounds.size.height);
    contentView.backgroundColor = [UIColor clearColor];
    
    if(attachmentViews.count > 0 && !pageControl)
        [self setupPager];
    pageControl.frame = CGRectMake(0, self.frame.size.height-36, self.frame.size.width, 36);
    int count = [attachmentViews count]/gridPageCount;
    if(count > 1)
        pageControl.numberOfPages = count;
    else
        pageControl.numberOfPages = 0;
    pageControl.currentPage = 0;

}
////////////////////////////////////////////////////////////////////////////////////////////
-(void)addAttachment:(NSString*)url text:(NSString*)text
{
    //UIViewContentModeScaleToFill [UIColor colorWithWhite:0.95 alpha:1]
    [self addAttachment:url text:text contentMode:UIViewContentModeScaleToFill backColor:[UIColor colorWithWhite:0.98 alpha:1]];
}
////////////////////////////////////////////////////////////////////////////////////////////
//does the magic
-(void)addAttachment:(NSString*)url text:(NSString*)text contentMode:(UIViewContentMode)mode backColor:(UIColor*)color
{
    int left = self.frame.size.width*[attachmentViews count];
    GPImageView* imageView = [[[GPImageView alloc] initWithFrame:CGRectMake(left, 0,self.frame.size.width, self.frame.size.height)] autorelease];
    imageView.URL = url;
    imageView.contentMode = mode;//UIViewContentModeScaleAspectFill;//UIViewContentModeScaleAspectFit;
    [imageView fetchImage];
    imageView.tag = attachmentViews.count;
    imageView.backgroundColor = color;
    imageView.userInteractionEnabled = YES;
    
    if(text)
    {
        UILabel* label = [[[UILabel alloc] init] autorelease];
        label.font = [UIFont boldSystemFontOfSize:12];
        label.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
        label.textColor = [UIColor whiteColor];
        label.text = text;
        label.textAlignment = UITextAlignmentCenter;
        [imageView addSubview:label];
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapImage:)];
    tap.numberOfTapsRequired = 1;
    [imageView addGestureRecognizer:tap];
    [tap release];
    
    [attachmentViews addObject:imageView];
    [contentView addSubview:imageView];
    [self setNeedsLayout];
}
////////////////////////////////////////////////////////////////////////////////////////////
-(void)didTapImage:(UITapGestureRecognizer*)sender
{
    if([self.delegate respondsToSelector:@selector(didTapView:index:)])
        [self.delegate didTapView:self index:sender.view.tag];
}
////////////////////////////////////////////////////////////////////////////////////////////
-(void)removeAllItems
{
    for(UIView* view in attachmentViews)
        [view removeFromSuperview];
    pageControl.numberOfPages = 0;
    [attachmentViews removeAllObjects];
}
////////////////////////////////////////////////////////////////////////////////////////////
-(void)removeViewAtIndex:(int)index
{
    UIView* view = [attachmentViews objectAtIndex:index];
    [view removeFromSuperview];
    [attachmentViews removeObject:view];
    
}
////////////////////////////////////////////////////////////////////////////////////////////
-(UIView*)viewAtIndex:(int)index
{
    return [attachmentViews objectAtIndex:index];
}
////////////////////////////////////////////////////////////////////////////////////////////
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int page = contentView.contentOffset.x/(contentView.frame.size.width-pagePad);
    pageControl.currentPage = page;
}
////////////////////////////////////////////////////////////////////////////////////////////
-(void)dealloc
{
    [contentView release];
    [attachmentViews release];
    [pageControl release];
    [super dealloc];
}
////////////////////////////////////////////////////////////////////////////////////////////


@end
