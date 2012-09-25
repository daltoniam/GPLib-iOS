//
//  GPTabBarItem.h
//  GPLib
//
//  Created by Dalton Cherry on 5/21/12.
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
//TODO: add nipple if you want to use it.

#import <UIKit/UIKit.h>

@class GPTabBarItem;
//////////////////////////////////////////////////////////////////////////////////
@protocol GPTabBarItemDelegate <NSObject>

@optional

-(void)didSelectTab:(GPTabBarItem*)tabItem;
-(UIImage*)glowImage;

@end
//////////////////////////////////////////////////////////////////////////////////

@interface GPTabBarItem : UIView
{
    BOOL isSelected;
    UIImageView* imageView;
    UILabel* titleLabel;
}

@property (nonatomic, retain) UIColor* gradientStartColor;
@property (nonatomic, retain) UIColor* gradientEndColor;
@property (nonatomic, retain) UIColor* selectedColor;
@property (nonatomic, readonly) BOOL isSelected;

@property (nonatomic, assign)CGFloat gradientLength;
@property (nonatomic, assign)BOOL drawGloss;
@property(nonatomic,assign)NSInteger rounding;
@property(nonatomic,retain)UIColor* fillColor;

@property(nonatomic,assign)CGFloat borderWidth;
@property(nonatomic,retain)UIColor* borderColor;

@property(nonatomic,retain)UILabel* titleLabel;
@property(nonatomic,retain)UIColor* imageColor;
@property(nonatomic,retain)UIColor* selectedImageColor;
@property(nonatomic,retain)UIImage* image;
@property(nonatomic,retain)UIImage* selectedImage;

@property(nonatomic,assign)id<GPTabBarItemDelegate>delegate;

@property(nonatomic,assign)NSInteger tabIndex; //index in tab bar

@property(nonatomic,assign)BOOL imageFill;
@property(nonatomic,assign)BOOL centerImage;

//simulates a touch of the button
-(void)swapState:(BOOL)selected;
-(void)setGlowState:(BOOL)on;


@end
