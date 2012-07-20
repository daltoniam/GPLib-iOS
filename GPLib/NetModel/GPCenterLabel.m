//
//  GPCenterLabel.m
//  GPLib
//
//  Created by Dalton Cherry on 11/2/11.
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

#import "GPCenterLabel.h"

@implementation GPCenterLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        self.backgroundColor = [UIColor whiteColor];
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, (frame.size.height/2)-20, frame.size.width, 20)];
        label.textAlignment = UITextAlignmentCenter;
        label.text = @"No Internet Connection";
        label.textColor = [UIColor darkGrayColor];
        label.shadowColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
        label.shadowOffset = CGSizeMake(0.0f, 1.0f);
        label.font = [UIFont boldSystemFontOfSize:17];
        [self addSubview:label];
        
        UILabel* lowerlabel = [[UILabel alloc] initWithFrame:CGRectMake(0,(label.frame.origin.y + label.frame.size.height)+10, frame.size.width, 20)];
        lowerlabel.textAlignment = UITextAlignmentCenter;
        lowerlabel.textColor = [UIColor darkGrayColor];
        lowerlabel.shadowColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
        lowerlabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
        lowerlabel.text = @"There was an error loading the stream";
        lowerlabel.font = [UIFont boldSystemFontOfSize:12];
        [self addSubview:lowerlabel];
        
        [label release];
        [lowerlabel release];
    }
    return self;
}

@end
