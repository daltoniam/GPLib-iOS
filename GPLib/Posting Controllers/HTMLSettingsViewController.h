//
//  HTMLSettingsViewController.h
//  GPLib
//
//  Created by Dalton Cherry on 3/21/12.
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

#import <UIKit/UIKit.h>
#import "GPTableViewController.h"
#import "HTMLText.h"
#import "HTMLListViewController.h"
#import "GPTableTextItem.h"
#import "GPTableHTMLItem.h"
#import "GPTableSegmentItem.h"
#import "HTMLColors.h"

//disable/hide list options
#define HTML_SETTINGS_PARA_STYLE @"parastyle" //remove the whole parastyle section
#define HTML_SETTINGS_TEXT_STYLE @"textstyle" //remove the textstyle area

#define HTML_SETTINGS_STRIKE_THROUGH @"strike" //remove strike
#define HTML_SETTINGS_BOLD @"bold" //remove bold
#define HTML_SETTINGS_ITALIC @"italic" //remove italic
#define HTML_SETTINGS_UNDERLINE @"under" //remove

#define HTML_SETTINGS_FONTS @"font" //remove the font
#define HTML_SETTINGS_TEXT_COLOR @"textcolor" //remove the textcolor
#define HTML_SETTINGS_TEXT_SIZE @"textsize" //remove the textcolor

#define HTML_SETTINGS_LINKS @"links" //remove the links section

#define HTML_SETTINGS_LEFT_JUSTIFY @"leftjust" //remove the left justify option
#define HTML_SETTINGS_CENTER_JUSTIFY @"centerjust" //remove the center justify option
#define HTML_SETTINGS_RIGHT_JUSTIFY @"rightjust" //remove the right justify option
#define HTML_SETTINGS_JUSTIFY_JUSTIFY @"justjust" //remove the justify justify option

#define HTML_SETTINGS_ORDER @"orderlist"
#define HTML_SETTINGS_UNORDER @"unorderlist"

@protocol HTMLSettingsDelegate <NSObject>

@optional

//iphone dimissed view
-(void)viewWasDimissed;
//should we show the enable hyperlink menu
-(BOOL)isHyperLinkReady;
//basically a forward for did select object.
-(void)didSelectItem:(id)object path:(NSIndexPath*)indexPath;
//bold was selected
-(void)updateBold:(BOOL)isBold;
//italic was selected
-(void)updateItalic:(BOOL)isItalic;
//underline was selected
-(void)updateUnderLine:(BOOL)isUnderLine;
//strike was selected
-(void)updateStrike:(BOOL)isStrike;
//align was updated
-(void)updateAlignment:(NSInteger)align;
//list was enabled
-(void)updateList:(NSInteger)listType;
//set the disable list
-(NSDictionary*)disableList;

//forwards from HTML List View
-(BOOL)isAllowedFont:(NSString*)fontName;

@end

@interface HTMLSettingsViewController : GPTableViewController<HTMLListDelegate>
{
    NSInteger currentIndex;
    UISegmentedControl* SegControl;
    id<HTMLSettingsDelegate>delegate;
    NSDictionary* Settings;
    GPTableTextItem* ColorItem;
    GPTableTextItem* textSizeItem;
    GPTableTextItem* fontItem;
    NSDictionary* disableSettings;
}
@property(nonatomic,assign)id<HTMLSettingsDelegate>delegate;

-(void)setToDefault:(NSDictionary*)query;
-(id)initWithExtras:(NSDictionary*)query;

-(void)setoptionsAtIndex:(int)index;
-(void)setupContentMenu;
@end
