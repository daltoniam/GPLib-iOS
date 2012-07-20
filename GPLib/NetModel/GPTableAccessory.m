//
//  GPTableAccessory.m
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

#import "GPTableAccessory.h"

@implementation GPTableAccessory

@synthesize accessoryColor,highlightedColor,hightlightImage,accessoryImage;
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)commonInit
{
    self.backgroundColor = [UIColor clearColor];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self commonInit];
    }
    return self;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(id)init
{
    if(self = [super init])
    {
        [self commonInit];
    }
    return self;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder])
    {
        [self commonInit];
    }
    return self;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)drawRect:(CGRect)rect
{
    if(accessoryImage)
    {
        [super drawRect:rect];
        if(self.highlighted && hightlightImage)
            [hightlightImage drawInRect:self.bounds];
        else
            [accessoryImage drawInRect:self.bounds];
        return;
    }
	// (x,y) is the tip of the arrow
	CGFloat x = CGRectGetMaxX(self.bounds)-3.0;;
	CGFloat y = CGRectGetMidY(self.bounds);
	const CGFloat R = 4.5;
	CGContextRef ctxt = UIGraphicsGetCurrentContext();
	CGContextMoveToPoint(ctxt, x-R, y-R);
	CGContextAddLineToPoint(ctxt, x, y);
	CGContextAddLineToPoint(ctxt, x-R, y+R);
	CGContextSetLineCap(ctxt, kCGLineCapSquare);
	CGContextSetLineJoin(ctxt, kCGLineJoinMiter);
	CGContextSetLineWidth(ctxt, 3);
    
	if (self.highlighted)
	{
		[self.highlightedColor setStroke];
	}
	else
	{
		[self.accessoryColor setStroke];
	}
    
	CGContextStrokePath(ctxt);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setHighlighted:(BOOL)highlighted
{
	[super setHighlighted:highlighted];
	[self setNeedsDisplay];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)dealloc
{
    [super dealloc];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
+(GPTableAccessory*)accessoryWithColor:(UIColor *)color highlight:(UIColor*)hightlightColor
{
    GPTableAccessory* accessory = [[[GPTableAccessory alloc] initWithFrame:CGRectMake(0, 0, 11.0, 15.0)] autorelease];
    accessory.accessoryColor = color;
    accessory.highlightedColor = hightlightColor;
    return accessory;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
+(GPTableAccessory*)accessoryWithImage:(UIImage*)image highlight:(UIImage*)hightImage
{
    GPTableAccessory* accessory = [[[GPTableAccessory alloc] initWithFrame:CGRectMake(0, 0, 11.0, 15.0)] autorelease];
    accessory.accessoryImage = image;
    accessory.hightlightImage = hightImage;
    return accessory;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
@end
