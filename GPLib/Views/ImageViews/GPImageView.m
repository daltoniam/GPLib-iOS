//
//  GPImageView.m
//  GPLib
//
//  Created by Dalton Cherry on 12/5/11.
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

#import "GPImageView.h"
#import "GPDrawExtras.h"
#import <QuartzCore/QuartzCore.h>
#import "GPGif.h"

@implementation GPImageView

@synthesize URL = URL,isQueue = isQueue,showProgress = showProgress,delegate = delegate,borderWidth,borderColor;

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)layoutSubviews
{
    [super layoutSubviews];
    //[self FetchImage];
    if(LoadingView)
    {
        LoadingView.frame = CGRectMake(0, 0, 24, 24);
        LoadingView.center = self.center;
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//load image from http
-(void)fetchImage
{
    if(!URL || isQueue)
        return;
    else if([URL hasPrefix:@"http"])
    {
        if(showProgress)
        {
            if(!LoadingView)
            {
                LoadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
                [self addSubview:LoadingView];
            }
            
            LoadingView.hidden = NO;
            [LoadingView startAnimating];
        }
        
        SendRequest = [[GPHTTPRequest requestWithURL:[NSURL URLWithString:URL]] retain];
        [SendRequest setCacheModel:GPHTTPCacheCustomTime];
        [SendRequest setCacheTimeout:60*60*1]; // Cache for 1 hour
        [SendRequest setDelegate:self];
        [SendRequest startAsync];
    }
    else
    {
        self.image = [UIImage imageNamed:URL];
        if(!self.image)
            self.image = [UIImage imageWithContentsOfFile:URL];
        if(!self.image)
        {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *path = [paths objectAtIndex:0];
            self.image = [UIImage imageWithContentsOfFile: [NSString stringWithFormat:@"%@/%@",path,[URL encodeURL]] ];
        }
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//cancel http load
-(void)stopImage
{
    [SendRequest cancel];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)requestFinished:(GPHTTPRequest *)request
{
    self.image = [UIImage imageWithData:[request responseData]];
    if(self.borderColor && self.borderWidth)
        self.image = [GPDrawExtras drawBorderAroundImage:self.image color:self.borderColor width:self.borderWidth rounding:self.layer.cornerRadius];
    if(showProgress)
    {
        [LoadingView stopAnimating];
        LoadingView.hidden = YES;
    }
    if([[request.responseHeaders objectForKey:@"Content-Type"] isEqualToString:@"image/gif"])
    {
        GPGif* gif = [GPGif decodeGif:[request responseData]];
        [GPGif setupImageView:self gifObject:gif];
    }
    if([self.delegate respondsToSelector:@selector(imageDidFinish:)])
        [self.delegate imageDidFinish:self];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)dealloc
{
    self.delegate = nil;
    if(SendRequest)
    {
        [SendRequest cancel];
        SendRequest.delegate = nil;
    }
    [SendRequest release];
    [LoadingView release];
    [super dealloc];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@end
