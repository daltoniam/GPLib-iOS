//
//  GPDragToRefreshView.m
//  GPLib
//
//  Created by Dalton Cherry on 12/16/11.
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

#import "GPDragToRefreshView.h"
#import "UIImage+Additions.h"
#import <QuartzCore/QuartzCore.h>

@implementation GPDragToRefreshView

@synthesize textColor = _textColor,arrowImage = _arrowImage,shadowColor = _shadowColor;

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showActivity:(BOOL)shouldShow animated:(BOOL)animated {
    if (shouldShow)
        [activityView startAnimating];
        
     else
        [activityView stopAnimating];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:(animated ? 0.2 : 0.0)];
    arrowImage.alpha = (shouldShow ? 0.0 : 1.0);
    [UIView commitAnimations];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setImageFlipped:(BOOL)flipped {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    [arrowImage layer].transform = (flipped ?
                                     CATransform3DMakeRotation(M_PI * 2, 0.0f, 0.0f, 1.0f) :
                                     CATransform3DMakeRotation(M_PI, 0.0f, 0.0f, 1.0f));
    [UIView commitAnimations];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSObject


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame 
{
    if (self = [super initWithFrame:frame]) 
    {
        self.textColor = [UIColor colorWithRed:109/255.0f  green:128/255.0f  blue:153/255.0f  alpha:1];
        self.shadowColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        lastUpdatedLabel = [[UILabel alloc]
                             initWithFrame:CGRectMake(0.0f, frame.size.height - 30.0f,
                                                      frame.size.width, 20.0f)];
        lastUpdatedLabel.autoresizingMask =
        UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
        lastUpdatedLabel.font            = [UIFont systemFontOfSize:12.0f];
        lastUpdatedLabel.textColor       = self.textColor;
        lastUpdatedLabel.shadowColor     = self.shadowColor;
        lastUpdatedLabel.shadowOffset    = CGSizeMake(0.0f, 1.0f);
        lastUpdatedLabel.backgroundColor = [UIColor clearColor];
        lastUpdatedLabel.textAlignment   = UITextAlignmentCenter;
        [self addSubview:lastUpdatedLabel];
        
        statusLabel = [[UILabel alloc]
                        initWithFrame:CGRectMake(0.0f, frame.size.height - 48.0f,
                                                 frame.size.width, 20.0f )];
        statusLabel.autoresizingMask =
        UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
        statusLabel.font             = [UIFont boldSystemFontOfSize:14.0f];
        statusLabel.textColor        = self.textColor;//[UIColor colorWithRed:109/255.0f  green:128/255.0f  blue:153/255.0f  alpha:1];
        statusLabel.shadowColor      = self.shadowColor;
        statusLabel.shadowOffset     = CGSizeMake(0.0f, 1.0f);
        statusLabel.backgroundColor  = [UIColor clearColor];
        statusLabel.textAlignment    = UITextAlignmentCenter;
        [self setStatus:GPTableHeaderDragRefreshPullToReload];
        [self addSubview:statusLabel];
        
        UIImage* image = [UIImage libraryImageNamed:@"blueArrow.png"];
        arrowImage = [[UIImageView alloc]
                       initWithFrame:CGRectMake(25.0f, frame.size.height - 60.0f,
                                                image.size.width, image.size.height)];
        arrowImage.image = image;
        [arrowImage layer].transform = CATransform3DMakeRotation(M_PI, 0.0f, 0.0f, 1.0f);
        [self addSubview:arrowImage];
        
        activityView = [[UIActivityIndicatorView alloc]
                         initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityView.frame = CGRectMake( 30.0f, frame.size.height - 38.0f, 20.0f, 20.0f );
        activityView.hidesWhenStopped  = YES;
        [self addSubview:activityView];
    }
    return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setTextColor:(UIColor *)color
{
    statusLabel.textColor = color;
    lastUpdatedLabel.textColor = color;
    _textColor = color;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setShadowColor:(UIColor *)color
{
    statusLabel.shadowColor = color;
    lastUpdatedLabel.shadowColor = color;
    _shadowColor = color;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setArrowImage:(UIImage *)arrow
{
    arrowImage.image = arrow;
    _arrowImage = arrow;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc 
{
    [activityView release];
    [statusLabel release];
    [arrowImage release];
    [lastUpdatedLabel release];
    [lastUpdatedDate release];
    [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setUpdateDate:(NSDate*)newDate 
{
    if (newDate) 
    {
        if (lastUpdatedDate != newDate)
            [lastUpdatedDate release];
        
        lastUpdatedDate = [newDate retain];
        
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterShortStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        lastUpdatedLabel.text = [NSString stringWithFormat:@"Last updated: %@",
                                  [formatter stringFromDate:lastUpdatedDate]];
        [formatter release];
        
    } 
    else 
    {
        lastUpdatedDate = nil;
        lastUpdatedLabel.text = @"Last updated: never";
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setCurrentDate {
    [self setUpdateDate:[NSDate date]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setStatus:(GPTableHeaderDragRefreshStatus)status 
{
    switch (status) 
    {
        case GPTableHeaderDragRefreshReleaseToReload: 
        {
            [self showActivity:NO animated:NO];
            [self setImageFlipped:YES];
            statusLabel.text = @"Release to update...";
            break;
        }
            
        case GPTableHeaderDragRefreshPullToReload: 
        {
            [self showActivity:NO animated:NO];
            [self setImageFlipped:NO];
            statusLabel.text = @"Pull down to update...";
            break;
        }
            
        case GPTableHeaderDragRefreshLoading: 
        {
            [self showActivity:YES animated:YES];
            [self setImageFlipped:NO];
            statusLabel.text = @"Updating...";
            break;
        }
            
        default: 
        {
            break;
        }
    }
}
///////////////////////////////////////////////////////////////////////////////////////////////////

@end
