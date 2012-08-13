
/*Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.*/

//
//  HTMLTextView.m
//  GPLib
//
//  Created by Dalton Cherry on 12/12/11.
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
// most of this code is from the ego textview. Huge props to all
//contrubitors to that project as this gave lots of ground work for this class


#import "HTMLTextView.h"
#include <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>
#import "HTMLText.h"
//temp; remove after testing
#import "HTMLTextLabel.h"
#import "UIImage+Additions.h"

@implementation HTMLTextView

@synthesize autocapitalizationType;
@synthesize autocorrectionType;        
@synthesize keyboardType;                       
@synthesize keyboardAppearance;             
@synthesize returnKeyType;                    
@synthesize enablesReturnKeyAutomatically; 
@synthesize attributedString = attributedString;
@synthesize stringAttributes = stringAttributes;
@synthesize delegate = delegate;
@synthesize editable = editable;
@synthesize defaultAttributes;
@synthesize correctionAttributes;
@synthesize menuItemActions;
@synthesize correctionRange;
@synthesize font;
@synthesize selectedRange;
@synthesize markedRange;
@synthesize markedTextStyle=_markedTextStyle;
@synthesize inputDelegate=_inputDelegate;
@synthesize imageArray = imageArray;
@synthesize textArray = textArray;
@synthesize videoArray = videoArray;

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)commonInit 
{
    imageArray = [[NSMutableArray alloc] init];
    textArray = [[NSMutableArray alloc] init];
    videoArray = [[NSMutableArray alloc] init];
    self.alwaysBounceVertical = YES;
    self.editable = YES;
    self.backgroundColor = [UIColor whiteColor];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.clipsToBounds = YES;
    
    HTMLContentView *contentView = [[HTMLContentView alloc] initWithFrame:CGRectInset(self.bounds, 8.0f, 8.0f)];
    contentView.autoresizingMask = self.autoresizingMask;
    contentView.delegate = self;
    [self addSubview:contentView];
    textContentView = [contentView retain];
    [contentView release];
    
    UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    gesture.delegate = (id<UIGestureRecognizerDelegate>)self;
    [self addGestureRecognizer:gesture];
    [gesture release];
    longPress = gesture;
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    [doubleTap setNumberOfTapsRequired:2];
    [self addGestureRecognizer:doubleTap];
    [doubleTap release];
    
    UITapGestureRecognizer *singleTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self addGestureRecognizer:singleTap];
    [singleTap release];
    if(!self.font)
        self.font = [UIFont systemFontOfSize:12];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frameSize 
{
    if ((self = [super initWithFrame:frameSize]))
        [self commonInit];

    return self;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init 
{
    if ((self = [self initWithFrame:CGRectZero])) {}
    return self;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithCoder: (NSCoder *)aDecoder 
{
    if ((self = [super initWithCoder: aDecoder])) 
        [self commonInit];

    return self;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc 
{
    textWindow=nil;
    [attributedString release];
    attributedString = nil;
    [caretView release]; 
    caretView = nil;
    self.menuItemActions = nil;
    self.defaultAttributes = nil;
    self.correctionAttributes = nil;
    [imageArray release];
    [textArray release];
    [videoArray release];
    [super dealloc];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)clearPreviousLayoutInformation 
{
    
    if (framesetter != NULL) 
    {
        CFRelease(framesetter);
        framesetter = NULL;
    }
    
    if (frame != NULL) 
    {
        CFRelease(frame);
        frame = NULL;
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)boundingWidthForHeight:(CGFloat)height 
{
    CGSize suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), NULL, CGSizeMake(CGFLOAT_MAX, height), NULL);
    return suggestedSize.width;   
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)boundingHeightForWidth:(CGFloat)width 
{
    CGSize suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), NULL, CGSizeMake(width, CGFLOAT_MAX), NULL);
    return suggestedSize.height;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)textChanged 
{
    
    if ([[UIMenuController sharedMenuController] isMenuVisible])
        [[UIMenuController sharedMenuController] setMenuVisible:NO animated:NO];
    
    CTFramesetterRef setter = framesetter;
    framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self.attributedString);
    if (setter!=NULL)
        CFRelease(setter); 
    
    CGRect rect = textContentView.frame;
    CGFloat height = [self boundingHeightForWidth:rect.size.width];
    rect.size.height = height;
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0)
        textContentView.frame = rect;
    self.contentSize = CGSizeMake(self.frame.size.width, rect.size.height);
    
    CGRect textBounds = textContentView.bounds;
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:textBounds]; //textContentView.bounds
    
    CTFrameRef frameRef = frame;
    frame =  CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), [path CGPath], NULL);
    if (frameRef!=NULL)
        CFRelease(frameRef);
    
    [textContentView setNeedsDisplay];
    
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//- (void)setAttributedString:(NSMutableAttributedString*)string 
-(void)UpdateDelegate:(NSString*)string
{
    
    /*NSMutableAttributedString *aString = attributedString;
    attributedString = [string copy];
    [aString release];
    aString = nil;*/
    
    [self textChanged];
    
    if ([delegate respondsToSelector:@selector(HTMLTextViewDidChange:string:)]) 
        [self.delegate HTMLTextViewDidChange:self string:string];
    
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)willDelegate:(NSString*)string
{
    if ([delegate respondsToSelector:@selector(HTMLTextViewWillChange:string:)]) 
        [self.delegate HTMLTextViewWillChange:self string:string];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*-(void)setAttributedString:(NSMutableAttributedString *)string
{
    NSMutableAttributedString *aString = attributedString;
    attributedString = [string copy];
    [aString release];
    aString = nil;
    
    [self textChanged];
    
    if ([delegate respondsToSelector:@selector(HTMLTextViewDidChange:string:)]) 
        [self.delegate HTMLTextViewDidChange:self string:@""];
}*/
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)appendUpdateCaret
{
    [self.inputDelegate selectionWillChange:self];
    
    self.markedRange = NSMakeRange(NSNotFound, 0);
    //self.selectedRange = NSMakeRange(attributedString.length, 0);
    self.selectedRange = NSMakeRange(attributedString.length, 0);
    
    [self.inputDelegate selectionDidChange:self];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)appendString:(NSMutableAttributedString*)string
{
    self.selectedRange = NSMakeRange(self.selectedRange.location+(string.length-1), 0);
    [self.attributedString appendAttributedString:string];
    [self textChanged];
    [self performSelector:@selector(appendUpdateCaret) withObject:nil afterDelay:0.1];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setEditable:(BOOL)edit 
{
    
    if (edit) 
    {
        if (caretView ==  nil)
            caretView = [[HTMLCaretView alloc] initWithFrame:CGRectZero];
        
        tokenizer = [[UITextInputStringTokenizer alloc] initWithTextInput:self];
        textChecker = [[UITextChecker alloc] init];
        attributedString = [[NSMutableAttributedString alloc] init];
        
        NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:(int)(kCTUnderlineStyleThick|kCTUnderlinePatternDot)], kCTUnderlineStyleAttributeName, (id)[UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:1.0f].CGColor, kCTUnderlineColorAttributeName, nil];
        self.correctionAttributes = dictionary;
        [dictionary release];
    } 
    else 
    {
        
        if (caretView) 
        {
            [caretView removeFromSuperview];
            [caretView release];
            caretView=nil;
        }
        
        self.correctionAttributes = nil;
        if (textChecker!=nil) 
        {
            [textChecker release];
            textChecker=nil;
        }

        if (tokenizer!=nil)
        {
            [tokenizer release];
            tokenizer=nil;
        }

        /*if (attributedString != nil) 
        {
            [attributedString release];
            attributedString = nil;
        }*/
        
    }
    editable = edit;
    
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Layout methods
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSRange)rangeIntersection:(NSRange)first withSecond:(NSRange)second 
{
    NSRange result = NSMakeRange(NSNotFound, 0);
    
    if (first.location > second.location) 
    {
        NSRange tmp = first;
        first = second;
        second = tmp;
    }
    
    if (second.location < first.location + first.length) 
    {
        result.location = second.location;
        NSUInteger end = MIN(first.location + first.length, second.location + second.length);
        result.length = end - result.location;
    }
    
    return result;    
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)drawPathFromRects:(NSArray*)array cornerRadius:(CGFloat)cornerRadius 
{
    
    if (array==nil || [array count] == 0) return;
    
    CGMutablePathRef _path = CGPathCreateMutable();
    
    CGRect firstRect = CGRectFromString([array lastObject]);
    CGRect lastRect = CGRectFromString([array objectAtIndex:0]);  
    if ([array count]>1)
        lastRect.size.width = textContentView.bounds.size.width-lastRect.origin.x;
    
    if (cornerRadius>0) 
    {
        CGPathAddPath(_path, NULL, [UIBezierPath bezierPathWithRoundedRect:firstRect cornerRadius:cornerRadius].CGPath);
        CGPathAddPath(_path, NULL, [UIBezierPath bezierPathWithRoundedRect:lastRect cornerRadius:cornerRadius].CGPath);
    } 
    else 
    {
        CGPathAddRect(_path, NULL, firstRect);
        CGPathAddRect(_path, NULL, lastRect);
    }
    
    if ([array count] > 1) 
    {
        
        CGRect fillRect = CGRectZero;
        
        CGFloat originX = ([array count]==2) ? MIN(CGRectGetMinX(firstRect), CGRectGetMinX(lastRect)) : 0.0f;
        CGFloat originY = firstRect.origin.y + firstRect.size.height;
        CGFloat width = ([array count]==2) ? originX+MIN(CGRectGetMaxX(firstRect), CGRectGetMaxX(lastRect)) : textContentView.bounds.size.width;
        CGFloat height =  MAX(0.0f, lastRect.origin.y-originY);
        
        fillRect = CGRectMake(originX, originY, width, height);
        
        if (cornerRadius>0)
            CGPathAddPath(_path, NULL, [UIBezierPath bezierPathWithRoundedRect:fillRect cornerRadius:cornerRadius].CGPath);
        else
            CGPathAddRect(_path, NULL, fillRect);
    }
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextAddPath(ctx, _path);
    CGContextFillPath(ctx);
    CGPathRelease(_path);
    
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)drawBoundingRangeAsSelection:(NSRange)selectionRange cornerRadius:(CGFloat)cornerRadius {
	
    if (selectionRange.length == 0 || selectionRange.location == NSNotFound) 
        return;
    
    NSMutableArray *pathRects = [[NSMutableArray alloc] init];
    NSArray *lines = (NSArray*)CTFrameGetLines(frame);
    CGPoint *origins = (CGPoint*)malloc([lines count] * sizeof(CGPoint));
    CTFrameGetLineOrigins(frame, CFRangeMake(0, [lines count]), origins);
    NSInteger count = [lines count];
    
    for (int i = 0; i < count; i++) 
    {
        
        CTLineRef line = (CTLineRef) [lines objectAtIndex:i];
        CFRange lineRange = CTLineGetStringRange(line);
        NSRange range = NSMakeRange(lineRange.location==kCFNotFound ? NSNotFound : lineRange.location, lineRange.length);
        NSRange intersection = [self rangeIntersection:range withSecond:selectionRange];
        
        if (intersection.location != NSNotFound && intersection.length > 0) 
        {
            
            CGFloat xStart = CTLineGetOffsetForStringIndex(line, intersection.location, NULL);
            CGFloat xEnd = CTLineGetOffsetForStringIndex(line, intersection.location + intersection.length, NULL);
            
            CGPoint origin = origins[i];
            CGFloat ascent, descent;
            CTLineGetTypographicBounds(line, &ascent, &descent, NULL);
            
            CGRect selectionRect = CGRectMake(origin.x + xStart, origin.y - descent, xEnd - xStart, ascent + descent); 
            
            if (range.length==1)
                selectionRect.size.width = textContentView.bounds.size.width;
            
            [pathRects addObject:NSStringFromCGRect(selectionRect)];
            
        } 
    }  
    
    [self drawPathFromRects:pathRects cornerRadius:cornerRadius];
    [pathRects release];
    free(origins);
    
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)drawContentInRect:(CGRect)rect 
{    
    //CGContextRef ctx = UIGraphicsGetCurrentContext();
    [[UIColor colorWithRed:0.8f green:0.8f blue:0.8f alpha:1.0f] setFill];
    [self drawBoundingRangeAsSelection:linkRange cornerRadius:2.0f];
    [[HTMLTextView selectionColor] setFill];
    [self drawBoundingRangeAsSelection:self.selectedRange cornerRadius:0.0f];
    [[HTMLTextView spellingSelectionColor] setFill];
    [self drawBoundingRangeAsSelection:self.correctionRange cornerRadius:2.0f];
    
	CGPathRef framePath = CTFrameGetPath(frame);
	CGRect frameRect = CGPathGetBoundingBox(framePath);
    
    
    //CTFrameDraw(frame,ctx);
	NSArray *lines = (NSArray*)CTFrameGetLines(frame);
    NSInteger count = [lines count];
    textCount = 0;
    
    CGPoint *origins = (CGPoint*)malloc(count * sizeof(CGPoint));
    CTFrameGetLineOrigins(frame, CFRangeMake(0, count), origins);
	CGContextRef ctx = UIGraphicsGetCurrentContext();
    //CGContextSetTextMatrix(ctx, CGAffineTransformIdentity);
    //CGContextTranslateCTM(ctx, 0, self.bounds.size.height);
    //CGContextScaleCTM(ctx, 1.0, -1.0);
	for (int i = 0; i < count; i++)
    {
        CTLineRef line = (CTLineRef)CFArrayGetValueAtIndex((CFArrayRef)lines, i);
        [self drawCustomElements:line ctx:ctx index:count points:origins mainRect:rect];
        CGContextSetTextPosition(ctx, frameRect.origin.x + origins[i].x, frameRect.origin.y + origins[i].y);
        CTLineDraw(line, ctx);

	}
    free(origins);
    
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)drawCustomElements:(CTLineRef)oneLine ctx:(CGContextRef)ctx index:(int)lineIndex points:(CGPoint*)origins mainRect:(CGRect)mainRect
{
    CFArrayRef runs = CTLineGetGlyphRuns(oneLine);
    CGRect lineBounds = CTLineGetImageBounds(oneLine, ctx);
    
    lineBounds.origin.x += origins[lineIndex].x;
    lineBounds.origin.y += origins[lineIndex].y;
    lineIndex++;
    CGFloat offset = 0;
    CGFloat YOffset = 0;
    NSInteger imgtop = 0;
    NSInteger imgleft = 0;
    
    for (id oneRun in (NSArray *)runs)
    {
        CGFloat ascent = 0;
        CGFloat descent = 0;
        
        CGFloat width = CTRunGetTypographicBounds((CTRunRef) oneRun,CFRangeMake(0, 0),&ascent,&descent, NULL);
        CGFloat xOffset = CTLineGetOffsetForStringIndex((CTLineRef)oneLine, CTRunGetStringRange((CTRunRef)oneRun).location, NULL);
        
        NSDictionary *attributes = (NSDictionary *)CTRunGetAttributes((CTRunRef) oneRun);
        
        BOOL strikeOut = [[attributes objectForKey:STRIKE_OUT] boolValue];
        NSString* imageurl = [attributes objectForKey:IMAGE_LINK];
        NSString* videourl = [attributes objectForKey:VIDEO_LINK];
        NSString* list = [attributes objectForKey:HTML_LIST];
        UIImage* imagedata = [attributes objectForKey:HTML_IMAGE_DATA];
        
        if (strikeOut)
        {
            CGRect bounds = CGRectMake(lineBounds.origin.x + offset,lineBounds.origin.y,width, ascent + descent);
            
            // don't draw too far to the right
            if (bounds.origin.x + bounds.size.width > CGRectGetMaxX(lineBounds))
                bounds.size.width = CGRectGetMaxX(lineBounds) - bounds.origin.x;
            // get text color or use black
            id color = [attributes objectForKey:(id)kCTForegroundColorAttributeName];
            
            if (color)
                CGContextSetStrokeColorWithColor(ctx, (CGColorRef)color);
            else
                CGContextSetGrayStrokeColor(ctx, 0, 1.0);
            CGFloat y = roundf(bounds.origin.y + (bounds.size.height/2) ); //3.5
            y -= bounds.size.height + bounds.size.height/2.5;
            CGContextMoveToPoint(ctx, bounds.origin.x, y);
            CGContextAddLineToPoint(ctx, bounds.origin.x + bounds.size.width, y);
            
            CGContextStrokePath(ctx);
        }
        offset += width;
        YOffset += ascent - descent;
        
        if(imageurl && ![self didLoadURL:imageurl])
        {
            /*float imgheight = [(NSString*)[(NSDictionary*)attributes objectForKey:@"height"] floatValue];
            float imgwidth = [(NSString*)[(NSDictionary*)attributes objectForKey:@"width"] floatValue];
            if(imgleft + imgwidth > self.frame.size.width)
            {
                imgtop += imgheight;
                imgleft = 0;
            }
            CGFloat y =  mainRect.size.height - lineBounds.origin.y;//roundf(lineBounds.origin.y );
            if(imagedata)
                [imageArray addObject:[ImageItem imageItem:[UIImage imageByScalingProportionallyToSize:CGSizeMake(imgwidth, imgheight) image:imagedata] url:imageurl frame:CGRectMake(lineBounds.origin.x-imgwidth,y ,imgwidth, imgheight)]];
            else
                [self FetchImage:[ImageItem imageItem:nil url:imageurl frame:CGRectMake(lineBounds.origin.x-imgwidth,y ,imgwidth, imgheight)]]; 
            //lineBounds.origin.y
            imgleft += imgwidth;*/
            float imgheight = [(NSString*)[(NSDictionary*)attributes objectForKey:@"height"] floatValue];
            float imgwidth = [(NSString*)[(NSDictionary*)attributes objectForKey:@"width"] floatValue];
            float top = 0;
            if([(NSDictionary*)attributes objectForKey:@"padding"])
                top = [(NSString*)[(NSDictionary*)attributes objectForKey:@"padding"] floatValue];
            top = -top; //we swap to negitive, as the bounds are reversed
            CGRect runBounds;
            runBounds.size.width = imgwidth;
            runBounds.size.height = imgheight;
            runBounds.origin.x = origins[lineIndex].x + xOffset;
            runBounds.origin.y = origins[lineIndex].y + self.frame.origin.y + top;
            runBounds.origin.y -= descent;
            CGPathRef pathRef = CTFrameGetPath(frame); //10
            CGRect colRect = CGPathGetBoundingBox(pathRef);
            
            CGRect imgBounds = CGRectOffset(runBounds, colRect.origin.x, colRect.origin.y - self.frame.origin.y);
            //if(self.ignoreXAttachment)
            imgBounds.origin.x = 0;
            
            if(imagedata)
                [imageArray addObject:[ImageItem imageItem:[UIImage imageByScalingProportionallyToSize:CGSizeMake(imgwidth, imgheight) image:imagedata] url:imageurl frame:imgBounds]]; //(origins[lineIndex].y+10)
            else
                [self FetchImage:[ImageItem imageItem:nil url:imageurl frame:imgBounds]];
        }
        if(videourl && ![self didLoadVideo:videourl])
        {
            float vidheight = [(NSString*)[(NSDictionary*)attributes objectForKey:@"height"] floatValue];
            float vidwidth = [(NSString*)[(NSDictionary*)attributes objectForKey:@"width"] floatValue];
            //CGRect vidframe = CGRectMake(origins[lineIndex].x,(origins[lineIndex].y) ,vidwidth, vidheight);
            CGFloat y =  mainRect.size.height - lineBounds.origin.y;
            [self FetchImage:[ImageItem imageItem:nil url:videourl frame:CGRectMake(lineBounds.origin.x-vidwidth,y ,vidwidth, vidheight)]];
            //[self addSubview:youtube];
            imgleft += vidwidth;
            imgtop += vidheight;
        }
        NSString* txt = list;
        if(list)
        {
            textCount++;
            if([list isEqualToString:HTML_ORDER_LIST])
                txt = [NSString stringWithFormat:@"%d. ",textCount];
        }
        if(list && (![self doesContain:txt] || textCount >= textArray.count))
        {
            float h = [(NSString*)[(NSDictionary*)attributes objectForKey:@"height"] floatValue];
            float w = [(NSString*)[(NSDictionary*)attributes objectForKey:@"width"] floatValue];
            CGFloat y =  (mainRect.size.height - lineBounds.origin.y);
            int x = 7 - txt.length;
            [textArray addObject:[TextItem textItem:txt frame:CGRectMake(x,y,w, h) tag:[textArray count] ]]; //lineBounds.origin.x-w
        }
            
    }
}
//////////////////////////////////////////////////////////////////////////////
//load image from http
-(void)FetchImage:(ImageItem*)item
{
    NSString* url = nil;
    if([item.URL rangeOfString:@"youtube"].location != NSNotFound)
    {
        [videoArray addObject:item];
        url = [self youtubeThumb:item.URL];
    }
    else
    {
        [imageArray addObject:item];
        url = item.URL;
    }
    if(!url)
        return;
    else if([url hasPrefix:@"http"])
    {
        GPHTTPRequest* SendRequest = [GPHTTPRequest requestWithString:url];
        [SendRequest setCacheModel:GPHTTPCacheCustomTime];
        [SendRequest setCacheTimeout:60*60*1]; // Cache for 1 hour
        [SendRequest setDelegate:self];
        [SendRequest startAsync];
    }
    else
    {
        UIImage* image = [UIImage imageNamed:url];
        if(!image)
            image = [UIImage imageWithContentsOfFile:url];
        [(ImageItem*)[imageArray lastObject] setImageData:[UIImage imageByScalingProportionallyToSize:CGSizeMake(item.frame.size.width, item.frame.size.height) image:image]];
        [textContentView setNeedsDisplay];
    }
}
//////////////////////////////////////////////////////////////////////////////
- (void)requestFinished:(GPHTTPRequest *)request
{
    UIImage* image = [UIImage imageWithData:[request responseData]];
    if([request.URL.absoluteString rangeOfString:@"i.ytimg.com"].location != NSNotFound)
    {
        for(ImageItem* item in videoArray )
            if([[self youtubeThumb:item.URL] isEqualToString:request.URL.absoluteString])
                item.imageData = [UIImage imageByScalingProportionallyToSize:CGSizeMake(item.frame.size.width, item.frame.size.height) image:image];;
    }
    else
    {
        for(ImageItem* item in imageArray )
            if([item.URL isEqualToString:request.URL.absoluteString])
                item.imageData = [UIImage imageByScalingProportionallyToSize:CGSizeMake(item.frame.size.width, item.frame.size.height) image:image];
    }
    [textContentView setNeedsDisplay];
}
//////////////////////////////////////////////////////////////////////////////
-(BOOL)didLoadURL:(NSString*)url
{
    for(ImageItem* item in imageArray)
        if([item.URL isEqualToString:url])
            return YES;
    return NO;
}
//////////////////////////////////////////////////////////////////////////////
-(BOOL)didLoadVideo:(NSString*)url
{
    for(ImageItem* item in videoArray)
        if([item.URL isEqualToString:url])
            return YES;
    return NO;
}
//////////////////////////////////////////////////////////////////////////////
-(ImageItem*)videoForURL:(NSString*)url
{
    for(ImageItem* item in videoArray)
        if([item.URL isEqualToString:url])
            return item;
    return nil;
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
//////////////////////////////////////////////////////////////////////////////
-(ImageItem*)itemForURL:(NSString*)url
{
    for(ImageItem* item in imageArray)
        if([item.URL isEqualToString:url])
            return item;
    return nil;
}
//////////////////////////////////////////////////////////////////////////////
-(TextItem*)itemForText:(NSString*)text
{
    for(TextItem* item in textArray)
        if([item.text hasPrefix:text])
            return item;
    return nil;
}
//////////////////////////////////////////////////////////////////////////////
-(BOOL)doesContain:(NSString*)text
{
    for(TextItem* item in textArray)
        if([item.text isEqualToString:text])
            return YES;
    return NO;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)closestWhiteSpaceIndexToPoint:(CGPoint)point 
{
    
    point = [self convertPoint:point toView:textContentView];
    NSArray *lines = (NSArray*)CTFrameGetLines(frame);
    NSInteger count = [lines count];
    CGPoint *origins = (CGPoint*)malloc(count * sizeof(CGPoint));
    CTFrameGetLineOrigins(frame, CFRangeMake(0, count), origins); 
    
    __block NSRange returnRange = NSMakeRange(attributedString.length, 0);
    
    for (int i = 0; i < lines.count; i++) 
    {
        
        if (point.y > origins[i].y) {
            
            CTLineRef line = (CTLineRef)[lines objectAtIndex:i];
            CFRange cfRange = CTLineGetStringRange(line);
            NSRange range = NSMakeRange(cfRange.location == kCFNotFound ? NSNotFound : cfRange.location, cfRange.length);
            CGPoint convertedPoint = CGPointMake(point.x - origins[i].x, point.y - origins[i].y);
            CFIndex cfIndex = CTLineGetStringIndexForPosition(line, convertedPoint);
            NSInteger index = cfIndex == kCFNotFound ? NSNotFound : cfIndex;
            
            if(range.location==NSNotFound)
                break;
            
            if (index>= attributedString.length) 
            {
                returnRange = NSMakeRange(attributedString.length, 0);
                break;
            }
            
            if (range.length <= 1) {
                returnRange = NSMakeRange(range.location, 0);
                break;
            }
            
            if (index == range.location) {
                returnRange = NSMakeRange(range.location, 0);
                break;                
            }
            
            
            if (index >= (range.location+range.length)) 
            {
                
                if (range.length > 1 && [attributedString.string characterAtIndex:(range.location+range.length)-1] == '\n') 
                {
                    returnRange = NSMakeRange(index-1, 0);
                    break;
                } 
                else 
                {
                    returnRange = NSMakeRange(range.location+range.length, 0);
                    break;
                }
                
            }
            
            [attributedString.string enumerateSubstringsInRange:range options:NSStringEnumerationByWords usingBlock:^(NSString *subString, NSRange subStringRange, NSRange enclosingRange, BOOL *stop)
            {
                if (NSLocationInRange(index, enclosingRange)) 
                {
                    if (index > (enclosingRange.location+(enclosingRange.length/2))) 
                        returnRange = NSMakeRange(subStringRange.location+subStringRange.length, 0);
                        
                    else 
                        returnRange = NSMakeRange(subStringRange.location, 0);
                    *stop = YES;
                }
                
            }];
            
            break;
        }
    }
    
    return returnRange.location;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)closestIndexToPoint:(CGPoint)point 
{	
    point = [self convertPoint:point toView:textContentView];
    NSArray *lines = (NSArray*)CTFrameGetLines(frame);
    NSInteger count = [lines count];
    CGPoint *origins = (CGPoint*)malloc(count * sizeof(CGPoint));
    CTFrameGetLineOrigins(frame, CFRangeMake(0, count), origins);    
    CFIndex index = kCFNotFound;
    
    for (int i = 0; i < lines.count; i++) 
    {
        if (point.y > origins[i].y) 
        {
            CTLineRef line = (CTLineRef)[lines objectAtIndex:i];
            CGPoint convertedPoint = CGPointMake(point.x - origins[i].x, point.y - origins[i].y);
            index = CTLineGetStringIndexForPosition(line, convertedPoint);  
            break;
        }
    }
    
    if (index == kCFNotFound)
        index = [attributedString length];
    
    free(origins);
    return index;
    
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSRange)characterRangeAtPoint_:(CGPoint)point 
{
    
    __block NSArray *lines = (NSArray*)CTFrameGetLines(frame);
    
    CGPoint *origins = (CGPoint*)malloc([lines count] * sizeof(CGPoint));
    CTFrameGetLineOrigins(frame, CFRangeMake(0, [lines count]), origins);    
    __block NSRange returnRange = NSMakeRange(NSNotFound, 0);
    
    for (int i = 0; i < lines.count; i++) 
    {
        if (point.y > origins[i].y) 
        {
            
            CTLineRef line = (CTLineRef)[lines objectAtIndex:i];
            CGPoint convertedPoint = CGPointMake(point.x - origins[i].x, point.y - origins[i].y);
            NSInteger index = CTLineGetStringIndexForPosition(line, convertedPoint);
            
            CFRange cfRange = CTLineGetStringRange(line);
            NSRange range = NSMakeRange(cfRange.location == kCFNotFound ? NSNotFound : cfRange.location, cfRange.length);
            
            [attributedString.string enumerateSubstringsInRange:range options:NSStringEnumerationByWords usingBlock:^(NSString *subString, NSRange subStringRange, NSRange enclosingRange, BOOL *stop)
            {
                if (index - subStringRange.location <= subStringRange.length) 
                {
                    returnRange = subStringRange;
                    *stop = YES;
                }
                
            }];
            break;
        }
    }
    
    free(origins);
    return  returnRange;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSRange)characterRangeAtIndex:(NSInteger)index 
{
    __block NSArray *lines = (NSArray*)CTFrameGetLines(frame);
    NSInteger count = [lines count];  
    __block NSRange returnRange = NSMakeRange(NSNotFound, 0);
    
    for (int i=0; i < count; i++) 
    {
        
        __block CTLineRef line = (CTLineRef)[lines objectAtIndex:i];
        CFRange cfRange = CTLineGetStringRange(line);
        NSRange range = NSMakeRange(cfRange.location == kCFNotFound ? NSNotFound : cfRange.location, cfRange.length == kCFNotFound ? 0 : cfRange.length);
        
        if (index >= range.location && index <= range.location+range.length) 
        {
            if (range.length > 1) 
            {
                [attributedString.string enumerateSubstringsInRange:range options:NSStringEnumerationByWords usingBlock:^(NSString *subString, NSRange subStringRange, NSRange enclosingRange, BOOL *stop){
                    
                    if (index - subStringRange.location <= subStringRange.length) 
                    {
                        returnRange = subStringRange;
                        *stop = YES;
                    }
                    
                }];
            }
            
        }
    }
    return returnRange;
    
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (CGRect)caretRectForIndex:(NSInteger)index 
{  
    NSArray *lines = (NSArray*)CTFrameGetLines(frame);
    
    // no text / first index
    if (attributedString.length == 0 || index == 0) 
    {
        CGPoint origin = CGPointMake(CGRectGetMinX(textContentView.bounds), CGRectGetMaxY(textContentView.bounds) - self.font.leading);
        return CGRectMake(origin.x, origin.y, 3, self.font.ascender + fabs(self.font.descender*2));
    }    
    
    // last index is newline
    if (index == attributedString.length && [attributedString.string characterAtIndex:(index - 1)] == '\n' ) 
    {
        CTLineRef line = (CTLineRef)[lines lastObject];
        CFRange range = CTLineGetStringRange(line);
        CGFloat xPos = CTLineGetOffsetForStringIndex(line, range.location, NULL);
        CGFloat ascent, descent;
        CTLineGetTypographicBounds(line, &ascent, &descent, NULL);
        
        CGPoint origin;
        CGPoint *origins = (CGPoint*)malloc(1 * sizeof(CGPoint));
        int lineCount = [lines count]-1;
        if(lineCount < 0)
            lineCount = 0;
        CTFrameGetLineOrigins(frame, CFRangeMake(lineCount, 0), origins);
        origin = origins[0];
        free(origins);
        
        origin.y -= self.font.leading;
        return CGRectMake(origin.x + xPos, floorf(origin.y - descent), 3, ceilf((descent*2) + ascent));  
    }
    
    index = MAX(index, 0);
    index = MIN(attributedString.string.length, index);
    
    NSInteger count = [lines count];  
    CGPoint *origins = (CGPoint*)malloc(count * sizeof(CGPoint));
    CTFrameGetLineOrigins(frame, CFRangeMake(0, count), origins);
    CGRect returnRect = CGRectZero;
    
    for (int i = 0; i < count; i++) 
    {
        CTLineRef line = (CTLineRef)[lines objectAtIndex:i];
        CFRange cfRange = CTLineGetStringRange(line);
        NSRange range = NSMakeRange(range.location == kCFNotFound ? NSNotFound : cfRange.location, cfRange.length);
        
        if (index >= range.location && index <= range.location+range.length) 
        {
            CGFloat ascent, descent, xPos;
            xPos = CTLineGetOffsetForStringIndex((CTLineRef)[lines objectAtIndex:i], index, NULL); 
            CTLineGetTypographicBounds(line, &ascent, &descent, NULL);
            CGPoint origin = origins[i];
            
            if (selectedRange.length>0 && index != selectedRange.location && range.length == 1) 
                xPos = textContentView.bounds.size.width - 3.0f; // selection of entire line
                
             else if ([attributedString.string characterAtIndex:index-1] == '\n' && range.length == 1) 
                xPos = 0.0f; // empty line
            returnRect = CGRectMake(origin.x + xPos,  floorf(origin.y - descent), 3, ceilf((descent*2) + ascent));
            
        } 
        
    }
    
    free(origins);
    return returnRect;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (CGRect)firstRectForNSRange:(NSRange)range 
{    
    NSInteger index = range.location;
    
    NSArray *lines = (NSArray *) CTFrameGetLines(frame);
    NSInteger count = [lines count];
    CGPoint *origins = (CGPoint*)malloc(count * sizeof(CGPoint));
    CTFrameGetLineOrigins(frame, CFRangeMake(0, count), origins);
    CGRect returnRect = CGRectNull;
    
    for (int i = 0; i < count; i++) 
    {
        CTLineRef line = (CTLineRef) [lines objectAtIndex:i];
        CFRange lineRange = CTLineGetStringRange(line);
        NSInteger localIndex = index - lineRange.location;
        
        if (localIndex >= 0 && localIndex < lineRange.length) 
        {
            NSInteger finalIndex = MIN(lineRange.location + lineRange.length, range.location + range.length);
            CGFloat xStart = CTLineGetOffsetForStringIndex(line, index, NULL);
            CGFloat xEnd = CTLineGetOffsetForStringIndex(line, finalIndex, NULL);
            CGPoint origin = origins[i];
            CGFloat ascent, descent;
            CTLineGetTypographicBounds(line, &ascent, &descent, NULL);
            
            returnRect = [textContentView convertRect:CGRectMake(origin.x + xStart, origin.y - descent, xEnd - xStart, ascent + (descent*2)) toView:self];
            break;
        }
    }
    
    free(origins);
    return returnRect;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// MARK: -
// MARK: Text Selection
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)selectionChanged 
{
    
    if (!editing) {
        [caretView removeFromSuperview];
    }
    
    ignoreSelectionMenu = NO;
    
    if (self.selectedRange.length == 0) {
        
        if (selectionView!=nil) {
            [selectionView removeFromSuperview];
            selectionView=nil;
        }
        
        if (!caretView.superview) {
            [textContentView addSubview:caretView];
            [textContentView setNeedsDisplay];            
        }
        
        caretView.frame = [self caretRectForIndex:self.selectedRange.location];
        [caretView delayBlink];
        
        CGRect cframe = caretView.frame;
        cframe.origin.y -= (self.font.lineHeight*2);
        [self scrollRectToVisible:[textContentView convertRect:cframe toView:self] animated:YES];
        
        [textContentView setNeedsDisplay];
        
        longPress.minimumPressDuration = 0.5f;
        
    } else {
        
        longPress.minimumPressDuration = 0.0f;
        
        if ((caretView!=nil) && caretView.superview) {
            [caretView removeFromSuperview];
        }
        
        if (selectionView==nil) {
            
            HTMLSelectionView *view = [[HTMLSelectionView alloc] initWithFrame:textContentView.bounds];
            [textContentView addSubview:view];
            selectionView=view;
            [view release];  
            
        }
        
        CGRect begin = [self caretRectForIndex:selectedRange.location];
        CGRect end = [self caretRectForIndex:selectedRange.location+selectedRange.length];
        [selectionView setBeginCaret:begin endCaret:end];
        [textContentView setNeedsDisplay];
        
    }    
    
    if (self.markedRange.location != NSNotFound) {
        [textContentView setNeedsDisplay];
    }
    
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSRange)markedRange {
    return markedRange;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSRange)selectedRange {
    return selectedRange;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setMarkedRange:(NSRange)range {    
    markedRange = range;
    //[self selectionChanged];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setSelectedRange:(NSRange)range {
    selectedRange = NSMakeRange(range.location == NSNotFound ? NSNotFound : MAX(0, range.location), range.length);
    [self selectionChanged];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setCorrectionRange:(NSRange)range {
    
    if (NSEqualRanges(range, correctionRange) && range.location == NSNotFound && range.length == 0) 
    {
        correctionRange = range;
        return;
    }
    correctionRange = range;
    if (range.location != NSNotFound && range.length > 0) {
        
        if (caretView.superview) {
            [caretView removeFromSuperview];
        }
        
        [self removeCorrectionAttributesForRange:correctionRange];
        [self showCorrectionMenuForRange:correctionRange];
        
        
    } 
    else 
    {
        if (!caretView.superview) 
        {
            [textContentView addSubview:caretView];
            [caretView delayBlink];
        }
        
    }
    [textContentView setNeedsDisplay];
    
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setLinkRange:(NSRange)range 
{
    linkRange = range;
    
    if (linkRange.length>0) 
    {
        if (caretView.superview!=nil)
            [caretView removeFromSuperview];
    } 
    else 
    {
        if (caretView.superview==nil) 
        {
            if (!caretView.superview) 
            {
                [textContentView addSubview:caretView];
                caretView.frame = [self caretRectForIndex:self.selectedRange.location];
                [caretView delayBlink];
            }
        }
        
    }
    
    [textContentView setNeedsDisplay];
    
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setLinkRangeFromTextCheckerResults:(NSTextCheckingResult*)results 
{
    if (linkRange.length>0) 
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[[results URL] absoluteString] delegate:(id<UIActionSheetDelegate>)self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Open", nil];
        [actionSheet showInView:self];
        [actionSheet release];
    }
    
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+ (UIColor*)selectionColor 
{
    static UIColor *color = nil;
    if (color == nil)
        color = [[UIColor colorWithRed:0.800f green:0.867f blue:0.929f alpha:1.0f] retain];    
    return color;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+ (UIColor*)caretColor 
{
    static UIColor *color = nil;
    if (color == nil) 
        color = [[UIColor colorWithRed:0.259f green:0.420f blue:0.949f alpha:1.0f] retain];
    return color;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+ (UIColor*)spellingSelectionColor 
{
    static UIColor *color = nil;
    if (color == nil)
        color = [[UIColor colorWithRed:1.000f green:0.851f blue:0.851f alpha:1.0f] retain];
    return color;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// MARK: -
// MARK: UITextInput methods
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// MARK: UITextInput - Replacing and Returning Text
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)textInRange:(UITextRange *)range 
{
    if(!attributedString || attributedString.string.length == 0)
        return nil;
    HTMLIndexedRange *r = (HTMLIndexedRange *)range;
    return ([attributedString.string substringWithRange:r.range]);
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)replaceRange:(UITextRange *)range withText:(NSString *)text 
{    
    HTMLIndexedRange *r = (HTMLIndexedRange *)range;
    
    NSRange selectedNSRange = self.selectedRange;
    if ((r.range.location + r.range.length) <= selectedNSRange.location) 
        selectedNSRange.location -= (r.range.length - text.length);
    else 
        selectedNSRange = [self rangeIntersection:r.range withSecond:selectedRange];
    
    [attributedString replaceCharactersInRange:r.range withString:text];
    self.selectedRange = selectedNSRange;
    
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// MARK: UITextInput - Working with Marked and Selected Text
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (UITextRange *)selectedTextRange 
{
    return [HTMLIndexedRange rangeWithNSRange:self.selectedRange];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setSelectedTextRange:(UITextRange *)range 
{
    HTMLIndexedRange *r = (HTMLIndexedRange *)range;
    self.selectedRange = r.range;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (UITextRange *)markedTextRange 
{
    return [HTMLIndexedRange rangeWithNSRange:self.markedRange];    
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setMarkedText:(NSString *)markedText selectedRange:(NSRange)selectedRange 
{
    NSRange selectedNSRange = self.selectedRange;
    NSRange markedTextRange = self.markedRange;
    
    if (markedTextRange.location != NSNotFound) 
    {
        if (!markedText)
            markedText = @"";
        
        [attributedString replaceCharactersInRange:markedTextRange withString:markedText];
        markedTextRange.length = markedText.length;
        
    } 
    else if (selectedNSRange.length > 0) 
    {
        [attributedString replaceCharactersInRange:selectedNSRange withString:markedText];
        markedTextRange.location = selectedNSRange.location;
        markedTextRange.length = markedText.length;
        
    }
    else 
    {
        //NSDictionary* attribs = nil;
        //if(selectedNSRange.location != NSNotFound && [attributedString length] > 0)
          //  attribs = [attributedString attributesAtIndex:selectedNSRange.location-1 effectiveRange:NULL];
        NSAttributedString *string = [[NSAttributedString alloc] initWithString:markedText attributes:self.stringAttributes]; //self.defaultAttributes
        [attributedString insertAttributedString:string atIndex:selectedNSRange.location];  
        [string release];
        
        markedTextRange.location = selectedNSRange.location;
        markedTextRange.length = markedText.length;
    }
    
    selectedNSRange = NSMakeRange(self.selectedRange.location + markedTextRange.location, self.selectedRange.length);
    
    //self.attributedString = _attributedString;
    self.markedRange = markedTextRange;
    self.selectedRange = selectedNSRange;    
    
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)unmarkText 
{    
    NSRange markedTextRange = self.markedRange;
    
    if (markedTextRange.location == NSNotFound)
        return;
    
    markedTextRange.location = NSNotFound;
    self.markedRange = markedTextRange;   
    
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// MARK: UITextInput - Computing Text Ranges and Text Positions
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (UITextPosition*)beginningOfDocument {
    return [HTMLIndexedPosition positionWithIndex:0];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (UITextPosition*)endOfDocument {
    return [HTMLIndexedPosition positionWithIndex:attributedString.length];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (UITextRange*)textRangeFromPosition:(UITextPosition *)fromPosition toPosition:(UITextPosition *)toPosition 
{    
    HTMLIndexedPosition *from = (HTMLIndexedPosition *)fromPosition;
    HTMLIndexedPosition *to = (HTMLIndexedPosition *)toPosition;    
    NSRange range = NSMakeRange(MIN(from.index, to.index), ABS(to.index - from.index));
    return [HTMLIndexedRange rangeWithNSRange:range];    
    
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (UITextPosition*)positionFromPosition:(UITextPosition *)position offset:(NSInteger)offset 
{    
    HTMLIndexedPosition *pos = (HTMLIndexedPosition *)position;    
    NSInteger end = pos.index + offset;
	
    if (end > attributedString.length || end < 0)
        return nil;
    
    return [HTMLIndexedPosition positionWithIndex:end];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (UITextPosition*)positionFromPosition:(UITextPosition *)position inDirection:(UITextLayoutDirection)direction offset:(NSInteger)offset 
{
    HTMLIndexedPosition *pos = (HTMLIndexedPosition *)position;
    NSInteger newPos = pos.index;
    
    switch (direction) 
    {
        case UITextLayoutDirectionRight:
            newPos += offset;
            break;
        case UITextLayoutDirectionLeft:
            newPos -= offset;
            break;
        UITextLayoutDirectionUp: // not supported right now
            break; 
        UITextLayoutDirectionDown: // not supported right now
            break;
        default:
            break;
            
    }
    
    if (newPos < 0)
        newPos = 0;
    
    if (newPos > attributedString.length)
        newPos = attributedString.length;
    
    return [HTMLIndexedPosition positionWithIndex:newPos];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// MARK: UITextInput - Evaluating Text Positions
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSComparisonResult)comparePosition:(UITextPosition *)position toPosition:(UITextPosition *)other 
{
    HTMLIndexedPosition *pos = (HTMLIndexedPosition *)position;
    HTMLIndexedPosition *o = (HTMLIndexedPosition *)other;
    
    if (pos.index == o.index) 
        return NSOrderedSame;
    if (pos.index < o.index) 
        return NSOrderedAscending;
     else 
        return NSOrderedDescending;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)offsetFromPosition:(UITextPosition *)from toPosition:(UITextPosition *)toPosition 
{
    HTMLIndexedPosition *f = (HTMLIndexedPosition *)from;
    HTMLIndexedPosition *t = (HTMLIndexedPosition *)toPosition;
    return (t.index - f.index);
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// MARK: UITextInput - Text Input Delegate and Text Input Tokenizer
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (id <UITextInputTokenizer>)tokenizer {
    return tokenizer;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// MARK: UITextInput - Text Layout, writing direction and position
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (UITextPosition *)positionWithinRange:(UITextRange *)range farthestInDirection:(UITextLayoutDirection)direction {
    
    HTMLIndexedRange *r = (HTMLIndexedRange *)range;
    NSInteger pos = r.range.location;
    
    switch (direction) 
    {
        case UITextLayoutDirectionUp:
        case UITextLayoutDirectionLeft:
            pos = r.range.location;
            break;
        case UITextLayoutDirectionRight:
        case UITextLayoutDirectionDown:            
            pos = r.range.location + r.range.length;
            break;
    }
    
    return [HTMLIndexedPosition positionWithIndex:pos];        
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (UITextRange *)characterRangeByExtendingPosition:(UITextPosition *)position inDirection:(UITextLayoutDirection)direction 
{    
    HTMLIndexedPosition *pos = (HTMLIndexedPosition *)position;
    NSRange result = NSMakeRange(pos.index, 1);
    
    switch (direction) 
    {
        case UITextLayoutDirectionUp:
        case UITextLayoutDirectionLeft:
            result = NSMakeRange(pos.index - 1, 1);
            break;
        case UITextLayoutDirectionRight:
        case UITextLayoutDirectionDown:            
            result = NSMakeRange(pos.index, 1);
            break;
    }
    
    return [HTMLIndexedRange rangeWithNSRange:result];   
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (UITextWritingDirection)baseWritingDirectionForPosition:(UITextPosition *)position inDirection:(UITextStorageDirection)direction {
    return UITextWritingDirectionLeftToRight;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setBaseWritingDirection:(UITextWritingDirection)writingDirection forRange:(UITextRange *)range {
    // only ltr supported for now.
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// MARK: UITextInput - Geometry
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (CGRect)firstRectForRange:(UITextRange *)range 
{    
    HTMLIndexedRange *r = (HTMLIndexedRange *)range;    
    return [self firstRectForNSRange:r.range];   
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (CGRect)caretRectForPosition:(UITextPosition *)position 
{
    HTMLIndexedPosition *pos = (HTMLIndexedPosition *)position;
	return [self caretRectForIndex:pos.index];    
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (UIView *)textInputView 
{
    return textContentView;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// MARK: UITextInput - Hit testing
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (UITextPosition*)closestPositionToPoint:(CGPoint)point {
    
    HTMLIndexedPosition *position = [HTMLIndexedPosition positionWithIndex:[self closestIndexToPoint:point]];
    return position;
    
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (UITextPosition*)closestPositionToPoint:(CGPoint)point withinRange:(UITextRange *)range 
{	
    HTMLIndexedPosition *position = [HTMLIndexedPosition positionWithIndex:[self closestIndexToPoint:point]];
    return position;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (UITextRange*)characterRangeAtPoint:(CGPoint)point 
{	
    HTMLIndexedRange *range = [HTMLIndexedRange rangeWithNSRange:[self characterRangeAtPoint_:point]];
    return range;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// MARK: UITextInput - Styling Information
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSDictionary*)textStylingAtPosition:(UITextPosition *)position inDirection:(UITextStorageDirection)direction 
{    
    HTMLIndexedPosition *pos = (HTMLIndexedPosition*)position;
    NSInteger index = MAX(pos.index, 0);
    index = MIN(index, attributedString.length-1);
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:1];
    if(attributedString.length > 0)
    {
        NSDictionary *attribs = [attributedString attributesAtIndex:index effectiveRange:nil];
        
        CTFontRef ctFont = (CTFontRef)[attribs valueForKey:(NSString*)kCTFontAttributeName];
        UIFont *afont = [UIFont fontWithName:(NSString*)CTFontCopyFamilyName(ctFont) size:CTFontGetSize(ctFont)];
        if(!afont)
            afont = self.font;
        //[afont release];
        [dictionary setObject:self.font forKey:UITextInputTextFontKey];
    }
    else
        [dictionary setObject:self.font forKey:UITextInputTextFontKey];
    
    return dictionary;
    
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// MARK: -
// MARK: UIKeyInput methods
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)hasText {
    return (attributedString.length != 0);
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)insertText:(NSString *)text attribs:(NSDictionary*)attr
{    
    [self willDelegate:text];
    NSRange selectedNSRange = self.selectedRange;
    NSRange markedTextRange = self.markedRange;
    
    NSDictionary* attribs = self.stringAttributes;

    if(selectedNSRange.location != NSNotFound && selectedNSRange.location != 0 && [attributedString length] > 0)
    {
        attribs = [attributedString attributesAtIndex:selectedNSRange.location-1 effectiveRange:NULL];
        if([attribs objectForKey:(NSString*)kCTRunDelegateAttributeName] &&  attributedString && selectedNSRange.location > 1)
            attribs = [attributedString attributesAtIndex:selectedNSRange.location-2 effectiveRange:NULL];
        //stringAttributes = attribs;
    }
    if(attr)
        attribs = attr;
    NSAttributedString *newString = [[NSAttributedString alloc] initWithString:text attributes:attribs]; //self.defaultAttributes
    
    if(correctionRange.location != NSNotFound && correctionRange.length > 0)
    {
        [attributedString replaceCharactersInRange:self.correctionRange withAttributedString:newString];
        selectedNSRange.length = 0;
        selectedNSRange.location = (self.correctionRange.location+text.length);
        self.correctionRange = NSMakeRange(NSNotFound, 0);
        
    } 
    else if (markedTextRange.location != NSNotFound) 
    {
        [attributedString replaceCharactersInRange:markedTextRange withAttributedString:newString];
        selectedNSRange.location = markedTextRange.location + text.length;
        selectedNSRange.length = 0;
        markedTextRange = NSMakeRange(NSNotFound, 0); 
        
    } 
    else if (selectedNSRange.length > 0) 
    {
        [attributedString replaceCharactersInRange:selectedNSRange withAttributedString:newString];
        selectedNSRange.length = 0;
        selectedNSRange.location = (selectedNSRange.location + text.length);
        
    } 
    else 
    {
        [attributedString insertAttributedString:newString atIndex:selectedNSRange.location];        
        selectedNSRange.location += text.length;
    }
    
    [newString release];
    
    //self.attributedString = _mutableAttributedString;
    [self UpdateDelegate:text];
    self.markedRange = markedTextRange;
    self.selectedRange = selectedNSRange;  
    
    if (text.length > 1 || ([text isEqualToString:@" "] || [text isEqualToString:@"\n"])) 
        [self checkSpellingForRange:[self characterRangeAtIndex:self.selectedRange.location-1]];
        
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)insertText:(NSString *)text 
{
    [self insertText:text attribs:nil];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)deleteBackward  
{    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showCorrectionMenuWithoutSelection) object:nil];
    
    NSRange selectedNSRange = self.selectedRange;
    NSRange markedTextRange = self.markedRange;
    
    NSString* text = [[attributedString mutableString] substringWithRange:selectedNSRange];
    [self willDelegate:text];
    
    if(selectedNSRange.location != NSNotFound && [attributedString length] > 0)
    {
        if(selectedNSRange.length == 0 && selectedNSRange.location != 0)
        {
            NSDictionary* attribs = [attributedString attributesAtIndex:selectedNSRange.location-1 effectiveRange:NULL];
            ImageItem* item = [self itemForURL:[attribs objectForKey:IMAGE_LINK]];
            if(item)
                [imageArray removeObject:item];
            
            if([attribs objectForKey:HTML_LIST] && [textArray lastObject])
                [textArray removeLastObject];
        }
        else
        {
            [attributedString enumerateAttribute:IMAGE_LINK inRange:selectedNSRange options:0 usingBlock:
             ^(id value, NSRange range, BOOL *stop) 
             {
                 ImageItem* item = [self itemForURL:value];
                 [imageArray removeObject:item];
             }];
            [attributedString enumerateAttribute:VIDEO_LINK inRange:selectedNSRange options:0 usingBlock:
             ^(id value, NSRange range, BOOL *stop) 
             {
                 ImageItem* item = [self videoForURL:value];
                 [videoArray removeObject:item];
             }];
            
            [attributedString enumerateAttribute:HTML_LIST inRange:selectedNSRange options:0 usingBlock:
             ^(id value, NSRange range, BOOL *stop) 
             {
                 if([textArray lastObject])
                     [textArray removeLastObject];
             }];
        }
    }
    //[self UpdateDelegate];
    if (correctionRange.location != NSNotFound && correctionRange.length > 0) 
    {
        [attributedString beginEditing];
        [attributedString deleteCharactersInRange:self.correctionRange];
        [attributedString endEditing];
        self.correctionRange = NSMakeRange(NSNotFound, 0);
        selectedNSRange.length = 0;
    } 
    else if (markedTextRange.location != NSNotFound) 
    {
        [attributedString beginEditing];
        [attributedString deleteCharactersInRange:selectedNSRange];
        [attributedString endEditing];
        
        selectedNSRange.location = markedTextRange.location;
        selectedNSRange.length = 0;
        markedTextRange = NSMakeRange(NSNotFound, 0);
    } 
    else if (selectedNSRange.length > 0) 
    {
        
        [attributedString beginEditing];
        [attributedString deleteCharactersInRange:selectedNSRange];
        [attributedString endEditing];
        
        selectedNSRange.length = 0;
        
    } 
    else if (selectedNSRange.location > 0) 
    {
        NSInteger index = MAX(0, selectedNSRange.location-1);
        index = MIN(attributedString.length-1, index);
        if ([attributedString.string characterAtIndex:index] == ' ') 
            [self performSelector:@selector(showCorrectionMenuWithoutSelection) withObject:nil afterDelay:0.2f];
        
        selectedNSRange.location--;
        selectedNSRange.length = 1;
        
        text = [[attributedString mutableString] substringWithRange:selectedNSRange];
        
        [attributedString beginEditing];
        [attributedString deleteCharactersInRange:selectedNSRange];
        [attributedString endEditing];
        
        selectedNSRange.length = 0;
        
    }
    [self UpdateDelegate:@""];
    //self.attributedString = _mutableAttributedString;
    self.markedRange = markedTextRange;
    self.selectedRange = selectedNSRange; 
    
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// MARK: -
// MARK: Spell Checking
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)insertCorrectionAttributesForRange:(NSRange)range 
{    
    [attributedString addAttributes:self.correctionAttributes range:range];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)removeCorrectionAttributesForRange:(NSRange)range 
{    
    //NSMutableAttributedString *string = [attributedString mutableCopy];
    [attributedString removeAttribute:(NSString*)kCTUnderlineStyleAttributeName range:range];
    //self.attributedString = string;
    //[string release];
    
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)checkSpellingForRange:(NSRange)range 
{
    //[attributedString setAttributedString:self.attributedString];
    [self UpdateDelegate:@""];
    
    NSInteger location = range.location-1;
    NSInteger currentOffset = MAX(0, location);
    NSRange currentRange;
    NSString *string = self.attributedString.string;
    NSRange stringRange = NSMakeRange(0, string.length-1);
    NSArray *guesses;
    BOOL done = NO;
    
    NSString *language = [[UITextChecker availableLanguages] objectAtIndex:0];
    if (!language)
        language = @"en_US";
    
    while (!done) 
    {
        if(stringRange.location != NSNotFound && string.length > 0 && stringRange.length < string.length)
            currentRange = [textChecker rangeOfMisspelledWordInString:string range:stringRange startingAt:currentOffset wrap:NO language:language];
        
        if (currentRange.location == NSNotFound || currentRange.location > range.location) 
        {
            done = YES;
            continue;
        }
        
        guesses = [textChecker guessesForWordRange:currentRange inString:string language:language];
        
        if (guesses!=nil) 
            [attributedString addAttributes:self.correctionAttributes range:currentRange];
        
        currentOffset = currentOffset + (currentRange.length-1);
        
    }
    
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// MARK: -
// MARK: Gestures
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (HTMLTextWindow*)htmlTextWindow 
{    
    if (textWindow==nil) 
    {
        HTMLTextWindow *window = nil;
        
        for (HTMLTextWindow *aWindow in [[UIApplication sharedApplication] windows])
        {
            if ([aWindow isKindOfClass:[HTMLTextWindow class]]) 
            {
                window = aWindow;
                window.frame = [[UIScreen mainScreen] bounds];
                break;
            }
        }
        
        if (window==nil) 
            window = [[HTMLTextWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        
        window.windowLevel = UIWindowLevelStatusBar;
        window.hidden = NO;
        textWindow=window;
        
    }
    return textWindow;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)longPress:(UILongPressGestureRecognizer*)gesture 
{
    
    if (gesture.state==UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged) 
    {
        if (linkRange.length>0 && gesture.state == UIGestureRecognizerStateBegan) 
        {
            gesture.enabled=NO;
            gesture.enabled=YES;
        }
        
        
        UIMenuController *menuController = [UIMenuController sharedMenuController];
        if ([menuController isMenuVisible]) {
            [menuController setMenuVisible:NO animated:NO];
        }
        
        CGPoint point = [gesture locationInView:self];
        BOOL selection = (selectionView!=nil);
        
        if (!selection && caretView!=nil)
            [caretView show];

        
        textWindow = [self htmlTextWindow];
        [textWindow updateWindowTransform];
        [textWindow setType:selection ? HTMLWindowMagnify : HTMLWindowLoupe];
        
        point.y -= 20.0f;
        NSInteger index = [self closestIndexToPoint:point];
        
        if (selection) {
            
            if (gesture.state == UIGestureRecognizerStateBegan)
                textWindow.selectionType = (index > (selectedRange.location+(selectedRange.length/2))) ? HTMLSelectionTypeRight : HTMLSelectionTypeLeft;
            
            CGRect rect = CGRectZero;
            if (textWindow.selectionType == HTMLSelectionTypeLeft) 
            {
                NSInteger begin = MAX(0, index);
                begin = MIN(selectedRange.location+selectedRange.length-1, begin);
                
                NSInteger end = selectedRange.location + selectedRange.length;
                end = MIN(attributedString.string.length, end-begin);
                
                self.selectedRange = NSMakeRange(begin, end);
                index = selectedRange.location;
                
            } 
            else 
            {
                NSInteger length = MIN(index-selectedRange.location, attributedString.string.length-selectedRange.location);
                length = MAX(1, length);                    
                self.selectedRange = NSMakeRange(self.selectedRange.location, length);
                index = (selectedRange.location+selectedRange.length); 
                
            }
            
            rect = [self caretRectForIndex:index];
            
            if (gesture.state == UIGestureRecognizerStateBegan)
                [textWindow showFromView:textContentView rect:[textContentView convertRect:rect toView:textWindow]];
                
            else
                [textWindow renderWithContentView:textContentView fromRect:[textContentView convertRect:rect toView:textWindow]];
            
        } 
        else 
        {
            CGPoint location = [gesture locationInView:textWindow];
            CGRect rect = CGRectMake(location.x, location.y, caretView.bounds.size.width, caretView.bounds.size.height);
            
            self.selectedRange = NSMakeRange(index, 0);
            
            if (gesture.state == UIGestureRecognizerStateBegan)
                [textWindow showFromView:textContentView rect:rect];

            else
                [textWindow renderWithContentView:textContentView fromRect:rect];
        }
        
    } 
    else 
    {
        if (caretView!=nil)
            [caretView delayBlink];
        
        if ((textWindow!=nil)) 
        {
            [textWindow hide:YES];
            textWindow=nil;
        }
        
        if (gesture.state == UIGestureRecognizerStateEnded) 
        {
            if (self.selectedRange.location!=NSNotFound && self.selectedRange.length>0) 
                [self showMenu];
        }
    }
    
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)doubleTap:(UITapGestureRecognizer*)gesture 
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showMenu) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showCorrectionMenu) object:nil];
    
    NSInteger index = [self closestWhiteSpaceIndexToPoint:[gesture locationInView:self]];
    NSRange range = [self characterRangeAtIndex:index];
    if (range.location!=NSNotFound && range.length>0) 
    {
        [self.inputDelegate selectionWillChange:self];
        self.selectedRange = range;
        [self.inputDelegate selectionDidChange:self];
        
        if (![[UIMenuController sharedMenuController] isMenuVisible])
            [self performSelector:@selector(showMenu) withObject:nil afterDelay:0.1f];
    } 
    
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)tap:(UITapGestureRecognizer*)gesture 
{
    if (editable && ![self isFirstResponder]) 
    {
        [self becomeFirstResponder];  
        return;
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showMenu) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showCorrectionMenu) object:nil];
    
    self.correctionRange = NSMakeRange(NSNotFound, 0);
    if (self.selectedRange.length>0)
        self.selectedRange = NSMakeRange(selectedRange.location, 0);
    
    NSInteger index = [self closestWhiteSpaceIndexToPoint:[gesture locationInView:self]];
    
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    if ([menuController isMenuVisible]) 
        [menuController setMenuVisible:NO animated:NO];
    else 
    {
        if (index==self.selectedRange.location) 
            [self performSelector:@selector(showMenu) withObject:nil afterDelay:0.35f];
        else 
            if (editing)
                [self performSelector:@selector(showCorrectionMenu) withObject:nil afterDelay:0.35f];
    }
    
    [self.inputDelegate selectionWillChange:self];
    
    self.markedRange = NSMakeRange(NSNotFound, 0);
    self.selectedRange = NSMakeRange(index, 0);
    
    [self.inputDelegate selectionDidChange:self];
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// MARK: -
// MARK: UIGestureRecognizerDelegate
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:NSClassFromString(@"UIScrollViewPanGestureRecognizer")]) 
    {
        UIMenuController *menuController = [UIMenuController sharedMenuController];
        if ([menuController isMenuVisible])
            [menuController setMenuVisible:NO animated:NO];

    }
    return NO;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer==longPress) 
    {
        if (selectedRange.length>0 && selectionView!=nil) 
        {            
            return CGRectContainsPoint(CGRectInset([textContentView convertRect:selectionView.frame toView:self], -20.0f, -20.0f) , [gestureRecognizer locationInView:self]);
        }
        
    }
    return YES;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// MARK: -
// MARK: UIResponder
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)canBecomeFirstResponder
{    
    if (editable && [delegate respondsToSelector:@selector(HTMLTextViewShouldBeginEditing:)])
        return [self.delegate HTMLTextViewShouldBeginEditing:self];

    return YES;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)becomeFirstResponder 
{    
    if (editable) 
    {
        editing = YES;
        if ([delegate respondsToSelector:@selector(HTMLTextViewDidBeginEditing:)])
            [self.delegate HTMLTextViewDidBeginEditing:self];

        [self selectionChanged];
    }
    return [super becomeFirstResponder];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)canResignFirstResponder 
{
    if (editable && [delegate respondsToSelector:@selector(HTMLTextViewShouldEndEditing:)]) 
        return [self.delegate HTMLTextViewShouldEndEditing:self];
    return YES;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)resignFirstResponder 
{
    
    if (editable) 
    {
        editing = NO;	
        if ([delegate respondsToSelector:@selector(HTMLTextViewDidEndEditing:)]) 
            [self.delegate HTMLTextViewDidEndEditing:self];
        
        [self selectionChanged];
    }
	return [super resignFirstResponder];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// MARK: -
// MARK: UIMenu Presentation
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (CGRect)menuPresentationRect 
{
    
    CGRect rect = [textContentView convertRect:caretView.frame toView:self];
    
    if (selectedRange.location != NSNotFound && selectedRange.length > 0) 
    {
        if (selectionView!=nil)
            rect = [textContentView convertRect:selectionView.frame toView:self];
        else 
            rect = [self firstRectForNSRange:selectedRange];
        
    } 
    else if (editing && correctionRange.location != NSNotFound && correctionRange.length > 0) 
        rect = [self firstRectForNSRange:correctionRange];
    
    return rect;
    
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showMenu 
{
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    
    if ([menuController isMenuVisible])
        [menuController setMenuVisible:NO animated:NO]; 
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [menuController setMenuItems:nil];
        [menuController setTargetRect:[self menuPresentationRect] inView:self];
        [menuController update];
        [menuController setMenuVisible:YES animated:YES]; 
    });
    
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showCorrectionMenu 
{
    if (editing) 
    {
        NSRange range = [self characterRangeAtIndex:self.selectedRange.location];
        if(range.location > 1000)
            return;
        if (range.location!=NSNotFound && range.length>1) 
        {
            NSString *language = [[UITextChecker availableLanguages] objectAtIndex:0];
            if (!language)
                language = @"en_US";
            if(range.location != NSNotFound && attributedString.string > 0 && range.length < attributedString.string.length)
                self.correctionRange = [textChecker rangeOfMisspelledWordInString:attributedString.string range:range startingAt:0 wrap:YES language:language];
            
        }
    }
    
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showCorrectionMenuWithoutSelection 
{
    if (editing) 
    {
        NSRange range = [self characterRangeAtIndex:self.selectedRange.location];
        [self showCorrectionMenuForRange:range];
    } 
    else
        [self showMenu];
    
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showCorrectionMenuForRange:(NSRange)range 
{    
    if (range.location==NSNotFound || range.length==0) return;
    
    range.location = MAX(0, range.location);
    range.length = MIN(attributedString.string.length, range.length);
    
    [self removeCorrectionAttributesForRange:range];
    
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    
    if ([menuController isMenuVisible]) return;
    ignoreSelectionMenu = YES;
    
    NSString *language = [[UITextChecker availableLanguages] objectAtIndex:0];
    if (!language)
        language = @"en_US";
    
    NSArray *guesses = [textChecker guessesForWordRange:range inString:attributedString.string language:language];
    
    [menuController setTargetRect:[self menuPresentationRect] inView:self];
    
    if (guesses!=nil && [guesses count]>0) 
    {
        NSMutableArray *items = [[NSMutableArray alloc] init];
        
        if (self.menuItemActions==nil)
            self.menuItemActions = [NSMutableDictionary dictionary];
        
        for (NSString *word in guesses)
        {
            NSString *selString = [NSString stringWithFormat:@"spellCheckMenu_%i:", [word hash]];
            SEL sel = sel_registerName([selString UTF8String]);
            
            [self.menuItemActions setObject:word forKey:NSStringFromSelector(sel)]; 
            class_addMethod([self class], sel, [[self class] instanceMethodForSelector:@selector(spellingCorrection:)], "v@:@");
            
            UIMenuItem *item = [[UIMenuItem alloc] initWithTitle:word action:sel];
            [items addObject:item];
            [item release];
            if ([items count]>=4) {
                break;
            }
        }
        
        [menuController setMenuItems:items];  
        [items release];
        
    } 
    else 
    {
        
        UIMenuItem *item = [[UIMenuItem alloc] initWithTitle:@"No Replacements Found" action:@selector(spellCheckMenuEmpty:)];
        [menuController setMenuItems:[NSArray arrayWithObject:item]];
        [item release];        
    }
    
    [menuController setMenuVisible:YES animated:YES];
    
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// MARK: -
// MARK: UIMenu Actions
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender 
{    
    if (self.correctionRange.length>0 || ignoreSelectionMenu) 
    {
        if ([NSStringFromSelector(action) hasPrefix:@"spellCheckMenu"])
            return YES;
    
        return NO;
    }
    
    if (action==@selector(cut:)) 
        return (selectedRange.length>0 && editing);

    else if (action==@selector(copy:)) 
        return ((selectedRange.length>0));

    else if ((action == @selector(select:) || action == @selector(selectAll:))) 
        return (selectedRange.length==0 && [self hasText]);

    else if (action == @selector(paste:))
        return (editing && [[UIPasteboard generalPasteboard] containsPasteboardTypes:[NSArray arrayWithObject:@"public.utf8-plain-text"]]);
    
    else if (action == @selector(delete:))
        return NO;
    
    return [super canPerformAction:action withSender:sender];
    
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)spellingCorrection:(UIMenuController*)sender 
{    
    NSRange replacementRange = correctionRange;
    
    if (replacementRange.location==NSNotFound || replacementRange.length==0) 
        replacementRange = [self characterRangeAtIndex:self.selectedRange.location];

    if (replacementRange.location!=NSNotFound && replacementRange.length!=0) 
    {
        NSString *text = [self.menuItemActions objectForKey:NSStringFromSelector(_cmd)];
        [self.inputDelegate textWillChange:self];       
        [self replaceRange:[HTMLIndexedRange rangeWithNSRange:replacementRange] withText:text];
        [self.inputDelegate textDidChange:self];       
        replacementRange.length = text.length;
        [self removeCorrectionAttributesForRange:replacementRange];
    }
    
    self.correctionRange = NSMakeRange(NSNotFound, 0);
    self.menuItemActions = nil;
    [sender setMenuItems:nil];
    
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)spellCheckMenuEmpty:(id)sender 
{    
    self.correctionRange = NSMakeRange(NSNotFound, 0);
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)menuDidHide:(NSNotification*)notification 
{    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerDidHideMenuNotification object:nil];
    
    if (selectionView)
        [self showMenu];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)paste:(id)sender 
{    
    NSString *pasteText = [[UIPasteboard generalPasteboard] valueForPasteboardType:@"public.utf8-plain-text"];
    
    if (pasteText!=nil)
        [self insertText:pasteText];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)selectAll:(id)sender 
{    
    NSString *string = [attributedString string];
    NSString *trimmedString = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.selectedRange = [attributedString.string rangeOfString:trimmedString];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuDidHide:) name:UIMenuControllerDidHideMenuNotification object:nil];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)select:(id)sender 
{    
    NSRange range = [self characterRangeAtPoint_:caretView.center];
    self.selectedRange = range;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuDidHide:) name:UIMenuControllerDidHideMenuNotification object:nil];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)cut:(id)sender 
{    
    NSString *string = [attributedString.string substringWithRange:selectedRange];
    [[UIPasteboard generalPasteboard] setValue:string forPasteboardType:@"public.utf8-plain-text"];
    
    //[attributedString setAttributedString:self.attributedString];
    [self UpdateDelegate:string];
    [attributedString deleteCharactersInRange:selectedRange];
    
    [self.inputDelegate textWillChange:self];       
    //[self setAttributedString:attributedString];
    [self UpdateDelegate:string];
    [self.inputDelegate textDidChange:self];       
    
    self.selectedRange = NSMakeRange(selectedRange.location, 0);
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)copy:(id)sender 
{    
    NSString *string = [self.attributedString.string substringWithRange:selectedRange];
    [[UIPasteboard generalPasteboard] setValue:string forPasteboardType:@"public.utf8-plain-text"];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)delete:(id)sender 
{
    //NSString *string = [attributedString.string substringWithRange:selectedRange];
    [self UpdateDelegate:@""];
    [attributedString deleteCharactersInRange:selectedRange];
    [self.inputDelegate textWillChange:self];       
    [self UpdateDelegate:@""];
    [self.inputDelegate textDidChange:self];   
    
    self.selectedRange = NSMakeRange(selectedRange.location, 0);
    
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)replace:(id)sender 
{    
}

@end
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// MARK: -
// MARK: HTMLIndexedPosition
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


@implementation HTMLIndexedPosition 
@synthesize index=_index;

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+ (HTMLIndexedPosition *)positionWithIndex:(NSUInteger)index 
{
    HTMLIndexedPosition *pos = [[HTMLIndexedPosition alloc] init];
    pos.index = index;
    return [pos autorelease];
}

@end
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// MARK: -
// MARK: EGOIndexedRange
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation HTMLIndexedRange 
@synthesize range=_range;

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+ (HTMLIndexedRange *)rangeWithNSRange:(NSRange)theRange 
{
    if (theRange.location == NSNotFound)
        return nil;    
    HTMLIndexedRange *range = [[HTMLIndexedRange alloc] init];
    range.range = theRange;
    return [range autorelease];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (UITextPosition *)start {
    return [HTMLIndexedPosition positionWithIndex:self.range.location];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (UITextPosition *)end {
	return [HTMLIndexedPosition positionWithIndex:(self.range.location + self.range.length)];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(BOOL)isEmpty {
    return (self.range.length == 0);
}

@end
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// MARK: -
// MARK: HTMLContentView
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation HTMLContentView

@synthesize delegate= delegate;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame 
{
    if ((self = [super initWithFrame:frame])) 
    {
        self.userInteractionEnabled = NO;
        self.layer.geometryFlipped = YES;
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews 
{
    [super layoutSubviews];
    [self.delegate textChanged]; // reset layout on frame / orientation change
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)drawRect:(CGRect)rect 
{    
    [delegate drawContentInRect:rect];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    // Flip the coordinate system
    CGContextSetTextMatrix(ctx, CGAffineTransformIdentity);
    CGContextTranslateCTM(ctx, 0, self.bounds.size.height);
    CGContextScaleCTM(ctx, 1.0, -1.0);
    int i = 0;
    for (ImageItem* entry in delegate.imageArray) 
    {
        UIImage* image = entry.imageData;
        if(image)
        {
            CGRect imgBounds = entry.frame;
            //CGContextDrawImage(ctx, imgBounds, image.CGImage);
            [image drawInRect:imgBounds];
        }
        i++;
    }
    for (ImageItem* entry in delegate.videoArray) 
    {
        UIImage* image = entry.imageData;
        if(image)
        {
            CGRect imgBounds = entry.frame;
            [image drawInRect:imgBounds];
        }
    }
    for(TextItem* item in delegate.textArray)
    {
        NSString* text = item.text;
        if([text isEqualToString:HTML_UNORDER_LIST])
        {
            CGRect frame =item.frame;
            frame.size.width = 8;
            frame.origin.y += 8;
            frame.size.height = 8;
            CGContextSetLineWidth(ctx, 1.0);
            CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
            CGContextAddEllipseInRect(ctx, frame);
            CGContextFillEllipseInRect(ctx, frame);
        }
        else
            [text drawInRect:item.frame withFont:[UIFont boldSystemFontOfSize:item.frame.size.height] ];
        
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@end

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// MARK: -
// MARK: HTMLCaretView
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation HTMLCaretView

static const NSTimeInterval kInitialBlinkDelay = 0.6f;
static const NSTimeInterval kBlinkRate = 1.0;

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame 
{
    if ((self = [super initWithFrame:frame]))
        self.backgroundColor = [HTMLTextView caretColor];

    return self;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)show 
{    
    [self.layer removeAllAnimations];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didMoveToSuperview 
{    
    if (self.superview)
        [self delayBlink];
    else 
        [self.layer removeAllAnimations];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)delayBlink 
{    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    animation.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:1.0f], [NSNumber numberWithFloat:1.0f], [NSNumber numberWithFloat:0.0f], [NSNumber numberWithFloat:0.0f], nil];
    animation.calculationMode = kCAAnimationCubic;
    animation.duration = kBlinkRate;
    animation.beginTime = CACurrentMediaTime() + kInitialBlinkDelay;
    animation.repeatCount = CGFLOAT_MAX;
    [self.layer addAnimation:animation forKey:@"BlinkAnimation"];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
    [super dealloc];
}

@end


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// MARK: -
// MARK: HTMLLoupeView
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation HTMLLoupeView

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init 
{
    if ((self = [super initWithFrame:CGRectMake(0.0f, 0.0f, 127.0f, 127.0f)])) 
        self.backgroundColor = [UIColor clearColor];
    return self;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)drawRect:(CGRect)rect 
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    [[UIImage libraryImageNamed:@"loupe-lo.png"] drawInRect:rect];
    
    if ((contentImage!=nil)) 
    {
        CGContextSaveGState(ctx);
        CGContextClipToMask(ctx, rect, [UIImage libraryImageNamed:@"loupe-mask.png"].CGImage);
        [contentImage drawInRect:rect];        
        CGContextRestoreGState(ctx);
    }
    
    [[UIImage libraryImageNamed:@"loupe-hi.png"] drawInRect:rect];
    
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setContentImage:(UIImage *)image 
{    
    [contentImage release], contentImage=nil;
    contentImage = [image retain];
    [self setNeedsDisplay];
    
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
    [contentImage release], contentImage=nil;
    [super dealloc];
}

@end

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// MARK: -
// MARK: HTMLTextWindow
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation HTMLTextWindow

@synthesize showing=_showing;
@synthesize selectionType=_selectionType;
@synthesize type=_type;

static const CGFloat kLoupeScale = 1.2f;
static const CGFloat kMagnifyScale = 1.0f;
static const NSTimeInterval kDefaultAnimationDuration = 0.15f;

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame 
{    
    if ((self = [super initWithFrame:frame])) 
    {
        self.backgroundColor = [UIColor clearColor];
        _type = HTMLWindowLoupe;
    }
    return self;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)selectionForRange:(NSRange)range {
    return range.location;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showFromView:(UIView*)view rect:(CGRect)rect 
{
    CGPoint pos = CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect));
    
    if (!_showing) 
    {
        if (_view == nil) 
        {
            UIView *view;
            if (_type==HTMLWindowLoupe) 
                view = [[HTMLLoupeView alloc] init];
            else 
                view = [[HTMLMagnifyView alloc] init];
    
            [self addSubview:view];
            _view=view;
            [view release];
        }
        
        CGRect frame = _view.frame;
        frame.origin.x = floorf(pos.x - (_view.bounds.size.width/2));
        frame.origin.y = floorf(pos.y - _view.bounds.size.height);
        
        if (_type==HTMLWindowMagnify) 
        {
            frame.origin.y = MAX(frame.origin.y+8.0f, 0.0f);
            frame.origin.x += 2.0f;
        } else 
            frame.origin.y = MAX(frame.origin.y-10.0f, -40.0f);
        
        CGRect originFrame = frame;
        frame.origin.y += frame.size.height/2;
        _view.frame = frame;
        _view.transform = CGAffineTransformMakeScale(0.01f, 0.01f);
        _view.alpha = 0.01f;
        
        [UIView animateWithDuration:kDefaultAnimationDuration animations:^{
            
            _view.alpha = 1.0f;
            _view.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
            _view.frame = originFrame;
            
        } completion:^(BOOL finished) {
            
            _showing=YES;
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (0.0f*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self renderWithContentView:view fromRect:rect];
            });
            
        }];
        
    }
    
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)hide:(BOOL)animated 
{    
    if ((_view!=nil))
    {
        [UIView animateWithDuration:kDefaultAnimationDuration animations:^{
            
            CGRect frame = _view.frame;
            CGPoint center = _view.center;
            frame.origin.x = floorf(center.x-(frame.size.width/2));
            frame.origin.y = center.y;
            _view.frame = frame;
            _view.transform = CGAffineTransformMakeScale(0.01f, 0.01f);
            
        } completion:^(BOOL finished) 
        {
            _showing=NO;
            [_view removeFromSuperview];
            _view=nil;
            self.windowLevel = UIWindowLevelNormal;
            self.hidden = YES;
            
        }];
        
    }
    
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (UIImage*)screenshotFromCaretFrame:(CGRect)rect inView:(UIView*)view scale:(BOOL)scale 
{    
    CGRect offsetRect = [self convertRect:rect toView:view];
    offsetRect.origin.y += ((UIScrollView*)view.superview).contentOffset.y;
    offsetRect.origin.y -= _view.bounds.size.height+20.0f;
    offsetRect.origin.x -= (_view.bounds.size.width/2);
    
    //CGFloat magnifyScale = 1.0f; 
    
    if (scale) 
    {
        //CGFloat max = 24.0f;
        // magnifyScale = max/offsetRect.size.height;
        // NSLog(@"max %f scale %f", max, magnifyScale);
    } else if (rect.size.height < 22.0f) 
    {
        //magnifyScale = 22.0f/offsetRect.size.height;
        //NSLog(@"cale %f", magnifyScale);
    }
    
    UIGraphicsBeginImageContextWithOptions(_view.bounds.size, YES, [[UIScreen mainScreen] scale]);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f].CGColor);
    UIRectFill(CGContextGetClipBoundingBox(ctx));
    
    CGContextSaveGState(ctx);
    CGContextTranslateCTM(ctx, 0, view.bounds.size.height);
    CGContextScaleCTM(ctx, 1.0, -1.0);
    
    //    CGContextConcatCTM(ctx, CGAffineTransformMakeScale(magnifyScale, magnifyScale));
    CGContextConcatCTM(ctx, CGAffineTransformMakeTranslation(-(offsetRect.origin.x), offsetRect.origin.y));
    
    UIView *selectionView = nil;
    CGRect selectionFrame = CGRectZero;
    
    for (UIView *subview in view.subviews)
        if ([subview isKindOfClass:[HTMLSelectionView class]]) 
            selectionView = subview;
    
    if (selectionView!=nil) 
    {
        selectionFrame = selectionView.frame;
        CGRect newFrame = selectionFrame;
        newFrame.origin.y = (selectionFrame.size.height - view.bounds.size.height) - ((selectionFrame.origin.y + selectionFrame.size.height) - view.bounds.size.height);
        selectionView.frame = newFrame;
    }
    
    [view.layer renderInContext:ctx];
    
    if (selectionView!=nil)
        selectionView.frame = selectionFrame;
    
    CGContextRestoreGState(ctx);
    UIImage *aImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return aImage;
    
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)renderWithContentView:(UIView*)view fromRect:(CGRect)rect 
{    
    CGPoint pos = CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect));
    
    if (_showing && _view!=nil) 
    {
        CGRect frame = _view.frame;
        frame.origin.x = floorf((pos.x - (_view.bounds.size.width/2)) + (rect.size.width/2));
        frame.origin.y = floorf(pos.y - _view.bounds.size.height);
        
        if (_type == HTMLWindowMagnify)
        {
            frame.origin.y = MAX(0.0f, frame.origin.y);
            rect = [self convertRect:rect toView:view];
        } else 
        {
            frame.origin.y = MAX(frame.origin.y-10.0f, -40.0f);
            rect = [self convertRect:rect toView:view];
        }
        _view.frame = frame;
        
        UIImage *image = [self screenshotFromCaretFrame:rect inView:view scale:(_type==HTMLWindowMagnify)];
        [(HTMLLoupeView*)_view setContentImage:image];
        
    }
    
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)updateWindowTransform 
{    
    self.frame = [[UIScreen mainScreen] bounds];
    switch ([[UIApplication sharedApplication] statusBarOrientation]) 
    {
        case UIInterfaceOrientationPortrait:
            self.layer.transform = CATransform3DIdentity;
            break;
        case UIInterfaceOrientationLandscapeRight:
            self.layer.transform = CATransform3DMakeRotation((M_PI/180)*90, 0, 0, 1);
            break;
        case UIInterfaceOrientationLandscapeLeft:
            self.layer.transform = CATransform3DMakeRotation((M_PI/180)*-90, 0, 0, 1);
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            self.layer.transform = CATransform3DMakeRotation((M_PI/180)*180, 0, 0, 1);
            break;
        default:
            break;
    }
    
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews 
{
    [super layoutSubviews];
    [self updateWindowTransform];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc 
{
    _view=nil;
    [super dealloc];
}

@end


/////////////////////////////////////////////////////////////////////////////
// MARK: -
// MARK: EGOMagnifyView
/////////////////////////////////////////////////////////////////////////////

@implementation HTMLMagnifyView

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init 
{
    if ((self = [super initWithFrame:CGRectMake(0.0f, 0.0f, 145.0f, 59.0f)]))
        self.backgroundColor = [UIColor clearColor];
    return self;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)drawRect:(CGRect)rect 
{    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    [[UIImage libraryImageNamed:@"magnifier-ranged-lo.png"] drawInRect:rect];
    
    if ((contentImage!=nil)) 
    {
        CGContextSaveGState(ctx);
        CGContextClipToMask(ctx, rect, [UIImage libraryImageNamed:@"magnifier-ranged-mask.png"].CGImage);
        [contentImage drawInRect:rect];        
        CGContextRestoreGState(ctx);
    }
    [[UIImage libraryImageNamed:@"magnifier-ranged-hi.png"] drawInRect:rect];
    
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setContentImage:(UIImage *)image 
{    
    [contentImage release], contentImage=nil;
    contentImage = [image retain];
    [self setNeedsDisplay];
    
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
    [contentImage release], contentImage=nil;
    [super dealloc];
}

@end


/////////////////////////////////////////////////////////////////////////////
// MARK: -
// MARK: HTMLSelectionView
/////////////////////////////////////////////////////////////////////////////

@implementation HTMLSelectionView

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame 
{
    if ((self = [super initWithFrame:frame])) 
    {
        self.backgroundColor = [UIColor clearColor]; 
        self.userInteractionEnabled = NO;
        self.layer.geometryFlipped = YES;
    }
    return self;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setBeginCaret:(CGRect)begin endCaret:(CGRect)end 
{    
    if(!self.superview) return;

    self.frame = CGRectMake(begin.origin.x, begin.origin.y + begin.size.height, end.origin.x - begin.origin.x, (end.origin.y-end.size.height)-begin.origin.y);   
    begin = [self.superview convertRect:begin toView:self];
    end = [self.superview convertRect:end toView:self];
    
    
    if (leftCaret == nil) 
    {
        UIView *view = [[UIView alloc] initWithFrame:begin];
        view.backgroundColor = [HTMLTextView caretColor];
        [self addSubview:view]; 
        leftCaret=[view retain];
        [view release];
    }
    
    if (leftDot == nil) 
    {
        UIImage *dotImage = [UIImage libraryImageNamed:@"drag-dot.png"];
        UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, dotImage.size.width, dotImage.size.height)];
        [view setImage:dotImage];
        [self addSubview:view];
        leftDot = view;
        [view release];
    }
    
    CGFloat _dotShadowOffset = 5.0f;
    leftCaret.frame = begin;
    leftDot.frame = CGRectMake(floorf(leftCaret.center.x - (leftDot.bounds.size.width/2)), leftCaret.frame.origin.y-(leftDot.bounds.size.height-_dotShadowOffset), leftDot.bounds.size.width, leftDot.bounds.size.height);
    
    if (rightCaret==nil) 
    {
        UIView *view = [[UIView alloc] initWithFrame:end];
        view.backgroundColor = [HTMLTextView caretColor];
        [self addSubview:view];
        rightCaret = [view retain];
        [view release];
    }
    
    if (rightDot==nil)
    {
        UIImage *dotImage = [UIImage libraryImageNamed:@"drag-dot.png"];
        UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, dotImage.size.width, dotImage.size.height)];
        [view setImage:dotImage];
        [self addSubview:view];
        rightDot = view;
        [view release];
    }
    
    rightCaret.frame = end;
    rightDot.frame = CGRectMake(floorf(rightCaret.center.x - (rightDot.bounds.size.width/2)), CGRectGetMaxY(rightCaret.frame), rightDot.bounds.size.width, rightDot.bounds.size.height);
    
    
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc 
{    
    [leftCaret release], leftCaret=nil;
    [rightCaret release], rightCaret=nil;
    rightDot=nil;
    leftDot=nil;
    [super dealloc];
}

@end


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TextItem

@synthesize frame = frame,text = text,tag =tag;
+(TextItem*)textItem:(NSString*)text frame:(CGRect)rect tag:(NSInteger)tag
{
    TextItem* item = [[[TextItem alloc] init] autorelease];
    item.text = text;
    item.frame = rect;
    item.tag = tag;
    return item;
}

@end

