//
//  GPPostingViewController.m
//  GPLib
//
//  Created by Dalton Cherry on 12/20/11.
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

#import "GPPostingViewController.h"
#import "GPBubbleView.h"
#import "GPImageView.h"
#import "HTMLKit.h"
#import "GPTableTextItem.h"
#import <QuartzCore/QuartzCore.h>

@implementation GPPostingViewController

@synthesize delegate = delegate;
///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        self.navigationItem.rightBarButtonItem =[[[UIBarButtonItem alloc] initWithTitle: @"Post"
                                                                                  style: UIBarButtonItemStyleBordered
                                                                                 target: self
                                                                                 action:@selector(postText)] autorelease];
        self.navigationItem.leftBarButtonItem =[[[UIBarButtonItem alloc] initWithTitle: @"Cancel"
                                                                                 style: UIBarButtonItemStyleBordered
                                                                                target: self
                                                                                action:@selector(cancelText)] autorelease];
    }
    return self;
}

#pragma mark - View lifecycle

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor underPageBackgroundColor];
    //UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissTextView)];
    //[self.view addGestureRecognizer:tap];
    //[tap release];
    GPImageView* imageView =[[[GPImageView alloc] init] autorelease];
    int left = 5;
    int top = 6;
    imageView.frame = CGRectMake(left, top, 50, 50);
    imageView.URL = [self photoURL];
    [imageView fetchImage];
    CALayer * l = [imageView layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:10.0];
    [self.view addSubview:imageView];
    left += 55;
    GPBubbleView* bubbleview = [[GPBubbleView alloc] initWithFrame:CGRectMake(left, top, 
                                                                              self.view.frame.size.width-(left + 10), self.view.frame.size.height/2.6)];
    bubbleview.BorderColor = [UIColor colorWithCSS:@"#CECECE"];
    top += 5;
    TextView = [[UITextView alloc] initWithFrame:CGRectMake(15, top, bubbleview.frame.size.width-20, bubbleview.frame.size.height-20)];
    TextView.delegate = self;
    TextView.returnKeyType = UIReturnKeyDone;
    TextView.contentInset = UIEdgeInsetsMake(5, 5, 5, 5);
    [bubbleview addSubview:TextView];
    [self.view addSubview:bubbleview];
    //ActLabel.hidden = YES;
    [ActLabel removeFromSuperview];
    [TextView becomeFirstResponder];
    int offset = bubbleview.frame.origin.y + bubbleview.frame.size.height;
    if(GPIsPad())
        _tableView.frame = CGRectMake(20, offset, self.view.frame.size.width, self.view.frame.size.height-offset);
    else
        _tableView.frame = CGRectMake(0, offset, self.view.frame.size.width, self.view.frame.size.height-offset);
    [bubbleview release];
    [bubbleview bringSubviewToFront:TextView];
    [bubbleview setNeedsDisplay];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //bug fix?
    CGPoint offset = TextView.contentOffset;
    offset.x += 1;
    TextView.contentOffset = offset;
    offset.x -= 1;
    TextView.contentOffset = offset;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event 
{
    [self dismissTextView];
    [self.nextResponder touchesEnded:touches withEvent:event];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//textview delegate
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)textViewDidBeginEditing:(UITextView *)textView
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)textViewDidEndEditing:(UITextView *)textView
{
    if(TextView.text.length > 0)
        self.navigationItem.rightBarButtonItem.enabled = YES;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text 
{    
    if([text isEqualToString:@"\n"]) 
    {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//posting
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)postText
{
    if(!isPosting)
    {
        if([delegate respondsToSelector:@selector(textDidPost:)])
            [delegate textDidPost:TextView.text];
    }
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)cancelText
{
    if(!isPosting)
    {
        if(![TextView.text isEqualToString:@""])
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
            if([delegate respondsToSelector:@selector(didCancel)])
                [delegate didCancel];
    }
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 0)
	{
        if([delegate respondsToSelector:@selector(didCancel)])
            [delegate didCancel];
	}
	else if (buttonIndex == 1)
	{
		return;
	}
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)dismissTextView
{
    [TextView resignFirstResponder];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//subclass this to enable set to grouped style.
-(BOOL)grouped
{
    return YES;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(UIColor*)tableBackground
{
    return [UIColor clearColor];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//subclass!
///////////////////////////////////////////////////////////////////////////////////////////////////
//set the photoURL for the user pic.
-(NSString*)photoURL
{
    return nil;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)dealloc
{
    [TextView release];
    [super dealloc];
}

@end
