//
//  GPImageViewer.h
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
//this is an async image loader. It follows the apple PhotoScroller example to create a custom subclass of scrollView to create the image view.

#import "GPImageScrollView.h"

@interface GPImageViewer : UIViewController<UIScrollViewDelegate>
{
    UIScrollView* ScrollView;;
    NSArray* PhotoSource; //I will probably change this to a custom datasource object
    NSMutableSet *recycledPages;
    NSMutableSet *visiblePages;
    UILabel* NoPhotosLabel;
    // these values are stored off before we start rotation so we adjust our content offset appropriately during rotation
    int firstVisiblePageIndexBeforeRotation;
    CGFloat percentScrolledIntoFirstVisiblePage;
}
@property(nonatomic,retain)NSArray* PhotoSource;
- (CGRect)frameForScrollView;
- (CGSize)contentSizeForScrollView;
- (CGRect)frameForPageAtIndex:(NSUInteger)index;
-(void)updatePages;
- (BOOL)isDisplayingPageForIndex:(NSUInteger)index;
- (GPImageScrollView *)dequeueRecycledPage;
- (void)configurePage:(GPImageScrollView *)page forIndex:(NSUInteger)index;
-(void)titleIndex:(int)index;
-(void)setBar:(BOOL)hide;
-(void)setCurrentPhotoIndex:(int)index;

@end
