//
//  GPGridViewItem.m
//  GPLib
//
//  Created by Dalton Cherry on 4/11/12.
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

#import "GPGridViewItem.h"

@implementation GPGridViewItem

@synthesize text, image,NavURL,Properties,imageURL,color,font,isSelected,drawDropShadow,infoText,isLoading;
/////////////////////////////////////////////////////////////////////////////////////////
+(GPGridViewItem*)itemWithImage:(UIImage*)image text:(NSString*)text
{
    return [GPGridViewItem itemWithImage:image text:text url:nil];
}
/////////////////////////////////////////////////////////////////////////////////////////
+(GPGridViewItem*)itemWithImage:(UIImage*)image text:(NSString*)text url:(NSString *)url
{
    return [GPGridViewItem itemWithImage:image text:text url:url properties:nil];
}
/////////////////////////////////////////////////////////////////////////////////////////
+(GPGridViewItem*)itemWithImage:(UIImage*)image text:(NSString*)text url:(NSString*)url properties:(NSDictionary*)props
{
    GPGridViewItem* item = [[[GPGridViewItem alloc] init] autorelease];
    item.text = text;
    item.image = image;
    item.NavURL = url;
    item.Properties = props;
    return item;
}
/////////////////////////////////////////////////////////////////////////////////////////
+(GPGridViewItem*)itemWithImageURL:(NSString*)imageURL text:(NSString*)text
{
    return [GPGridViewItem itemWithImageURL:imageURL text:text url:nil];
}
/////////////////////////////////////////////////////////////////////////////////////////
+(GPGridViewItem*)itemWithImageURL:(NSString*)imageURL text:(NSString*)text url:(NSString *)url
{
    return [GPGridViewItem itemWithImageURL:imageURL text:text url:url properties:nil];
}
/////////////////////////////////////////////////////////////////////////////////////////
+(GPGridViewItem*)itemWithImageURL:(NSString*)imageURL text:(NSString*)text url:(NSString*)url properties:(NSDictionary*)props
{
    GPGridViewItem* item = [[[GPGridViewItem alloc] init] autorelease];
    item.text = text;
    item.imageURL = imageURL;
    item.NavURL = url;
    item.Properties = props;
    return item;
}
/////////////////////////////////////////////////////////////////////////////////////////

@end
