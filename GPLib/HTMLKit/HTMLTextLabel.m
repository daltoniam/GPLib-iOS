//
//  HTMLTextLabel.m
//  GPLib
//
//  Created by Dalton Cherry on 11/22/11.
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

#import "HTMLTextLabel.h"
#import "HTMLText.h"
#import "HTMLParser.h"
#import <QuartzCore/QuartzCore.h>
#import "HTMLText.h"

#define LONG_PRESS_THRESHOLD 0.75

@implementation HTMLTextLabel

@synthesize extendHeightToFit,attributedText = attributedText,delegate = delegate,rawHTML,ignoreXAttachment,autoSizeImages; //cachedFramesetter

//////////////////////////////////////////////////////////////////////////////
-(void)commonInit
{
    self.backgroundColor = [UIColor clearColor];
    self.userInteractionEnabled = YES;
    imageArray = [[NSMutableArray alloc] init];
    videoArray = [[NSMutableArray alloc] init];
    viewArray = [[NSMutableArray alloc] init];
}
//////////////////////////////////////////////////////////////////////////////
-(void)commonClean
{
    [imageArray removeAllObjects];
    for(ImageItem* item in videoArray)
        [item.subView removeFromSuperview];
    [videoArray removeAllObjects];
    
    for(ImageItem* item in viewArray)
        [item.subView removeFromSuperview];
    [viewArray removeAllObjects];
}
//////////////////////////////////////////////////////////////////////////////
-(id)init
{
    if(self = [super init])
    {
        [self commonInit];
    }
    return self;
}
//////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame 
{
    if ((self = [super initWithFrame:frame])) 
    {
        [self commonInit];
    }
    return self;
}
////////////////////////////////////////////////////////////////////////////////////////
//init with nsattributed string and resource urls from the GPHTMLParser
- (id)initWithAttributedString:(NSAttributedString*)string
{
    self = [super init];
    if (self) 
    {
        [self commonInit];
        self.attributedText = string;
    }
    return self;
}
////////////////////////////////////////////////////////////////////////////////////////
//set html string and if content should be embed
- (id)initWithHTML:(NSString*)html embed:(BOOL)embed frame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        [self commonInit];
        rawHTML = [html retain];
        HTMLParser* parser = [[[HTMLParser alloc] initWithHTML:html] autorelease];
        parser.Embed = embed;
        self.attributedText = [parser ParseHTML];
    }
    return self;
}
////////////////////////////////////////////////////////////////////////////////////////
-(void)setHTML:(NSString*)html embed:(BOOL)embed
{
    [self commonClean];
    rawHTML = [html retain];
    HTMLParser* parser = [[[HTMLParser alloc] initWithHTML:html] autorelease];
    parser.Embed = embed;
    self.attributedText = [parser ParseHTML];
    //if(self.cachedFramesetter)
    //    CFRelease(self.cachedFramesetter);
    //self.cachedFramesetter = NULL;
    [self setNeedsDisplay];
}
////////////////////////////////////////////////////////////////////////////////////////
//much higher preformance than setHTML, use when possible.
-(void)setAttributedString:(NSAttributedString *)string height:(CGFloat)height frame:(CTFramesetterRef)framesetter
{
    [self commonClean];
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
    self.attributedText = string;
    //self.cachedFramesetter = framesetter;
}
////////////////////////////////////////////////////////////////////////////////////////
//draw non text content
-(void)drawRect:(CGRect)rect
{
    isDrawing = YES;
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    for(ImageItem* entry in videoArray)
    {
        [entry.subView removeFromSuperview];
        [self addSubview:entry.subView];
        [(GPYouTubeView*)entry.subView loadVideo];
        [self bringSubviewToFront:entry.subView];
    }
    for(ImageItem* entry in viewArray)
    {
        [entry.subView removeFromSuperview];
        [self addSubview:entry.subView];
        [self bringSubviewToFront:entry.subView];
    }
    
    for (ImageItem* entry in imageArray) 
    {
        UIImage* image = entry.imageData;
        if(image)
        {
            CGRect imgBounds = entry.frame;
            if([delegate respondsToSelector:@selector(willLoadImage:frame:)])
                image = [delegate willLoadImage:image frame:imgBounds];

            CGContextDrawImage(context, imgBounds, image.CGImage);
            //[image drawInRect:imgBounds];
        }
    }
    isDrawing = NO;
}
//////////////////////////////////////////////////////////////////////////////
//load image from http
-(void)FetchImage:(ImageItem*)item
{
    [imageArray addObject:item];
    NSString* url = item.URL;
    if(!url)
        return;
    else if([url hasPrefix:@"http"])
    {
        if(!requestArray)
            requestArray = [[NSMutableArray alloc] init];
        GPHTTPRequest* SendRequest = [GPHTTPRequest requestWithString:url];
        [SendRequest setCacheModel:GPHTTPCacheCustomTime];
        [SendRequest setCacheTimeout:60*60*1]; // Cache for 1 hour
        [SendRequest setDelegate:self];
        [SendRequest startAsync];
        [requestArray addObject:SendRequest];
    }
    else
    {
        UIImage* image = [UIImage imageNamed:url];
        if(!image)
            image = [UIImage imageWithContentsOfFile:url];
        if(!image)
        {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *path = [paths objectAtIndex:0];
            image = [UIImage imageWithContentsOfFile: [NSString stringWithFormat:@"%@/%@",path,[url encodeURL]] ];
        }
        for(ImageItem* item in imageArray )
            if([item.URL isEqualToString:url])
                item.imageData = image;
    }
}
//////////////////////////////////////////////////////////////////////////////
- (void)requestFinished:(GPHTTPRequest *)request
{
    [requestArray removeObject:request];
    UIImage* image = [UIImage imageWithData:[request responseData]];
    for(ImageItem* item in imageArray )
    {
        if([item.URL isEqualToString:request.URL.absoluteString])
        {
            item.imageData = image;
            if(self.autoSizeImages)
            {
                int width = image.size.width;
                int height = image.size.height;
                while(width > self.frame.size.width)
                {
                    height = height - height/4;//height/2;
                    width = width - width/4;//width/2;
                }
                //create a temp copy to enumerate through, that way if the attributedText is modified, we are still golden
                NSAttributedString* tempString = [[[NSAttributedString alloc] initWithAttributedString:self.attributedText] autorelease];
                NSRange validRange = NSMakeRange(0,[tempString length]);
                [tempString enumerateAttributesInRange:validRange options:0 usingBlock:
                 ^(NSDictionary *attributes, NSRange range, BOOL *stop) 
                 {
                     NSString* imageurl = [attributes objectForKey:IMAGE_LINK];
                     if([imageurl isEqualToString:request.URL.absoluteString])
                     {
                         if([self.delegate respondsToSelector:@selector(imageFinished:height:width:)])
                             [self.delegate imageFinished:item.URL height:height width:width];
                     }
                 }];
            }
        }
    }
    if(!isDrawing)
        [self setNeedsDisplay];
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
-(BOOL)didAddView:(int)value
{
    for(ImageItem* item in viewArray)
        if(item.subView.tag = value)
            return YES;
    return NO;
}
//////////////////////////////////////////////////////////////////////////////
- (void)drawTextInRect:(CGRect)rect
{
    isDrawing = YES;
    if (self.attributedText) 
    {
		CGContextRef ctx = UIGraphicsGetCurrentContext();
		//CGContextSaveGState(ctx);
        
		// flipping the context to draw core text
		// no need to flip our typographical bounds from now on
        CGContextSetTextMatrix(ctx, CGAffineTransformIdentity);
        CGContextTranslateCTM(ctx, 0, self.bounds.size.height);
        CGContextScaleCTM(ctx, 1.0, -1.0);
		//CGContextConcatCTM(ctx, CGAffineTransformScale(CGAffineTransformMakeTranslation(0, self.bounds.size.height), 1.f, -1.f));
        
		if (self.shadowColor) 
			CGContextSetShadowWithColor(ctx, self.shadowOffset, 0.0, self.shadowColor.CGColor);
        
		if (textFrame == NULL) 
        {
            CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self.attributedText);
            //if(!self.cachedFramesetter)
            //    self.cachedFramesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self.attributedText);
			CGRect frame = self.bounds;
			if (self.extendHeightToFit)
            {
                CGSize size = CTFramesetterSuggestFrameSizeWithConstraints(framesetter,CFRangeMake(0,0),NULL,CGSizeMake(frame.size.width,CGFLOAT_MAX),NULL); //self.cachedFramesetter
                CGFloat delta = MAX(0.f , ceilf(size.height - frame.size.height)) + 10;
                frame.origin.y -= delta;
                frame.size.height += delta;
                //NSLog(@"height: %f",frame.size.height);
                
				//if (self.CenterVertically)
				//	frame.origin.y -= (frame.size.height - sz.height)/2;
			}
			CGMutablePathRef path = CGPathCreateMutable();
			CGPathAddRect(path, NULL, frame);
			textFrame = CTFramesetterCreateFrame(framesetter,CFRangeMake(0,0), path, NULL); //self.cachedFramesetter
			CGPathRelease(path);
			CFRelease(framesetter);
		}
        
		CTFrameDraw(textFrame, ctx);
        CFArrayRef leftLines = CTFrameGetLines(textFrame); //textFrame
        CGPoint *origins = malloc(sizeof(CGPoint)*[(NSArray *)leftLines count]);
        CTFrameGetLineOrigins(textFrame,CFRangeMake(0, 0), origins);
        NSInteger lineIndex = 0;
        
        for (id oneLine in (NSArray *)leftLines)
        {
            CFArrayRef runs = CTLineGetGlyphRuns((CTLineRef)oneLine);
            
            for (id oneRun in (NSArray *)runs)
            {
                CGFloat ascent = 0;
                CGFloat descent = 0;
                
                CGFloat width = CTRunGetTypographicBounds((CTRunRef) oneRun,CFRangeMake(0, 0),&ascent,&descent, NULL);
                
                CGFloat xOffset = CTLineGetOffsetForStringIndex((CTLineRef)oneLine, CTRunGetStringRange((CTRunRef)oneRun).location, NULL);
                CGFloat height = ascent + descent;
                
                CGRect runRect = CGRectMake(origins[lineIndex].x + xOffset,origins[lineIndex].y + self.frame.origin.y,width,height );
                runRect.origin.y -= descent;
                CGPathRef pathRef = CTFrameGetPath(textFrame);
                CGRect colRect = CGPathGetBoundingBox(pathRef);
                
                runRect = CGRectOffset(runRect, colRect.origin.x, colRect.origin.y - self.frame.origin.y);
                runRect = CGRectIntegral(runRect);	
                runRect = CGRectInset(runRect, -1, -1);
                
                NSDictionary *attributes = (NSDictionary *)CTRunGetAttributes((CTRunRef) oneRun);
                
                BOOL strikeOut = [[attributes objectForKey:STRIKE_OUT] boolValue];
                NSString* hyperlink = [attributes objectForKey:HYPER_LINK];
                NSString* imageurl = [attributes objectForKey:IMAGE_LINK];
                UIImage* imagedata = [attributes objectForKey:HTML_IMAGE_DATA];
                NSString* videourl = [attributes objectForKey:VIDEO_LINK];
                NSNumber* viewSpace = [attributes objectForKey:VIEW_SPACE];
                
                if (strikeOut)
                {
                    CGContextSaveGState(ctx);
                    id color = [attributes objectForKey:(id)kCTForegroundColorAttributeName];
                    
                    if (color)
                        CGContextSetStrokeColorWithColor(ctx, (CGColorRef)color);
                    else
                        CGContextSetGrayStrokeColor(ctx, 0, 1.0);
                    CGFloat y = roundf(runRect.origin.y + (runRect.size.height/2) );
                    CGContextMoveToPoint(ctx, runRect.origin.x, y);
                    CGContextAddLineToPoint(ctx, runRect.origin.x + runRect.size.width, y);
                    
                    CGContextStrokePath(ctx);
                    CGContextRestoreGState(ctx);
                }
                
                UIColor* highlight = [UIColor clearColor];
                if(hyperlink && [hyperlink isEqualToString:CurrentHyperLink])
                    highlight = [UIColor colorWithWhite:0.4 alpha:0.3];
                
                if(hyperlink)
                {
                    CGContextSaveGState(ctx);
                    CGContextSetFillColorWithColor(ctx,highlight.CGColor);
                    CGContextFillRect(ctx,runRect);
                    CGContextRestoreGState(ctx);
                    [self processHyperLink:hyperlink];
                }
                if(imageurl && ![self didLoadURL:imageurl])
                {
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
                    CGPathRef pathRef = CTFrameGetPath(textFrame); //10
                    CGRect colRect = CGPathGetBoundingBox(pathRef);
                    
                    CGRect imgBounds = CGRectOffset(runBounds, colRect.origin.x, colRect.origin.y - self.frame.origin.y);
                    if(self.ignoreXAttachment)
                        imgBounds.origin.x = 0;
                    
                    if(imagedata)
                        [imageArray addObject:[ImageItem imageItem:imagedata url:imageurl frame:imgBounds]]; //(origins[lineIndex].y+10)
                    else                                                                                       
                        [self FetchImage:[ImageItem imageItem:nil url:imageurl frame:imgBounds]]; //(origins[lineIndex].y+10)+imgtop
                    
                }
                if(videourl && ![self didLoadVideo:videourl])
                {
                    float vidheight = [(NSString*)[(NSDictionary*)attributes objectForKey:@"height"] floatValue];
                    float vidwidth = [(NSString*)[(NSDictionary*)attributes objectForKey:@"width"] floatValue];

                    CGRect runBounds;
                    runBounds.size.width = vidwidth;
                    runBounds.size.height = vidheight;
                    
                    runBounds.origin.x = rect.size.width - origins[lineIndex].x;
                    runBounds.origin.x -= vidwidth;
                    runBounds.origin.y = rect.size.height - origins[lineIndex].y;
                    runBounds.origin.y -= descent;
                    runBounds.origin.y -= vidheight;
                    CGPathRef pathRef = CTFrameGetPath(textFrame); //10
                    CGRect colRect = CGPathGetBoundingBox(pathRef);
                    
                    CGRect frame = CGRectOffset(runBounds, colRect.origin.x, colRect.origin.y - self.frame.origin.y);
                    if(self.ignoreXAttachment)
                        frame.origin.x = 0;
                    
                     //(origins[lineIndex].y + 5)+ imgtop
                    GPYouTubeView* youtube = [[[GPYouTubeView alloc] initWithFrame:frame] autorelease];
                    youtube.URL = videourl;
                    [videoArray addObject:[ImageItem videoItem:youtube url:videourl frame:frame]];
                }
                if(viewSpace && ![self didAddView:[viewSpace intValue]])
                {
                    if([self.delegate respondsToSelector:@selector(subViewWillLoad:)])
                    {
                        float height = [(NSString*)[(NSDictionary*)attributes objectForKey:@"height"] floatValue];
                        float width = [(NSString*)[(NSDictionary*)attributes objectForKey:@"width"] floatValue];
                        float top = 0;
                        if([(NSDictionary*)attributes objectForKey:@"padding"])
                            top = [(NSString*)[(NSDictionary*)attributes objectForKey:@"padding"] floatValue];
                        top = -top; //we swap to negitive, as the bounds are reversed
                        CGRect runBounds;
                        runBounds.size.width = width;
                        runBounds.size.height = height;
                        
                        runBounds.origin.x = xOffset;
                        runBounds.origin.y = self.frame.size.height + self.frame.origin.y + top; //origins[lineIndex].y 
                        runBounds.origin.y -= descent;
                        runBounds.origin.y -=  origins[lineIndex].y; //height+5;
                        CGPathRef pathRef = CTFrameGetPath(textFrame); //10
                        CGRect colRect = CGPathGetBoundingBox(pathRef);
                        
                        CGRect frame = CGRectOffset(runBounds, colRect.origin.x, colRect.origin.y - self.frame.origin.y);
                        //frame.origin.y -= height/2 + 1;
                        //if(self.ignoreXAttachment)
                        //    frame.origin.x = 0;
                        if(frame.origin.x + width > self.frame.size.width)
                        {
                            frame.origin.x = 0;
                            frame.origin.y += height;
                        }
                        //ask delegate for view and add to array so it will only exist once
                        UIView* view = [self.delegate subViewWillLoad:[viewSpace intValue]];
                        view.frame = frame;
                        view.tag = [viewSpace intValue];
                        [viewArray addObject:[ImageItem viewItem:view frame:frame]];
                    }
                }

                
            }
            lineIndex++;
        }
        
        // cleanup
        free(origins);
		//CGContextRestoreGState(ctx);
    }
    else
		[super drawTextInRect:rect];
    isDrawing = NO;
}
//////////////////////////////////////////////////////////////////////////////
-(CGFloat)getTextHeight
{
    if (attributedText) 
    {
        //if(!self.cachedFramesetter)
        //    self.cachedFramesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedText);
        CGRect frame = self.bounds;
        if (self.extendHeightToFit)
        {
            CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedText);
            //NSLog(@"frame.size.width: %f",frame.size.width);
            CGSize size = CTFramesetterSuggestFrameSizeWithConstraints(framesetter,CFRangeMake(0,0),NULL,CGSizeMake(frame.size.width,CGFLOAT_MAX),NULL);
            //NSLog(@"size: %f",size.height);
            CGFloat delta = MAX(0.f , ceilf(size.height - frame.size.height)) + 10;
            frame.origin.y -= delta;
            frame.size.height += delta;
            CFRelease(framesetter);
            //NSLog(@"text label frame height: %f",frame.size.height);
        }
        return frame.size.height;
    }
    return 0;
}
//////////////////////////////////////////////////////////////////////////////
//finds the character tap on at a point
- (NSUInteger)characterIndexAtPoint:(CGPoint)p 
{
    if (!CGRectContainsPoint(self.bounds, p)) 
        return NSNotFound;
    
    CGRect textRect = self.bounds;
    if (!CGRectContainsPoint(textRect, p)) 
        return NSNotFound;
    
    // Convert tap coordinates (start at top left) to CT coordinates (start at bottom left)
    p = CGPointMake(p.x, textRect.size.height - p.y);
    
    CFIndex idx = NSNotFound;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, textRect);
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedText);
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [self.attributedText length]), path, NULL);
    CFArrayRef lines = CTFrameGetLines(frame);
    NSUInteger numberOfLines = CFArrayGetCount(lines);
    if(numberOfLines > 0)
    {
        CGPoint lineOrigins[numberOfLines];
        CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), lineOrigins);
        NSUInteger lineIndex;
        
        for (lineIndex = 0; lineIndex < (numberOfLines - 1); lineIndex++)
        {
            CGPoint lineOrigin = lineOrigins[lineIndex];
            if (lineOrigin.y < p.y)
                break;
        }
        
        CGPoint lineOrigin = lineOrigins[lineIndex];
        CTLineRef line = CFArrayGetValueAtIndex(lines, lineIndex);
        // Convert CT coordinates to line-relative coordinates
        CGPoint relativePoint = CGPointMake(p.x - lineOrigin.x, p.y - lineOrigin.y);
        idx = CTLineGetStringIndexForPosition(line, relativePoint);
    }
    
    CFRelease(frame);
    CFRelease(path);
    
    return idx;
}
//////////////////////////////////////////////////////////////////////////////
-(void)processHyperLink:(NSString*)link
{
    //sub class this if you plan to do something fancy to the links
}
//////////////////////////////////////////////////////////////////////////////
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
    isLongPress = NO;
    UITouch* touch = [touches anyObject];
	CGPoint pt = [touch locationInView:self];
    CFIndex idx = [self characterIndexAtPoint:pt];
    if(idx != NSNotFound && idx < [attributedText length])
    {
        NSDictionary* attribs = [attributedText attributesAtIndex:idx effectiveRange:NULL];
        NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithDictionary:attribs];
        [dict setValue:[NSValue valueWithCGPoint:pt] forKey:@"point"];
        
        [self performSelector:@selector(fireLongPress:)
                   withObject:dict
                   afterDelay:LONG_PRESS_THRESHOLD];
        NSString* hyperlink = [attribs objectForKey:HYPER_LINK];
        if(hyperlink)
        {
            CurrentHyperLink = hyperlink;
            [self setNeedsDisplay];
        }
    }
    [self.nextResponder touchesBegan:touches withEvent:event];
}
//////////////////////////////////////////////////////////////////////////////
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if(CurrentHyperLink)
    {
        CurrentHyperLink = nil;
        [self setNeedsDisplay];
    }
    [self.nextResponder touchesEnded:touches withEvent:event];
}
//////////////////////////////////////////////////////////////////////////////
//handles hyperlink clicking
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event 
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if(isLongPress)
    {
        isLongPress = NO;
        [self.nextResponder touchesEnded:touches withEvent:event];
        return;
    }
    if(CurrentHyperLink)
    {
        CurrentHyperLink = nil;
        [self setNeedsDisplay];
    }
	UITouch* touch = [touches anyObject];
	CGPoint pt = [touch locationInView:self];
    CFIndex idx = [self characterIndexAtPoint:pt];
    if(idx != NSNotFound && idx < [attributedText length])
    {
        NSDictionary* attribs = [attributedText attributesAtIndex:idx effectiveRange:NULL];
        NSString* hyperlink = [attribs objectForKey:HYPER_LINK];
        NSString* imageURL = [attribs objectForKey:IMAGE_LINK];
        if([delegate respondsToSelector:@selector(didSelectLink:)] && hyperlink)
        {
            [delegate didSelectLink:hyperlink];
            return;
        }
        if(imageURL)
        {
            if([delegate respondsToSelector:@selector(didSelectImage:)] && imageURL)
            {
                [delegate didSelectImage:imageURL];
                return;
            }
        }
    }
    [self.nextResponder touchesEnded:touches withEvent:event];
}
//////////////////////////////////////////////////////////////////////////////
- (void)fireLongPress:(NSDictionary*)attribs
{
    isLongPress = YES;
    CurrentHyperLink = nil;
    [self setNeedsDisplay];
    NSString* hyperlink = [attribs objectForKey:HYPER_LINK];
    NSString* imageURL = [attribs objectForKey:IMAGE_LINK];
    if([delegate respondsToSelector:@selector(didLongPressLink:frame:)] && hyperlink)
    {
        CGPoint pt = [[attribs objectForKey:@"point"] CGPointValue];
        CGRect frame = CGRectMake(pt.x, pt.y, hyperlink.length, 14);
        [delegate didLongPressLink:hyperlink frame:frame];
        return;
    }
    if([delegate respondsToSelector:@selector(didLongPressImage:)] && imageURL)
    {
        [delegate didLongPressImage:hyperlink];
        return;
    }
}
//////////////////////////////////////////////////////////////////////////////
-(void)setNeedsDisplay 
{
    if (textFrame) 
    {
		CFRelease(textFrame);
		textFrame = NULL;
    }
    /*if(self.cachedFramesetter)
    {
        CFRelease(self.cachedFramesetter);
        self.cachedFramesetter = NULL;
    }*/
	[super setNeedsDisplay];
}
//////////////////////////////////////////////////////////////////////////////
-(void)dealloc
{
    if (textFrame) 
    {
		CFRelease(textFrame);
		textFrame = NULL;
    }
    /*if(self.cachedFramesetter)
    {
        CFRelease(self.cachedFramesetter);
        self.cachedFramesetter = NULL;
    }*/
    self.delegate = nil;
    for(GPHTTPRequest* request in requestArray)
    {
        [request cancel];
        request.delegate = nil;
    }
    [requestArray release];
    [attributedText release];
    [imageArray release];
    [videoArray release];
    [viewArray release];
    [super dealloc];
}
@end
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
@implementation ImageItem

@synthesize frame = frame,imageData = imageData,URL = URL,subView,didTransform;
//////////////////////////////////////////////////////////////////////////////
+(ImageItem*)imageItem:(UIImage*)image url:(NSString*)url frame:(CGRect)rect
{
    ImageItem* item = [[[ImageItem alloc] init] autorelease];
    item.URL = url;
    item.frame = rect;
    item.imageData = image;
    return item;
}
//////////////////////////////////////////////////////////////////////////////
+(ImageItem*)videoItem:(GPYouTubeView*)view url:(NSString*)url frame:(CGRect)rect
{
    ImageItem* item = [[[ImageItem alloc] init] autorelease];
    item.URL = url;
    item.frame = rect;
    item.subView = view;
    return item;
}
//////////////////////////////////////////////////////////////////////////////
+(ImageItem*)viewItem:(UIView*)view frame:(CGRect)rect
{
    ImageItem* item = [[[ImageItem alloc] init] autorelease];
    item.frame = rect;
    item.subView = view;
    return item;
}
//////////////////////////////////////////////////////////////////////////////

@end
