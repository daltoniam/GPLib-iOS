//
//  GPReceiptField.h
//  GPLib
//
//  Created by Dalton Cherry on 1/27/12.
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

#import <UIKit/UIKit.h>
#import "GPPillLabel.h"


@protocol GPReceiptFieldDelegate <NSObject>

@optional

//this notifies the delegate that text is being typed. It is up to the delegate to call, [instance addItem:text];
//to add a bubble to the view. this allows any custom text need. This basically just forwards UItextField should change delegate
- (void)didChange:(UITextField *)textField CharactersInRange:(NSRange)range replacementString:(NSString *)string;
- (void)heightDidChange:(int)height;
- (void)showPicker;
- (void)textFieldWillDismiss:(UITextField*)textField;
@end

@interface GPReceiptField : UIView<UITextFieldDelegate>
{
    UILabel* TextLabel;
    UITextField* TextField;
    NSMutableArray* Bubbles;
    UIScrollView* ScrollView;
    GPPillLabel *SelectedCell;
    id<GPReceiptFieldDelegate> delegate;
    int numberOfLines;
    int lineCount;
    int OGHeight;
    int pickerOffset;
    BOOL shouldShowPicker;
    UIButton* contactButton;
}
@property(nonatomic,assign)id<GPReceiptFieldDelegate> delegate;
@property(nonatomic,assign)int numberOfLines;
@property(nonatomic,assign)BOOL shouldShowPicker;
@property(nonatomic,retain)NSMutableArray* Bubbles;

-(void)addItem:(NSString*)text;
-(void)removeItem;
-(CGSize)GetLabelFrame:(UILabel*)label;
-(void)layoutBubbleViews:(int*)left top:(int*)top;
-(UIColor*)bubbleColor:(UIControlState)state;
-(UIColor*)textLabelColor:(UIControlState)state;
-(void)setBubbleState:(UIControlState)state view:(GPPillLabel*)view;

@end
