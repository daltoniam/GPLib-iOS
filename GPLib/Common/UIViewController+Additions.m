//
//  UIViewController+Additions.m
//  GPLib
//
//  Created by Dalton Cherry on 4/9/12.
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

#import "UIViewController+Additions.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIViewController (Additions)

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)expandView:(UIView*)view toViewController:(UIViewController*)viewController
{
    CGRect sourceRect = [view convertRect:view.bounds toView:self.view];
    CGPoint sourceCenter = CGPointMake(CGRectGetMidX(sourceRect), CGRectGetMidY(sourceRect));
    CGPoint targetCenter = self.view.center;
    
    targetCenter.y -= 44;
    view.hidden = NO;
    
    CGFloat sourceAspect = sourceRect.size.width / sourceRect.size.height;
    CGFloat targetAspect = self.view.frame.size.width / self.view.frame.size.height;
    CGFloat scale = 1.0;
    if (sourceAspect > targetAspect)
        scale = self.view.frame.size.width / sourceRect.size.width;
    else
        scale = self.view.frame.size.height / sourceRect.size.height;

    CATransform3D t = CATransform3DScale(CATransform3DIdentity, scale, scale, 2.0);
    float y = (targetCenter.y - sourceCenter.y)/scale;
    float x = (targetCenter.x - sourceCenter.x)/scale;
    
    [UIView animateWithDuration:0.5
                     animations:^(void) {
                         view.layer.transform = CATransform3DTranslate(t,x,y,0);
                         
                     } completion:^(BOOL finished) {
                         UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
                         [self presentModalViewController:navigationController animated:NO];
                         [navigationController release];
                         view.hidden = YES;
                     }];
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)dismissExpandViewController:(UIView*)view
{
    CGFloat scale = 1.0;
    view.hidden = NO;
    [self dismissModalViewControllerAnimated:NO];

    CATransform3D t = CATransform3DScale(CATransform3DIdentity, scale, scale, 1.0);
    float y = 0;
    float x = 0;    
    
    [UIView animateWithDuration:0.5
                     animations:^(void) {
                         view.layer.transform = CATransform3DTranslate(t,x,y,0);
                         
                     } completion:^(BOOL finished) {
                     }];
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@end
