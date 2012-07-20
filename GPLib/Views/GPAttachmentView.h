//
//  GPAttachmentView.h
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

@class GPAttachmentView;
@protocol GPAttachmentViewDelegate <NSObject>

@optional

//notify that the image is done loading
-(void)didTapView:(GPAttachmentView*)view index:(int)index;

@end

@interface GPAttachmentView : UIView<UIScrollViewDelegate>
{
    UIScrollView* contentView;
    NSMutableArray* attachmentViews;
    UIPageControl* pageControl;
}

-(void)addAttachment:(NSString*)url text:(NSString*)text contentMode:(UIViewContentMode)mode backColor:(UIColor*)color;
-(void)addAttachment:(NSString*)url text:(NSString*)text;
-(void)removeAllItems;
-(void)removeViewAtIndex:(int)index;
-(UIView*)viewAtIndex:(int)index;

@property(nonatomic,assign)id<GPAttachmentViewDelegate>delegate;
@property(nonatomic,assign)BOOL isGridStyle;
@property(nonatomic,assign)NSInteger gridPageCount;

@end
