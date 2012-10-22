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
    BOOL didLayoutButtons;
}
@property(nonatomic,assign)id<GPPostDelegate> delegate;
@property(nonatomic,assign)NSInteger textLimit; //default is 0 (no limit)

//override this to return an array of barButtonItems. (you will probably want to add flexable space in between each of them)
-(NSArray*)barButtonItems;

//dismiss the keyboard.
-(void)dismissKeyboard;

//add this to your in as one of your buttons in the barButtonItems method above to you want to show
//a text counter of how much text you have left. If textLimit is 0, it will just count up
-(GPLabel*)textCounter;

//the post action called by the right bar button item.
-(void)post;

//the cancel action called by the left bar button item.
-(void)cancel;

//checks if the post is ready to be posted. Meaning you have filled out text, add attachments,etc.
-(void)checkPostStatus;

//use to figure out if iPhone 5 or iPhone 4 and how far to go down.
-(void)resizeKeyboard:(CGRect)keyboardFrame;

@end
