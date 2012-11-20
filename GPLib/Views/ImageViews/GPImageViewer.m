//
//  GPImageViewer.m
//  GPLib
//
//  Created by Dalton Cherry on 1/26/12.
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

#import "GPImageViewer.h"
#import "GPNavigator.h"

#define PADDING  10

@implementation GPImageViewer

/////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        self.wantsFullScreenLayout = YES;
        ScrollView = [[UIScrollView alloc] init];
        ScrollView.delegate = self;
        ScrollView.pagingEnabled = YES;
        ScrollView.frame = [self frameForScrollView];
        ScrollView.backgroundColor = [UIColor blackColor];
        ScrollView.showsVerticalScrollIndicator = NO;
        ScrollView.showsHorizontalScrollIndicator = NO;
        
        recycledPages = [[NSMutableSet alloc] init];
        visiblePages  = [[NSMutableSet alloc] init];
        
        /*self.navigationItem.leftBarButtonItem =[[[UIBarButtonItem alloc] initWithTitle: @"Done"
                                                                                 style: UIBarButtonItemStyleDone
                                                                                target: self
                                                                                action:@selector(dimiss)] autorelease];*/
    }
    return self;
}
/////////////////////////////////////////////////////////////////////////////////////
-(void)dimiss
{
    [self dismissModalViewControllerAnimated:YES];//[[GPNavigator navigator] dismissModal];
}
/////////////////////////////////////////////////////////////////////////////////////
#pragma mark - View lifecycle


/////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view = ScrollView;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.translucent = YES;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];
}
/////////////////////////////////////////////////////////////////////////////////////
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.visibleViewController.navigationController.navigationBar.translucent = NO;
}
/////////////////////////////////////////////////////////////////////////////////////
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationController.navigationBar.translucent = NO;
    //[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}
