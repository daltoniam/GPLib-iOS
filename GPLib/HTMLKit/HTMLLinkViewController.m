//
//  HTMLLinkViewController.m
//  GPLib
//
//  Created by Dalton Cherry on 3/19/12.
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

#import "HTMLLinkViewController.h"

@interface HTMLLinkViewController ()

@end

@implementation HTMLLinkViewController

@synthesize delegate = delegate;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        self.title = @"Anchor Link";
        self.navigationItem.rightBarButtonItem =[[[UIBarButtonItem alloc] initWithTitle: @"Create"
                                                                                  style: UIBarButtonItemStyleBordered
                                                                                 target: self
                                                                                 action:@selector(linkaccept)] autorelease];
        if(!GPIsPad())
            self.navigationItem.leftBarButtonItem =[[[UIBarButtonItem alloc] initWithTitle: @"Cancel"
                                                                                 style: UIBarButtonItemStyleBordered
                                                                                target: self
                                                                                action:@selector(linkcancel)] autorelease];
    }
    return self;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(id)initWithText:(NSString*)text link:(NSString*)link
{
    if(self = [super init])
    {
        textHolder = [text retain];
        linkHolder = [link retain];
    }
    return self;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.contentSizeForViewInPopover = CGSizeMake(300,400);
	if(GPIsPad())
        self.view.backgroundColor = [UIColor underPageBackgroundColor]; //scrollViewTexturedBackgroundColor
    else
        self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    sections = [[NSMutableArray alloc] initWithObjects:@"Link", nil];
    
    UITextField* linkfield = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 0, 44)];
    linkfield.delegate = self;
    linkfield.enabled = NO;
    linkfield.placeholder = textHolder;
    
    textfield = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 0, 44)];
    textfield.delegate = self;
    textfield.placeholder = @"http://";
    textfield.text = linkHolder;
    textfield.textColor = [UIColor colorWithRed:0 green:82/255.0f blue:204/255.0f alpha:1];
    textfield.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textfield.autocorrectionType = UITextAutocorrectionTypeNo;
    textfield.keyboardType = UIKeyboardTypeURL;
    textfield.enablesReturnKeyAutomatically = YES;
    textfield.clearButtonMode = UITextFieldViewModeWhileEditing;
    [textfield becomeFirstResponder];
    [items addObject:[NSArray arrayWithObjects:linkfield,textfield, nil]];
    [linkfield release];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)linkaccept
{
    NSString* text = textfield.text;
    if([text rangeOfString:@"://"].location == NSNotFound && text.length != 0)
        text = [NSString stringWithFormat:@"http://%@",text];
    if([self.delegate respondsToSelector:@selector(didCreate:)])
        [self.delegate didCreate:text];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)linkcancel
{
    if([self.delegate respondsToSelector:@selector(didCancel)])
        [self.delegate didCancel];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if(GPIsPad())
        return YES;
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(BOOL)grouped
{
    return YES;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)dealloc
{
    [textfield release];
    [super dealloc];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@end
