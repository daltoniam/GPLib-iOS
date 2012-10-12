//
//  GPSideBarView.h
//  GPLib
//
//  Created by Dalton Cherry on 10/4/12.
//  Copyright (c) 2012 Lightspeed Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GPSideBarView : UIView
{
    BOOL isShowing;
    UIView* sideMenu;
    UIScrollView* sideScroll;
    UIView* smokeView;
}
@property(nonatomic,assign)BOOL showFromRight;

-(void)show;

@end
