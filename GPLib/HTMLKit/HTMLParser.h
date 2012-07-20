//
//  HTMLParser.h
//  GPLib
//
//  Created by Dalton Cherry on 11/21/11.
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
#import "HTMLTextLabel.h"

@interface HTMLParser : NSObject
{
    @private
    NSString* RawHTML;
    NSMutableString* Chars;
    //NSMutableArray* Items;
    NSMutableAttributedString* HTMLText;
    BOOL isBold;
    BOOL isItalic;
    BOOL isBlockQuote;
    BOOL isUnOrderList;
    BOOL isOrderList;
    BOOL isListItem;
    NSString* HyperLink;
    NSMutableArray* SpanStyle;
    BOOL gotError;
    int imageindex;
    int orderListIndex;
    CTTextAlignment Alignment;
}
@property(nonatomic,copy)NSString* RawHTML;
@property(nonatomic,assign)BOOL Embed;

-(id)initWithHTML:(NSString*)html;
- (NSAttributedString*)ParseHTML;
-(void)FontType:(NSMutableAttributedString*)string Size:(int)size;
-(void)StyleString:(NSMutableAttributedString*)string;
-(int)GetSize:(NSString*)string;
-(void)updateAlignment:(NSString*)style;
-(NSString*)youtubeThumb:(NSString*)url;

-(void)didStartElement:(NSString*)tag attributes:(NSDictionary*)attributeDict;
-(void)foundCharacters:(NSString*)string;
-(void)didEndElement:(NSString*)tag;
-(void)documentDidEnd;

+(void)setDefaultLinkColor:(UIColor*)color;
+(void)setDefaultFont:(NSString*)fontName;
+(void)setDefaultFontSize:(int)size;

@end
