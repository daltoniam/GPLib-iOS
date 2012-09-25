///////////////////////////////////////////////////////////////////////////////////////////////////
//
//  GPSlideView.h
//  GPLib
//
//  Created by Dalton Cherry on 9/25/12.
//  Copyright (c) 2012 Basement Krew. All rights reserved.
//
// special view that binds to the window that slides in a view.
///////////////////////////////////////////////////////////////////////////////////////////////////

#import <UIKit/UIKit.h>

typedef enum {
    GPSlideViewTop,
    GPSlideViewLeft,
    GPSlideViewRight,
    GPSlideViewBottom
} GPSlideViewDirection;

@interface GPSlideView : UIView
{
    CGRect oFrame;
    GPSlideViewDirection slideD;
}
@property(nonatomic,retain)UIView* displayView;

-(id)initWithView:(UIView*)slideView;
-(void)show:(GPSlideViewDirection)direction;
-(void)dismiss:(GPSlideViewDirection)direction;
-(void)dismiss;

+(CGRect)windowBounds;
+(void)addViewShadow:(UIView*)view;
@end
