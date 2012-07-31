//
//  GPTableSegmentItem.m
//  test
//
//  Created by Dalton Cherry on 7/30/12.
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

#import "GPTableSegmentItem.h"

@implementation GPTableSegmentItem

@synthesize segments,startColor,endColor,isMultiSelect,font,textColor,segType,selectedIndex,target;

//////////////////////////////////////////////////////////////////////////////////////////////////
+(GPTableSegmentItem*)itemWithSegments:(NSArray*)array
{
    return [GPTableSegmentItem itemWithSegments:array type:GPTableSegmentAuto];
}
//////////////////////////////////////////////////////////////////////////////////////////////////
+(GPTableSegmentItem*)itemWithSegments:(NSArray*)array type:(GPTableSegmentType)type
{
    GPTableSegmentItem* item = [[[GPTableSegmentItem alloc] init] autorelease];
    item.segments = array;
    item.segType = type;
    return item;
}
//////////////////////////////////////////////////////////////////////////////////////////////////

@end

@implementation GPTableSegmentItemProps

@synthesize isSelected,buttonTap,title,image;
//////////////////////////////////////////////////////////////////////////////////////////////////
+(GPTableSegmentItemProps*)segmentWithTitle:(NSString*)title selector:(SEL)sel isSelected:(BOOL)selected
{
    GPTableSegmentItemProps* props = [[[GPTableSegmentItemProps alloc] init] autorelease];
    props.title = title;
    props.buttonTap = sel;
    props.isSelected = selected;
    return props;
}
//////////////////////////////////////////////////////////////////////////////////////////////////
+(GPTableSegmentItemProps*)segmentWithImage:(UIImage*)image selector:(SEL)sel isSelected:(BOOL)selected
{
    GPTableSegmentItemProps* props = [[[GPTableSegmentItemProps alloc] init] autorelease];
    props.image = image;
    props.buttonTap = sel;
    props.isSelected = selected;
    return props;
}
//////////////////////////////////////////////////////////////////////////////////////////////////

@end
