//
//  PostingViewController.h
//  TestApp
//
//  Created by Dalton Cherry on 10/5/12.
//  Copyright (c) 2012 Basement Krew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPLabel.h"

@protocol GPPostDelegate <NSObject>

@optional

//notify that the post button has been clicked
- (void)textDidPost:(NSString*)htmltext;
- (void)didCancel;

@end

@interface GPPostingViewController : UIViewController<UITextViewDelegate>
{
    UITextView* textView;
    UIView* buttonView;
    GPLabel* limitLabel;
    UIView* containerView;
    UIScrollView* contentView;
}
@property(nonatomic,assign)id<GPPostDelegate> delegate;
@property(nonatomic,assign)NSInteger textLimit; //default is 0 (no limit)

-(NSArray*)barButtonItems;
-(void)dismissKeyboard;
-(GPLabel*)textCounter;
-(void)post;
-(void)cancel;

-(void)checkPostStatus;
-(void)resizeKeyboard:(CGRect)keyboardFrame;

@end
