//
//  GPTableMessageItem.m
//  GPLib
//
//  Created by Dalton Cherry on 12/22/11.
//  Copyright (c) 2011 Basement Crew/180 Dev Designs. All rights reserved.
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

#import "GPTableMessageItem.h"

@implementation GPTableMessageItem

@synthesize rowHeight,cachedFramesetter,cachedAttribString;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+ (GPTableMessageItem*)itemWithHTML:(NSString*)htmlstring imageURL:(NSString*)imageurl
{
    GPTableMessageItem* item = [[[GPTableMessageItem alloc] init] autorelease];
    item.text = htmlstring;
    item.imageURL = imageurl;
    item.topJustifyImage = YES;
    return item;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+ (GPTableMessageItem*)itemWithHTML:(NSString*)htmlstring imageURL:(NSString*)imageurl URL:(NSString*)url
{
    GPTableMessageItem* item = [[[GPTableMessageItem alloc] init] autorelease];
    item.text = htmlstring;
    item.imageURL = imageurl;
    item.navURL = url;
    item.topJustifyImage = YES;
    return item;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+ (GPTableMessageItem*)itemWithHTML:(NSString*)htmlstring imageURL:(NSString*)imageurl URL:(NSString*)url Properties:(NSDictionary*)data
{
    GPTableMessageItem* item = [[[GPTableMessageItem alloc] init] autorelease];
    item.text = htmlstring;
    item.navURL = url;
    item.imageURL = imageurl;
    item.properties = data;
    item.topJustifyImage = YES;
    return item;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSComparisonResult)compare:(GPTableMessageItem*)otherObject 
{
    if([self.text isEqualToString:otherObject.text])
        return NSOrderedSame;
    return [[self.text stringByStrippingHTML] compare:[otherObject.text stringByStrippingHTML]];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@end
