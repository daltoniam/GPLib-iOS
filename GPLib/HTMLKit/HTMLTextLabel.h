//
//  HTMLTextLabel.h
//  GPLib
//
//  Created by Dalton Cherry on 11/22/11.
//  Copyright (c) 2011 Basement Crew/180 Dev Designs. All rights reserved.
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

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import "GPHTTPRequest.h"

@interface ImageItem : NSObject
{
    UIImage* imageData;
    NSString* URL;
    CGRect frame;
}
+(ImageItem*)imageItem:(UIImage*)image url:(NSString*)url frame:(CGRect)rect;
+(ImageItem*)videoItem:(UIView*)view url:(NSString*)url frame:(CGRect)rect;
+(ImageItem*)viewItem:(UIView*)view frame:(CGRect)rect;
@property(nonatomic, retain) UIImage* imageData;
@property(nonatomic, copy) NSString* URL;
@property(nonatomic,assign)CGRect frame;
@property(nonatomic,retain)UIView* subView;
@property(nonatomic,assign)BOOL didTransform;

@end
//////////////////////////////////////////////////////////////////////////////////
@protocol HTMLTextLabelDelegate <NSObject>

@optional

//delegate options
- (void)didSelectLink:(NSString*)link;
- (void)didLongPressLink:(NSString*)link frame:(CGRect)frame;
- (void)didSelectImage:(NSString*)imageURL;
- (void)didLongPressImage:(NSString*)imageURL;
//return any frame motifications or just return imgBound if no changes desired
- (UIImage*)willLoadImage:(UIImage*)image frame:(CGRect)imgBounds;
-(void)imageFinished:(NSString*)url height:(int)height width:(int)width;
//return the view you want to use a subview
-(UIView*)subViewWillLoad:(int)index;

@end

@interface HTMLTextLabel : UILabel<GPHTTPRequestDelegate>
{
    CTFrameRef textFrame;
    NSMutableAttributedString* attributedText;
    id<HTMLTextLabelDelegate> delegate;
    NSString* CurrentHyperLink;
    NSMutableArray* imageArray;
    NSMutableArray* videoArray;
    NSMutableArray* viewArray;
    BOOL isDrawing;
    BOOL isLongPress;
    NSMutableArray* requestArray;
}
@property(nonatomic, assign) BOOL extendHeightToFit;
@property(nonatomic, assign) BOOL autoSizeImages;
@property(nonatomic, copy) NSAttributedString* attributedText;
@property(nonatomic,assign)id<HTMLTextLabelDelegate> delegate;
@property(nonatomic,retain,readonly)NSString* rawHTML;
@property(nonatomic,assign)BOOL ignoreXAttachment;
//@property(nonatomic,assign)CTFramesetterRef cachedFramesetter;

- (id)initWithHTML:(NSString*)html embed:(BOOL)embed frame:(CGRect)frame;
- (id)initWithAttributedString:(NSAttributedString*)items;
-(void)setHTML:(NSString*)html embed:(BOOL)embed;
-(void)setAttributedString:(NSAttributedString *)string height:(CGFloat)height frame:(CTFramesetterRef)framesetter;
-(void)setAttributedString:(NSAttributedString *)string height:(CGFloat)height;
-(CGFloat)getTextHeight;
-(void)processHyperLink:(NSString*)link;
@end
