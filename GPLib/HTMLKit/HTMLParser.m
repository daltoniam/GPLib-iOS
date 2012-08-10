//
//  HTMLParser.m
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

#import "HTMLParser.h"

#import "HTMLText.h"
#import "HTMLColors.h"
#import "HTMLElements.h"
#import <libxml2/libxml/HTMLparser.h>

@implementation HTMLParser

@synthesize RawHTML = RawHTML,Embed;

static void elementDidStart(void *ctx,const xmlChar *name,const xmlChar **atts);
static void foundChars(void *ctx,const xmlChar *ch,int len);
static void elementDidEnd(void *ctx,const xmlChar *name);
static void documentDidEnd(void *ctx);
static void error( void * ctx, const char * msg, ... );

static UIColor* linkColor;
static NSString* defaultFontName;
static int defaultFontSize;
////////////////////////////////////////////////////////////////////////////////////////////////
-(id)init
{
    if(self = [super init])
    {
        SpanStyle = [[NSMutableArray alloc] init];
    }
    return self;
}
////////////////////////////////////////////////////////////////////////////////////////////////
-(id)initWithHTML:(NSString*)html
{
    if(self = [super init])
    {
        //NSLog(@"html : %@",html);
        RawHTML = [html retain];
        SpanStyle = [[NSMutableArray alloc] init];
    }
    return self;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSAttributedString*)ParseHTML 
{
    viewIndex = 0;
    HTMLText = [[NSMutableAttributedString alloc] init];
    RawHTML = [RawHTML stringByStrippingWISWIGElements];
    //NSString* document = [NSString stringWithFormat:@"<x>%@</x>", RawHTML];
    //NSData* data = [document dataUsingEncoding:RawHTML.fastestEncoding];
    
    //NSLog(@"raw HTML: %@",RawHTML);
    CFStringEncoding cfenc = CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding);
    CFStringRef cfencstr = CFStringConvertEncodingToIANACharSetName(cfenc);
    const char *enc = CFStringGetCStringPtr(cfencstr, 0);
    
    htmlSAXHandler saxHandler;
    memset( &saxHandler, 0, sizeof(saxHandler) );
    saxHandler.startElement = &elementDidStart;
    saxHandler.endElement = &elementDidEnd;
    saxHandler.characters = &foundChars;
    saxHandler.endDocument = &documentDidEnd;
    saxHandler.error = &error;
    htmlDocPtr _doc = htmlSAXParseDoc((xmlChar*)[RawHTML UTF8String],enc,&saxHandler,self);
    //xmlCleanupParser();
    free(_doc);
    return HTMLText;
}
///////////////////////////////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////////////////////////////////
//private
///////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////
//c functions that forward to objective c functions
///////////////////////////////////////////////////////////////////////////////////////////////////
void elementDidStart(void *ctx,const xmlChar *name,const xmlChar **atts)
{
    NSString* elementName = [NSString stringWithCString:(const char*)name encoding:NSUTF8StringEncoding];
    NSMutableDictionary* collect = nil;
    
    if(atts)
    {
        const xmlChar *attrib = NULL;
        collect = [NSMutableDictionary dictionary];
        int i = 0;
        NSString* key = @"";
        do
        {
            attrib = *atts;
            if(!attrib)
                break;
            if(i % 2 != 0 && i != 0)
            {
                NSString* val = [NSString stringWithCString:(const char*)attrib encoding:NSUTF8StringEncoding];
                [collect setObject:val forKey:key];
            }
            else
                 key = [NSString stringWithCString:(const char*)attrib encoding:NSUTF8StringEncoding];
            atts++;
            i++;
        }while(attrib != NULL);
    }
        
    NSString* tag = [elementName lowercaseString];
    //NSLog(@"collect: %@",collect);
    HTMLParser* parser = (HTMLParser*)ctx;
    [parser didStartElement:tag attributes:collect];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
void foundChars(void *ctx,const xmlChar *ch,int len)
{
    NSString* string = [NSString stringWithCString:(const char*)ch encoding:NSUTF8StringEncoding];
    HTMLParser* parser = (HTMLParser*)ctx;
    [parser foundCharacters:string];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
void elementDidEnd(void *ctx,const xmlChar *name)
{
    NSString* elementName = [NSString stringWithCString:(const char*)name encoding:NSUTF8StringEncoding];
    NSString* tag = [elementName lowercaseString];
    HTMLParser* parser = (HTMLParser*)ctx;
    [parser didEndElement:tag];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
void documentDidEnd(void *ctx)
{
    HTMLParser* parser = (HTMLParser*)ctx;
    [parser documentDidEnd];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
void error( void * ctx, const char * msg, ... )
{
    //va_list args;
    //va_start(args, msg);
    //NSString *retVal = [[[NSString alloc] initWithFormat:[NSString stringWithCString:msg encoding:NSUTF8StringEncoding] arguments:args] autorelease];
    //va_end(args);
    // NSLog(@"Got an error: %@ ",retVal);
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//objective c function from c functions above
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)didStartElement:(NSString*)tag attributes:(NSDictionary*)attributeDict
{
    //NSLog(@"tag did start name: %@",tag);
    if ([tag isEqualToString:@"b"] || [tag isEqualToString:@"strong"]) 
        isBold = YES;
    
    else if ([tag isEqualToString:@"i"] || [tag isEqualToString:@"em"]) 
        isItalic = YES;
    
    else if ([tag isEqualToString:@"blockquote"]) 
        isBlockQuote = YES;
    
    else if ([tag isEqualToString:@"ol"]) 
        isOrderList = YES;
    
    else if ([tag isEqualToString:@"ul"]) 
        isUnOrderList = YES;
    else if ([tag isEqualToString:@"li"])
    {
        orderListIndex++;
        isListItem= YES;
    }
    else if([tag isEqualToString:@"p"])
    {
        if([attributeDict objectForKey:@"style"])
            [self updateAlignment:[attributeDict objectForKey:@"style"]];
    }
    else if ([tag isEqualToString:@"span"]) 
    {
        //NSLog(@"span check: %@",attributeDict);
        if([attributeDict objectForKey:@"style"])
            [SpanStyle addObject:[attributeDict objectForKey:@"style"]];
    } 
    else if ([tag isEqualToString:@"embed"]) 
    {
        //NSString* thumb = [self youtubeThumb:[attributeDict objectForKey:@"src"]];
        //TO DO: UPDATE might be able to do a movie controller and play that way, stay tune
        //make youtube videos work. Add there thumb nails like so:
        //http://i.ytimg.com/vi/GUPAyGWKd6c/2.jpg
        //http://i.ytimg.com/vi/obqJtc2wuXg/2.jpg
        //so the random guid string is replace and will give a thumb nail.
        //[HTMLText release];
        //HTMLText = [[NSMutableAttributedString alloc] init];
        //NSLog(@"embed check: %@",attributeDict);
        NSMutableAttributedString* childString = nil;
        if(imageindex % 2 == 0)
            childString = [[[NSMutableAttributedString alloc] initWithString:@" "] autorelease];
        else
            childString = [[[NSMutableAttributedString alloc] initWithString:@"\n"] autorelease];
        
        NSString* h = @"250";
        NSString* w = @"280";
        if(GPIsPad())
        {
            h = @"450";
            w = @"480";
        }
        [childString  setYoutubeTag:[attributeDict objectForKey:@"src"] attribs:[NSDictionary dictionaryWithObjectsAndKeys:h,@"height",w,@"width", nil]];
        [HTMLText appendAttributedString:childString];
        imageindex++;
    } 
    else if ([tag isEqualToString:@"img"]) 
    {
        NSString* imageURL = [attributeDict objectForKey:@"src"];
        if(!imageURL)
            return;
        if(self.Embed)
        {
            //[Items addObject:HTMLText];
            //[HTMLText release];
            //HTMLText = [[NSMutableAttributedString alloc] init];
            //[Items addObject:[NSString stringWithFormat:@"img://%@",imageURL]];
            NSString* height = [attributeDict objectForKey:@"height"];
            NSString* width = [attributeDict objectForKey:@"width"];
            NSString* top = [attributeDict objectForKey:@"padding"];
            if(!height)
                height = @"150";
            if(!width)
                width = @"200";
            NSMutableAttributedString* childString = nil;
            if(imageindex % 2 == 0)
                childString = [[[NSMutableAttributedString alloc] initWithString:@" "] autorelease];
            else
                childString = [[[NSMutableAttributedString alloc] initWithString:@"\n"] autorelease];
            [childString  setImageTag:imageURL attribs:[NSDictionary dictionaryWithObjectsAndKeys:height,@"height",width,@"width",top,@"padding", nil]];
            [HTMLText appendAttributedString:childString];
            imageindex++;
        }
        else
        {
            NSMutableAttributedString* childString = [[[NSMutableAttributedString alloc] initWithString:imageURL] autorelease];
            [childString setTextIsHyperLink:[NSString stringWithFormat:@"img://%@",imageURL]];
            [childString setTextColor:[UIColor blueColor]];
            [HTMLText appendAttributedString:childString];
        }
    }
    else if ([tag isEqualToString:@"a"]) 
    {
        HyperLink = [attributeDict objectForKey:@"href"];
        //NSLog(@"a check: %@",attributeDict);
    }
    else if ([tag isEqualToString:@"br"])
    {
        NSMutableAttributedString* childString = [[[NSMutableAttributedString alloc] initWithString:@"\n"] autorelease];
        [HTMLText appendAttributedString:childString];
    }
    else if ([tag isEqualToString:@"gpview"])
    {
        float height = [[attributeDict objectForKey:@"height"] floatValue];
        float width = [[attributeDict objectForKey:@"width"] floatValue];
        float top = [[attributeDict objectForKey:@"padding"] floatValue];
        NSMutableAttributedString* childString = nil;
        if(imageindex % 2 == 0)
            childString = [[[NSMutableAttributedString alloc] initWithString:@" "] autorelease];
        else
            childString = [[[NSMutableAttributedString alloc] initWithString:@"\n"] autorelease];
        [childString setViewSpaceTag:height width:width top:top index:viewIndex];
        [HTMLText appendAttributedString:childString];
        viewIndex++;
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)foundCharacters:(NSString*)string
{
    //NSLog(@"string: Text: %@",string);
    if(string)
    {
        if(isBlockQuote)
            string = [NSString stringWithFormat:@"\t%@",string];
        if(isUnOrderList && isListItem)
        {
            string = [NSString stringWithFormat:@". %@",string];
            NSMutableAttributedString* temp = [[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@". "]] autorelease];
            [HTMLText appendAttributedString:temp];
            isListItem = NO;
        }
        if(isOrderList && isListItem)
        {
            NSMutableAttributedString* temp = [[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d. ",orderListIndex]] autorelease];
            [HTMLText appendAttributedString:temp];
            isListItem = NO;
        }
        
        NSMutableAttributedString* childString = [[[NSMutableAttributedString alloc] initWithString:string] autorelease];
        if(HyperLink)
        {
            if(!linkColor)
                linkColor = [[UIColor colorWithRed:(0.0/255.0f) green:(82.0/255.0f) blue:(204.0/255.0f) alpha:1] retain];
            [childString setTextIsHyperLink:HyperLink];
            [childString setTextColor:linkColor];
            //45 184 235 0 82 204
            //[childString setFont:[UIFont boldSystemFontOfSize:14]];
        }
        [self StyleString:childString];
        [childString setTextAlignment:Alignment lineBreakMode:kCTLineBreakByWordWrapping];
        [HTMLText appendAttributedString:childString];
    }
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)didEndElement:(NSString*)tag
{
    //NSLog(@"tag did end name: %@",tag);
    if ([tag isEqualToString:@"b"] || [tag isEqualToString:@"strong"]) 
        isBold = NO;
    else if ([tag isEqualToString:@"i"] || [tag isEqualToString:@"em"]) 
        isItalic = NO;
    else if ([tag isEqualToString:@"blockquote"]) 
        isBlockQuote = NO;
    else if ([tag isEqualToString:@"span"]) 
        [SpanStyle removeLastObject];
    else if ([tag isEqualToString:@"a"]) 
        HyperLink = nil;
    else if ([tag isEqualToString:@"ul"]) 
        isUnOrderList = NO;
    else if ([tag isEqualToString:@"ol"])
    {
        isOrderList = NO;
        orderListIndex = 0;
    }
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//append a space in case the last attribute is a img tag, or anything that creates a delegate space.
-(void)documentDidEnd
{
    NSMutableAttributedString* childString = [[[NSMutableAttributedString alloc] initWithString:@" "] autorelease];
    [HTMLText appendAttributedString:childString];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//set the style of the string
-(void)StyleString:(NSMutableAttributedString*)string
{
    int FontSize = 12;
    if(defaultFontSize)
        FontSize = defaultFontSize;
    NSString* style = [SpanStyle lastObject];
    if(style)
    {
        NSRange find = [style rangeOfString:@"font-size:"];
        if(find.location != NSNotFound)
        {
            int pos = find.location+find.length;
            NSRange end = [style rangeOfString:@";" options:0 range:NSMakeRange(pos, [style length]-pos)];
            NSString* size = [style substringWithRange:NSMakeRange(pos, end.location-pos)];
            FontSize = [self GetSize:size];
            //NSLog(@"FontSize: %d",FontSize);
        }
        find = [style rangeOfString:@"text-decoration:"];
        if(find.location != NSNotFound)
        {
            int pos = find.location+find.length;
            //NSRange end = [style rangeOfString:@";" options:0 range:NSMakeRange(pos, [style length]-pos)];
            NSString* decorations = [style substringWithRange:NSMakeRange(pos, [style length]-pos)];
            if([decorations rangeOfString:@"line-through"].location != NSNotFound)
                [string setTextStrikeOut:YES];
            if([decorations rangeOfString:@"underline"].location != NSNotFound)
                [string setTextIsUnderlined:YES];
        }
        find = [style rangeOfString:@"color:"];
        if(find.location != NSNotFound)
        {
            int pos = find.location+find.length;
            NSRange end = [style rangeOfString:@";" options:0 range:NSMakeRange(pos, [style length]-pos)];
            NSString* cssstring = [style substringWithRange:NSMakeRange(pos, end.location-pos)];
            //NSLog(@"cssstring: %@",cssstring);
            [string setTextColor:[UIColor colorWithCSS:cssstring]];
        }
        find = [style rangeOfString:@"text-align:"];
        if(find.location != NSNotFound)
        {
            int pos = find.location+find.length;
            NSRange end = [style rangeOfString:@";" options:0 range:NSMakeRange(pos, [style length]-pos)];
            NSString* align = [style substringWithRange:NSMakeRange(pos, end.location-pos)];
            if([align rangeOfString:@"right"].location != NSNotFound)
                Alignment = kCTRightTextAlignment;
            else if([align rangeOfString:@"center"].location != NSNotFound)
                Alignment = kCTCenterTextAlignment;
            else if([align rangeOfString:@"justify"].location != NSNotFound)
                Alignment = kCTJustifiedTextAlignment;
            else
                Alignment = kCTLeftTextAlignment;
            
            [string setTextAlignment:Alignment lineBreakMode:kCTLineBreakByWordWrapping];
        }
        find = [style rangeOfString:@"font-family:"];
        if(find.location != NSNotFound)
        {
            int pos = find.location+find.length;
            NSRange end = [style rangeOfString:@";" options:0 range:NSMakeRange(pos, [style length]-pos)];
            if(end.location == NSNotFound)
                end = [style rangeOfString:@"'" options:0 range:NSMakeRange(pos, [style length]-pos)];
            if(end.location == NSNotFound)
            {
                NSString* font = [style substringWithRange:NSMakeRange(pos, end.location-pos)];
                find = [font rangeOfString:@","];
                if(find.location != NSNotFound)
                    font = [font substringToIndex:find.location];
                
                font = [font stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                font = [font stringByReplacingOccurrencesOfString:@"'" withString:@""];
                for(NSString* fontName in [UIFont familyNames])
                {
                    if([[fontName lowercaseString] rangeOfString:[font lowercaseString]].location != NSNotFound)
                    {
                        font = fontName;
                        if([font rangeOfString:@"Bold"].location == NSNotFound && [font rangeOfString:@"Italic"].location == NSNotFound)
                            break;
                    }
                }
                //NSLog(@"font: %@",font);
                [string setFontFamily:font size:FontSize bold:isBold italic:isItalic];
            }
            else
                [self FontType:string Size:FontSize];
        }
        else
            [self FontType:string Size:FontSize];
    }
    else
        [self FontType:string Size:FontSize];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//set the alignment of the string
-(void)updateAlignment:(NSString*)style
{
    NSRange find = [style rangeOfString:@"text-align:"];
    if(find.location != NSNotFound)
    {
        int pos = find.location+find.length;
        NSRange end = [style rangeOfString:@";" options:0 range:NSMakeRange(pos, [style length]-pos)];
        if(end.location == NSNotFound)
            end = [style rangeOfString:@"'" options:0 range:NSMakeRange(pos, [style length]-pos)];
        if(end.location != NSNotFound)
        {
            NSString* align = [style substringWithRange:NSMakeRange(pos, end.location-pos)];
            if([align rangeOfString:@"right"].location != NSNotFound)
                Alignment = kCTRightTextAlignment;
            else if([align rangeOfString:@"center"].location != NSNotFound)
                Alignment = kCTCenterTextAlignment;
            else if([align rangeOfString:@"justify"].location != NSNotFound)
                Alignment = kCTJustifiedTextAlignment;
            else
                Alignment = kCTLeftTextAlignment;
        }
    }
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//create font type
-(void)FontType:(NSMutableAttributedString*)string Size:(int)size
{
    if(isItalic && isBold)
        [string setFontName:@"Trebuchet-BoldItalic" size:size];
     else if(isItalic)
         [string setFontName:@"TrebuchetMS-Italic" size:size];
     else if(isBold)
         [string setFontName:@"TrebuchetMS-Bold" size:size];
     else if(size != 12 && !defaultFontName)
        [string setFont:[UIFont systemFontOfSize:size]];
    else if(defaultFontName)
        [string setFont:[UIFont fontWithName:defaultFontName size:size]];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//create font type
-(int)GetSize:(NSString*)string
{
    string = [string lowercaseString];
    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if([string isEqualToString:@"xx-small"])
        return 8;
    else if([string isEqualToString:@"x-small"])
        return 10;
    else if([string isEqualToString:@"small"])
        return 12;
    else if([string isEqualToString:@"medium"])
        return 14;
    else if([string isEqualToString:@"large"])
        return 18;
    else if([string isEqualToString:@"x-large"])
        return 24;
    else if([string isEqualToString:@"xx-large"])
        return 36;
    else if([string rangeOfString:@"px"].location != NSNotFound)
        return [[string substringToIndex:2] intValue];
    return 12;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(NSString*)youtubeThumb:(NSString*)url
{
    NSRange end = [url rangeOfString:@"?"];
    if(end.location != NSNotFound)
    {
        //NSLog(@"substring: %@",[url substringWithRange:NSMakeRange(0, range.location)]);
        NSRange start = [url rangeOfString:@"/" options:NSBackwardsSearch range:NSMakeRange(0, end.location)];
        if(start.location != NSNotFound)
        {
            NSString* video_id = [url substringWithRange:NSMakeRange(start.location+1, (end.location-1)-start.location)];
            //NSLog(@"video_id: %@",video_id);
            //http://i.ytimg.com/vi/GUPAyGWKd6c/2.jpg
            return [NSString stringWithFormat:@"http://i.ytimg.com/vi/%@/0.jpg",video_id];
        }
    }
    return nil;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)dealloc
{
    [HTMLText release];
    [SpanStyle release];
    [super dealloc];
}
////////////////////////////////////////////////////////////////////////////////////////////////
//public
////////////////////////////////////////////////////////////////////////////////////////////////
+(void)setDefaultLinkColor:(UIColor*)color
{
    [linkColor release];
    linkColor = [color retain];
}
////////////////////////////////////////////////////////////////////////////////////////////////
+(void)setDefaultFont:(NSString*)fontName
{
    defaultFontName = fontName;
}
////////////////////////////////////////////////////////////////////////////////////////////////
+(void)setDefaultFontSize:(int)size
{
    defaultFontSize = size;
}
////////////////////////////////////////////////////////////////////////////////////////////////

@end
