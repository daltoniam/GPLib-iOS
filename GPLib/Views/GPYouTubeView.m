//
//  GPYouTubeView.m
//  GPLib
//
//  Created by Dalton Cherry on 1/27/12.
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

#import "GPYouTubeView.h"

@implementation GPYouTubeView

static NSString* EmbedHTML = @"<html>\
<head>\
<style>body,html,iframe{margin:0;padding:0;}</style> \
<meta name=\"viewport\" content=\"initial-scale=1.0, user-scalable=no, width=%0.0f\"/>\
</head>\
<iframe width=\"%0.0f\" height=\"%0.0f\" src=\"%@\" frameborder=\"0\" allowfullscreen></iframe></html>";

@synthesize URL = URL;
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)loadVideo
{
    if(self.URL)
    {
        if([[self.URL lowercaseString] rangeOfString:@"youtube"].location != NSNotFound)
            self.URL = [self.URL stringByReplacingOccurrencesOfString:@"/v" withString:@"/embed"];
        NSString* html = [NSString stringWithFormat:EmbedHTML,self.frame.size.width, self.frame.size.width, self.frame.size.height,URL];
        [self loadHTMLString:html baseURL:nil];
    }
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews {
    [self stringByEvaluatingJavaScriptFromString:
     [NSString stringWithFormat:@"yt.width = %0.0f; yt.height = %0.0f", self.frame.size.width, self.frame.size.height]];
    for (id subview in self.subviews)
        if ([[subview class] isSubclassOfClass: [UIScrollView class]])
        {
            ((UIScrollView *)subview).bounces = NO;
            [(UIScrollView *)subview setShowsHorizontalScrollIndicator:NO];
            [(UIScrollView *)subview setShowsVerticalScrollIndicator:NO];
        }
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@end
