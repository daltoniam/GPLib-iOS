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

@synthesize delegate = delegate, popover;

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
    self.view.backgroundColor = [UIColor whiteColor];
    int h = self.view.frame.size.height;//self.view.frame.size.height/2.09; // 1.88
    //if(GPIsPad())
      //  h = self.view.frame.size.height/1.54; //1.40
    
    contentView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:contentView];
    textView = [[HTMLTextView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, h)];
    textView.scrollEnabled = NO;
    textView.contentSize = CGSizeMake(self.view.frame.size.width, h);
    if(tempAttribString)
    {
        [textView.attribString appendAttributedString:tempAttribString];
        [textView reload];
        [tempAttribString release];
    }
    
    textView.contentInset = UIEdgeInsetsMake(2,2,2,2); //25
    textView.delegate = self;
    contentView.contentSize = textView.contentSize;
    if(GPIsPad())
        textView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    contentView.autoresizingMask =  UIViewAutoresizingFlexibleWidth;
    [contentView addSubview:textView];
    
    [textView becomeFirstResponder];
    self.tableView.sections = [[NSMutableArray alloc] initWithCapacity:3];
    
    [self.tableView removeFromSuperview];
    
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
    [self resizeContentArea:textView];
    
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
    /*[UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    //[UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    CGRect newFrame = Textview.frame;
    if (up) 
        newFrame.size.height -= keyboardFrame.size.height;
    else 
        newFrame.size.height += keyboardFrame.size.height;
    Textview.frame = newFrame;
    
    [UIView commitAnimations];*/
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
    [textView.attribString setTextIsHyperLink:link range:textView.selectedRange];
    [textView.attribString setTextColor:[UIColor blueColor] range:textView.selectedRange];
    [textView.attribString setTextIsUnderlined:YES range:textView.selectedRange];
    if(!link || link.length == 0)
    {
        [textView.attribString setTextColor:[UIColor blackColor] range:textView.selectedRange];
        [textView.attribString setTextIsUnderlined:NO range:textView.selectedRange];
    }
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
    
    frame = textView.frame;
    frame.size.height += 50;
    textView.frame = frame;
    
    [UIView commitAnimations];
    [navBar.view removeFromSuperview];
    textView.userInteractionEnabled = YES;
    [textView becomeFirstResponder];
    isEditing = NO;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(BOOL)isHyperLinkReady
{
    if(textView.selectedRange.length > 0)
        return YES;
    return NO;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)updateBold:(BOOL)bold
{
    if(textView.selectedRange.length > 0)
        [textView.attribString setTextBold:bold range:textView.selectedRange];
    else
        textView.boldText = bold;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)updateItalic:(BOOL)italic
{
    if(textView.selectedRange.length > 0)
        [textView.attribString setTextItalic:italic range:textView.selectedRange];
    else
        textView.italizeText = italic;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)updateUnderLine:(BOOL)isUnder
{
    if(textView.selectedRange.length > 0)
        [textView.attribString setTextIsUnderlined:isUnder range:textView.selectedRange];
    else
        textView.underlineText = isUnder;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)updateStrike:(BOOL)strike
{
    if(textView.selectedRange.length > 0)
        [textView.attribString setTextStrikeOut:strike range:textView.selectedRange];
    else
        textView.strikeText = strike;
    
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)updateAlignment:(NSInteger)align
{
    textView.textAlignment = align;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)updateList:(NSInteger)listType
{
    if(listType == 0)
        isOrderList = !isOrderList;
    else
        isUnorderList = !isUnorderList;
    
    if(isUnorderList)
        isOrderList = NO;
    if(isOrderList)
        isUnorderList = NO;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)didSelectItem:(id)object path:(NSIndexPath*)indexPath
{
    GPTableTextItem* item = (GPTableTextItem*)object;
    if([item.navURL isEqualToString:HYPER_LINK])
    {
        NSString* text = [textView.attribString.string substringWithRange:textView.selectedRange];
        NSString* link = nil;
        NSDictionary* attribs = [textView.attribString attributesAtIndex:textView.selectedRange.location longestEffectiveRange:NULL inRange:textView.selectedRange];
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
    int fontSize = textView.font.pointSize;
    NSString* fontName = textView.font.fontName;
    NSString* type = [item.properties objectForKey:@"type"];
    if([type isEqualToString:KEYWORD_HTML_COLOR])
        textView.textColor = item.color;
    else if([type isEqualToString:KEYWORD_HTML_SIZE])
        fontSize = item.font.pointSize;
    else if([type isEqualToString:KEYWORD_HTML_FONT])
        fontName = item.text;
    
    if(textView.selectedRange.length > 0)
    {
        if([type isEqualToString:KEYWORD_HTML_COLOR])
            [textView.attribString setTextColor:item.color range:textView.selectedRange];
        else if([type isEqualToString:KEYWORD_HTML_SIZE])
            [textView.attribString setFontName:fontName size:fontSize range:textView.selectedRange];
        else if([type isEqualToString:KEYWORD_HTML_FONT])
            [textView.attribString setFontName:fontName size:fontSize range:textView.selectedRange];
    }
    else
        textView.font = [UIFont fontWithName:fontName size:fontSize];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [navBar popToRootViewControllerAnimated:YES];
    isEditing = NO;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//posting
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)PostText
{
    NSString* rawhtml = [textView.attribString convertToHTML];
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
                [self.popover presentPopoverFromBarButtonItem:editButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            else
            {
                [textView resignFirstResponder];
                textView.userInteractionEnabled = NO;
                [self.view addSubview:navBar.view];
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:0.2];
                [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                CGRect frame = navBar.view.frame;
                frame.origin.y -= 300;
                navBar.view.frame = frame;
                
                //frame = Textview.frame;
                //frame.size.height -= 50;
                //Textview.frame = frame;
                [UIView commitAnimations];
            }
        }
        else if(GPIsPad())
        {
            [self.popover dismissPopoverAnimated:YES];
            isEditing = NO;
        }
        else
            [self viewWasDimissed];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)CancelText
{
    if(![textView.attribString.mutableString isEqualToString:@""])
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
    BOOL isItalic = textView.italizeText;
    BOOL isBold = textView.boldText;
    BOOL isStrike = textView.strikeText;
    BOOL isUnder = textView.underlineText;
    CGFloat size = textView.font.pointSize;
    NSString* fontName = textView.font.fontName;
    UIColor* textcolor = textView.textColor;
    CTTextAlignment alignment = textView.textAlignment;
    
    if(textView.selectedRange.location != NSNotFound && textView.selectedRange.location > 0 && textView.selectedRange.location < textView.attribString.length)
    {
        NSDictionary* attributes = [textView.attribString attributesAtIndex:textView.selectedRange.location effectiveRange:NULL];
        
        CTFontRef font = (CTFontRef)[attributes objectForKey:(NSString*)kCTFontAttributeName];
        CTFontSymbolicTraits traits = CTFontGetSymbolicTraits(font);
        isItalic = ((traits & kCTFontItalicTrait) == kCTFontItalicTrait);
        isBold = ((traits & kCTFontBoldTrait) == kCTFontBoldTrait);
        isStrike = [[attributes objectForKey:STRIKE_OUT] boolValue];
        CTParagraphStyleRef parastyles = (CTParagraphStyleRef)[attributes objectForKey:(NSString*)kCTParagraphStyleAttributeName];

        CTParagraphStyleGetValueForSpecifier(parastyles,kCTParagraphStyleSpecifierAlignment,sizeof(CTTextAlignment),&alignment);
        size = CTFontGetSize(font);
        fontName = [(NSString*)CTFontCopyFamilyName(font) autorelease];
        
        UIColor* tempColor = [UIColor colorWithCGColor:(CGColorRef)[attributes objectForKey:(NSString*)kCTForegroundColorAttributeName]];
        if(tempColor)
            textcolor = tempColor;

        int32_t line = [[attributes objectForKey:(NSString*)kCTUnderlineStyleAttributeName] intValue];
        if(line == (kCTUnderlineStyleSingle|kCTUnderlinePatternSolid))
            isUnder = YES;
    }
    
    NSMutableDictionary* dic = [[[NSMutableDictionary alloc] initWithCapacity:7] autorelease];
    [dic setObject:[NSNumber numberWithBool:isBold] forKey:@"bold"];
    [dic setObject:[NSNumber numberWithBool:isItalic] forKey:@"italic"];
    [dic setObject:[NSNumber numberWithBool:isStrike] forKey:@"strike"];
    [dic setObject:[NSNumber numberWithBool:isUnder] forKey:@"underline"];
    [dic setObject:[NSNumber numberWithInt:alignment] forKey:@"alignment"];
    [dic setObject:textcolor forKey:@"color"];
    [dic setObject:fontName forKey:@"font"];
    [dic setObject:[NSNumber numberWithInt:size] forKey:@"size"];
    [dic setObject:[NSNumber numberWithBool:isOrderList] forKey:@"orderlist"];
    [dic setObject:[NSNumber numberWithBool:isUnorderList] forKey:@"unorderlist"];
    return dic;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//subclass this to set custom settings menu. then handle your custom delegates manually
-(HTMLSettingsViewController*)settingsMenu
{
    return [[[HTMLSettingsViewController alloc] initWithExtras:nil] autorelease];
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
- (void)HTMLTextViewDidUpdateText:(HTMLTextView *)htmlTextView text:(NSString*)text
{
    if([text isEqualToString:@"\n"] && htmlTextView.attribString.length > 1 && isspace([htmlTextView.attribString.string characterAtIndex:textView.selectedRange.location-2]) )
    {
        isOrderList = isUnorderList = NO;
    }
    else if([text isEqualToString:@"\n"] && (isOrderList || isUnorderList ))
    {
        NSMutableAttributedString* string = [[[NSMutableAttributedString alloc] initWithString:@" "] autorelease];
        [string setOrderList:isOrderList];
        [string setUnOrderList:isUnorderList];
        [textView.attribString appendAttributedString:string];
        textView.selectedRange = NSMakeRange(textView.selectedRange.location+1, textView.selectedRange.length);
        [textView reload];
    }
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)HTMLTextView:(HTMLTextView *)htmlTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    [self resizeContentArea:textView];
    return YES;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)resizeContentArea:(HTMLTextView *)htmlTextView
{
    int keyboard = keyboardFrame.size.height;
    int check = self.view.frame.size.height - keyboard;
    int h = htmlTextView.contentSize.height + 20;
    if(h < self.view.frame.size.height)
        h = self.view.frame.size.height;
    if((htmlTextView.contentSize.height) > check-10)
    {
        h += keyboard + 70;
        int yoffset = htmlTextView.contentSize.height - oldOffset;
        
        CGPoint offset = contentView.contentOffset;
        offset.y += yoffset;
        [contentView setContentOffset:offset animated:YES];
    }
    contentView.contentSize = CGSizeMake(htmlTextView.contentSize.width, h);
    
    CGRect frame = htmlTextView.frame;
    frame.size.height = h;
    htmlTextView.frame = frame;
    
    oldOffset = htmlTextView.contentSize.height;
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
    [textView release];
    [contentView release];
    [super dealloc];
}

@end

