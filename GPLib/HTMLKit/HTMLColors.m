//
//  HTMLColors.m
//  GPLib
//
//  Created by Dalton Cherry on 12/6/11.
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

#import "HTMLColors.h"
#import "NSString+GPString.h"

@implementation UIColor (HTMLColors)

////////////////////////////////////////////////////////////////////////////////////////////////////
+ (UIColor*) colorWithCSS:(NSString*)css 
{
	if (css == nil || [css length] == 0)
		return [UIColor blackColor];
    
	if ([css characterAtIndex:0] == '#')
		css = [css substringFromIndex:1];
    
	NSString *a, *r, *g, *b;
    
	int len = [css length];
	if (len == 6) {
	six:
		a = @"FF";
		r = [css substringWithRange:NSMakeRange(0, 2)];
		g = [css substringWithRange:NSMakeRange(2, 2)];
		b = [css substringWithRange:NSMakeRange(4, 2)];
	}
	else if (len == 8) {
	eight:
		a = [css substringWithRange:NSMakeRange(0, 2)];
		r = [css substringWithRange:NSMakeRange(2, 2)];
		g = [css substringWithRange:NSMakeRange(4, 2)];
		b = [css substringWithRange:NSMakeRange(6, 2)];
	}
	else if (len == 3) {
	three: 
		a = @"FF";
		r = [css substringWithRange:NSMakeRange(0, 1)];
		r = [r stringByAppendingString:a];
		g = [css substringWithRange:NSMakeRange(1, 1)];
		g = [g stringByAppendingString:a];
		b = [css substringWithRange:NSMakeRange(2, 1)];
		b = [b stringByAppendingString:a];
	}
	else if (len == 4) {
		a = [css substringWithRange:NSMakeRange(0, 1)];
		a = [a stringByAppendingString:a];
		r = [css substringWithRange:NSMakeRange(1, 1)];
		r = [r stringByAppendingString:a];
		g = [css substringWithRange:NSMakeRange(2, 1)];
		g = [g stringByAppendingString:a];
		b = [css substringWithRange:NSMakeRange(3, 1)];
		b = [b stringByAppendingString:a];
	}
	else if (len == 5 || len == 7) {
		css = [@"0" stringByAppendingString:css];	
		if (len == 5) goto six;
		goto eight;
	}
	else if (len < 3) {
		css = [css stringByPaddingTheLeftToLength:3 withString:@"0" startingAtIndex:0];	
		goto three;
	}
	else if (len > 8) {
		css = [css substringFromIndex:len-8];
		goto eight;
	}
	else {
		css = @"FF000000";
		goto eight;
	}
    
	// parse each component separetely. This gives more accurate results than 
	// throwing it all together in one string and use scanf on the global string.
	a = [@"0x" stringByAppendingString:a];
	r = [@"0x" stringByAppendingString:r];
	g = [@"0x" stringByAppendingString:g];
	b = [@"0x" stringByAppendingString:b];
    
	uint av, rv, gv, bv;
	sscanf([a cStringUsingEncoding:NSASCIIStringEncoding], "%x", &av);
	sscanf([r cStringUsingEncoding:NSASCIIStringEncoding], "%x", &rv);
	sscanf([g cStringUsingEncoding:NSASCIIStringEncoding], "%x", &gv);
	sscanf([b cStringUsingEncoding:NSASCIIStringEncoding], "%x", &bv);
    
    if(av == 0)
        av = 1;
    
    //NSLog(@"rv: %u",rv);
    //NSLog(@"gv: %u",gv);
    //NSLog(@"bv: %u",bv);
    //NSLog(@"av: %u",av);
    
	return [UIColor colorWithRed: rv / ((CGFloat)0xFF) 
						   green: gv / ((CGFloat)0xFF) 
							blue: bv / ((CGFloat)0xFF)
						   alpha: 1]; //av / ((CGFloat)0xFF)
}
////////////////////////////////////////////////////////////////////////////////////////////////////
+ (UIColor*) colorWithHex: (uint)hex {
	CGFloat red, green, blue, alpha;
    
	red = ((CGFloat)((hex >> 16) & 0xFF)) / ((CGFloat)0xFF);
	green = ((CGFloat)((hex >> 8) & 0xFF)) / ((CGFloat)0xFF);
	blue = ((CGFloat)((hex >> 0) & 0xFF)) / ((CGFloat)0xFF);
	alpha = hex > 0xFFFFFF ? ((CGFloat)((hex >> 24) & 0xFF)) / ((CGFloat)0xFF) : 1;
	return [UIColor colorWithRed: red green:green blue:blue alpha:alpha];
}
////////////////////////////////////////////////////////////////////////////////////////////////////
+ (UIColor*)colorFromRGB:(float)red green:(float)green blue:(float)blue alpha:(float)alpha
{
    return [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:alpha];
}
////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)getRGBComponents:(CGFloat [3])components 
{
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char resultingPixel[4];
    CGContextRef context = CGBitmapContextCreate(&resultingPixel,
                                                 1,
                                                 1,
                                                 8,
                                                 4,
                                                 rgbColorSpace,
                                                 kCGImageAlphaNoneSkipLast);
    CGContextSetFillColorWithColor(context, [self CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, 1, 1));
    CGContextRelease(context);
    CGColorSpaceRelease(rgbColorSpace);
    
    for (int component = 0; component < 3; component++) {
        components[component] = resultingPixel[component] / 255.0f;
    }
}
////////////////////////////////////////////////////////////////////////////////////////////////////
-(NSString*)CSSValue
{
    CGFloat components[3];
    [self getRGBComponents:components];
    //NSLog(@"red: %f blue: %f green: %f",components[0],components[1],components[2]);
    if(components[0] == 0.0f && components[1] == 0.0f && components[2] == 0.0f)
        return @"#000000";
    uint red = components[0]*0xFF;
    uint green = components[1]*0xFF;
    uint blue = components[2]*0xFF;
    uint rgb = (blue) | ((green << 8)) | ((red << 16));
    //(red << 16) | (green << 8) | blue;
    //NSLog(@"rbg: %u",rgb);
    //NSLog(@"hex: %x",rgb);
    //rgb = blue | (green << 8) | (red << 16);
    NSString* value = [NSString stringWithFormat:@"#%x",rgb];
    //if the string is short, then we need to swap and make blue the domaint color
    if(value.length < 4)
    {
        value = [value substringFromIndex:1];
        value = [NSString stringWithFormat:@"#0000%@",value];
    }
    else if(value.length < 6)
    {
        value = [value substringFromIndex:1];
        value = [NSString stringWithFormat:@"#00%@",value];
    }
    //NSLog(@"color value: %@",value);
    return value;
}


@end
