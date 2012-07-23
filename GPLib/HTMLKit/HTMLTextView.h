//
//  HTMLTextView.h
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

#import <CoreText/CoreText.h>
#import <UIKit/UITextChecker.h>
#import "GPHTTPRequest.h"

typedef enum {
    HTMLWindowLoupe = 0,
    HTMLWindowMagnify,
} HTMLWindowType;

typedef enum {
    HTMLSelectionTypeLeft = 0,
    HTMLSelectionTypeRight,
} HTMLSelectionType;
///////////////////////////////////////////////////////////////////////
@class HTMLTextView;
@interface HTMLContentView : UIView
{
@private
    HTMLTextView* delegate;
}
@property(nonatomic,assign) HTMLTextView* delegate;
@end
///////////////////////////////////////////////////////////////////////
@interface HTMLCaretView : UIView 
{
    NSTimer *blinkTimer;
}

- (void)delayBlink;
- (void)show;
@end
///////////////////////////////////////////////////////////////////////
@interface HTMLLoupeView : UIView {
@private
    UIImage *contentImage;
}
- (void)setContentImage:(UIImage*)image;
@end
///////////////////////////////////////////////////////////////////////

@interface HTMLMagnifyView : UIView {
@private
    UIImage *contentImage;
}
- (void)setContentImage:(UIImage*)image;
@end
///////////////////////////////////////////////////////////////////////
@interface HTMLTextWindow : UIWindow 
{
@private
    UIView *_view;
    HTMLWindowType type;
    HTMLSelectionType selectionType;
    BOOL showing;
    
}
@property(nonatomic,assign) HTMLWindowType type;
@property(nonatomic,assign) HTMLSelectionType selectionType;
@property(nonatomic,readonly,getter=isShowing) BOOL showing;
- (void)setType:(HTMLWindowType)type;
- (void)renderWithContentView:(UIView*)view fromRect:(CGRect)rect;
- (void)showFromView:(UIView*)view rect:(CGRect)rect;
- (void)hide:(BOOL)animated;
- (void)updateWindowTransform;
@end
///////////////////////////////////////////////////////////////////////
@interface HTMLSelectionView : UIView {
@private
    UIView *leftDot;
    UIView *rightDot;
    UIView *leftCaret;
    UIView *rightCaret;
}
- (void)setBeginCaret:(CGRect)begin endCaret:(CGRect)rect;
@end
///////////////////////////////////////////////////////////////////////
@interface HTMLIndexedPosition : UITextPosition {
    NSUInteger               _index;
    id <UITextInputDelegate> _inputDelegate;
}

@property (nonatomic) NSUInteger index;
+ (HTMLIndexedPosition *)positionWithIndex:(NSUInteger)index;

@end

///////////////////////////////////////////////////////////////////////
@interface HTMLIndexedRange : UITextRange {
    NSRange _range;
}

@property (nonatomic) NSRange range;
+ (HTMLIndexedRange *)rangeWithNSRange:(NSRange)range;
@end
///////////////////////////////////////////////////////////////////////
@class HTMLTextView;
@protocol HTMLTextViewDelegate <NSObject, UIScrollViewDelegate>
@optional

- (BOOL)HTMLTextViewShouldBeginEditing:(HTMLTextView *)textView;
- (BOOL)HTMLTextViewShouldEndEditing:(HTMLTextView *)textView;

- (void)HTMLTextViewDidBeginEditing:(HTMLTextView *)textView;
- (void)HTMLTextViewDidEndEditing:(HTMLTextView *)textView;

- (void)HTMLTextViewDidChange:(HTMLTextView *)textView string:(NSString*)string;
- (void)HTMLTextViewWillChange:(HTMLTextView *)textView string:(NSString*)string;

- (void)HTMLTextViewDidChangeSelection:(HTMLTextView *)textView;

