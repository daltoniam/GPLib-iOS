//
//  GPTableTextViewCell.m
//  GPLib
//
//  Created by Dalton Cherry on 7/27/12.
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

#import "GPTableTextViewCell.h"

@implementation GPTableTextViewCell

@synthesize textView = textView;
///////////////////////////////////////////////////////////////////////////////////////////////////
+ (CGFloat)tableView:(UITableView*)tableView rowHeightForObject:(id)object 
{
    float height = 44;
    if([object isKindOfClass:[GPTableTextViewItem class]])
    {
        GPTableTextViewItem* item = object;
        if(item.height > 44)
            height = item.height;
    }
    return height;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) 
    {
        textView = [[UITextView alloc] init];
        textView.delegate = self;
        [self.contentView addSubview:textView];
    }
    return self;
}
//////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setObject:(id)object 
{
    if([object isKindOfClass:[GPTableTextViewItem class]])
    {
        GPTableTextViewItem* item = object;
        currentObject = item;
        textView.text = item.text;
        textView.secureTextEntry = item.isSecure;
        textView.autocapitalizationType = item.autoCap;
        textView.returnKeyType = item.returnKey;
        textView.editable = !item.disabled;
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"])
        [self returnKeyTapped];
    else
        [self performSelector:@selector(updateObjectText) withObject:nil afterDelay:0.1];
    return YES;
}
//////////////////////////////////////////////////////////////////////////////////////////////////
-(void)updateObjectText
{
    currentObject.text = textView.text;
    if([currentObject.delegate respondsToSelector:@selector(textViewTextDidUpdate:object:cell:)])
        [currentObject.delegate textViewTextDidUpdate:textView.text object:currentObject cell:self];
}
//////////////////////////////////////////////////////////////////////////////////////////////////
//move on or dismiss the keyboard
-(void)returnKeyTapped
{
    if([currentObject.delegate respondsToSelector:@selector(returnKeyTapped:object:cell:)])
        [currentObject.delegate returnKeyTapped:textView object:currentObject cell:self];
}
//////////////////////////////////////////////////////////////////////////////////////////////////
-(void)layoutSubviews
{
    [super layoutSubviews];
    
    textView.frame = CGRectMake(TableCellSmallMargin, TableCellSmallMargin, 
                                 self.contentView.bounds.size.width-TableCellSmallMargin*2, self.contentView.bounds.size.height-TableCellSmallMargin*2);
    textView.backgroundColor = [UIColor clearColor];
}
//////////////////////////////////////////////////////////////////////////////////////////////////
-(void)dealloc
{
    [textView release];
    [super dealloc];
}
//////////////////////////////////////////////////////////////////////////////////////////////////

@end
