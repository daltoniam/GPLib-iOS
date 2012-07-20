//
//  GPTableTextFieldCell.m
//  GPLib
//
//  Created by Dalton Cherry on 4/19/12.
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

#import "GPTableTextFieldCell.h"

@implementation GPTableTextFieldCell

@synthesize textField = textField;
///////////////////////////////////////////////////////////////////////////////////////////////////
+ (CGFloat)tableView:(UITableView*)tableView rowHeightForObject:(id)object 
{
    float height = 44;
    if([object isKindOfClass:[GPTableTextFieldItem class]])
    {
        GPTableTextFieldItem* item = object;
        if(item.height > 44)
            height = item.height;
    }
    else if([object isKindOfClass:[UIView class]])
    {
        UIView* view = object;
        if(view.frame.size.height > 44)
            height = view.frame.size.height;
    }
    return height;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) 
    {
        textField = [[UITextField alloc] init];
        textField.delegate = self;
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [self.contentView addSubview:textField];
    }
    return self;
}
//////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setObject:(id)object 
{
    if([object isKindOfClass:[GPTableTextFieldItem class]])
    {
        GPTableTextFieldItem* item = object;
        currentObject = item;
        textField.text = item.text;
        textField.placeholder = item.placeHolder;
        textField.secureTextEntry = item.isSecure;
        if(item.keyboardType)
            textField.keyboardType = item.keyboardType;
        textField.autocapitalizationType = item.autoCap;
        textField.returnKeyType = item.returnKey;
        textField.enabled = !item.disabled;
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if([string isEqualToString:@"\n"])
        [self returnKeyTapped];
    else
        [self performSelector:@selector(updateObjectText) withObject:nil afterDelay:0.1];
    return YES;
}
//////////////////////////////////////////////////////////////////////////////////////////////////
-(void)updateObjectText
{
    currentObject.text = textField.text;
    if([currentObject.delegate respondsToSelector:@selector(textDidUpdate:object:cell:)])
        [currentObject.delegate textDidUpdate:textField.text object:currentObject cell:self];
}
//////////////////////////////////////////////////////////////////////////////////////////////////
//move on or dismiss the keyboard
-(void)returnKeyTapped
{
    if([currentObject.delegate respondsToSelector:@selector(returnKeyWasTapped:object:cell:)])
        [currentObject.delegate returnKeyWasTapped:textField object:currentObject cell:self];
}
//////////////////////////////////////////////////////////////////////////////////////////////////
-(void)layoutSubviews
{
    [super layoutSubviews];

    textField.frame = CGRectMake(TableCellSmallMargin, TableCellSmallMargin, 
                                self.contentView.bounds.size.width-TableCellSmallMargin*2, self.contentView.bounds.size.height-TableCellSmallMargin*2);
    textField.backgroundColor = [UIColor clearColor];
}
//////////////////////////////////////////////////////////////////////////////////////////////////
-(void)dealloc
{
    [textField release];
    [super dealloc];
}
//////////////////////////////////////////////////////////////////////////////////////////////////

@end
