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
#import "GPYouTubeView.h"

@interface ImageItem : NSObject
{
    UIImage* imageData;
    NSString* URL;
    CGRect frame;
}
+(ImageItem*)imageItem:(UIImage*)image url:(NSString*)url frame:(CGRect)rect;
+(ImageItem*)videoItem:(GPYouTubeView*)view url:(NSString*)url frame:(CGRect)rect;
@property(nonatomic, retain) UIImage* imageData;
@property(nonatomic, copy) NSString* URL;
@property(nonatomic,assign)CGRect frame;
@property(nonatomic,retain)GPYouTubeView* videoView;
@property(nonatomic,assign)BOOL didTransform;

@end
//////////////////////////////////////////////////////////////////////////////////
@protocol HTMLTextLabelDelegate <NSObject>

@optional

//delegate options
- (void)didSelectLink:(NSString*)link;
- (void)didSelectImage:(NSString*)imageURL;
//return any frame motifications or just return imgBound if no changes desired
- (UIImage*)willLoadImage:(UIImage*)image frame:(CGRect)imgBounds;

@end

@interface HTMLTextLabel : UILabel
{
    CTFrameRef textFrame;
    NSMutableAttributedString* attributedText;
    id<HTMLTextLabelDelegate> delegate;
    NSString* CurrentHyperLink;
    NSMutableArray* imageArray;
    NSMutableArray* videoArray;
}
@property(nonatomic, assign) BOOL extendHeightToFit;
@property(nonatomic, copy) NSAttributedString* attributedText;
@property(nonatomic,assign)id<HTMLTextLabelDelegate> delegate;
@property(nonatomic,retain,readonly)NSString* rawHTML;
@property(nonatomic,assign)BOOL ignoreXAttachment;

- (id)initWithHTML:(NSString*)html embed:(BOOL)embed frame:(CGRect)frame;
- (id)initWithAttributedString:(NSAttributedString*)items;
-(void)setHTML:(NSString*)html embed:(BOOL)embed;
-(CGFloat)getTextHeight;
-(void)processHyperLink:(NSString*)link;
@end
