//
//  HTMLPostViewController.m
//  GPLib
//
//  Created by Dalton Cherry on 12/15/11.
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

#import "HTMLPostViewController.h"
#import "GPButton.h"
#import "GPTableTextItem.h"
#import "GPTableHTMLItem.h"
#import "HTMLKit.h"
#import "GPTransparentToolbar.h"
#import <QuartzCore/QuartzCore.h>

@implementation HTMLPostViewController

@synthesize delegate = delegate, Popover;

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        GPTransparentToolbar* toolbar = [[[GPTransparentToolbar alloc] initWithFrame:CGRectMake(0, 0, 105, 44)] autorelease];
        if([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0)
            [[UIToolbar appearance] setTintColor:[[UINavigationBar appearance] tintColor] ];
        
        editButton =  [[UIBarButtonItem alloc] initWithTitle: @"Edit"
                                                        style: UIBarButtonItemStyleBordered
                                                       target: self
                                                      action:@selector(editText)];
        toolbar.items = [NSArray arrayWithObjects: editButton,
                                                    [[[UIBarButtonItem alloc] initWithTitle: @"Post"
                                                                                   style: UIBarButtonItemStyleBordered
                                                                                  target: self
                                                                                  action:@selector(PostText)] autorelease] ,nil];
        
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]initWithCustomView:toolbar] autorelease];
        
        
        self.navigationItem.leftBarButtonItem =[[[UIBarButtonItem alloc] initWithTitle: @"Cancel"
                                                                                 style: UIBarButtonItemStyleBordered
                                                                                target: self
                                                                                action:@selector(CancelText)] autorelease];
        self.title = @"Post";
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardDidShowNotification //UIKeyboardDidShowNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
    }
    return self;
}

#pragma mark - View lifecycle