@end
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@interface HTMLTextView : UIScrollView <UITextInputTraits,UITextInput,GPHTTPRequestDelegate>
{
    NSDictionary *markedTextStyle;
    id <UITextInputDelegate> inputDelegate;
    UITextInputStringTokenizer *tokenizer;
    UITextChecker* textChecker;
    UILongPressGestureRecognizer *longPress;
    NSMutableAttributedString  *attributedString;
    BOOL editing;
    BOOL editable; 
    BOOL spellCheck;
    BOOL ignoreSelectionMenu;
    
    NSRange markedRange; 
    NSRange selectedRange;
    NSRange correctionRange;
    NSRange linkRange;
    
    CTFramesetterRef    framesetter;
    CTFrameRef          frame;
    id <HTMLTextViewDelegate> delegate;
    HTMLContentView* textContentView;
    HTMLTextWindow* textWindow;
    HTMLCaretView* caretView;
    HTMLSelectionView* selectionView;
    NSMutableArray* imageArray;
    NSMutableArray* videoArray;
    NSMutableArray* textArray;
    NSDictionary* stringAttributes;
    NSInteger textCount;
}
- (void)textChanged;
-(void)appendString:(NSMutableAttributedString*)string;
-(void)drawCustomElements:(CTLineRef)oneLine ctx:(CGContextRef)ctx index:(int)lineIndex points:(CGPoint*)origins mainRect:(CGRect)mainRect;
@property(nonatomic) UITextAutocapitalizationType autocapitalizationType;
@property(nonatomic) UITextAutocorrectionType autocorrectionType;        
@property(nonatomic) UIKeyboardType keyboardType;                       
@property(nonatomic) UIKeyboardAppearance keyboardAppearance;             
@property(nonatomic) UIReturnKeyType returnKeyType;                    
@property(nonatomic) BOOL enablesReturnKeyAutomatically; 
@property(nonatomic,copy) NSMutableAttributedString *attributedString;
@property(nonatomic,retain)NSDictionary* stringAttributes;
@property(nonatomic,assign) id <HTMLTextViewDelegate> delegate;
@property(nonatomic,assign) BOOL editable;
@property(nonatomic) NSRange selectedRange;
@property(nonatomic) NSRange markedRange;
@property(nonatomic,retain) UIFont *font;
@property(nonatomic,retain,readonly) NSMutableArray* videoArray;
@property(nonatomic,retain,readonly) NSMutableArray* imageArray;
@property(nonatomic,retain,readonly) NSMutableArray* textArray;
@end

///////////////////////////////////////////////////////////////////////
@interface HTMLTextView (Private)

- (CGRect)caretRectForIndex:(int)index;
- (CGRect)firstRectForNSRange:(NSRange)range;
- (NSInteger)closestIndexToPoint:(CGPoint)point;
- (NSRange)characterRangeAtPoint_:(CGPoint)point;
- (void)checkSpellingForRange:(NSRange)range;
- (void)removeCorrectionAttributesForRange:(NSRange)range;
- (void)insertCorrectionAttributesForRange:(NSRange)range;
- (void)showCorrectionMenuForRange:(NSRange)range;
- (void)checkLinksForRange:(NSRange)range;
- (void)scanAttachments;
- (void)showMenu;
- (CGRect)menuPresentationRect;

+ (UIColor *)selectionColor;
+ (UIColor *)spellingSelectionColor;
+ (UIColor *)caretColor;

@end
///////////////////////////////////////////////////////////////////////
@interface HTMLTextView ()
@property(nonatomic,retain) NSDictionary *defaultAttributes;
@property(nonatomic,retain) NSDictionary *correctionAttributes;
@property(nonatomic,retain) NSMutableDictionary *menuItemActions;
@property(nonatomic) NSRange correctionRange;
@end
///////////////////////////////////////////////////////////////////////
@interface TextItem : NSObject
{
    NSString* text;
    CGRect frame;
    NSInteger tag;
}
+(TextItem*)textItem:(NSString*)text frame:(CGRect)rect tag:(NSInteger)t;
@property(nonatomic, copy) NSString* text;
@property(nonatomic,assign)CGRect frame;
@property(nonatomic,assign)NSInteger tag;
@end


