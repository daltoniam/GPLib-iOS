//
//  GPTableMoreCell.m
//  GPLib
//
//  Created by Dalton Cherry on 2/3/12.
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

#import "GPTableMoreCell.h"
#import "GPTableMoreItem.h"

@implementation GPTableMoreCell


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        ActivityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.contentView addSubview:ActivityView];
    }
    return self;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)layoutSubviews
{
    if(isAuto)
    {
         CGRect frame = self.bounds;
        //ActivityView.frame = CGRectMake(TableCellSmallMargin, TableCellSmallMargin, 24, 24);
        ActivityView.frame = CGRectMake(frame.size.width/2 - 24, TableCellSmallMargin, 24, 24);
        //ActivityView.frame = CGRectMake(0, 0, 24, 24);
        //ActivityView.center = self.contentView.center;
    }
    else
    {
        [super layoutSubviews];
        ActivityView.frame = CGRectMake(TableCellSmallMargin, TableCellSmallMargin, 24, 24);
        CGRect frame = self.textLabel.frame;
        frame.origin.x += TableCellSmallMargin + 24;
        frame.size.width -= TableCellSmallMargin + 24;
        self.textLabel.frame = frame;
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setObject:(id)object 
{
    [super setObject:object];
    [self setSelectionStyle:UITableViewCellSelectionStyleBlue];
    GPTableMoreItem* item = object;
    isAuto = item.isAutoLoad;
    [self setAnimating:item.isLoading];
        
}
//////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setAnimating:(BOOL)swap
{
    if(swap)
        [ActivityView startAnimating];
    else
        [ActivityView stopAnimating];
}
//////////////////////////////////////////////////////////////////////////////////////////////////
-(void)dealloc
{
    [ActivityView release];
    [super dealloc];
}

@end
