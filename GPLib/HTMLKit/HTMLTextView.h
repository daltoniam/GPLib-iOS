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

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import <UIKit/UITextChecker.h>

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
@interface HTMLIndexedRange : UITextRange {
    NSRange range;
}

@property (nonatomic) NSRange range;
+ (HTMLIndexedRange *)rangeWithNSRange:(NSRange)range;
@end
///////////////////////////////////////////////////////////////////////
@interface HTMLIndexedPosition : UITextPosition {
    NSUInteger               index;
    id <UITextInputDelegate> inputDelegate;
}

@property (nonatomic) NSUInteger index;
+ (HTMLIndexedPosition *)positionWithIndex:(NSUInteger)index;

@end
///////////////////////////////////////////////////////////////////////

@protocol HTMLInputViewDelegate <NSObject>

-(void)updateSize:(CGSize)size;

@property(nonatomic,retain) UIFont* font;
@property(nonatomic,retain) UIColor* textColor;
@property(nonatomic,assign) BOOL strikeText;
@property(nonatomic,assign) BOOL boldText;
@property(nonatomic,assign) BOOL italizeText;
@property(nonatomic,assign) BOOL underlineText;
@property(nonatomic,assign) CTTextAlignment textAlignment;
@property(nonatomic) UITextAutocorrectionType autocorrectionType;
@property(nonatomic) UIKeyboardType keyboardType;
@property(nonatomic) UIKeyboardAppearance keyboardAppearance;
@property(nonatomic) UIReturnKeyType returnKeyType;
@property(nonatomic) BOOL enablesReturnKeyAutomatically;
@property(nonatomic,assign) BOOL editable;
@property(nonatomic,assign) NSRange selectedRange;

-(void)addImage:(UIImage*)image;
-(void)addImageURL:(NSString*)imageURL;
-(void)addVideoURL:(NSString*)videoURL;

- (BOOL)textViewShouldBeginEditing;
- (BOOL)textViewShouldEndEditing;

- (void)textViewDidBeginEditing;
- (void)textViewDidEndEditing;

- (BOOL)textView:(NSRange)range replacementText:(NSString *)text;
- (void)textViewDidChange;
- (void)textViewDidUpdateText:(NSString*)text;

@end

@interface HTMLInputView : UIView<UITextInput,UITextInputTraits,UIGestureRecognizerDelegate> //UITextInputTraits
{
    id <UITextInputDelegate> inputDelegate;
    UITextInputStringTokenizer *tokenizer;
    UITextRange *markedTextRange;
    NSDictionary *markedTextStyle;
    UITextRange *selectedTextRange;
    NSMutableAttributedString* attribString;
    UIView* caretView;
    CTFrameRef textFrame;
    HTMLLoupeView* magnifyView;
    HTMLMagnifyView* caretMagnifyView;
    UITextChecker* textChecker;
    NSDictionary* correctionDict;
    UIView* leftCaretView;
    UIView* rightCaretView;
    BOOL ignoreSelectionMenu;
    NSMutableArray* imageURLArray;
    NSMutableDictionary* imageURLData;
    BOOL isDrawing;
}

@property(nonatomic,assign) id<HTMLInputViewDelegate>delegate;
@property(nonatomic,retain) NSMutableAttributedString* attribString;
@property(nonatomic) UITextAutocapitalizationType autocapitalizationType;

@property(nonatomic,assign) BOOL editable;
@property(nonatomic) NSRange selectedRange;

@property(nonatomic,retain) NSDictionary *correctionAttributes;
@property(nonatomic,retain) NSMutableDictionary *menuItemActions;
@property(nonatomic) NSRange correctionRange;

@property(nonatomic,retain)UIColor* selectionColor;

-(void)addImage:(UIImage*)image;
-(void)addImageURL:(NSString*)imageURL;
-(void)addVideoURL:(NSString*)videoURL;

@end

///////////////////////////////////////////////////////////////////////
@class HTMLTextView;

@protocol HTMLTextViewDelegate <UIScrollViewDelegate>

@optional

- (BOOL)HTMLTextViewShouldBeginEditing:(HTMLTextView *)textView;
- (BOOL)HTMLTextViewShouldEndEditing:(HTMLTextView *)textView;

- (void)HTMLTextViewDidBeginEditing:(HTMLTextView *)textView;
- (void)HTMLTextViewDidEndEditing:(HTMLTextView *)textView;

- (BOOL)HTMLTextView:(HTMLTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
- (void)HTMLTextViewDidChange:(HTMLTextView *)textView;
- (void)HTMLTextViewDidUpdateText:(HTMLTextView *)textView text:(NSString*)text;

@end

@interface HTMLTextView : UIScrollView<HTMLInputViewDelegate>{
    HTMLInputView* inputView;
}

@property(nonatomic,retain) NSMutableAttributedString* attribString;
@property(nonatomic,assign) id<HTMLTextViewDelegate>delegate;

-(void)reload;
///////////////////////////////////////////////////////////////////////
@end




