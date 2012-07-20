//
//  GPMessagePostViewController.m
//  GPLib
//
//  Created by Dalton Cherry on 1/31/12.
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

#import "GPMessagePostViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "GPTableTextItem.h"

@implementation GPMessagePostViewController

@synthesize shouldShowPicker = shouldShowPicker,delegate = delegate;
///////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        self.title = @"Post";
        self.navigationItem.rightBarButtonItem =[[[UIBarButtonItem alloc] initWithTitle: @"Post"
                                                                                  style: UIBarButtonItemStyleBordered
                                                                                 target: self
                                                                                 action:@selector(postText)] autorelease];
        self.navigationItem.leftBarButtonItem =[[[UIBarButtonItem alloc] initWithTitle: @"Cancel"
                                                                                 style: UIBarButtonItemStyleBordered
                                                                                target: self
                                                                                action:@selector(cancelText)] autorelease];
        searchItems = [[NSMutableArray alloc] init];
        shouldShowPicker = YES;
        [model loadModel:NO];
    }
    return self;
}
///////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidLoad
{
    [super viewDidLoad];
    [ActLabel removeFromSuperview];
    self.view.backgroundColor = [UIColor whiteColor];
    int left = 0;
    int top = 0;
    ScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    ScrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
    
    int width = self.view.frame.size.width;
    
    Field =[[GPReceiptField alloc] initWithFrame:CGRectMake(left, top, width, 40)];
    Field.shouldShowPicker = shouldShowPicker;
    Field.delegate = self;
    Field.numberOfLines = 0;
    [ScrollView addSubview:Field];
    top += Field.frame.size.height;
    LineView = [[UIView alloc] initWithFrame:CGRectMake(left, top, self.view.frame.size.width, 1)];
    LineView.backgroundColor = [UIColor lightGrayColor];
    [ScrollView addSubview:LineView];
    top += LineView.frame.size.height;
    textView = [[UITextView alloc] initWithFrame:CGRectMake(left, top, self.view.frame.size.width, self.view.frame.size.height-top)];
    textView.delegate = self;
    textView.font = [UIFont systemFontOfSize:14];
    textView.scrollEnabled = NO;
    textView.contentInset = UIEdgeInsetsMake(2, 2, 2, 2);
    [ScrollView addSubview:textView];
    [self.view addSubview:ScrollView];
    
    [_tableView removeFromSuperview];
    [ScrollView addSubview:_tableView];
    [ScrollView bringSubviewToFront:_tableView];
    [ScrollView bringSubviewToFront:Field];
    
    _tableView.hidden = YES;
    _tableView.frame = textView.frame;
    CGRect frame = _tableView.frame;
    frame.size.height -= 30;
    _tableView.frame = frame;
    Field.layer.shadowOpacity = 0.2;
    Field.layer.shadowRadius = 1.0;
    Field.layer.shouldRasterize = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardDidShowNotification //UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
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
    
    // Animate up or down
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    //[UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    CGRect newFrame = _tableView.frame;
    CGRect keyboardFrame = [self.view convertRect:keyboardEndFrame toView:nil];
    if (up) 
        newFrame.size.height -= keyboardFrame.size.height+10;
    else 
        newFrame.size.height += keyboardFrame.size.height+10;
    _tableView.frame = newFrame;
    
    [UIView commitAnimations];
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)keyboardWillShow:(NSNotification *)aNotification {
    [self moveTextViewForKeyboard:aNotification up:YES];
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)keyboardWillHide:(NSNotification *)aNotification {
    [self moveTextViewForKeyboard:aNotification up:NO]; 
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//posting
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)postText
{
    if(!isPosting)
    {
        if([delegate respondsToSelector:@selector(textDidPost:users:)])
            [delegate textDidPost:textView.text users:Field.Bubbles];
    }
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)cancelText
{
    if(!isPosting)
    {
        if(![textView.text isEqualToString:@""])
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

///////////////////////////////////////////////////////////////////////////////////////////////////////
//GPReceiptField Delegate
///////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didChange:(UITextField *)textField CharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if([self shouldAddItemInline:textField CharactersInRange:range replacementString:string])
    {
        //[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [Field addItem:[textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] ];
        [self showTableView:NO];
        [searchItems removeAllObjects];
    }
    if(textField.text.length > 1)
    {
        [self showTableView:YES];
        [self searchTable:[textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    }
    else
    {
        [self showTableView:NO];
        [searchItems removeAllObjects];
    }
}
///////////////////////////////////////////////////////////////////////////////////////////////////////
//update the lineView that it needs to with the Field view
- (void)heightDidChange:(int)height
{
    CGRect frame = LineView.frame;
    frame.origin.y = height;
    LineView.frame = frame;
    
    /*int offset = frame.origin.y+1;
    
    frame = textView.frame;
    int top = offset - (frame.origin.y);
    frame.origin.y = offset; 
    frame.size.height = frame.size.height - top;
    textView.frame = frame;*/
    
    int offset = frame.origin.y+1;
    frame = textView.frame;
    int top = offset - (frame.origin.y);
    frame.origin.y = offset; 
    textView.frame = frame;
    _tableView.frame = frame;
    CGSize size = ScrollView.contentSize;
    size.height += top;
    ScrollView.contentSize = size;
    
}
///////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)textViewDidChange:(UITextView *)view 
{    
    /*CGFloat fontHeight = (view.font.ascender - view.font.descender) + 1;
    CGRect newTextFrame = view.frame;
    newTextFrame.size = view.contentSize;
    newTextFrame.size.height = newTextFrame.size.height + fontHeight;
    
    CGSize size = ScrollView.contentSize;
    size.height += newTextFrame.size.height - view.frame.size.height;
    ScrollView.contentSize = size;
    
    view.frame = newTextFrame;*/
    CGFloat fontHeight = (view.font.ascender - view.font.descender) + 1;
    int pad = 15;
    CGSize size = ScrollView.contentSize;
    size.height = view.contentSize.height+view.frame.origin.y+view.frame.size.height+fontHeight+pad;
    ScrollView.contentSize = size;
}
///////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)textFieldWillDismiss:(UITextField*)textField
{
    if(![textField.text isEqualToString:@" "] && ![textField.text isEqualToString:@""])
    {
        [Field addItem:[textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] ];
    }
}
///////////////////////////////////////////////////////////////////////////////////////////////////////
//I expect the subclass to handle this by opening a view picker modally (or popover if iPad). The picker 
//view will then need a delegate that notifies that an item has been selected and dismiss the view. Standard iOS
//view navigation.
- (void)showPicker
{
    //open a picker here (E.G.)
    //[[GPNavigator navigator] openURL:@"tt://contactpicker" NavType:GPNavTypeModal];
}
///////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)showTableView:(BOOL)show
{
    if(show)
        Field.layer.shadowOffset = CGSizeMake(0, 5);
    else
        Field.layer.shadowOffset = CGSizeMake(0, 0);
    
    _tableView.hidden = !show;
    ScrollView.scrollEnabled = !show;
}
///////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)searchTable:(NSString*)text
{
    [searchItems removeAllObjects];
    for(id item in items)
    {
        if([self filterItems:item text:text])
            [searchItems addObject:item];
    }
    [_tableView reloadData];
    if(searchItems.count == 0)
        [self showTableView:NO];
}
///////////////////////////////////////////////////////////////////////////////////////////////////////
//I am making this just hide the tableview so subclass can call super without it running normally navigation logic.
-(void)didSelectObject:(id)object atIndexPath:(NSIndexPath *)indexPath
{
    [self showTableView:NO];
    [searchItems removeAllObjects];
}
///////////////////////////////////////////////////////////////////////////////////////////////////////
-(UIColor*)tableBackground
{
    return [UIColor colorWithWhite:0.95 alpha:0.7];
}
///////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return [searchItems count];
    //return [super tableView:tableView numberOfRowsInSection:section];
}
///////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)tableView:(UITableView*)tableView objectForRowAtIndexPath:(NSIndexPath*)indexPath 
{
    if(indexPath.row < searchItems.count)
        return [searchItems objectAtIndex:indexPath.row];
    return nil;
    //return [super tableView:tableView objectForRowAtIndexPath:indexPath];
}
///////////////////////////////////////////////////////////////////////////////////////////////////////
//sub class
///////////////////////////////////////////////////////////////////////////////////////////////////////
//return true if to add the item to the possible selection. this can be subclass.
-(BOOL)filterItems:(id)object text:(NSString*)text
{
    GPTableTextItem* item = (GPTableTextItem*)object;
    if([[item.text lowercaseString] hasPrefix:[text lowercaseString]])
        return YES;
    return NO;
}
///////////////////////////////////////////////////////////////////////////////////////////////////////
//return true if to add the item from the text that has been typed. By default it will add on a return key.
-(BOOL)shouldAddItemInline:(UITextField *)textField CharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if([string isEqualToString:@"\n"] && ![[string lowercaseString] isEqualToString:[textField.text lowercaseString]])
        return YES;
    return NO;
}
///////////////////////////////////////////////////////////////////////////////////////////////////////
//make empty stub
-(void)showEmptyView
{
}
///////////////////////////////////////////////////////////////////////////////////////////////////////
//make empty, so does not show
-(UIView*)defaultEmptyView
{
    return nil;
}
///////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)dealloc
{
    [Field release];
    [LineView release];
    [textView release];
    [ScrollView release];
    [searchItems release];
    [super dealloc];
}
///////////////////////////////////////////////////////////////////////////////////////////////////////
@end
