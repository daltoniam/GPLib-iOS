//
//  NSString+GPString.m
//  GPLib
//
//  Created by Dalton Cherry on 2/3/12.
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

#import "NSString+GPString.h"

@implementation NSString (GPString)

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(NSString*)encodeURL
{
    NSString * encodedURL = (NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                NULL,
                                                                                (CFStringRef)self,
                                                                                NULL,
                                                                                (CFStringRef)@"!*'\"();:@&=+$,/?%#[] ",
                                                                                kCFStringEncodingUTF8 );
    return [encodedURL autorelease];
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(NSString*)decodeURL
{
    NSString * DecodedURL = (NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(
                                                                                                NULL,
                                                                                                (CFStringRef)self,
                                                                                                CFSTR(""),
                                                                                                kCFStringEncodingUTF8 );
    return [DecodedURL autorelease];
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(NSString*)trimWhiteSpace
{
  return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(NSString *)stringByStrippingHTML
{
    NSRange r;
    NSString *s = self;
    while ((r = [s rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        s = [s stringByReplacingCharactersInRange:r withString:@""];
    s= [s stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@""];
    s = [s stringByReplacingOccurrencesOfString:@"&amp;" withString:@""];
    s = [s stringByReplacingOccurrencesOfString:@"&apos;" withString:@""];
    s = [s stringByReplacingOccurrencesOfString:@"&lt;" withString:@""];
    s = [s stringByReplacingOccurrencesOfString:@"&gt;" withString:@""];
    s = [s stringByReplacingOccurrencesOfString:@"&quot;" withString:@""];
    s = [s stringByReplacingOccurrencesOfString:@"&iexcl;" withString:@""];
    s = [s stringByReplacingOccurrencesOfString:@"&cent;" withString:@""];
    s = [s stringByReplacingOccurrencesOfString:@"&pound;" withString:@""];
    s = [s stringByReplacingOccurrencesOfString:@"&curren;" withString:@""];
    s = [s stringByReplacingOccurrencesOfString:@"&yen;" withString:@""];
    s = [s stringByReplacingOccurrencesOfString:@"&brvbar;" withString:@""];
    s = [s stringByReplacingOccurrencesOfString:@"&sect;" withString:@""];
    s = [s stringByReplacingOccurrencesOfString:@"&uml;" withString:@""];
    s = [s stringByReplacingOccurrencesOfString:@"&uml;" withString:@""];
    s = [s stringByReplacingOccurrencesOfString:@"&copy;" withString:@""];
    s = [s stringByReplacingOccurrencesOfString:@"&ordf;" withString:@""];
    s = [s stringByReplacingOccurrencesOfString:@"&laquo;" withString:@""];
    s = [s stringByReplacingOccurrencesOfString:@"&not;" withString:@""];
    s = [s stringByReplacingOccurrencesOfString:@"&shy;" withString:@""];
    s = [s stringByReplacingOccurrencesOfString:@"&reg;" withString:@""];
    s = [s stringByReplacingOccurrencesOfString:@"&macr;" withString:@""];
    s = [s stringByReplacingOccurrencesOfString:@"&deg;" withString:@""];
    s = [s stringByReplacingOccurrencesOfString:@"&plusmn;" withString:@""];
    s = [s stringByReplacingOccurrencesOfString:@"&sup2;" withString:@""];
    s = [s stringByReplacingOccurrencesOfString:@"&sup3;" withString:@""];
    s = [s stringByReplacingOccurrencesOfString:@"&acute;" withString:@""];
    s = [s stringByReplacingOccurrencesOfString:@"&micro;" withString:@""];
    s = [s stringByReplacingOccurrencesOfString:@"&para;" withString:@""];
    s = [s stringByReplacingOccurrencesOfString:@"&middot;" withString:@""];
    s = [s stringByReplacingOccurrencesOfString:@"&cedil;" withString:@""];
    s = [s stringByReplacingOccurrencesOfString:@"&ordm;" withString:@""];
    s = [s stringByReplacingOccurrencesOfString:@"&raquo;" withString:@""];
    s = [s stringByReplacingOccurrencesOfString:@"&frac14;" withString:@""];
    s = [s stringByReplacingOccurrencesOfString:@"&frac12;" withString:@""];
    s = [s stringByReplacingOccurrencesOfString:@"&frac34;" withString:@""];
    s = [s stringByReplacingOccurrencesOfString:@"&iquest;" withString:@""];
    s = [s stringByReplacingOccurrencesOfString:@"&times;" withString:@""];
    s = [s stringByReplacingOccurrencesOfString:@"&divide;" withString:@""];
    
    return s; 
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// taken from http://stackoverflow.com/questions/964322/padding-string-to-left-with-objective-c

- (NSString *) stringByPaddingTheLeftToLength:(NSUInteger) newLength withString:(NSString *) padString startingAtIndex:(NSUInteger) padIndex
{
    if ([self length] <= newLength)
        return [[@"" stringByPaddingToLength:newLength - [self length] withString:padString startingAtIndex:padIndex] stringByAppendingString:self];
    else
        return [[self copy] autorelease];
}


@end
