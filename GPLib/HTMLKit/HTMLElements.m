//
//  HTMLElements.m
//  GPLib
//
//  Created by Dalton Cherry on 12/9/11.
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

#import "HTMLElements.h"
#import "HTMLColors.h"

@implementation  NSString (HTMLElements)

////////////////////////////////////////////////////////////////////////////////////////
//returns your url string in a html img tag
-(NSString*)HTMLParagraph
{
    return [NSString stringWithFormat:@"<p>%@</p>",self];
}
////////////////////////////////////////////////////////////////////////////////////////
//returns your url string in a html img tag
-(NSString*)HTMLParagraph:(UITextAlignment)align
{
    NSString* alignment = @"text-align: ";
    if(align == UITextAlignmentCenter)
        alignment = [alignment stringByAppendingString:@"center;"];
    else if(align == UITextAlignmentRight)
        alignment = [alignment stringByAppendingString:@"right;"];
    else
        alignment = [alignment stringByAppendingString:@"left;"];
    return [NSString stringWithFormat:@"<p style=\"%@\">%@</p>",alignment,self];
}
////////////////////////////////////////////////////////////////////////////////////////
//returns your text (more than likely already wrap in some kind of other tag) in a html span tag
-(NSString*)HTMLSpan:(NSString*)style
{
    return [NSString stringWithFormat:@"<span style=\"%@\">%@</span>",style,self];
}
////////////////////////////////////////////////////////////////////////////////////////
//returns your text string in a html bold tag
-(NSString*)HTMLBold
{
    return [NSString stringWithFormat:@"<b>%@</b>",self];
}
////////////////////////////////////////////////////////////////////////////////////////
//returns image tag
-(NSString*)HTMLImg
{
    return [NSString stringWithFormat:@"<img src=\"%@\" />",self];
}
////////////////////////////////////////////////////////////////////////////////////////
//returns image tag with size
-(NSString*)HTMLImg:(float)height width:(float)width
{
    return [NSString stringWithFormat:@"<img src=\"%@\" height=\"%f\" width=\"%f\"/>",self,height,width];
}
////////////////////////////////////////////////////////////////////////////////////////
//returns image tag with size and top padding
-(NSString*)HTMLImg:(float)height width:(float)width top:(float)top
{
    return [NSString stringWithFormat:@"<img src=\"%@\" height=\"%f\" width=\"%f\" padding=\"%f\"/>",self,height,width,top];
}
////////////////////////////////////////////////////////////////////////////////////////
//returns embed tag
-(NSString*)HTMLEmbed
{
    return [NSString stringWithFormat:@"<embed src=\"%@\"/>",self];
}
////////////////////////////////////////////////////////////////////////////////////////
//returns anchor tag
-(NSString*)HTMLLink:(NSString*)link
{
    return [NSString stringWithFormat:@"<a href=\"%@\">%@</a>",link,self];
}
////////////////////////////////////////////////////////////////////////////////////////
//returns your url string in a html img tag
+(NSString*)HTMLStyle:(UIColor*)color
{
    return [self HTMLStyle:color fontSize:0];
}
////////////////////////////////////////////////////////////////////////////////////////
//returns span style
+(NSString*)HTMLStyleSize:(int)size
{
    return [self HTMLStyle:nil fontSize:size];
}
////////////////////////////////////////////////////////////////////////////////////////
//returns span style
+(NSString*)HTMLStyle:(UIColor*)color fontSize:(int)size
{
    return [self HTMLStyle:color fontSize:size underline:NO strikethrough:NO];
}
////////////////////////////////////////////////////////////////////////////////////////
//returns span style
+(NSString*)HTMLStyle:(UIColor*)color fontSize:(int)size underline:(BOOL)under strikethrough:(BOOL)strike
{
    NSString* colorformat = @"";
    NSString* sizeformat = @"";
    NSString* underlineformat = @"";
    //NSLog(@"CSS value: %@",[color CSSValue]);
    if(color)
        colorformat = [NSString stringWithFormat:@"color:%@;",[color CSSValue]];
    if(size)
        sizeformat = [NSString stringWithFormat:@"font-size:%dpx;",size];
    if(under || strike)
    {
        NSString* sline = @"";
        NSString* uline = @"";
        if(under)
            uline = @"underline;";
        if(strike)
            sline = @"line-through;";
        underlineformat = [NSString stringWithFormat:@"text-decoration: %@ %@",sline,uline];
    }
    NSString* temp = [NSString stringWithFormat:@"%@ %@ %@",colorformat,sizeformat,underlineformat];
    //NSLog(@"check format: %@",temp);
    return temp;
}
////////////////////////////////////////////////////////////////////////////////////////
//returns image tag with size
+(NSString*)HTMLView:(float)height width:(float)width
{
    return [NSString stringWithFormat:@"<gpview height=\"%f\" width=\"%f\"/>",height,width];
}
////////////////////////////////////////////////////////////////////////////////////////
//returns image tag with size and top padding
+(NSString*)HTMLView:(float)height width:(float)width top:(float)top
{
    return [NSString stringWithFormat:@"<gpview height=\"%f\" width=\"%f\" padding=\"%f\"/>",height,width,top];
}
////////////////////////////////////////////////////////////////////////////////////////
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
////////////////////////////////////////////////////////////////////////////////////////
-(NSString *)stringByStrippingWISWIGElements
{
    NSString *s = self;
    NSRange r;
    // !p|b|strong|span|i|em|img|a
    while ((r = [s rangeOfString:@"<mbc[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
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
    s = [s stringByReplacingOccurrencesOfString:@"&#39;" withString:@""];
    s = [s stringByReplacingOccurrencesOfString:@"&#039;" withString:@""];
    
    s = [s stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
    
    return s; 
}
@end
