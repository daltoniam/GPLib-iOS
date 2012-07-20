//
//  GPLauncherButton.h
//  GPLib
//
//  Created by Dalton Cherry on 2/6/12.
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

#import <UIKit/UIKit.h>
#import "GPBubbleView.h"

@class GPLauncherButton;
@protocol GPLauncherButtonDelegate <NSObject>

@optional

//notify that the button has been clicked
-(void)didSelectButton:(GPLauncherButton*)button;

@end


@interface GPLauncherButton : UIView
{
    UIImageView* imageView;
    UILabel* textLabel;
    UIFont* font;
    UIImage* selectedImage;
    UIImage* normalImage;
    NSInteger badgeNumber;
    GPBubbleView* badgeView;
    id<GPLauncherButtonDelegate> delegate;
}
@property(nonatomic,retain)UILabel* textLabel;
@property(nonatomic,assign)NSInteger index;
@property(nonatomic,copy)NSString* URL;
@property(nonatomic,assign)NSInteger badgeNumber;
@property(nonatomic,retain)id<GPLauncherButtonDelegate> delegate;

-(void)setImage:(UIImage*)image;
-(UIImage *)imageWithOverlayColor:(UIImage *)baseImage color:(UIColor *)color;

+(GPLauncherButton*)buttonWithTitle:(NSString*)text image:(UIImage*)image;
+(GPLauncherButton*)buttonWithTitle:(NSString*)text image:(UIImage*)image url:(NSString*)url;
@end
