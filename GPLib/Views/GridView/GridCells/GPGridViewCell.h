//
//  GPGridViewCell.h
//  GPLib
//
//  Created by Dalton Cherry on 4/6/12.
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
//handles centering and draw a highlight over the view in the grid.
//basically this is a container for the view you want to display

#import <QuartzCore/QuartzCore.h>
#import "GPLoadingLabel.h"

@class GPGridViewCell;

@protocol GPGridCellDelegate <NSObject>

@optional
/*!
 Called when the grid view loads.
 */
-(void)gridCellWasSelected:(GPGridViewCell*)gridView;
-(void)gridTextLabelWasSelected:(UIButton*)textLabel cell:(GPGridViewCell*)cell;
@end


@interface GPGridViewCell : UIView
{
    NSInteger columnIndex;
    NSInteger rowIndex;
    CAGradientLayer* touchLayer;
    BOOL isSelected;
    UIImageView* imageView;
    //UILabel* textLabel;
    UIButton* textLabel;
    UIView* blankView;
    GPLoadingLabel* loadingLabel;
    BOOL drawShadow;
    UIImageView* containerView;
    UILabel* lowerTextLabel;
    BOOL isLowerText;
    BOOL isLoading;
}
@property(nonatomic,assign)NSInteger columnIndex;
@property(nonatomic,assign)NSInteger rowIndex;
@property(nonatomic,copy)NSString* identifier;
@property(nonatomic,assign)id<GPGridCellDelegate>delegate;
@property(nonatomic,retain,readonly)UIImageView* imageView;
@property(nonatomic,retain,readonly)UIButton* textLabel;

-(id)initWithIdentifer:(NSString*)indent;
-(void)setObject:(id)object;
-(UIView*)expandView;
-(void)isLoadingState:(BOOL)state;

-(void)setupImageView;
-(void)setupTextLabel;
-(void)setupBlankView;

-(void)isSelected:(BOOL)selected;

-(void)setImage:(UIImage*)image;

@end
