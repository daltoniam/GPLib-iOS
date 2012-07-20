//
//  NSMutableAttributedString+HTMLText.h
//  GPLib
//
//  Created by Dalton Cherry on 12/2/11.
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

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

#define STRIKE_OUT @"GPStrikeOut"
#define HYPER_LINK @"GPHyperLink"
#define IMAGE_LINK @"GPImageLink"
#define VIDEO_LINK @"GPVideoLink"
#define HTML_LIST @"GPList"
#define HTML_CLOSE_LIST @"CloseGPList"
#define HTML_ORDER_LIST @"0"
#define HTML_UNORDER_LIST @"1"

#define HTML_IMAGE_DATA @"GPImageData"

@interface NSMutableAttributedString (HTMLText)

-(void)setFont:(UIFont*)font;
-(void)setFont:(UIFont*)font range:(NSRange)range;
-(void)setFontName:(NSString*)fontName size:(CGFloat)size;
-(void)setFontName:(NSString*)fontName size:(CGFloat)size range:(NSRange)range;

-(void)setTextColor:(UIColor*)color;
-(void)setTextColor:(UIColor*)color range:(NSRange)range;
-(void)setTextIsUnderlined:(BOOL)underlined;
-(void)setTextIsUnderlined:(BOOL)underlined range:(NSRange)range;
-(void)setTextBold:(BOOL)isBold range:(NSRange)range;
-(void)setTextBold:(BOOL)isBold;
-(void)setTextItalic:(BOOL)isItalic range:(NSRange)range;
-(void)setTextItalic:(BOOL)isItalic;
-(void)setTextStrikeOut:(BOOL)strikeout range:(NSRange)range;
-(void)setTextStrikeOut:(BOOL)isStrikeOut;

-(void)setTextIsHyperLink:(NSString*)hyperlink range:(NSRange)range;
-(void)setTextIsHyperLink:(NSString*)hyperlink;

-(void)setTextAlignment:(CTTextAlignment)alignment lineBreakMode:(CTLineBreakMode)lineBreakMode;
-(void)setTextAlignment:(CTTextAlignment)alignment lineBreakMode:(CTLineBreakMode)lineBreakMode range:(NSRange)range;

-(void)setFontFamily:(NSString*)fontFamily size:(CGFloat)size bold:(BOOL)isBold italic:(BOOL)isItalic range:(NSRange)range;
-(void)setFontFamily:(NSString*)fontFamily size:(CGFloat)size bold:(BOOL)isBold italic:(BOOL)isItalic;

-(void)setImageTag:(NSString*)imageURL attribs:(NSDictionary*)attribs;
-(void)setImageTag:(NSString*)imageURL range:(NSRange)range attribs:(NSDictionary*)attribs;

-(void)setYoutubeTag:(NSString*)videoURL attribs:(NSDictionary*)attribs;
-(void)setYoutubeTag:(NSString*)videoURL range:(NSRange)range attribs:(NSDictionary*)attribs;

-(NSString*)convertToHTML;
-(NSString*)spanStyle:(NSDictionary*)attributes;

+(NSMutableAttributedString*)spaceString:(NSString*)attrName value:(id)value height:(float)h width:(float)w;

@end