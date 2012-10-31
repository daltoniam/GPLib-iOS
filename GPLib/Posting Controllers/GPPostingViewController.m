//
//  PostingViewController.m
//  TestApp
//
//  Created by Dalton Cherry on 10/5/12.
//  Copyright (c) 2012 Basement Krew. All rights reserved.
//

#import "GPPostingViewController.h"
#import "GPTransparentToolbar.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+Additions.h"

@interface GPPostingViewController ()

@end

@implementation GPPostingViewController

@synthesize delegate,textLimit;
///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.rightBarButtonItem =[[[UIBarButtonItem alloc] initWithTitle: NSLocalizedString(@"Post", nil)
                                                                                  style: UIBarButtonItemStyleBordered
                                                                                 target: self
                                                                                 action:@selector(post)] autorelease];
        self.navigationItem.leftBarButtonItem =[[[UIBarButtonItem alloc] initWithTitle: NSLocalizedString(@"Cancel", nil)
                                                                                 style: UIBarButtonItemStyleBordered
                                                                                target: self
                                                                                action:@selector(cancel)] autorelease];
    }
    return self;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Post", nil);
    int top = 0;
    int height = 250;
    if(GPIsPad())
    {
        CGRect frame = self.view.frame;
        frame.size.height = 300;
        frame.size.width = 540;
        self.view.frame = frame;
        self.view.backgroundColor = [UIColor clearColor];
    }
    textView = [[UITextView alloc] initWithFrame:CGRectMake(0, top, self.view.frame.size.width, height)];
    textView.delegate = self;
    //textView.returnKeyType = UIReturnKeyDone;
    textView.contentInset = UIEdgeInsetsMake(2, 5, 5, 5);
    [textView becomeFirstResponder];
    textView.contentSize = CGSizeMake(textView.frame.size.height,textView.contentSize.height);
    textView.showsHorizontalScrollIndicator = NO;
    textView.bounces = NO;
    textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    top += textView.frame.size.height;    
    buttonView = [[UIView alloc] initWithFrame:CGRectMake(0, top, self.view.frame.size.width, 35)];
    top += buttonView.frame.size.height;
    buttonView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    buttonView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    UIView* topLine = [[[UIView alloc] initWithFrame:CGRectMake(0, buttonView.frame.size.height-0.5, buttonView.frame.size.width, 1)] autorelease];
    topLine.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    topLine.backgroundColor = [UIColor lightGrayColor];
    [buttonView addSubview:topLine];

    [self.view addSubview:buttonView];
    
    containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, height)];
    containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:containerView];
    [containerView addSubview:textView];
    
    contentView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, top, self.view.frame.size.width, self.view.frame.size.height-top)];
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    contentView.backgroundColor = buttonView.backgroundColor;
    contentView.pagingEnabled = YES;
    contentView.showsHorizontalScrollIndicator = NO;
    contentView.showsVerticalScrollIndicator = NO;
    
    if(!GPIsPad())
    {
        [self.view addSubview:contentView];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification //UIKeyboardDidShowNotification
                                                   object:nil];
    }
    else
        [self layoutButtons];
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)moveTextViewForKeyboard:(NSNotification*)aNotification up:(BOOL)up
{
    NSDictionary* userInfo = [aNotification userInfo];
    
    CGRect keyboardEndFrame;
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];

    CGRect keyboardFrame = [self.view convertRect:keyboardEndFrame toView:nil];
    [self resizeKeyboard:keyboardFrame];
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)keyboardWillShow:(NSNotification *)aNotification {
    [self moveTextViewForKeyboard:aNotification up:YES];
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)resizeKeyboard:(CGRect)keyboardFrame
{
    int height = self.view.frame.size.height - (buttonView.frame.size.height + keyboardFrame.size.height);
    CGRect newFrame = textView.frame;
    newFrame.size.height = height;
    textView.frame = newFrame;
    containerView.frame = newFrame;
    [self addShadow];
    
    newFrame = buttonView.frame;
    newFrame.origin.y = height;
    buttonView.frame = newFrame;
    
    newFrame = contentView.frame;
    newFrame.origin.y = height + buttonView.frame.size.height;
    newFrame.size.height = keyboardFrame.size.height;
    contentView.frame = newFrame;
    [self layoutButtons];
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)addShadow
{
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:containerView.bounds];
    containerView.layer.masksToBounds = NO;
    containerView.layer.shadowColor = [UIColor blackColor].CGColor;
    containerView.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    containerView.layer.shadowOpacity = 0.5;
    containerView.layer.shadowRadius = 2;
    containerView.layer.shadowPath = shadowPath.CGPath;
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)layoutButtons
{
    if(!didLayoutButtons)
    {
        didLayoutButtons = YES;
        GPTransparentToolbar* toolBar = [[[GPTransparentToolbar alloc] initWithFrame:CGRectMake(0, 0, buttonView.frame.size.width, buttonView.frame.size.height)] autorelease];
        [buttonView addSubview:toolBar];
        [toolBar setItems:[self barButtonItems]];
    }
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//textview delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)textViewDidBeginEditing:(UITextView *)txtView
{
    if(txtView.text.length == 0)
        self.navigationItem.rightBarButtonItem.enabled = NO;
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)textViewDidEndEditing:(UITextView *)txtView
{
    if(txtView.text.length > 0)
        self.navigationItem.rightBarButtonItem.enabled = YES;
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(BOOL)textView:(UITextView *)txtView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if(limitLabel)
    {
        if(self.textLimit <= 0)
            limitLabel.text = [NSString stringWithFormat:@"%d",[txtView.text length]];
        else
        {
            int offset = self.textLimit - [txtView.text length];
            limitLabel.text = [NSString stringWithFormat:@"%d",offset];
            [self performSelector:@selector(checkPostStatus) withObject:nil afterDelay:0.1];
            if(offset <= 0 && ![text isEqualToString:@""])
                return NO;
        }
    }
    return YES;
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)checkPostStatus
{
    int count = [textView.text length];
    int left = self.textLimit - count;
    if(left <= 0 || count == 0)
        self.navigationItem.rightBarButtonItem.enabled = NO;
    else
        self.navigationItem.rightBarButtonItem.enabled = YES;
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//posting
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)post
{
    if([self.delegate respondsToSelector:@selector(textDidPost:)])
        [self.delegate textDidPost:textView.text];
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)cancel
{
    if(![textView.text isEqualToString:@""])
    {
        UIAlertView *alert = [[UIAlertView alloc] init];
        [alert setTitle:@"Confirm"];
        [alert setMessage:@"Are you sure you want to cancel?"];
        [alert setDelegate:self];
        [alert addButtonWithTitle:@"Yes"];
        [alert addButtonWithTitle:@"No"];
        [alert show];
        [alert release];
    }
    else
        if([self.delegate respondsToSelector:@selector(didCancel)])
            [self.delegate didCancel];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 0)
	{
        if([self.delegate respondsToSelector:@selector(didCancel)])
            [self.delegate didCancel];
	}
	else if (buttonIndex == 1)
	{
		return;
	}
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)dismissKeyboard
{
    [textView resignFirstResponder];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//Subclass sections
///////////////////////////////////////////////////////////////////////////////////////////////////
//return an array of barButtonItems. (you will probably want to add flexable space in between each of them)
-(NSArray*)barButtonItems
{
    /*NSMutableArray* array = [NSMutableArray arrayWithCapacity:12];
    for(int i = 0; i < 4; i++)
    {
        if(i != 0)
        {
            UIBarButtonItem* item = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
            [array addObject:item];
        }
        UIBarButtonItem* item = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(post)] autorelease];
        [array addObject:item];
    }
    UIBarButtonItem* item = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
    [array addObject:item];
    item = [[[UIBarButtonItem alloc] initWithCustomView:[self textCounter]] autorelease];
    [array addObject:item];
    return array;*/
    //example of usage above
    return nil;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//add this to your in as one of your buttons in the barButtonItems method above to you want to show
//a text counter of how much text you have left. If textLimit is 0, it will just count up
-(GPLabel*)textCounter
{
    limitLabel = [[GPLabel alloc] initWithFrame:CGRectMake(0, 0, 30, buttonView.frame.size.height)];
    limitLabel.backgroundColor = [UIColor clearColor];
    limitLabel.font = [UIFont systemFontOfSize:15];
    limitLabel.textColor = [UIColor lightGrayColor];
    limitLabel.text = [NSString stringWithFormat:@"%d",self.textLimit];
    limitLabel.textShadowBlur = 1;
    limitLabel.textShadowColor = [UIColor whiteColor];
    limitLabel.textShadowOffset = CGSizeMake(0, 1);
    limitLabel.textAlignment = NSTextAlignmentRight;
    return limitLabel;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)dealloc
{
    [containerView release];
    [limitLabel release];
    [buttonView release];
    [textView release];
    [super dealloc];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
@end
