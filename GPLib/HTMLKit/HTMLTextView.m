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

#import "HTMLTextView.h"
#import "HTMLText.h"
#import <objc/runtime.h>
#import "GPHTTPRequest.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+Additions.h"

//////////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation HTMLTextView

@synthesize boldText,italizeText,underlineText,strikeText,textAlignment,font,textColor;
@synthesize autocorrectionType,enablesReturnKeyAutomatically,keyboardAppearance,keyboardType,returnKeyType;
@synthesize editable,delegate;
//////////////////////////////////////////////////////////////////////////////////////////////////////////
-(id)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        inputView = [[HTMLInputView alloc] initWithFrame:frame];
        inputView.delegate = self;
        [self addSubview:inputView];
        self.font = [UIFont systemFontOfSize:12];
        self.textColor = [UIColor blackColor];
        self.textAlignment = kCTLeftTextAlignment;
        self.editable = YES;
        self.contentInset = UIEdgeInsetsMake(5, 5, 5, 5);
    }
    return self;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)reload
{
    [inputView setNeedsDisplay];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)updateSize:(CGSize)size
{
    self.contentSize = size;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
//forward the the input view.
//////////////////////////////////////////////////////////////////////////////////////////////////////////
-(NSMutableAttributedString*)attribString
{
    return inputView.attribString;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setAttribString:(NSMutableAttributedString *)string
{
    inputView.attribString = string;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setEditable:(BOOL)edit
{
    inputView.editable = edit;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
-(NSRange)selectedRange
{
    return inputView.selectedRange;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setSelectedRange:(NSRange)range
{
    inputView.selectedRange = range;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)addImage:(UIImage*)image
{
    [inputView addImage:image];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)addImageURL:(NSString*)imageURL
{
    [inputView addImageURL:imageURL];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)addVideoURL:(NSString*)videoURL
{
    [inputView addVideoURL:videoURL];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)textViewShouldBeginEditing
{
    if([self.delegate respondsToSelector:@selector(HTMLTextViewShouldBeginEditing:)])
        return [self.delegate HTMLTextViewShouldBeginEditing:self];
    return YES;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)textViewShouldEndEditing
{
    if([self.delegate respondsToSelector:@selector(HTMLTextViewShouldEndEditing:)])
        return [self.delegate HTMLTextViewShouldEndEditing:self];
    return YES;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)textViewDidBeginEditing
{
    if([self.delegate respondsToSelector:@selector(HTMLTextViewDidBeginEditing:)])
        return [self.delegate HTMLTextViewDidBeginEditing:self];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)textViewDidEndEditing
{
    if([self.delegate respondsToSelector:@selector(HTMLTextViewDidEndEditing:)])
        return [self.delegate HTMLTextViewDidEndEditing:self];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)textView:(NSRange)range replacementText:(NSString *)text
{
    if([self.delegate respondsToSelector:@selector(HTMLTextView:shouldChangeTextInRange:replacementText:)])
        return [self.delegate HTMLTextView:self shouldChangeTextInRange:range replacementText:text];
    return YES;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)textViewDidChange
{
    if([self.delegate respondsToSelector:@selector(textViewDidChange:)])
        return [self.delegate HTMLTextViewDidChange:self];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)textViewDidUpdateText:(NSString *)text
{
    if([self.delegate respondsToSelector:@selector(HTMLTextViewDidUpdateText:text:)])
        return [self.delegate HTMLTextViewDidUpdateText:self text:text];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
@end

//////////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation HTMLInputView

@synthesize autocapitalizationType;
@synthesize inputDelegate=inputDelegate,tokenizer = tokenizer,markedTextRange = markedTextRange,markedTextStyle = markedTextStyle;
@synthesize selectedTextRange = selectedTextRange,attribString = attribString;
@synthesize selectedRange; //editable
@synthesize correctionAttributes,correctionRange,menuItemActions,editable = editable;
//@synthesize boldText,italizeText,underlineText,strikeText,textAlignment,font,textColor;
@synthesize delegate;
//////////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor whiteColor];
        UITapGestureRecognizer* tap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(receivedTap:)] autorelease];
        tap.delegate = self;
        [self addGestureRecognizer:tap];
        UILongPressGestureRecognizer *gesture = [[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)] autorelease];
        [self addGestureRecognizer:gesture];
        
        tap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)] autorelease];
        tap.numberOfTapsRequired = 2;
        [self addGestureRecognizer:tap];
        
        self.editable = YES;
        attribString = [[NSMutableAttributedString alloc] init];
        caretView = [[UIView alloc] init];
        caretView.backgroundColor = [UIColor blueColor];
        [self blinkAnimation];
        [self addSubview:caretView];
        caretView.hidden = YES;
        selectedRange = NSMakeRange(0, 0);
        tokenizer = [[UITextInputStringTokenizer alloc] initWithTextInput:self];
        self.selectionColor = [UIColor colorWithRed:204/255.0f green:221/255.0f blue:237/255.0f alpha:1];
    }
    return self;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)canBecomeFirstResponder
{
    if(self.editable)
        if([self.delegate respondsToSelector:@selector(textViewShouldBeginEditing)])
            return [self.delegate textViewShouldBeginEditing];
    
	return self.editable;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)becomeFirstResponder
{
    if (editable)
    {
        if ([self.delegate respondsToSelector:@selector(textViewDidBeginEditing)])
            [self.delegate textViewDidBeginEditing];
        
    }
    caretView.hidden = NO;
    return [super becomeFirstResponder];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)canResignFirstResponder
{
    if (editable && [self.delegate respondsToSelector:@selector(textViewShouldEndEditing)])
        return [self.delegate textViewShouldEndEditing];
    return YES;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)resignFirstResponder
{
    
    if (editable)
    {
        if ([self.delegate respondsToSelector:@selector(textViewDidEndEditing)])
            [self.delegate textViewDidEndEditing];
    }
    caretView.hidden = YES;
	return [super resignFirstResponder];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setEditable:(BOOL)edit
{
    editable = edit;
    if([self isFirstResponder] && !editable)
        [self resignFirstResponder];
    caretView.hidden = !editable;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)addImage:(UIImage*)image
{
    NSMutableAttributedString* temp = [[[NSMutableAttributedString alloc] initWithString:@" "] autorelease];
    [temp setImageData:image];
    [self.attribString appendAttributedString:temp];
    [self.attribString appendAttributedString:[[[NSMutableAttributedString alloc] initWithString:@"\n"] autorelease]];
    [self setNeedsDisplay];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)addImageURL:(NSString*)imageURL
{
    NSMutableAttributedString* temp = [[[NSMutableAttributedString alloc] initWithString:@" "] autorelease];
    [temp setImageTag:imageURL attribs:[NSDictionary dictionaryWithObjectsAndKeys:@"150",@"height",@"200",@"width",@"0",@"padding", nil]];
    [self.attribString appendAttributedString:temp];
    [self.attribString appendAttributedString:[[[NSMutableAttributedString alloc] initWithString:@"\n"] autorelease]];
    [self setNeedsDisplay];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)addVideoURL:(NSString*)videoURL
{
    NSMutableAttributedString* temp = [[[NSMutableAttributedString alloc] initWithString:@" "] autorelease];
    [temp setYoutubeTag:videoURL attribs:[NSDictionary dictionaryWithObjectsAndKeys:@"250",@"height",@"300",@"width",@"0",@"padding", nil]];
    [self.attribString appendAttributedString:temp];
    [self.attribString appendAttributedString:[[[NSMutableAttributedString alloc] initWithString:@"\n"] autorelease]];
    [self setNeedsDisplay];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
-(NSString*)convertYoutubeURL:(NSString*)url
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
            //"i.ytimg.com/vi/%@/0.jpg"
            if(video_id)
            {
                 return [NSString stringWithFormat:@"http://i3.ytimg.com/vi/%@/mqdefault.jpg",video_id];
            }
        }
    }
    return nil;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)fetchYouTubeURL:(NSString*)url
{
    NSString* imgURL = [self convertYoutubeURL:url];
    [self fetchImage:imgURL];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)fetchImage:(NSString*)url
{
    __block GPHTTPRequest* request = [GPHTTPRequest requestWithString:url];
    [request setFinishBlock:^{
        if(!imageURLData)
            imageURLData = [[NSMutableDictionary alloc] init];
        [imageURLData setValue:[UIImage imageWithData:[request responseData]] forKey:request.URL.absoluteString];
        [self reloadStringForImage:request.URL.absoluteString];
    }];
    [request startAsync];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)reloadStringForImage:(NSString*)imgURL
{
    NSMutableAttributedString* string = self.attribString;
    NSRange validRange = NSMakeRange(0,[string length]);
    __block NSRange find;
    [string enumerateAttributesInRange:validRange options:0 usingBlock:
     ^(NSDictionary *attributes, NSRange range, BOOL *stop)
     {
         NSString* imageurl = [attributes objectForKey:IMAGE_LINK];
         if(!imageurl)
             imageurl = [attributes objectForKey:VIDEO_LINK];
         if([imageurl isEqualToString:imgURL])
             find = range;
     }];
    if(find.location != NSNotFound && find.location != NSNotFound && find.location < self.attribString.length)
    {
        NSString* url = imgURL;
        if([url rangeOfString:@"youtube.com"].location != NSNotFound)
            url = [self convertYoutubeURL:url];
        UIImage* image = [imageURLData objectForKey:url];
        if(image)
        {
            [string setImageData:image range:find];
            //[string removeAttribute:IMAGE_LINK range:find];
            if(!isDrawing)
                [self setNeedsDisplay];
        }
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
//handle text input
//////////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)hasText
{
    if(self.attribString.length > 0)
        return YES;
    return NO;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)insertText:(NSString *)text
{
    if([self.delegate respondsToSelector:@selector(textView:replacementText:)])
    {
        if(![self.delegate textView:self.selectedRange replacementText:text])
        {
            [self setNeedsDisplay];
            return;
        }
    }
    if([self isMenuShowing])
    {
        [self hideMenu];
        caretView.hidden = NO;
        [self updateCaretFrame];
    }
    if(self.selectedRange.length > 1)
        [self deleteBackward];
    ignoreSelectionMenu = NO;
    NSMutableAttributedString* tempString = [[NSMutableAttributedString alloc] initWithString:text];
    [tempString setFont:self.delegate.font];
    [tempString setTextColor:self.delegate.textColor];
    [tempString setTextBold:self.delegate.boldText];
    [tempString setTextItalic:self.delegate.italizeText];
    [tempString setTextStrikeOut:self.delegate.strikeText];
    [tempString setTextIsUnderlined:self.delegate.underlineText];
    [tempString setTextAlignment:self.delegate.textAlignment lineBreakMode:kCTLineBreakByWordWrapping];
    
    if(self.attribString.length > 2 && [text isEqualToString:@" "])
    {
        if([self.attribString.string characterAtIndex:selectedRange.location-1] == ' ' && [self.attribString.string characterAtIndex:selectedRange.location-2] != ' ' && [self.attribString.string characterAtIndex:selectedRange.location-2] != '.')
            [self.attribString replaceCharactersInRange:NSMakeRange(selectedRange.location-1, 1) withString:@"."];
            
    }
    if(selectedRange.location != NSNotFound && selectedRange.location < self.attribString.length)
         [self.attribString insertAttributedString:tempString atIndex:selectedRange.location];
    else
        [self.attribString appendAttributedString:tempString];
    [tempString release];
    if (text.length > 1 || ([text isEqualToString:@" "] || [text isEqualToString:@"\n"]))
        [self checkSpellingForRange:[self characterRangeAtIndex:self.selectedRange.location-1]];
    [self setNeedsDisplay];
    selectedRange.location += text.length;
    if([self.delegate respondsToSelector:@selector(textViewDidUpdateText:)])
        [self.delegate textViewDidUpdateText:text];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)deleteBackward
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showCorrectionMenuWithoutSelection) object:nil];
    if(self.attribString.length != 0)
	{
        BOOL update = NO;
		NSRange range = selectedRange;
        if(range.length == NSNotFound || range.length == 0)
            range.length = 1;
        if(range.location > self.attribString.length-1)
            range.location = self.attribString.length-1;
        else if(range.length > 1)
        {
            update = YES;
        }
        else if(range.location > 0 && range.location != self.attribString.length)
            range.location -= 1;
		[self.attribString deleteCharactersInRange:range];
        if(update)
        {
            selectedRange.length = 0;
            caretView.hidden = NO;
            [self updateCaretFrame];
            [self hideMenu];
        }
        else
            selectedRange.location -= range.length;
        ignoreSelectionMenu = NO;
        int index = selectedRange.location-1;
        if(index > 0 && index < self.attribString.length && [self.attribString.string characterAtIndex:index] != ' ')
            [self showCorrectionMenuForIndex:index];
        [self setNeedsDisplay];
	}
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
//handle touches
//////////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if(touch.view == self)
        return YES;
    return NO;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)receivedTap:(UITapGestureRecognizer*)recognizer
{
    if(![self isFirstResponder])
        [self becomeFirstResponder];
    else
    {
        [self hideMenu];
        caretView.hidden = NO;
        CGPoint pt = [recognizer locationInView:self];
        int index = [self closestIndexToPoint:pt];
        [self.inputDelegate selectionWillChange:self];
        selectedRange = NSMakeRange(index, 0);
        [self.inputDelegate selectionDidChange:self];
        [self updateCaretFrame];
        [self showCorrectionMenuForIndex:index];
        [self setNeedsDisplay];
    }
    return;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)doubleTap:(UITapGestureRecognizer*)recognizer
{
    if(![self isFirstResponder])
        [self becomeFirstResponder];
    else
    {
        caretView.hidden = YES;
        CGPoint pt = [recognizer locationInView:self];
        int index = [self closestIndexToPoint:pt];
        NSRange range = [self characterRangeAtIndex:index];
        [self.inputDelegate selectionWillChange:self];
        //NSLog(@"text at double tap: %@",[self.attribString.string substringWithRange:range]);
        if(range.location != NSNotFound)
            selectedRange = range;//NSMakeRange(index, 0);
        else
        {
            selectedRange = NSMakeRange(index, 0);
            caretView.hidden = NO;
        }
        [self.inputDelegate selectionDidChange:self];
        [self updateCaretFrame];
        [self setNeedsDisplay];
        [self showMenu];
    }
    return;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)longPress:(UILongPressGestureRecognizer*)recognizer
{
    //NSLog(@"long press!");
    if(!leftCaretView.hidden)
        return;
    [magnifyView removeFromSuperview];
    if(recognizer.state == UIGestureRecognizerStateBegan || recognizer.state == UIGestureRecognizerStateChanged)
    {
        [self hideMenu];
        CGPoint pt = [recognizer locationInView:self];
        int index = [self closestIndexToPoint:pt];
        selectedRange = NSMakeRange(index, 0);
        [self updateCaretFrame];
        if(!magnifyView)
            magnifyView = [[HTMLLoupeView alloc] init];
        CGRect frame = magnifyView.frame;
        frame.origin.x = pt.x - frame.size.width/2;
        frame.origin.y = pt.y - frame.size.height/2;
        magnifyView.frame = frame;
        UIImage *image = [self screenshotFromFrame:magnifyView.frame offset:0];
        [magnifyView setContentImage:image];
        [self addSubview:magnifyView];
    }
    else
        [self showMenu];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
-(UIImage*)screenshotFromFrame:(CGRect)frame offset:(int)offset
{
    UIGraphicsBeginImageContext(frame.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    //CGContextSetFillColorWithColor(context, [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f].CGColor);
    //UIRectFill(CGContextGetClipBoundingBox(context));
    CGContextSaveGState(ctx);
    CGContextConcatCTM(ctx, CGAffineTransformMakeTranslation(-(frame.origin.x), -(frame.origin.y+offset) ));
    [self.layer renderInContext:ctx];
    CGContextRestoreGState(ctx);
    UIImage* viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return viewImage;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
//drawing
//////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)drawRect:(CGRect)rect
{
    isDrawing = YES;
    [self stopBlink];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [self.backgroundColor set];
	CGContextFillRect(ctx, rect);
    CGContextSetTextMatrix(ctx, CGAffineTransformIdentity);
    CGContextTranslateCTM(ctx, 0, self.bounds.size.height);
    CGContextScaleCTM(ctx, 1.0, -1.0);

    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self.attribString);
    CGRect frame = self.bounds;
    CGSize size = CTFramesetterSuggestFrameSizeWithConstraints(framesetter,CFRangeMake(0,0),NULL,CGSizeMake(frame.size.width,CGFLOAT_MAX),NULL);
    CGFloat delta = MAX(0.f , ceilf(size.height - frame.size.height)) + 10;
    frame.origin.y -= delta;
    frame.size.height += delta;
    //self.frame = frame;
    [self.delegate updateSize:CGSizeMake(size.width, size.height+self.delegate.font.pointSize)]; //frame.size.height
    if(size.height > self.frame.size.height)
    {
        CGRect f = self.frame;
        f.size.height = size.height;
        self.frame = f;
    }
    //self.contentSize = CGSizeMake(size.width, frame.size.height);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, frame);
    if(textFrame != NULL)
        CFRelease(textFrame);
    textFrame = CTFramesetterCreateFrame(framesetter,CFRangeMake(0,0), path, NULL);
    CGPathRelease(path);
    CFRelease(framesetter);
    /*if(self.correctionRange.length > 0)
    {
        CGRect start = [self caretRectForIndex:correctionRange.location];
        CGRect end = [self caretRectForIndex:correctionRange.location+correctionRange.length];
        int width = end.origin.x-start.origin.x;
        int height = end.size.height + (end.origin.y - start.origin.y);
        int top = self.frame.size.height-(start.origin.y+height);
        CGContextSaveGState(ctx);
        //204 221 237
        CGContextSetFillColorWithColor(ctx,[UIColor colorWithRed:255/255.0f green:217/255.0f blue:217/255.0f alpha:1].CGColor);
        CGContextFillRect(ctx,CGRectMake(start.origin.x, top, width, height));
        CGContextRestoreGState(ctx);
    }*/
    if(selectedRange.length > 1)
        [self drawSelectionColor:ctx];
    else
    {
        leftCaretView.hidden = YES;
        rightCaretView.hidden = YES;
    }
    CTFrameDraw(textFrame, ctx);
    [self drawCustomElements:ctx];
    if(selectedRange.length <= 1)
    {
        [self updateCaretFrame];
        [self blinkAnimation];
    }
    isDrawing = NO;
    if([self.delegate respondsToSelector:@selector(textViewDidChange)])
        [self.delegate textViewDidChange];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)drawCustomElements:(CGContextRef)ctx
{
    CFArrayRef leftLines = CTFrameGetLines(textFrame); //textFrame
    CGPoint *origins = malloc(sizeof(CGPoint)*[(NSArray *)leftLines count]);
    CTFrameGetLineOrigins(textFrame,CFRangeMake(0, 0), origins);
    NSInteger lineIndex = 0;
    int orderCount = 1;
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
            NSString* imageurl = [attributes objectForKey:IMAGE_LINK];
            UIImage* imagedata = [attributes objectForKey:HTML_IMAGE_DATA];
            NSString* videourl = [attributes objectForKey:VIDEO_LINK];
            BOOL unOrder = [[attributes objectForKey:HTML_UNORDER_LIST] boolValue];
            BOOL order = [[attributes objectForKey:HTML_ORDER_LIST] boolValue];
            if(imageurl || videourl)
            {
                if(!imageURLArray)
                    imageURLArray = [[NSMutableArray alloc] init];
                if(imageurl && ![imageURLArray containsObject:imageurl])
                {
                    [imageURLArray addObject:imageurl];
                    [self fetchImage:imageurl];
                }
                else if(imageurl)
                    [self reloadStringForImage:imageurl];
                
                if(videourl && ![imageURLArray containsObject:videourl])
                {
                    [imageURLArray addObject:videourl];
                    [self fetchYouTubeURL:videourl];
                }
                else if(videourl)
                    [self reloadStringForImage:videourl];
                
            }
            if(unOrder)
            {
                //CGFloat y = roundf(runRect.origin.y + (runRect.size.height/2) );
                CGRect frame = runRect;
                frame.origin.x += 3;
                frame.size.height -= 4;
                frame.size.width = frame.size.height;
                frame.origin.y += 2;

                CGContextSaveGState(ctx);
                CGContextSetLineWidth(ctx, 1.0);
                CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
                CGContextAddEllipseInRect(ctx, frame);
                CGContextFillEllipseInRect(ctx, frame);
                CGContextRestoreGState(ctx);
            }
            if(order)
            {
                //CGFloat y = roundf(runRect.origin.y + (runRect.size.height/2) );
                CGRect frame = runRect;
                frame.origin.x += 3;
                frame.size.height -= 4;
                frame.size.width = frame.size.height;
                frame.origin.y += 2;
                NSString* text = [NSString stringWithFormat:@"%d.",orderCount];
                CGContextSaveGState(ctx);
                CGContextSelectFont (ctx,[self.delegate.font.fontName UTF8String],14,kCGEncodingMacRoman);
                CGContextSetCharacterSpacing (ctx, 1);
                CGContextSetTextDrawingMode (ctx, kCGTextFillStroke);
                CGContextSetGrayStrokeColor(ctx, 0, 1.0);
  
                CGContextShowTextAtPoint (ctx, frame.origin.x, frame.origin.y, [text UTF8String], text.length);
                //[text drawInRect:frame withFont:[UIFont boldSystemFontOfSize:self.delegate.font.pointSize] ];
                CGContextRestoreGState(ctx);
                orderCount++;
            }
            if(strikeOut)
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
            if(imagedata)
            {
                CGRect imgBounds = runRect;
                imgBounds.size.height = imagedata.size.height;
                imgBounds.size.width = imagedata.size.width;
                CGContextDrawImage(ctx, imgBounds, imagedata.CGImage);
            }
        }
        lineIndex++;
    }
    free(origins);
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)drawSelectionColor:(CGContextRef)ctx
{
    CGRect start = [self caretRectForIndex:selectedRange.location];
    CGRect end = [self caretRectForIndex:selectedRange.location+selectedRange.length];

    [self setSelectionCarets:start end:end];
    CFArrayRef leftLines = CTFrameGetLines(textFrame); //textFrame
    CGPoint *origins = malloc(sizeof(CGPoint)*[(NSArray *)leftLines count]);
    CTFrameGetLineOrigins(textFrame,CFRangeMake(0, 0), origins);
    NSInteger lineIndex = 0;
    for (id oneLine in (NSArray *)leftLines)
    {
        CTLineRef line = (CTLineRef)oneLine;
        CFRange lineRange = CTLineGetStringRange(line);
        NSInteger localIndex = 0;
        if(selectedRange.length > lineRange.length)
        {
            lineRange.length += selectedRange.location;
            localIndex = selectedRange.location;
        }
        else
            localIndex = selectedRange.location - lineRange.location;
        
        if (localIndex >= 0 && localIndex < lineRange.length)
        {
            NSInteger finalIndex = MIN(lineRange.location + lineRange.length, selectedRange.location + selectedRange.length);
            CGFloat xStart = CTLineGetOffsetForStringIndex(line, selectedRange.location, NULL);
            CGFloat xEnd = CTLineGetOffsetForStringIndex(line, finalIndex, NULL);
            CGPoint origin = origins[lineIndex];
            CGFloat ascent, descent;
            CTLineGetTypographicBounds(line, &ascent, &descent, NULL);
            CGRect frame = CGRectMake(origin.x + xStart, origin.y + self.frame.origin.y, xEnd - xStart, ascent + (descent*2));
            
            frame.origin.y -= descent;
            CGPathRef pathRef = CTFrameGetPath(textFrame);
            CGRect colRect = CGPathGetBoundingBox(pathRef);
            
            frame = CGRectOffset(frame, colRect.origin.x, colRect.origin.y - self.frame.origin.y);
            
            CGContextSaveGState(ctx);
            CGContextSetFillColorWithColor(ctx,self.selectionColor.CGColor);
            CGContextFillRect(ctx,frame);
            CGContextRestoreGState(ctx);
            
        }
        
        lineIndex++;
    }
    free(origins);
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
//caretView
//////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)blinkAnimation
{
    CAKeyframeAnimation *animation = nil;
    animation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    animation.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:1.0f], [NSNumber numberWithFloat:1.0f], [NSNumber numberWithFloat:0.0f], [NSNumber numberWithFloat:0.0f], nil];
    animation.calculationMode = kCAAnimationCubic;
    animation.duration = 1.0;
    animation.beginTime = CACurrentMediaTime() + 0.6;
    animation.repeatCount = CGFLOAT_MAX;
    [caretView.layer addAnimation:animation forKey:@"BlinkAnimation"];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)stopBlink
{
    [caretView.layer removeAnimationForKey:@"BlinkAnimation"];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
-(CGRect)caretRectForIndex:(int)index
{
    NSArray *lines = (NSArray*)CTFrameGetLines(textFrame);
    int count = lines.count;
    if(count > 0)
    {
        //int index = self.selectedRange.location;
        index = MAX(index, 0);
        index = MIN(self.attribString.string.length, index);
        CGRect returnRect = CGRectZero;
        
        CGPoint *origins = (CGPoint*)malloc(count * sizeof(CGPoint));
        CTFrameGetLineOrigins(textFrame, CFRangeMake(0, count), origins);
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
                CGFloat height = ascent + (descent*2);
                //if (selectedRange.length>0 && index != selectedRange.location && range.length == 1)
                //    xPos = textContentView.bounds.size.width - 3.0f; // selection of entire line
                
                if (index > 0 && [self.attribString.string characterAtIndex:index-1] == '\n' && range.length == 1)
                    xPos = 0.0f; // empty line
                CGRect runBounds;
                runBounds.size.width = 3;
                runBounds.size.height = height;
                
                runBounds.origin.x = 0;
                runBounds.origin.y = (origin.y + self.frame.origin.y) - self.frame.size.height;
                runBounds.origin.y = -runBounds.origin.y;
                runBounds.origin.y -= descent;
                
                if (index > 0 && index == self.attribString.length && [self.attribString.string characterAtIndex:(index - 1)] == '\n' )
                {
                    runBounds.origin.y += height;
                    CTLineRef line = (CTLineRef)[lines lastObject];
                    CFRange range = CTLineGetStringRange(line);
                    xPos = CTLineGetOffsetForStringIndex(line, range.location, NULL);
                }
                
                //runBounds.origin.y -= self.font.leading;
                if(height > runBounds.origin.y)
                    runBounds.origin.y -= (height-(self.delegate.font.pointSize+3));
                
                returnRect = CGRectMake(origin.x + xPos, runBounds.origin.y, 3, height);
            }
            
        }
        free(origins);
        return returnRect;
    }
    return CGRectMake(1, 0, 3, self.delegate.font.pointSize);
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)updateCaretFrame
{
    caretView.frame = [self caretRectForIndex:self.selectedRange.location];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setSelectionCarets:(CGRect)start end:(CGRect)end
{
    start.size.height += 10;
    start.origin.y -= 10;
    end.size.height += 10;
    int offset = 12;
    start.size.width += offset;
    end.size.width += offset;
    start.origin.x -= offset/2;
    end.origin.x -= offset/2;
    leftCaretView.hidden = NO;
    rightCaretView.hidden = NO;
    if(!leftCaretView)
    {
        leftCaretView = [[UIView alloc] initWithFrame:start];
        UIPanGestureRecognizer* pan = [[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(caretDrag:)] autorelease];
        [leftCaretView addGestureRecognizer:pan];
        UIImage *dotImage = [UIImage libraryImageNamed:@"drag-dot.png"];
        UIImageView *dotView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, dotImage.size.width, dotImage.size.height)];
        [dotView setImage:dotImage];
        UIView* contanier = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, dotImage.size.width, dotImage.size.height)] autorelease];
        [contanier addSubview:dotView];
        [contanier addGestureRecognizer:pan];
        
        UIView* line = [[[UIView alloc] initWithFrame:CGRectMake(6, contanier.frame.size.height-5, end.size.width-offset, contanier.frame.size.height)] autorelease];
        line.tag = 123;
        line.backgroundColor = [UIColor blueColor];
        [leftCaretView addSubview:line];
        
        [leftCaretView addSubview:contanier];
        
        [self addSubview:leftCaretView];
    }
    if(!rightCaretView)
    {
        rightCaretView = [[UIView alloc] initWithFrame:end];
        UIPanGestureRecognizer* pan = [[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(caretDrag:)] autorelease];
        [rightCaretView addGestureRecognizer:pan];
        
        UIImage *dotImage = [UIImage libraryImageNamed:@"drag-dot.png"];
        UIImageView *dotView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, dotImage.size.width, dotImage.size.height)];
        [dotView setImage:dotImage];
        UIView* contanier = [[[UIView alloc] initWithFrame:CGRectMake(0, end.size.height-10, dotImage.size.width, dotImage.size.height)] autorelease];
        contanier.tag = 234;
        UIView* line = [[[UIView alloc] initWithFrame:CGRectMake(6, 0, end.size.width-offset, contanier.frame.size.height)] autorelease];
        line.tag = 123;
        line.backgroundColor = [UIColor blueColor];
        [rightCaretView addSubview:line];
        
        [contanier addSubview:dotView];
        [contanier addGestureRecognizer:pan];
        [rightCaretView addSubview:contanier];
        [self addSubview:rightCaretView];
    }
    
    leftCaretView.frame = start;
    rightCaretView.frame = end;
    for(UIView* view in rightCaretView.subviews)
    {
        if(view.tag == 123)
        {
            CGRect frame = view.frame;
            frame.size.height = rightCaretView.frame.size.height-6;
            view.frame = frame;
        }
        if(view.tag == 234)
        {
            CGRect frame = view.frame;
            frame.origin.y = rightCaretView.frame.size.height-17;
            view.frame = frame;
        }
    }
    for(UIView* view in leftCaretView.subviews)
    {
        if(view.tag == 123)
        {
            CGRect frame = view.frame;
            frame.size.height = leftCaretView.frame.size.height-6;
            view.frame = frame;
        }
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)caretDrag:(UIPanGestureRecognizer*)sender
{
    [self hideMenu];
    [caretMagnifyView removeFromSuperview];
    if(sender.state == UIGestureRecognizerStateBegan || sender.state == UIGestureRecognizerStateChanged)
    {
        if(!caretMagnifyView)
            caretMagnifyView = [[HTMLMagnifyView alloc] init];
        
        CGRect frame = caretMagnifyView.frame;
        frame.origin.x = leftCaretView.center.x - frame.size.width/2;
        frame.origin.y = leftCaretView.center.y - (frame.size.height+10);
        caretMagnifyView.frame = frame;
        UIImage *image = [self screenshotFromFrame:caretMagnifyView.frame offset:(frame.origin.y+10)];
        [caretMagnifyView setContentImage:image];
        [self addSubview:caretMagnifyView];
        
        CGPoint pt = [sender locationInView:self];
        int index = [self closestIndexToPoint:pt];
        if(leftCaretView == [sender view] || leftCaretView == [[sender view] superview])
        {
            selectedRange.length += selectedRange.location - index;
            selectedRange.location = index;
        }
        else if(rightCaretView == [sender view] || rightCaretView == [[sender view] superview])
        {
            selectedRange.length = index - selectedRange.location;
        }
        [self setNeedsDisplay];
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
//text cacluation
//////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)closestIndexToPoint:(CGPoint)point
{
    //point = [self convertPoint:point toView:self];
    NSArray *lines = (NSArray*)CTFrameGetLines(textFrame);
    NSInteger count = [lines count];
    CGPoint *origins = (CGPoint*)malloc(count * sizeof(CGPoint));
    CTFrameGetLineOrigins(textFrame, CFRangeMake(0, count), origins);
    CFIndex index = kCFNotFound;
    
    if(count > 0)
    {
        for (int i = lines.count-1; 0 <= i; i--)
        {
            CGFloat yOrigin = (origins[i].y + self.frame.origin.y) - self.frame.size.height;
            yOrigin = -yOrigin;
            if (point.y > yOrigin)
            {
                CTLineRef line = (CTLineRef)[lines objectAtIndex:i];
                CGPoint convertedPoint = CGPointMake(point.x - origins[i].x, point.y - origins[i].y);
                index = CTLineGetStringIndexForPosition(line, convertedPoint);
                break;
            }
        }
    }
    
    if (index == kCFNotFound)
        index = [self.attribString length];
    
    free(origins);
    return index;
    
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSRange)characterRangeAtIndex:(NSInteger)index
{
    __block NSArray *lines = (NSArray*)CTFrameGetLines(textFrame);
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
                [self.attribString.string enumerateSubstringsInRange:range options:NSStringEnumerationByWords usingBlock:^(NSString *subString, NSRange subStringRange, NSRange enclosingRange, BOOL *stop){
                    
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
//////////////////////////////////////////////////////////////////////////////////////////////////////////
// UIMenu Actions
//////////////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    BOOL editing = YES;
    if (ignoreSelectionMenu)
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
//////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)menuDidHide:(NSNotification*)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerDidHideMenuNotification object:nil];
    
    //if (selectionView)
    [self showMenu];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)paste:(id)sender
{
    NSString *pasteText = [[UIPasteboard generalPasteboard] valueForPasteboardType:@"public.utf8-plain-text"];
    
    if (pasteText!=nil)
        [self insertText:pasteText];
    [self updateCaretFrame];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)selectAll:(id)sender
{
    NSString *string = [self.attribString string];
    NSString *trimmedString = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.selectedRange = [self.attribString.string rangeOfString:trimmedString];
    caretView.hidden = YES;
    [self setNeedsDisplay];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuDidHide:) name:UIMenuControllerDidHideMenuNotification object:nil];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)select:(id)sender
{
    int offset = 0;
    int index = [self closestIndexToPoint:caretView.center];
    NSRange range = [self characterRangeAtIndex:index];
    while(range.location == NSNotFound)
    {
        offset++;
        int back = index - offset;
        if(back < 0)
            break;
        range = [self characterRangeAtIndex:back];
        if(range.location != NSNotFound)
            break;
        else
        {
            int forward = index + offset;
            if(forward > self.attribString.length)
                break;
            range = [self characterRangeAtIndex:forward];
            if(range.location != NSNotFound)
                break;
        }
    }
        
    if(range.location != NSNotFound)
    {
        caretView.hidden = YES;
        self.selectedRange = range;
        [self setNeedsDisplay];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuDidHide:) name:UIMenuControllerDidHideMenuNotification object:nil];
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)cut:(id)sender
{
    NSString *string = [self.attribString.string substringWithRange:selectedRange];
    [[UIPasteboard generalPasteboard] setValue:string forPasteboardType:@"public.utf8-plain-text"];

    [self.attribString deleteCharactersInRange:selectedRange];
    
    [self.inputDelegate textWillChange:self];
    [self.inputDelegate textDidChange:self];
    
    self.selectedRange = NSMakeRange(selectedRange.location, 0);
    [self updateCaretFrame];
    [self setNeedsDisplay];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)copy:(id)sender
{
    NSString *string = [self.attribString.string substringWithRange:selectedRange];
    [[UIPasteboard generalPasteboard] setValue:string forPasteboardType:@"public.utf8-plain-text"];
    [self updateCaretFrame];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)delete:(id)sender
{
    [self.attribString deleteCharactersInRange:selectedRange];
    [self.inputDelegate textWillChange:self];
    [self.inputDelegate textDidChange:self];
    self.selectedRange = NSMakeRange(selectedRange.location, 0);
    [self setNeedsDisplay];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)replace:(id)sender
{    
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
- (CGRect)menuPresentationRect
{
    CGRect rect = [self convertRect:caretView.frame toView:self];
    return rect;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
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
//////////////////////////////////////////////////////////////////////////////////////////////////////////
-(BOOL)isMenuShowing
{
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    return [menuController isMenuVisible];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)hideMenu
{
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    [menuController setMenuVisible:NO animated:NO];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
//check spelling
//////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)checkSpellingForRange:(NSRange)range
{
    //still some work before this works correctly.
    NSInteger location = range.location-1;
    NSInteger currentOffset = MAX(0, location);
    NSRange currentRange;
    NSString *string = self.attribString.string;
    NSRange stringRange = NSMakeRange(0, string.length-1);
    NSArray *guesses;
    BOOL done = NO;
    
    NSString *language = [[UITextChecker availableLanguages] objectAtIndex:0];
    if (!language)
        language = @"en_US";
    
    if(!textChecker)
    {
        textChecker = [[UITextChecker alloc] init];
        correctionDict = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:(int)(kCTUnderlineStyleThick|kCTUnderlinePatternDot)], kCTUnderlineStyleAttributeName, (id)[UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:1.0f].CGColor, kCTUnderlineColorAttributeName, nil];
        
    }
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
            [self.attribString addAttributes:correctionDict range:currentRange];
        
        currentOffset = currentOffset + (currentRange.length-1);
    }
    
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
//spelling menu
//////////////////////////////////////////////////////////////////////////////////////////////////////////
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
        [self.attribString removeAttribute:(NSString*)kCTUnderlineStyleAttributeName range:replacementRange];
        [self setNeedsDisplay];
    }
    
    self.correctionRange = NSMakeRange(NSNotFound, 0);
    self.menuItemActions = nil;
    [sender setMenuItems:nil];
    
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)spellCheckMenuEmpty:(id)sender
{
    self.correctionRange = NSMakeRange(NSNotFound, 0);
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)showCorrectionMenuForIndex:(int)index
{
    self.correctionRange = NSMakeRange(NSNotFound, 0);
    //self.selectedRange.location == NSNotFound self.selectedRange.location > self.attribString.length||
    if(index > self.attribString.length || self.attribString.length == 0)
        return;
    if(index == self.attribString.length)
        index--;
    NSDictionary* attribs = [self.attribString attributesAtIndex:index effectiveRange:NULL];
    BOOL needs = YES;
    for(id key in correctionDict)
        if(![attribs objectForKey:key])
            needs = NO;
    if(needs)
        [self performSelector:@selector(showCorrectionMenuWithoutSelection) withObject:nil afterDelay:0.35];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showCorrectionMenuWithoutSelection
{
    BOOL editing = YES;
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
            if(range.location != NSNotFound && self.attribString.string > 0 && range.length < self.attribString.string.length)
                self.correctionRange = [textChecker rangeOfMisspelledWordInString:self.attribString.string range:range startingAt:0 wrap:YES language:language];
            
        }
        [self showCorrectionMenuForRange:range];
    }
    else
        [self showMenu];
    
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showCorrectionMenuForRange:(NSRange)range
{
    if (range.location==NSNotFound || range.length==0) return;
    
    range.location = MAX(0, range.location);
    range.length = MIN(self.attribString.string.length, range.length);
    
    [self.attribString removeAttribute:(NSString*)kCTUnderlineStyleAttributeName range:range];
    
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    
    if ([menuController isMenuVisible]) return;
    ignoreSelectionMenu = YES;
    
    NSString *language = [[UITextChecker availableLanguages] objectAtIndex:0];
    if (!language)
        language = @"en_US";
    
    NSArray *guesses = [textChecker guessesForWordRange:range inString:self.attribString.string language:language];
    
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
//////////////////////////////////////////////////////////////////////////////////////////////////////////
//mostly unused text input functions and don't need to be changed
//////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////
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
//////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)textInRange:(UITextRange *)range
{
    if(!self.attribString || self.attribString.string.length == 0)
        return nil;
    HTMLIndexedRange *r = (HTMLIndexedRange *)range;
    return ([self.attribString.string substringWithRange:r.range]);
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)replaceRange:(UITextRange *)range withText:(NSString *)text
{
    HTMLIndexedRange *r = (HTMLIndexedRange *)range;
    
    NSRange selectRange = self.selectedRange;
    if ((r.range.location + r.range.length) <= selectRange.location)
        selectRange.location -= (r.range.length - text.length);
    else
        selectRange = [self rangeIntersection:r.range withSecond:selectedRange];
    
    [self.attribString replaceCharactersInRange:r.range withString:text];
    self.selectedRange = selectRange;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
- (UITextRange *)selectedTextRange
{
    return [HTMLIndexedRange rangeWithNSRange:self.selectedRange];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setSelectedTextRange:(UITextRange *)range
{
    HTMLIndexedRange *r = (HTMLIndexedRange *)range;
    self.selectedRange = r.range;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setMarkedText:(NSString *)markedText selectedRange:(NSRange)selectedRange
{
    //NSLog(@"marked text: %@",markedText);
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)unmarkText
{
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////
- (UITextRange *)textRangeFromPosition:(UITextPosition *)fromPosition toPosition:(UITextPosition *)toPosition
{
    HTMLIndexedPosition *from = (HTMLIndexedPosition *)fromPosition;
    HTMLIndexedPosition *to = (HTMLIndexedPosition *)toPosition;
    NSRange range = NSMakeRange(MIN(from.index, to.index), ABS(to.index - from.index));
    return [HTMLIndexedRange rangeWithNSRange:range];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
- (UITextPosition *)positionFromPosition:(UITextPosition *)position offset:(NSInteger)offset
{
    HTMLIndexedPosition *pos = (HTMLIndexedPosition *)position;
    NSInteger end = pos.index + offset;
	
    if (end > self.attribString.length || end < 0)
        return nil;
    
    return [HTMLIndexedPosition positionWithIndex:end];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
- (UITextPosition *)positionFromPosition:(UITextPosition *)position inDirection:(UITextLayoutDirection)direction offset:(NSInteger)offset
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
    
    if (newPos > self.attribString.length)
        newPos = self.attribString.length;
    
    return [HTMLIndexedPosition positionWithIndex:newPos];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
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
//////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)offsetFromPosition:(UITextPosition *)from toPosition:(UITextPosition *)toPosition
{
    HTMLIndexedPosition *f = (HTMLIndexedPosition *)from;
    HTMLIndexedPosition *t = (HTMLIndexedPosition *)toPosition;
    return (t.index - f.index);
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
- (UITextPosition *)positionWithinRange:(UITextRange *)range farthestInDirection:(UITextLayoutDirection)direction
{
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
//////////////////////////////////////////////////////////////////////////////////////////////////////////
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
//////////////////////////////////////////////////////////////////////////////////////////////////////////
- (UITextWritingDirection)baseWritingDirectionForPosition:(UITextPosition *)position inDirection:(UITextStorageDirection)direction
{
    return UITextWritingDirectionLeftToRight;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setBaseWritingDirection:(UITextWritingDirection)writingDirection forRange:(UITextRange *)range
{
    //not supported currently
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
- (UITextPosition*)beginningOfDocument {
    return [HTMLIndexedPosition positionWithIndex:0];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
- (UITextPosition*)endOfDocument {
    return [HTMLIndexedPosition positionWithIndex:self.attribString.length];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////
/* Geometry used to provide, for example, a correction rect. */
//////////////////////////////////////////////////////////////////////////////////////////////////////////
- (CGRect)firstRectForRange:(UITextRange *)range
{
    HTMLIndexedRange *r = (HTMLIndexedRange *)range;
    return [self firstRectForNSRange:r.range];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
- (CGRect)caretRectForPosition:(UITextPosition *)position
{
    HTMLIndexedPosition *pos = (HTMLIndexedPosition *)position;
	return [self caretRectForIndex:pos.index];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
- (CGRect)firstRectForNSRange:(NSRange)range
{
    NSInteger index = range.location;
    
    NSArray *lines = (NSArray *) CTFrameGetLines(textFrame);
    NSInteger count = [lines count];
    CGPoint *origins = (CGPoint*)malloc(count * sizeof(CGPoint));
    CTFrameGetLineOrigins(textFrame, CFRangeMake(0, count), origins);
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
            
            returnRect = [self convertRect:CGRectMake(origin.x + xStart, origin.y - descent, xEnd - xStart, ascent + (descent*2)) toView:self];
            break;
        }
    }
    
    free(origins);
    return returnRect;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
- (id <UITextInputTokenizer>)tokenizer {
    return tokenizer;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
/* Hit testing. */
//////////////////////////////////////////////////////////////////////////////////////////////////////////
- (UITextPosition*)closestPositionToPoint:(CGPoint)point
{
    HTMLIndexedPosition *position = [HTMLIndexedPosition positionWithIndex:[self closestIndexToPoint:point]];
    return position;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
- (UITextPosition*)closestPositionToPoint:(CGPoint)point withinRange:(UITextRange *)range
{
    HTMLIndexedPosition *position = [HTMLIndexedPosition positionWithIndex:[self closestIndexToPoint:point]];
    return position;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
- (UITextRange*)characterRangeAtPoint:(CGPoint)point
{
    int index = [self closestIndexToPoint:caretView.center];
    NSRange r = [self characterRangeAtIndex:index];
    HTMLIndexedRange *range = [HTMLIndexedRange rangeWithNSRange:r];
    return range;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSDictionary*)textStylingAtPosition:(UITextPosition *)position inDirection:(UITextStorageDirection)direction
{
    HTMLIndexedPosition *pos = (HTMLIndexedPosition*)position;
    NSInteger index = MAX(pos.index, 0);
    index = MIN(index, self.attribString.length-1);
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:1];
    if(self.attribString.length > 0)
    {
        NSDictionary *attribs = [self.attribString attributesAtIndex:index effectiveRange:nil];
        
        CTFontRef ctFont = (CTFontRef)[attribs valueForKey:(NSString*)kCTFontAttributeName];
        UIFont *afont = [UIFont fontWithName:(NSString*)CTFontCopyFamilyName(ctFont) size:CTFontGetSize(ctFont)];
        if(!afont)
            [dictionary setObject:self.delegate.font forKey:UITextInputTextFontKey];
        else
        {
            [dictionary setObject:afont forKey:UITextInputTextFontKey];
            //[afont release];
        }
    }
    else
        [dictionary setObject:self.delegate.font forKey:UITextInputTextFontKey];
    
    //NSLog(@"dictonary: %@",dictionary);
    return dictionary;
    
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
- (UIView *)textInputView
{
    return self;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
- (UITextAutocorrectionType)autocorrectionType {
    return UITextAutocorrectionTypeDefault;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSArray *)selectionRectsForRange:(UITextRange *)range
{
    return nil;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)dealloc
{
    [attribString release];
    [caretView release];
    [magnifyView release];
    [caretMagnifyView release];
    [leftCaretView release];
    [rightCaretView release];
    [correctionDict release];
    [textChecker release];
    [tokenizer release];
    [imageURLData release];
    [super dealloc];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////

@end


//////////////////////////////////////////////////////////////////////////////////////////////////////////
//supporting views
//////////////////////////////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////
//HTMLLoupeView
//////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation HTMLLoupeView

//////////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init
{
    if ((self = [super initWithFrame:CGRectMake(0.0f, 0.0f, 127.0f, 127.0f)]))
        self.backgroundColor = [UIColor clearColor];
    return self;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
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
//////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setContentImage:(UIImage *)image
{
    [contentImage release], contentImage=nil;
    contentImage = [image retain];
    [self setNeedsDisplay];
    
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
    [contentImage release], contentImage=nil;
    [super dealloc];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////

@end

//////////////////////////////////////////////////////////////////////////////////////////////////////////
//HTMLMagnifyView
//////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation HTMLMagnifyView

//////////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init
{
    if ((self = [super initWithFrame:CGRectMake(0.0f, 0.0f, 145.0f, 59.0f)]))
        self.backgroundColor = [UIColor clearColor];
    return self;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
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
//////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setContentImage:(UIImage *)image
{
    [contentImage release], contentImage=nil;
    contentImage = [image retain];
    [self setNeedsDisplay];
    
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
    [contentImage release], contentImage=nil;
    [super dealloc];
}

@end
//////////////////////////////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////////////////////////////////
//HTMLIndexedPosition
//////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation HTMLIndexedPosition
@synthesize index=_index;

//////////////////////////////////////////////////////////////////////////////////////////////////////////
+ (HTMLIndexedPosition *)positionWithIndex:(NSUInteger)index
{
    HTMLIndexedPosition *pos = [[HTMLIndexedPosition alloc] init];
    pos.index = index;
    return [pos autorelease];
}

@end
//////////////////////////////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////////////////////////////////
//HTMLIndexedRange
//////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation HTMLIndexedRange
@synthesize range=range;

//////////////////////////////////////////////////////////////////////////////////////////////////////////
+ (HTMLIndexedRange *)rangeWithNSRange:(NSRange)theRange
{
    if (theRange.location == NSNotFound)
        return nil;
    HTMLIndexedRange *range = [[HTMLIndexedRange alloc] init];
    range.range = theRange;
    return [range autorelease];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
- (UITextPosition *)start {
    return [HTMLIndexedPosition positionWithIndex:self.range.location];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
- (UITextPosition *)end {
	return [HTMLIndexedPosition positionWithIndex:(self.range.location + self.range.length)];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
-(BOOL)isEmpty {
    return (self.range.length == 0);
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////

@end