/////////////////////////////////////////////////////////////////////////////////////
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //[self setBar:YES];
    ScrollView.contentSize = [self contentSizeForScrollView];
    [self updatePages];
}
/////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self updatePages];
}
/////////////////////////////////////////////////////////////////////////////////////
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(decelerate)
        [self setBar:YES];
}
/////////////////////////////////////////////////////////////////////////////////////
//does the magic.
-(void)updatePages
{
    // Calculate which pages are visible
    CGRect visibleBounds = ScrollView.bounds;
    int firstNeededPageIndex = floorf(CGRectGetMinX(visibleBounds) / CGRectGetWidth(visibleBounds));
    int lastNeededPageIndex  = floorf((CGRectGetMaxX(visibleBounds)-1) / CGRectGetWidth(visibleBounds));
    firstNeededPageIndex = MAX(firstNeededPageIndex, 0);
    lastNeededPageIndex  = MIN(lastNeededPageIndex, [PhotoSource count] - 1);
        [self titleIndex:firstNeededPageIndex];
    // Recycle no-longer-visible pages 
    for (GPImageScrollView *page in visiblePages) 
    {
        if (page.index < firstNeededPageIndex || page.index > lastNeededPageIndex) 
        {
            [recycledPages addObject:page];
            [page removeFromSuperview];
        }
    }
    [visiblePages minusSet:recycledPages];
    
    // add missing pages
    for (int index = firstNeededPageIndex; index <= lastNeededPageIndex; index++) 
    {
        if (![self isDisplayingPageForIndex:index]) 
        {
            GPImageScrollView *page = [self dequeueRecycledPage];
            if (page == nil) 
                page = [[[GPImageScrollView alloc] init] autorelease];
    
            [self configurePage:page forIndex:index];
            [ScrollView addSubview:page];
            [visiblePages addObject:page];
        }
    }    

}
/////////////////////////////////////////////////////////////////////////////////////
//check if page is displaying
- (BOOL)isDisplayingPageForIndex:(NSUInteger)index
{
    BOOL foundPage = NO;
    for (GPImageScrollView *page in visiblePages) 
    {
        if (page.index == index) 
        {
            foundPage = YES;
            break;
        }
    }
    return foundPage;
}
/////////////////////////////////////////////////////////////////////////////////////
//recycle the views.
- (GPImageScrollView *)dequeueRecycledPage
{
    GPImageScrollView *page = [recycledPages anyObject];
    if (page) 
    {
        [[page retain] autorelease];
        [page stopImage];
        [recycledPages removeObject:page];
    }
    return page;
}
/////////////////////////////////////////////////////////////////////////////////////
//set the image URL and frame for the image
- (void)configurePage:(GPImageScrollView *)page forIndex:(NSUInteger)index
{
    page.index = index;
    page.frame = [self frameForPageAtIndex:index];
    [page displayImage:[PhotoSource objectAtIndex:index]];
    //[self setBar:NO];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
    tap.numberOfTapsRequired = 1;
    [page addGestureRecognizer:tap];
    [tap release];
}
/////////////////////////////////////////////////////////////////////////////////////
//caculate frame size of scrollView
- (CGRect)frameForScrollView 
{
    CGRect frame = [[UIScreen mainScreen] bounds];
    frame.origin.x -= PADDING;
    frame.size.width += (2 * PADDING);
    return frame;
}
/////////////////////////////////////////////////////////////////////////////////////
//get page frame index
- (CGRect)frameForPageAtIndex:(NSUInteger)index orientation:(UIInterfaceOrientation)o
{
    CGRect bounds = ScrollView.bounds;
    CGRect pageFrame = bounds;
    if(UIInterfaceOrientationIsLandscape(o)) //swap the bounds if landscape mode
    {
        float width = pageFrame.size.height;
        pageFrame.size.height = pageFrame.size.width;
        pageFrame.size.width = width;
    }
    pageFrame.size.width -= (2 * PADDING);
    pageFrame.origin.x = (bounds.size.width * index) + PADDING;
    return pageFrame;
}
/////////////////////////////////////////////////////////////////////////////////////
//get page frame index
- (CGRect)frameForPageAtIndex:(NSUInteger)index 
{
    UIInterfaceOrientation o = [[UIApplication sharedApplication] statusBarOrientation];
    return [self frameForPageAtIndex:index orientation:o];
}
/////////////////////////////////////////////////////////////////////////////////////
//content view frame
- (CGSize)contentSizeForScrollView 
{
    // We have to use the paging scroll view's bounds to calculate the contentSize, for the same reason outlined above.
    CGRect bounds = ScrollView.bounds;
    return CGSizeMake((bounds.size.width * [PhotoSource count]) + PADDING*2, bounds.size.height);
}
/////////////////////////////////////////////////////////////////////////////////////
//rotation support
/////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}
/////////////////////////////////////////////////////////////////////////////////////
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // here, our pagingScrollView bounds have not yet been updated for the new interface orientation. So this is a good
    // place to calculate the content offset that we will need in the new orientation
    CGFloat offset = ScrollView.contentOffset.x;
    CGFloat pageWidth = ScrollView.bounds.size.width;
    
    if (offset >= 0) 
    {
        firstVisiblePageIndexBeforeRotation = floorf(offset / pageWidth);
        percentScrolledIntoFirstVisiblePage = (offset - (firstVisiblePageIndexBeforeRotation * pageWidth)) / pageWidth;
    } else 
    {
        firstVisiblePageIndexBeforeRotation = 0;
        percentScrolledIntoFirstVisiblePage = offset / pageWidth;
    }    
}
/////////////////////////////////////////////////////////////////////////////////////
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // recalculate contentSize based on current orientation
    ScrollView.contentSize = [self contentSizeForScrollView];
    
    // adjust frames and configuration of each visible page
    for (GPImageScrollView *page in visiblePages) 
    {
        CGPoint restorePoint = [page pointToCenterAfterRotation];
        CGFloat restoreScale = [page scaleToRestoreAfterRotation];
        page.frame = [self frameForPageAtIndex:page.index orientation:UIInterfaceOrientationPortrait];
        [page setMaxMinZoomScalesForCurrentBounds];
        [page restoreCenterPoint:restorePoint scale:restoreScale];
        
    }
    // adjust contentOffset to preserve page location based on values collected prior to location
    CGFloat pageWidth = ScrollView.bounds.size.width;
    CGFloat newOffset = (firstVisiblePageIndexBeforeRotation * pageWidth) + (percentScrolledIntoFirstVisiblePage * pageWidth);
    ScrollView.contentOffset = CGPointMake(newOffset, 0);
}
/////////////////////////////////////////////////////////////////////////////////////
-(void)didTap:(UITapGestureRecognizer*)sender
{
    BOOL hide = YES;
    if([[self navigationController] navigationBar].alpha == 0)
        hide = NO;
    [self setBar:hide];
}
/////////////////////////////////////////////////////////////////////////////////////
-(void)setBar:(BOOL)hide
{
    /*[[UIApplication sharedApplication] setStatusBarHidden:hide withAnimation:UIStatusBarAnimationNone];
    CGFloat alpha = hide ? 0.0 : 1.0;
    [self.navigationController.navigationBar setAlpha:alpha];
    [self.navigationController setNavigationBarHidden:hide animated:NO];*/
    if (hide) 
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.4];
    }
    
    //if (![UIApplication sharedApplication].isStatusBarHidden) 
    //[[UIApplication sharedApplication] setStatusBarHidden:hide withAnimation:NO];
    
    CGFloat alpha = hide ? 0.0 : 1.0;
    
    // Must set the navigation bar's alpha, otherwise the photo
    // view will be pushed until the navigation bar.
    UINavigationBar *navbar = [[self navigationController] navigationBar];
    [navbar setAlpha:alpha];
    
    if (hide)
        [UIView commitAnimations];
}
/////////////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////////////
-(void)setCurrentPhotoIndex:(int)index
{
    if(index < PhotoSource.count && index > 0)
    {
        CGFloat pageWidth = ScrollView.bounds.size.width;
        CGPoint point = ScrollView.contentOffset;
        point.x = index*pageWidth;
        ScrollView.contentOffset = point;
        [self updatePages];
    }
}
/////////////////////////////////////////////////////////////////////////////////////
-(void)setPhotoSource:(NSArray*)items
{
    if(!items || items.count == 0)
    {
        if(!NoPhotosLabel)
        {
            NoPhotosLabel = [[UILabel alloc] initWithFrame:self.view.bounds];
            NoPhotosLabel.text= @"This album contains no photos";
            NoPhotosLabel.textAlignment = UITextAlignmentCenter;
            NoPhotosLabel.font = [UIFont systemFontOfSize:24];
            NoPhotosLabel.textColor = [UIColor lightTextColor];
            NoPhotosLabel.backgroundColor = ScrollView.backgroundColor;
            [self.view addSubview:NoPhotosLabel];
        }
        return;
    }
    else
        [NoPhotosLabel removeFromSuperview];
    [PhotoSource release];
    PhotoSource = [[NSArray alloc] initWithArray:items];
    ScrollView.contentSize = [self contentSizeForScrollView];
    GPImageScrollView *page = [self dequeueRecycledPage];
    if (page == nil) 
        page = [[[GPImageScrollView alloc] init] autorelease];
    
    [self configurePage:page forIndex:0];
    [ScrollView addSubview:page];
    [visiblePages addObject:page];
    [self titleIndex:0];
}
/////////////////////////////////////////////////////////////////////////////////////
-(NSArray*)PhotoSource
{
    return PhotoSource;
}
/////////////////////////////////////////////////////////////////////////////////////
-(void)titleIndex:(int)index
{
    if([PhotoSource count] > 0)
    {
        int i = index+1; //because non programmers don't use 0 as an index.
        self.title = [NSString stringWithFormat:@"%d of %d",i,[PhotoSource count]];
    }
}
/////////////////////////////////////////////////////////////////////////////////////
-(void)dealloc
{
    [NoPhotosLabel release];
    [PhotoSource release];
    [ScrollView release];
    [recycledPages release];
    [visiblePages release];
    [super dealloc];
}
/////////////////////////////////////////////////////////////////////////////////////
@end
