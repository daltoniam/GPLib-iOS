//
//  GPReceiptField.m
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

#import "GPReceiptField.h"

@implementation GPReceiptField

const int PADDING = 6;

@synthesize delegate = delegate,numberOfLines = numberOfLines,shouldShowPicker = shouldShowPicker;
////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.userInteractionEnabled = YES;
        ScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSelectItem:)];
        [ScrollView addGestureRecognizer:tap];
        [tap release];
        [self addSubview:ScrollView];
        TextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        TextLabel.textColor = [UIColor lightGrayColor];
        TextLabel.font = [UIFont systemFontOfSize:14];
        TextLabel.text = @"To:";
        [ScrollView addSubview:TextLabel];
        TextField = [[UITextField alloc] initWithFrame:CGRectZero];
        TextField.delegate = self;
        TextField.font = [UIFont systemFontOfSize:14];
        TextField.backgroundColor = [UIColor clearColor];
        [TextField becomeFirstResponder]; 
        [ScrollView addSubview:TextField];
        Bubbles = [[NSMutableArray alloc] init];
        self.backgroundColor = [UIColor whiteColor];
        numberOfLines = 3;
        lineCount = 0;
        OGHeight = self.frame.size.height;
        pickerOffset = 0;
    }
    return self;
}
////////////////////////////////////////////////////////////////////////////////////////////
-(id)init
{
    if((self = [self initWithFrame:CGRectZero])){}
    return self;
}
////////////////////////////////////////////////////////////////////////////////////////////
-(void)layoutSubviews
{
    [super layoutSubviews];
    ScrollView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    if(OGHeight == 0)
        OGHeight = self.frame.size.height;
    int left = 0;
    int top = PADDING;
    CGSize size = [self GetLabelFrame:TextLabel];
    TextLabel.frame = CGRectMake(2, top, size.width, size.height);
    left = size.width + 5;
    if(shouldShowPicker)
    {
        if(pickerOffset == 0)
        {
            int dem = 25;
            contactButton = [[UIButton buttonWithType:UIButtonTypeContactAdd] retain];
            //contactButton.frame = CGRectMake(ScrollView.frame.size.width- (PADDING + dem),self.frame.size.height - (dem +PADDING+2), dem, dem);
            [contactButton addTarget:self action:@selector(sendPicker:) forControlEvents:UIControlEventTouchDown]; //UIControlEventTouchUpInside
            [ScrollView addSubview:contactButton];
            pickerOffset = dem;
        }
    }
    
    [self layoutBubbleViews:&left top:&top];
    
    int offset = self.frame.size.width - (left + pickerOffset);
    if(offset < 75)
    {
        left = TextLabel.frame.size.width;
        top += 25;
            
    }
    TextField.frame = CGRectMake(left, top, self.frame.size.width-(left+pickerOffset), self.frame.size.height);
    ScrollView.contentSize = CGSizeMake(self.frame.size.width, top+size.height);
    if([Bubbles count] > 0)
    {
        lineCount = (TextField.frame.origin.y/25)+1;
        if(lineCount <= numberOfLines || numberOfLines == 0)
        {
            CGRect frame = self.frame;
            int size = lineCount*30;
            if(size < OGHeight)
                frame.size.height = OGHeight;
            else
                frame.size.height = size; //OGHeight
            self.frame = frame;
            ScrollView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
            if(numberOfLines == 0)
                ScrollView.contentSize = CGSizeMake(self.frame.size.width, self.frame.size.height);
            if([delegate respondsToSelector:@selector(heightDidChange:)])
                [delegate heightDidChange:self.frame.size.height];
        }
    }
    if(shouldShowPicker)
    {
        int dem = 25;
        contactButton.frame = CGRectMake( self.frame.size.width- (PADDING + dem), self.frame.size.height - (dem +PADDING+2), dem, dem);
    }
}
///////////////////////////////////////////////////////////////////////////////////////////
-(void)layoutBubbleViews:(int*)left top:(int*)top
{
    for(GPPillLabel* view in Bubbles)
    {
        int offset = self.frame.size.width - (*left + pickerOffset);
        if(offset < 75)
        {
            *left = TextLabel.frame.size.width;
            *top += 25;
        }
        
        CGSize tsize = [self GetLabelFrame:view];
        int width = tsize.width+20;
        BOOL reset = NO;
        offset = self.frame.size.width - (*left + pickerOffset);
        if(width > offset)
        {
            width = offset;
            reset = YES;
        }
        view.frame = CGRectMake(*left, *top, width, 20);
        *left += view.frame.size.width+PADDING;
        
        if(reset)
        {
            *left = TextLabel.frame.size.width;
            *top += 25;
        }
    }
}
////////////////////////////////////////////////////////////////////////////////////////////
//handles bubble clicking
-(void)didSelectItem:(id)sender
{
    UITapGestureRecognizer* gesture = (UITapGestureRecognizer*)sender;
    CGPoint location = [gesture locationInView:ScrollView];
    for(UIView* view in ScrollView.subviews)
    {
        if(CGRectContainsPoint(view.frame, location) && [view isKindOfClass:[GPPillLabel class]])
        {
            if(view != SelectedCell)
            {
                TextField.text = @" ";
                TextField.hidden = YES;
                if(SelectedCell)
                    [self setBubbleState:UIControlStateNormal view:SelectedCell];
                GPPillLabel *bubble = (GPPillLabel*)view;
                [self setBubbleState:UIControlStateSelected view:bubble];
                SelectedCell = bubble;
                return;
            }
        }
    }
    if(SelectedCell)
        [self setBubbleState:UIControlStateNormal view:SelectedCell];
    SelectedCell = nil;
    TextField.text = @" ";
    TextField.hidden = NO;
}
////////////////////////////////////////////////////////////////////////////////////////////
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
}
////////////////////////////////////////////////////////////////////////////////////////////
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if(SelectedCell)
        [self setBubbleState:UIControlStateNormal view:SelectedCell];
    SelectedCell = nil;
    if([self.delegate respondsToSelector:@selector(textFieldWillDismiss:)])
        [self.delegate textFieldWillDismiss:textField];
    TextField.text = @"";
    TextField.hidden = YES;
}
////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if((range.location == 0 && [string isEqualToString:@""] && [Bubbles count] > 0) || SelectedCell)
    {
        [self removeItem];
    }
    else if([delegate respondsToSelector:@selector(didChange:CharactersInRange:replacementString:)])
    {
            [delegate didChange:textField CharactersInRange:range replacementString:string];
    }
    
    /*else if([string isEqualToString:@" "] && ![[string lowercaseString] isEqualToString:[textField.text lowercaseString]])
    {
        [self addItem:textField.text];
    }*/
    return YES;
}
////////////////////////////////////////////////////////////////////////////////////////////
-(void)addItem:(NSString*)text
{
    if(![text isEqualToString:@""])
    {
        GPPillLabel* view = [GPPillLabel mailBubble];//[GPBubbleView textItem:[self bubbleColor:UIControlStateNormal] text:text];
        view.text = text;
        [Bubbles addObject:view];
        [ScrollView addSubview:[Bubbles lastObject]];
        TextField.text = @"";
        [self performSelector:@selector(delayText) withObject:nil afterDelay:0.1];
        [self layoutSubviews];
    }
}
////////////////////////////////////////////////////////////////////////////////////////////
-(void)removeItem
{
    if(!SelectedCell)
    {
        [self performSelector:@selector(delayText) withObject:nil afterDelay:0.1];
        TextField.hidden = YES;
        TextField.text = @"";
        SelectedCell = [Bubbles lastObject];
        [self setBubbleState:UIControlStateSelected view:SelectedCell];
    }
    else
    {
        [SelectedCell removeFromSuperview];
        [Bubbles removeObject:SelectedCell];
        SelectedCell = nil;
        [self performSelector:@selector(delayText) withObject:nil afterDelay:0.1];
        TextField.hidden = NO;
        TextField.text = @"";
    }
    [self layoutSubviews];
}
////////////////////////////////////////////////////////////////////////////////////////////
-(UIColor*)bubbleColor:(UIControlState)state
{
    if(state == UIControlStateSelected)
        return [UIColor colorWithRed:79/255.0f green:144/255.0f blue:255/255.0f alpha:1]; //79, 144, 255
    return [UIColor colorWithRed:221/255.0f green:231/255.0f blue:248/255.0f alpha:1];
}
////////////////////////////////////////////////////////////////////////////////////////////
-(UIColor*)textLabelColor:(UIControlState)state
{
    if(state == UIControlStateSelected)
        return [UIColor whiteColor];
    return [UIColor blackColor];
}
////////////////////////////////////////////////////////////////////////////////////////////
//change bubble state
-(void)setBubbleState:(UIControlState)state view:(GPPillLabel*)view
{
    [view setFillColor:[self bubbleColor:state]];
    view.textColor = [self textLabelColor:state];
    [view setNeedsDisplay];
}
////////////////////////////////////////////////////////////////////////////////////////////
-(void)delayText
{
    if([TextField.text isEqualToString:@""])
        TextField.text = @" ";
}
////////////////////////////////////////////////////////////////////////////////////////////
//caculate frame of text by font and text data
-(CGSize)GetLabelFrame:(UILabel*)label
{
    return [label.text sizeWithFont:label.font constrainedToSize:CGSizeMake(self.frame.size.width, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap]; 
}
////////////////////////////////////////////////////////////////////////////////////////////
-(void)sendPicker:(UIButton*)sender
{
    if([delegate respondsToSelector:@selector(showPicker)])
        [delegate showPicker];
}
////////////////////////////////////////////////////////////////////////////////////////////
//property of Bubbles
-(NSMutableArray*)Bubbles
{
    return Bubbles;
}
////////////////////////////////////////////////////////////////////////////////////////////
-(void)setBubbles:(NSMutableArray *)array
{
    for(NSString* text in array)
        [self addItem:text];
}
////////////////////////////////////////////////////////////////////////////////////////////
-(void)dealloc
{
    [TextLabel release];
    [TextField release];
    [Bubbles release];
    [ScrollView release];
    [contactButton release];
    [super dealloc];
}

@end
