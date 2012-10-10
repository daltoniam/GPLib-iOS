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
#import <QuartzCore/QuartzCore.h>
#import "UIImage+Additions.h"

@implementation GPAttachmentView

@synthesize isSideScroll,delegate;
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)commonInit
{
    scrollView = [[UIScrollView alloc] init];
    scrollView.pagingEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.delegate = self;
    [self addSubview:scrollView];
    attachmentViews = [[NSMutableArray alloc] init];
    self.userInteractionEnabled = YES;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(id)init
{
    if(self = [super init])
    {
        [self commonInit];
    }
    return self;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self commonInit];
    }
    return self;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)layoutSubviews
{
    [super layoutSubviews];
    scrollView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    pageControl.frame = CGRectMake(scrollView.frame.size.width/2-20, scrollView.frame.size.height-40, 40, 40);
    [self layoutFrames];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)layoutFrames
{
    if(isSideScroll)
        scrollView.contentSize = CGSizeMake(scrollView.frame.size.width*attachmentViews.count, scrollView.frame.size.height);
    else
        scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, scrollView.frame.size.height*attachmentViews.count);
    int pad = 6;
    int top = pad;
    int left = pad;
    for(GPImageView* view in attachmentViews)
    {
        view.frame = CGRectMake(left, top, scrollView.frame.size.width-(pad*2), scrollView.frame.size.height-(pad*2));
        for(UIView* subview in view.subviews)
            if([subview isKindOfClass:[UIButton class]])
                subview.frame = CGRectMake(view.frame.size.width-19, -6, 25, 25);
        if(view.image)
            [self addViewShadow:view];
        if(isSideScroll)
            left += scrollView.frame.size.width;
        else
            top += scrollView.frame.size.height;
        for(UIView* subview in view.subviews)
            if([subview isKindOfClass:[UILabel class]])
                subview.frame = CGRectMake(0, 0, view.frame.size.width-10, 20);
    }
    pageControl.numberOfPages = attachmentViews.count;
    if(attachmentViews.count < 2)
        pageControl.hidden = YES;
    else
        pageControl.hidden = NO;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)addAttachment:(UIImage*)image remove:(BOOL)canRemove
{
    GPImageView* imgView = [self setupImgView];
    imgView.image = image;
    if(canRemove)
        [self addRemoveButton:imgView];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)addAttachment:(NSString*)imgURL title:(NSString*)title remove:(BOOL)canRemove
{
    GPImageView* imgView = [self setupImgView];
    imgView.URL = imgURL;
    imgView.delegate = self;
    [imgView fetchImage];
    if(canRemove)
        [self addRemoveButton:imgView];
    if(title)
    {
        UILabel* label = [[[UILabel alloc] init] autorelease];
        label.text = title;
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor clearColor];
        [imgView addSubview:label];
    }
    
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(GPImageView*)setupImgView
{
    GPImageView* imgView = [[[GPImageView alloc] init] autorelease];
    imgView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapImage:)];
    tap.numberOfTapsRequired = 1;
    [imgView addGestureRecognizer:tap];
    [tap release];
    imgView.tag = attachmentViews.count;
    
    [attachmentViews addObject:imgView];
    [scrollView addSubview:imgView];
    [self setNeedsLayout];
    if(attachmentViews.count > 1)
        [self setupPager];
    
    return imgView;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setupPager
{
    if(!pageControl)
    {
        pageControl = [[UIPageControl alloc] init];
        pageControl.currentPage = 1;
        [self addSubview:pageControl];
        [self bringSubviewToFront:pageControl];
    }
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)addRemoveButton:(GPImageView*)imgView
{
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.tag = imgView.tag;
    [btn setImage:[UIImage libraryImageNamed:@"removeButton.png"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(removeView:) forControlEvents:UIControlEventTouchUpInside];
    [imgView addSubview:btn];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)removeView:(UIButton*)btn
{
    if([self.delegate respondsToSelector:@selector(didRemoveView:index:)])
        [self.delegate didRemoveView:self index:btn.tag];
    GPImageView* imgView = [(GPImageView*)btn.superview retain];
    [attachmentViews removeObject:imgView];
    [UIView animateWithDuration:0.35 animations:^{
        CGRect frame = imgView.frame;
        if(isSideScroll)
            frame.origin.y = imgView.frame.size.height+20;
        else
            frame.origin.x = imgView.frame.size.width+20;
        imgView.frame = frame;
    }completion:^(BOOL finished){
        [UIView animateWithDuration:0.35 animations:^{
            [self layoutFrames];
        }completion:NULL];
        [imgView removeFromSuperview];
        [imgView release];
    }];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scroll
{
    int page = 0;
    if(isSideScroll)
        page = scroll.contentOffset.x/scroll.frame.size.width;
    else
        page = scroll.contentOffset.y/scroll.frame.size.height;
    pageControl.currentPage = page;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//adds a simple shadow to your view
-(void)addViewShadow:(UIView*)view
{
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:view.bounds];
    view.layer.masksToBounds = NO;
    view.layer.shadowColor = [UIColor blackColor].CGColor;
    view.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    view.layer.shadowOpacity = 0.6;
    view.layer.shadowRadius = 3.0;
    view.layer.shadowPath = shadowPath.CGPath;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)didTapImage:(UITapGestureRecognizer*)sender
{
    if([self.delegate respondsToSelector:@selector(didTapView:index:)])
        [self.delegate didTapView:self index:sender.view.tag];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(UIView*)viewAtIndex:(int)index
{
    return [attachmentViews objectAtIndex:index];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)removeAllItems
{
    for(UIView* view in attachmentViews)
        [view removeFromSuperview];
    pageControl.numberOfPages = 0;
    pageControl.hidden = YES;
    [attachmentViews removeAllObjects];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)imageDidFinish:(GPImageView*)view
{
    [self addViewShadow:view];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)dealloc
{
    [pageControl release];
    [scrollView release];
    [attachmentViews release];
    [super dealloc];
}
///////////////////////////////////////////////////////////////////////////////////////////////////


@end