///////////////////////////////////////////////////////////////////////////////////////////////////
-(id)initWithHTML:(NSString*)html
{
    if(self = [super init])
    {
        if(html)
        {
            HTMLParser* parser = [[[HTMLParser alloc] initWithHTML:html] autorelease];
            parser.Embed = YES;
            tempAttribString = [[NSMutableAttributedString alloc] initWithAttributedString:[parser ParseHTML]]; 
        }
    }
    return self;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tbbackground.jpg"]];
    int h = self.view.frame.size.height;//self.view.frame.size.height/2.09; // 1.88
    //if(GPIsPad())
      //  h = self.view.frame.size.height/1.54; //1.40
    
    contentView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:contentView];
    Textview = [[HTMLTextView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, h)];
    Textview.scrollEnabled = NO;
    if(tempAttribString)
    {
        [Textview appendString:tempAttribString];
        [tempAttribString release];
    }
    
    Textview.contentInset = UIEdgeInsetsMake(2,2,2,2); //25
    Textview.delegate = self;
    contentView.contentSize = Textview.contentSize;
    if(GPIsPad())
        Textview.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    contentView.autoresizingMask =  UIViewAutoresizingFlexibleWidth;
    [contentView addSubview:Textview];
    
     ActLabel.hidden = YES;
    [Textview becomeFirstResponder];
    Alignment = kCTLeftTextAlignment;
    CurrentColor = [UIColor blackColor];
    CurrentSize = 12;
    FontName = @"Helvetica";//@"TrebuchetMS";
    sections = [[NSMutableArray alloc] initWithCapacity:3];
    
    [_tableView removeFromSuperview];
    
    HTMLSettingsViewController* view = [[self settingsMenu] retain];
    view.delegate = self;
    navBar = [[UINavigationController alloc] initWithRootViewController:view];
    
    if(GPIsPad())
    {
        UIPopoverController* pop = [[UIPopoverController alloc] initWithContentViewController:navBar];
        pop.delegate = self;
        self.Popover = pop;
        [pop release];
    }
    else
    {
        CGRect frame = navBar.view.frame;
        frame.origin.y += 130;
        frame.origin.y += 300;
        navBar.view.frame = frame;
    }
        [view release];
    
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) moveTextViewForKeyboard:(NSNotification*)aNotification up: (BOOL) up
{
    NSDictionary* userInfo = [aNotification userInfo];
    
    // Get animation info from userInfo
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    
    CGRect keyboardEndFrame;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    
    keyboardFrame = [self.view convertRect:keyboardEndFrame toView:nil];
    
    // Animate up or down
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    //[UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    CGRect newFrame = Textview.frame;
    if (up) 
        newFrame.size.height -= keyboardFrame.size.height;
    else 
        newFrame.size.height += keyboardFrame.size.height;
    Textview.frame = newFrame;
    
    [UIView commitAnimations];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)keyboardWillShow:(NSNotification *)aNotification {
    [self moveTextViewForKeyboard:aNotification up:YES];
    //if(!GPIsPad()) //there is always a keyboard size frame up, so we never dismiss
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)keyboardWillHide:(NSNotification *)aNotification 
{
        [self moveTextViewForKeyboard:aNotification up:NO]; 
}
///////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////
//link delegate
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didCreate:(NSString*)link
{
    [Textview.attributedString setTextIsHyperLink:link range:Textview.selectedRange];
    [Textview.attributedString setTextColor:[UIColor blueColor] range:Textview.selectedRange];
    [Textview.attributedString setTextIsUnderlined:YES range:Textview.selectedRange];
    if(!link || link.length == 0)
    {
        [Textview.attributedString setTextColor:[UIColor blackColor] range:Textview.selectedRange];
        [Textview.attributedString setTextIsUnderlined:NO range:Textview.selectedRange];
    }
    [Textview textChanged];
    if(!GPIsPad())
        [self dismissModalViewControllerAnimated:YES];
    [navBar popViewControllerAnimated:YES];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)DidCancel
{
    if(!GPIsPad())
        [self dismissModalViewControllerAnimated:YES];
    [navBar popViewControllerAnimated:YES];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//settings view delegate
///////////////////////////////////////////////////////////////////////////////////////////////////
//use for iphone dimiss of settings view
-(void)viewWasDimissed
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    CGRect frame = navBar.view.frame;
    frame.origin.y += 300;
    navBar.view.frame = frame;
    
    frame = Textview.frame;
    frame.size.height += 50;
    Textview.frame = frame;
    
    [UIView commitAnimations];
    [navBar.view removeFromSuperview];
    Textview.userInteractionEnabled = YES;
    [Textview becomeFirstResponder];
    isEditing = NO;
    [self updateStringSettings];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(BOOL)isHyperLinkReady
{
    if(Textview.selectedRange.length > 0)
        return YES;
    return NO;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)updateBold:(BOOL)bold
{
    isBold = bold;
    if(Textview.selectedRange.length > 0)
    {
        CTFontRef font = (CTFontRef)[Textview.stringAttributes objectForKey:(NSString*)kCTFontAttributeName];
        if(!font)
            [Textview.attributedString setFontName:FontName size:CurrentSize range:Textview.selectedRange];
        [Textview.attributedString setTextBold:isBold range:Textview.selectedRange];
        [Textview textChanged];
    }
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)updateItalic:(BOOL)italic
{
    isItalic = italic;
    if(Textview.selectedRange.length > 0)
    {
        CTFontRef font = (CTFontRef)[Textview.stringAttributes objectForKey:(NSString*)kCTFontAttributeName];
        if(!font)
            [Textview.attributedString setFontName:FontName size:CurrentSize range:Textview.selectedRange];
        [Textview.attributedString setTextItalic:isItalic range:Textview.selectedRange];
        [Textview textChanged];
    }
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)updateUnderLine:(BOOL)isUnder
{
    isUnderLine = isUnder;
    if(Textview.selectedRange.length > 0)
    {
        [Textview.attributedString setTextIsUnderlined:isUnderLine range:Textview.selectedRange];
        [Textview textChanged];
    }
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)updateStrike:(BOOL)strike
{
    isStrike = strike;
    if(Textview.selectedRange.length > 0)
    {
        [Textview.attributedString setTextStrikeOut:isStrike range:Textview.selectedRange];
        [Textview textChanged];
    }
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)updateAlignment:(NSInteger)align
{
    Alignment = align;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)updateList:(NSInteger)listType
{
    if(isOrderList && listType == 0)
    {
        NSRange attrib = Textview.selectedRange;
        if(attrib.location > 0 && attrib.location != NSNotFound)
            [Textview.attributedString addAttribute:HTML_CLOSE_LIST value:[NSNumber numberWithBool:YES] range:NSMakeRange(attrib.location-1, 1)];
    }
    else if(isUnorderList)
    {
        NSRange attrib = Textview.selectedRange;
        if(attrib.location > 0 && attrib.location != NSNotFound)
            [Textview.attributedString addAttribute:HTML_CLOSE_LIST value:[NSNumber numberWithBool:YES] range:NSMakeRange(attrib.location-1, 1)];
    }
        
    if(listType == 0)
        isOrderList = !isOrderList;
    else
        isUnorderList = !isUnorderList;
    
    if(isUnorderList)
        isOrderList = NO;
    if(isOrderList)
        isUnorderList = NO;
    if(isOrderList || isUnorderList)
    {
        [self startList];
    }
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)startList
{
    NSString* val = HTML_ORDER_LIST;
    if(isUnorderList)
        val = HTML_UNORDER_LIST;
    NSMutableAttributedString* tempString = [NSMutableAttributedString spaceString:HTML_LIST value:val height:13 width:20];
    [Textview appendString:tempString];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)didSelectItem:(id)object path:(NSIndexPath*)indexPath
{
    GPTableTextItem* item = (GPTableTextItem*)object;
    if([item.NavURL isEqualToString:HYPER_LINK])
    {
        NSString* text = [Textview.attributedString.string substringWithRange:Textview.selectedRange];
        NSString* link = nil;
        NSDictionary* attribs = [Textview.attributedString attributesAtIndex:Textview.selectedRange.location longestEffectiveRange:NULL inRange:Textview.selectedRange];
        link = [attribs objectForKey:HYPER_LINK];
        HTMLLinkViewController* linkview = [[[HTMLLinkViewController alloc] initWithText:text link:link] autorelease];
        linkview.delegate = self;
        if(GPIsPad())
            [navBar pushViewController:linkview animated:YES];
        else
        {
            UINavigationController* navigationController = [[[UINavigationController alloc] initWithRootViewController:linkview] autorelease];
            [self presentModalViewController:navigationController animated:YES];
        }
        return;
    }
    NSString* type = [item.Properties objectForKey:@"type"];
    if([type isEqualToString:KEYWORD_HTML_COLOR])
        CurrentColor = item.color;
    else if([type isEqualToString:KEYWORD_HTML_SIZE])
        CurrentSize = item.font.pointSize;
    else if([type isEqualToString:KEYWORD_HTML_FONT])
        FontName = item.text;
    
    if(Textview.selectedRange.length > 0)
    {
        if([type isEqualToString:KEYWORD_HTML_COLOR])
            [Textview.attributedString setTextColor:item.color range:Textview.selectedRange];
        else if([type isEqualToString:KEYWORD_HTML_SIZE])
            [Textview.attributedString setFontName:FontName size:item.font.pointSize range:Textview.selectedRange];
        else if([type isEqualToString:KEYWORD_HTML_FONT])
            [Textview.attributedString setFontName:FontName size:item.font.pointSize range:Textview.selectedRange];
        [Textview textChanged];
    }
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [navBar popToRootViewControllerAnimated:YES];
    isEditing = NO;
    [self updateStringSettings];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//posting
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)PostText
{
    NSString* rawhtml = [Textview.attributedString convertToHTML];
    if([delegate respondsToSelector:@selector(HTMLDidPost:)])
        [delegate HTMLDidPost:rawhtml];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)editText
{
        if(!isEditing)
        {
            [(HTMLSettingsViewController*)navBar.topViewController setToDefault:[self createSettingsQuery]];
            isEditing = YES;
            if(GPIsPad())
                [self.Popover presentPopoverFromBarButtonItem:editButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            else
            {
                [Textview resignFirstResponder];
                Textview.userInteractionEnabled = NO;
                [self.view addSubview:navBar.view];
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:0.2];
                [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                CGRect frame = navBar.view.frame;
                frame.origin.y -= 300;
                navBar.view.frame = frame;
                
                frame = Textview.frame;
                frame.size.height -= 50;
                Textview.frame = frame;
                [UIView commitAnimations];
            }
        }
        else if(GPIsPad())
        {
            [self.Popover dismissPopoverAnimated:YES];
            isEditing = NO;
        }
        else
            [self viewWasDimissed];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)CancelText
{
    if(![Textview.attributedString.mutableString isEqualToString:@""])
    {
        UIAlertView *alert = [[UIAlertView alloc] init];
        [alert setTitle:@"Confirm"];
        [alert setMessage:@"Are you sure to want to cancel?"];
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
//sub class createSettingsQuery if you have your own custom settings
-(NSDictionary*)createSettingsQuery
{
    [self updateEditValues];
    NSMutableDictionary* dic = [[[NSMutableDictionary alloc] initWithCapacity:7] autorelease];
    [dic setObject:[NSNumber numberWithBool:isBold] forKey:@"bold"];
    [dic setObject:[NSNumber numberWithBool:isItalic] forKey:@"italic"];
    [dic setObject:[NSNumber numberWithBool:isStrike] forKey:@"strike"];
    [dic setObject:[NSNumber numberWithBool:isUnderLine] forKey:@"underline"];
    [dic setObject:[NSNumber numberWithInt:Alignment] forKey:@"alignment"];
    [dic setObject:CurrentColor forKey:@"color"];
    [dic setObject:FontName forKey:@"font"];
    [dic setObject:[NSNumber numberWithInt:CurrentSize] forKey:@"size"];
    [dic setObject:[NSNumber numberWithBool:isOrderList] forKey:@"orderlist"];
    [dic setObject:[NSNumber numberWithBool:isUnorderList] forKey:@"unorderlist"];
    return dic;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)updateEditValues
{
    NSDictionary* attribs = [self getAttributesAtIndex:Textview.selectedRange.location-1];
    CTFontRef font = (CTFontRef)[attribs objectForKey:(NSString*)kCTFontAttributeName];
    if(font)
    {
        CTFontSymbolicTraits traits = CTFontGetSymbolicTraits(font);
        isItalic = ((traits & kCTFontItalicTrait) == kCTFontItalicTrait);
        isBold = ((traits & kCTFontBoldTrait) == kCTFontBoldTrait);
        CTParagraphStyleRef parastyles = (CTParagraphStyleRef)[attribs objectForKey:(NSString*)kCTParagraphStyleAttributeName];
        CTParagraphStyleGetValueForSpecifier(parastyles,kCTParagraphStyleSpecifierAlignment,sizeof(CTTextAlignment),&Alignment);
        
        [CurrentColor release];
        if([attribs objectForKey:(NSString*)kCTForegroundColorAttributeName])
            CurrentColor = [[UIColor colorWithCGColor:(CGColorRef)[attribs objectForKey:(NSString*)kCTForegroundColorAttributeName]] retain];
        else
            CurrentColor = [[UIColor blackColor] retain];
        isUnderLine = NO;
        int32_t line = [[attribs objectForKey:(NSString*)kCTUnderlineStyleAttributeName] intValue]; 
        if(line == (kCTUnderlineStyleSingle|kCTUnderlinePatternSolid))
            isUnderLine = YES;
        isStrike = [[attribs objectForKey:STRIKE_OUT] boolValue];
        CurrentSize = CTFontGetSize(font);
    }

}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(NSDictionary*)getAttributesAtIndex:(int)index
{
    if(index < Textview.attributedString.length && index > 0)
       return [Textview.attributedString attributesAtIndex:index effectiveRange:NULL];
    return nil;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//update the attributes the string will apply when typing
-(void)updateStringSettings
{
    NSMutableAttributedString* tempString = [[[NSMutableAttributedString alloc] initWithString:@"text"] autorelease];
    [tempString setFontName:FontName size:CurrentSize];
    [tempString setTextBold:isBold];
    [tempString setTextIsUnderlined:isUnderLine];
    [tempString setTextItalic:isItalic];
    [tempString setTextStrikeOut:isStrike];
    [tempString setTextAlignment:Alignment lineBreakMode:kCTLineBreakByWordWrapping];
    [tempString setTextColor:CurrentColor];
    NSDictionary* dic = [tempString attributesAtIndex:0 longestEffectiveRange:NULL inRange:NSMakeRange(0, 4)];
    Textview.stringAttributes = [dic retain];
    
    NSRange attrib = Textview.selectedRange;
    if(attrib.location > 0 && attrib.location != NSNotFound)
    {
        [Textview.attributedString setTextColor:CurrentColor range:NSMakeRange(attrib.location-1, 1)];
        [Textview.attributedString setFontName:FontName size:CurrentSize range:NSMakeRange(attrib.location-1, 1)];
        [Textview.attributedString setTextBold:isBold range:NSMakeRange(attrib.location-1, 1)];
        [Textview.attributedString setTextIsUnderlined:isUnderLine range:NSMakeRange(attrib.location-1, 1)];
        [Textview.attributedString setTextItalic:isItalic range:NSMakeRange(attrib.location-1, 1)];
        [Textview.attributedString setTextStrikeOut:isStrike range:NSMakeRange(attrib.location-1, 1)];
        [Textview.attributedString setTextAlignment:Alignment lineBreakMode:kCTLineBreakByWordWrapping range:NSMakeRange(attrib.location-1, 1)];
    }
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//subclass this to set custom settings menu. then handle your custom delegates manually
-(HTMLSettingsViewController*)settingsMenu
{
    return [[HTMLSettingsViewController alloc] initWithExtras:nil];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//text selection
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)HTMLTextViewDidBeginEditing:(HTMLTextView *)textView
{
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)HTMLTextViewDidEndEditing:(HTMLTextView *)textView
{
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)HTMLTextViewDidChange:(HTMLTextView *)textView string:(NSString*)string
{
    [self resizeContentArea:textView];
    if([string isEqualToString:@"\n"] && (isOrderList || isUnorderList ))
    {
       [self startList];
    }
    if(textView.attributedString.length-string.length <= 0 && (isOrderList || isUnorderList) && textView.attributedString.length > 0)
    {
        isOrderList = NO;
        isUnorderList = NO;
    }
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)HTMLTextViewWillChange:(HTMLTextView *)textView string:(NSString*)string
{
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)resizeContentArea:(HTMLTextView *)textView
{
    int keyboard = 250;
    
    int pad = 30;
    int h = textView.contentSize.height+ keyboard;
    contentView.contentSize = CGSizeMake(textView.contentSize.width, h+pad);
    int yoffset = h - textView.frame.size.height;
    CGRect frame = textView.frame;
    frame.size.height = h;
    textView.frame = frame;
    if(yoffset > 0 && textView.frame.size.height > self.view.frame.size.height)
    {
        CGPoint offset = contentView.contentOffset;
        offset.y += yoffset;
        [contentView setContentOffset:offset animated:YES];
    }
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if(GPIsPad())
        return YES;
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)dealloc
{
    [navBar release];
    //[editButton release];
    [CurrentColor release];
    [Textview release];
    [contentView release];
    [super dealloc];
}

@end

