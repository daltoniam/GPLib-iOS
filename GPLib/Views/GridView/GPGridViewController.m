//
//  GPGridViewController.m
//  GPLib
//
//  Created by Dalton Cherry on 10/31/12.
//  Copyright (c) 2012 Lightspeed Systems. All rights reserved.
//

#import "GPGridViewController.h"
#import "GPNavigator.h"
#import "GPGridViewItem.h"

@interface GPGridViewController ()

@end

@implementation GPGridViewController

@synthesize gridView,model;

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
	gridView = [[GPGridView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    gridView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    gridView.delegate = self;
    [self.view addSubview:gridView];
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
        loadingLabel.frame = gridView.frame;
        [self.view addSubview:loadingLabel];
    }
    loadingLabel.text = [self loadingText];
    loadingLabel.hidden = NO;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)modelShouldLoad
{
    if(!self.model.isLoading)
        [self.model fetchFromNetwork];
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
        if([object isKindOfClass:[GPGridViewItem class]])
        {
            GPGridViewItem* item = (GPGridViewItem*)object;
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
    gridView.delegate = nil;
    [gridView release];
    [super dealloc];
}
///////////////////////////////////////////////////////////////////////////////////////////////////

@end
