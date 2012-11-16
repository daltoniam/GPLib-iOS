//
//  GPTableViewController.m
//  GPLib
//
//  Created by Dalton Cherry on 10/18/12.
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

#import "GPTableViewController.h"
#import "GPTableTextItem.h"
#import "GPNavigator.h"

@interface GPTableViewController ()

@end

@implementation GPTableViewController

@synthesize tableView = tableView,model = model;
///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        model = [[self setupModel] retain];
        model.delegate = self;
    }
    return self;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidLoad
{
    [super viewDidLoad];
	tableView = [[GPTableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) isGrouped:[self grouped]];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tableView.delegate = self;
    [self.view addSubview:tableView];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)showLoadingLabel
{
    [self showLoadingLabel:GPLoadingLabelWhiteStyle];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)showLoadingLabel:(GPLoadingLabelStyle)style
{
    if(!loadingLabel)
    {
        loadingLabel = [[GPLoadingLabel alloc] initWithStyle:style];
        loadingLabel.frame = tableView.frame;
        loadingLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.view addSubview:loadingLabel];
    }
    loadingLabel.text = [self loadingText];
    loadingLabel.hidden = NO;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)modelShouldLoad:(BOOL)dragRefresh
{
    if(!self.model.isLoading)
    {
        if(dragRefresh)
            self.model.page = 1;
        [self.model fetchFromNetwork];
    }
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//subclass stuff
///////////////////////////////////////////////////////////////////////////////////////////////////
//using gpnavigator to navigate. Does nothing if GPNavigator is not used and will have to override
//to provide navigation
- (void)didSelectObject:(id)object atIndexPath:(NSIndexPath*)indexPath
{
    if ([object respondsToSelector:@selector(NavURL)])
    {
        NSString* URL = [object NavURL];
        if([object isKindOfClass:[GPTableTextItem class]])
        {
            GPTableTextItem* item = (GPTableTextItem*)object;
            NSString* theURL = item.NavURL;
            if (theURL)
            {
                if(item.Properties)
                    [[GPNavigator navigator] openURL:theURL NavType:GPNavTypeNormal query:item.Properties];
                else
                    [[GPNavigator navigator] openURL:URL];
            }
        }
        else if (URL)
            [[GPNavigator navigator] openURL:URL];
    }
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(GPModel*)setupModel
{
    return nil;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(BOOL)grouped
{
    return NO;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(NSString*)loadingText
{
    return NSLocalizedString(@"Loading...", nil);
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)dealloc
{
    [loadingLabel release];
    model.delegate = nil;
    [model release];
    tableView.delegate = nil;
    [tableView release];
    [super dealloc];
}
///////////////////////////////////////////////////////////////////////////////////////////////////

@end
