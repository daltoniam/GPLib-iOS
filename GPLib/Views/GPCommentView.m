//
//  GPCommentView.m
//  GPLib
//
//  Created by Dalton Cherry on 1/3/12.
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

#import "GPCommentView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+Additions.h"

#define MARGIN 6

@implementation GPCommentView

@synthesize delegate = delegate,charLimit,heightLimit,shouldDismiss,uploadImage,formatImage;
//////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        UIColor* color = [UIColor colorWithRed:190/255.0f green:190/255.0f blue:190/255.0f alpha:1];//[UIColor colorWithRed:223/255.0f green:223/255.0f blue:223/255.0f alpha:1];

        self.gradientLength = 0.75;
        self.gradientStartColor = [UIColor colorWithRed:242/255.0f green:242/255.0f blue:242/255.0f alpha:1];//[UIColor colorWithRed:248/255.0f green:248/255.0f blue:248/255.0f alpha:1];
        self.gradientEndColor = color;
        
        int height = self.frame.size.height-(MARGIN);
        int bwidth = 60;
        int boffset = self.frame.size.width- bwidth - MARGIN;
        
        Button = [[GPButton alloc] init];//[[UIButton buttonWithType:UIButtonTypeCustom] retain];
        //Button.backgroundColor = [UIColor clearColor];
        Button.fillColor = [UIColor colorWithRed:0/255.0f green:62/255.0f blue:255/255.0f alpha:1];
        Button.highlightColor = [UIColor blueColor];//[UIColor colorWithRed:0/255.0f green:62/255.0f blue:255/255.0f alpha:1];
        Button.frame = CGRectMake(self.frame.size.width - (bwidth + MARGIN), MARGIN, bwidth, height-8);
        [Button setTitle:@"Send" forState:UIControlStateNormal];
        [Button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [Button setTitleColor:[UIColor colorWithWhite:1 alpha:0.2] forState:UIControlStateDisabled];
        Button.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        Button.rounding = Button.frame.size.height/2;
        Button.drawGloss = YES;
        Button.borderColor = [UIColor blackColor];
        Button.borderWidth = 0.3;
        Button.enabled = NO;
        Button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
        [Button addTarget:self action:@selector(Post) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:Button];
        
        bubble = [[GPBubbleView alloc] initWithFrame:CGRectMake(MARGIN, MARGIN, boffset-10, (height-8))];
        bubble.TriangleSize = CGSizeMake(0, 0);
        bubble.layer.shadowOffset = CGSizeMake(0, 0);
        bubble.layer.shadowOpacity = 0;
        bubble.layer.shadowRadius = 0;
        bubble.BorderColor = [UIColor blackColor];
        bubble.BorderWidth = 0.3;
        bubble.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        bubble.drawInsetShadow = YES;
        
        [self addSubview:bubble];
        TextField = [[UITextView alloc] initWithFrame:
                                  CGRectMake(5, 2, bubble.frame.size.width-10, bubble.frame.size.height-4)]; //CGRectMake(MARGIN, MARGIN, boffset-10, (height-9)
        TextField.delegate = self;
        TextField.font = [UIFont systemFontOfSize:14];
        TextField.returnKeyType = UIReturnKeyDone;
        TextField.contentInset = UIEdgeInsetsMake(0, 1, 2, 1);
        TextField.backgroundColor = [UIColor clearColor];
        TextField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        
        [bubble addSubview:TextField];
                
        OFrame = frame;
        textFieldHeight = bubble.frame.size.height;
        self.shouldDismiss = YES;
        self.heightLimit = 120;
    }
    return self;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(GPButton*)attachmentButton
{
    int height = Button.frame.size.height;
    GPButton* button = [[GPButton alloc] initWithFrame:CGRectMake(MARGIN, MARGIN,height,height)];
    button.fillColor = [UIColor colorWithRed:82/255.0f green:82/255.0f blue:82/255.0f alpha:1];
    button.highlightColor = [UIColor colorWithRed:72/255.0f green:72/255.0f blue:72/255.0f alpha:1];;//[UIColor colorWithRed:0/255.0f green:62/255.0f blue:255/255.0f alpha:1];
    button.rounding = height/2;
    button.drawGloss = YES;
    button.borderColor = [UIColor blackColor];
    button.borderWidth = 0.3;
    int pad = button.rounding + height/3;
    UIImage* image = self.uploadImage;
    if(self.formatImage)
    {
        image = [UIImage imageByScalingProportionallyToSize:CGSizeMake(pad,pad) image:self.uploadImage];
        image = [UIImage imageWithOverlayColor:image color:[UIColor whiteColor]];
    }
    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:self action:@selector(attachmentButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    return [button autorelease];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)layoutSubviews
{
    [super layoutSubviews];
    if(self.uploadImage && !attachButton)
    {
        attachButton = YES;
        GPButton* button = [[self attachmentButton] retain];
        int offset = button.frame.size.width + MARGIN;
        CGRect frame = bubble.frame;
        frame.size.width -= offset;
        frame.origin.x += offset;
        bubble.frame = frame;
        
        frame = TextField.frame;
        frame.size.width -= offset;
        TextField.frame = frame;
        
        [self addSubview:button];
    }
    
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//textview delegate
//////////////////////////////////////////////////////////////////////////////////////////////
-(void)textViewDidBeginEditing:(UITextView *)textView
{
    if([delegate respondsToSelector:@selector(didSelectTextField:)])
        [delegate didSelectTextField:self];
}
//////////////////////////////////////////////////////////////////////////////////////////////
-(void)textViewDidEndEditing:(UITextView *)textView
{
    if([delegate respondsToSelector:@selector(didEndSelectTextField:)])
        [delegate didEndSelectTextField:self];
}
//////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text 
{   
    if([text isEqualToString:@"\n"]) 
    {
        [textView resignFirstResponder];
        return NO;
    }
    [self setTextFrame:textView];
    
    [self performSelector:@selector(checkTextFieldLength:) withObject:textView afterDelay:0.1];
    if(charLimit == 0 || [text isEqualToString:@""])
        return YES;
    if(textView.text.length >= charLimit)
        return NO;
    return YES;
}
//////////////////////////////////////////////////////////////////////////////////////////////
-(void)checkTextFieldLength:(UITextView*)textView
{
    if(textView.text.length > 0)
        Button.enabled = YES;
    if(textView.text.length < 1)
        Button.enabled = NO;
}
//////////////////////////////////////////////////////////////////////////////////////////////
-(void)Post
{
    if(shouldDismiss)
        [TextField resignFirstResponder];
    if([delegate respondsToSelector:@selector(textDidPost:)])
        [delegate textDidPost:TextField.text];
    [self resetTextView];
}
//////////////////////////////////////////////////////////////////////////////////////////////
-(void)attachmentButtonTapped
{
    if([self.delegate respondsToSelector:@selector(didSelectAttachmentButton)])
        [self.delegate didSelectAttachmentButton];
}
//////////////////////////////////////////////////////////////////////////////////////////////
//adjust the text view according to the text
-(void)setTextFrame:(UITextView*)textview
{
    int pad = (OFrame.size.height-textFieldHeight);
    int height = textview.contentSize.height;
    if(height < self.heightLimit || self.heightLimit == 0)
    {
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        int offset = (height-self.frame.size.height);
        //NSLog(@"offset: %d",offset);
        CGRect frame = self.frame;
        if(height > OFrame.size.height-(pad/2) && textview.text.length > 1)
        {
            frame.size.height = height+(pad/2);
            frame.origin.y -= offset+(pad/2);
        }
        self.frame = frame;
        
        CGRect bubbleFrame = bubble.frame;
        bubbleFrame.size.height = frame.size.height-(MARGIN*2);
        bubbleFrame.origin.y = MARGIN;
        bubble.frame = bubbleFrame;
        [bubble setNeedsDisplay];
        
        CGRect textframe = textview.frame;
        textframe.size.height = bubbleFrame.size.height-4;
        textframe.origin.y = 2;
        textview.frame = textframe;
        
        [UIView commitAnimations];
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////
-(void)resetTextView
{
    TextField.text = @"";
    Button.enabled = NO;
    [bubble setNeedsDisplay];
    int change = self.frame.size.height - OFrame.size.height;

    CGRect frame = self.frame;
    frame.size.height -= change;
    frame.origin.y += change;
    self.frame = frame;
    
    frame = bubble.frame;
    frame.origin.y =  MARGIN;
    frame.size.height = textFieldHeight;
    bubble.frame = frame;
    
    frame = TextField.frame;
    frame.origin.y =  2;
    frame.size.height = bubble.frame.size.height-4;
    TextField.frame = frame;
}
//////////////////////////////////////////////////////////////////////////////////////////////
-(void)dealloc
{
    [bubble release];
    [Button release];
    [TextField release];
    [super dealloc];
}
//////////////////////////////////////////////////////////////////////////////////////////////

@end
