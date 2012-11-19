//
//  HTMLListViewController.m
//  GPLib
//
//  Created by Dalton Cherry on 3/22/12.
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

#import "HTMLListViewController.h"
#import "GPTableTextItem.h"
#import "GPTableHTMLItem.h"
#import "GPButton.h"
#import "HTMLColors.h"

@interface HTMLListViewController ()

@end

@implementation HTMLListViewController

@synthesize delegate = delegate;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        self.tableView.sections = [[NSMutableArray alloc] initWithCapacity:1];
        self.contentSizeForViewInPopover = CGSizeMake(320, 500);
        if(!GPIsPad())
        {
            CGRect frame =  self.view.frame;
            frame.size.height -= 230;
            self.view.frame = frame;
            frame =  self.tableView.frame;
            frame.size.height -= 190;
            self.tableView.frame = frame;
        }
    }
    return self;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(id)initWithColor:(UIColor*)color
{
    if(self = [super init])
    {
        self.title = @"Color";
        fontColor = [color retain];
    }
    return self;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(id)initWithSize:(NSInteger)size
{
    if(self = [super init])
    {
        self.title = @"Size";
        fontSize = size;
    }
    return self;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(id)initWithFont:(NSString*)fontName
{
    if(self = [super init])
    {
        FontName = [fontName retain];
        self.title = @"Fonts";
    }
    return self;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidLoad
{
    [super viewDidLoad];
    if(fontColor)
    {
        [self.tableView.sections addObject:@"Text Color"];
        NSArray* colors = [self colorChoices];
        [self.tableView.items addObject:colors];
        int i = 0;
        int index = 0;
        for(GPTableTextItem* item in colors)
        {
            if([item.color isEqual:fontColor])
            {
                index = i;
                break;
            }
            i++;
        }
        
        GPTableTextItem* item = (GPTableTextItem*)[colors objectAtIndex:index];
        item.isChecked = YES;
    }
    if(fontSize > 0)
    {
        self.tableView.sections = [NSMutableArray arrayWithObject:@"Text Size"];
        NSArray* sizeArray = [self sizeChoices];
        [self.tableView.items addObject:sizeArray];
        int i = 0;
        int index = 2;
        for(GPTableTextItem* item in sizeArray)
        {
            if(item.font.pointSize == fontSize)
            {
                index = i;
                break;
            }
            i++;
        }
        
        GPTableTextItem* item = (GPTableTextItem*)[sizeArray objectAtIndex:index];
        item.isChecked = YES;
    }
    else
    {
        self.tableView.sections = [NSMutableArray arrayWithObject:@"Fonts"];
        [self loadFonts];
    }
    self.tableView.checkMarks = YES;
    [self.tableView reloadData];
    self.tableView.emptyView.hidden = YES;
    self.tableView.backgroundColor = [UIColor underPageBackgroundColor];
	// Do any additional setup after loading the view.
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)loadFonts
{
    if(FontName)
    {
        NSLog(@"Font Name: %@",FontName);
        [self.tableView.items removeAllObjects];
        NSArray* fontArray = [[self fontChoices] retain];
        [self.tableView.items addObject:fontArray];
        int i = 0;
        int index = 2;
        for(GPTableTextItem* item in fontArray)
        {
            if([item.font.fontName isEqualToString:FontName])
            {
                index = i;
                break;
            }
            i++;
        }
        
        GPTableTextItem* item = (GPTableTextItem*)[fontArray objectAtIndex:index];
        item.isChecked = YES;
        [fontArray release];
    }
    [self.tableView reloadData];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)didSelectObject:(id)object atIndexPath:(NSIndexPath *)indexPath
{
    if([object isKindOfClass:[GPTableTextItem class]])
    {
        if([self.delegate respondsToSelector:@selector(didSelectItem:path:)])
            [self.delegate didSelectItem:object path:indexPath];
    }
    
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(NSArray*)colorChoices
{
    int size = 17;
    NSArray* temp = [NSArray arrayWithObjects: [GPTableTextItem itemWithText:@"Black" color:[UIColor blackColor] font:[UIFont systemFontOfSize:size] url:nil properties:[NSDictionary dictionaryWithObject:KEYWORD_HTML_COLOR forKey:@"type"] ],
                     [GPTableTextItem itemWithText:@"Red" color:[UIColor redColor] font:[UIFont systemFontOfSize:size] url:nil properties:[NSDictionary dictionaryWithObject:KEYWORD_HTML_COLOR forKey:@"type"]],
                     [GPTableTextItem itemWithText:@"Blue" color:[UIColor blueColor] font:[UIFont systemFontOfSize:size] url:nil properties:[NSDictionary dictionaryWithObject:KEYWORD_HTML_COLOR forKey:@"type"]],
                     [GPTableTextItem itemWithText:@"Green" color:[UIColor greenColor] font:[UIFont systemFontOfSize:size] url:nil properties:[NSDictionary dictionaryWithObject:KEYWORD_HTML_COLOR forKey:@"type"]],
                     [GPTableTextItem itemWithText:@"Orange" color:[UIColor orangeColor] font:[UIFont systemFontOfSize:size] url:nil properties:[NSDictionary dictionaryWithObject:KEYWORD_HTML_COLOR forKey:@"type"]],
                     [GPTableTextItem itemWithText:@"Purple" color:[UIColor purpleColor] font:[UIFont systemFontOfSize:size] url:nil properties:[NSDictionary dictionaryWithObject:KEYWORD_HTML_COLOR forKey:@"type"]],
                     [GPTableTextItem itemWithText:@"Gray" color:[UIColor grayColor] font:[UIFont systemFontOfSize:size] url:nil properties:[NSDictionary dictionaryWithObject:KEYWORD_HTML_COLOR forKey:@"type"]],
                     [GPTableTextItem itemWithText:@"Cyan" color:[UIColor cyanColor] font:[UIFont systemFontOfSize:size] url:nil properties:[NSDictionary dictionaryWithObject:KEYWORD_HTML_COLOR forKey:@"type"]],
                     [GPTableTextItem itemWithText:@"Magenta" color:[UIColor magentaColor] font:[UIFont systemFontOfSize:size] url:nil properties:[NSDictionary dictionaryWithObject:KEYWORD_HTML_COLOR forKey:@"type"]],
                     [GPTableTextItem itemWithText:@"Yellow" color:[UIColor yellowColor] font:[UIFont systemFontOfSize:size] url:nil properties:[NSDictionary dictionaryWithObject:KEYWORD_HTML_COLOR forKey:@"type"] ],nil ];
    return temp;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(NSArray*)sizeChoices
{
    NSArray* temp = [NSArray arrayWithObjects:[GPTableTextItem itemWithText:@"8pt" font:[UIFont systemFontOfSize:8] url:nil],
                     [GPTableTextItem itemWithText:@"10pt" font:[UIFont systemFontOfSize:10] url:nil properties:[NSDictionary dictionaryWithObject:KEYWORD_HTML_SIZE forKey:@"type"]],
                     [GPTableTextItem itemWithText:@"12pt" font:[UIFont systemFontOfSize:12] url:nil properties:[NSDictionary dictionaryWithObject:KEYWORD_HTML_SIZE forKey:@"type"]],
                     [GPTableTextItem itemWithText:@"14pt" font:[UIFont systemFontOfSize:14] url:nil properties:[NSDictionary dictionaryWithObject:KEYWORD_HTML_SIZE forKey:@"type"]],
                     [GPTableTextItem itemWithText:@"18pt" font:[UIFont systemFontOfSize:18] url:nil properties:[NSDictionary dictionaryWithObject:KEYWORD_HTML_SIZE forKey:@"type"]],
                     [GPTableTextItem itemWithText:@"24pt" font:[UIFont systemFontOfSize:24] url:nil properties:[NSDictionary dictionaryWithObject:KEYWORD_HTML_SIZE forKey:@"type"]],
                     [GPTableTextItem itemWithText:@"36pt" font:[UIFont systemFontOfSize:36] url:nil properties:[NSDictionary dictionaryWithObject:KEYWORD_HTML_SIZE forKey:@"type"]],nil];
    
    return temp;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(NSArray*)fontChoices
{
    NSArray* fontNames = [UIFont familyNames];
    [fontNames sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    NSMutableArray* fontItems = [NSMutableArray arrayWithCapacity:fontNames.count];
    for(NSString* font in fontNames)
    {
        if([self.delegate respondsToSelector:@selector(isAllowedFont:)])
        {
            if([self.delegate isAllowedFont:font])
                [fontItems addObject:[GPTableTextItem itemWithText:font font:[UIFont fontWithName:font size:17] url:nil properties:[NSDictionary dictionaryWithObject:KEYWORD_HTML_FONT forKey:@"type"]]];
        }
        else
            [fontItems addObject:[GPTableTextItem itemWithText:font font:[UIFont fontWithName:font size:17] url:nil properties:[NSDictionary dictionaryWithObject:KEYWORD_HTML_FONT forKey:@"type"]]];
    }
    return fontItems;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setDelegate:(id<HTMLListDelegate>)del
{
    delegate = del;
    [self loadFonts];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//subclass this to enable set to grouped style.
-(BOOL)grouped
{
    return YES;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(BOOL)checkMarks
{
    return YES;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)dealloc
{
    [fontColor release];
    [FontName release];
    [super dealloc];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@end
