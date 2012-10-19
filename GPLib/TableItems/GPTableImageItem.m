//
//  GPTableImageItem.m
//  GPLib
//
//  Created by Dalton Cherry on 12/7/11.
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

#import "GPTableImageItem.h"

@implementation GPTableImageItem

@synthesize ImageURL,DefaultImage,imageData,imageSize,imageRounding,contentMode,topJustifyImage,imageBorderColor,imageBorderWidth;

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+ (GPTableImageItem*)itemWithText:(NSString*)text url:(NSString*)url
{
    GPTableImageItem* item = [[[GPTableImageItem alloc] init] autorelease];
    item.text = text;
    item.NavURL = url;
    return item;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+ (GPTableImageItem*)itemWithImage:(NSString*)imageurl text:(NSString*)string
{
    return [self itemWithImage:imageurl text:string font:nil color:[UIColor blackColor] DefaultImage:nil url:nil];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+ (GPTableImageItem*)itemWithImage:(NSString*)imageurl text:(NSString*)string URL:(NSString*)url
{
    return [self itemWithImage:imageurl text:string font:nil color:[UIColor blackColor] DefaultImage:nil properties:nil url:url];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+ (GPTableImageItem*)itemWithImage:(NSString*)imageurl text:(NSString*)string properties:(NSDictionary*)props url:(NSString*)url
{
    return [self itemWithImage:imageurl text:string font:nil color:[UIColor blackColor] DefaultImage:nil properties:props url:nil];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+ (GPTableImageItem*)itemWithImage:(NSString*)imageurl text:(NSString*)string DefaultImage:(UIImage*)image
{
    return [self itemWithImage:imageurl text:string font:nil color:[UIColor blackColor] DefaultImage:image url:nil];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+ (GPTableImageItem*)itemWithImage:(NSString*)imageurl text:(NSString*)string DefaultImage:(UIImage*)image properties:(NSDictionary*)props url:(NSString*)url
{
    return [self itemWithImage:imageurl text:string font:nil color:[UIColor blackColor] DefaultImage:image properties:props url:url];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+ (GPTableImageItem*)itemWithImage:(NSString*)imageurl text:(NSString*)string url:(NSString*)url
{
    return [self itemWithImage:imageurl text:string font:nil color:[UIColor blackColor] DefaultImage:nil url:url];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+ (GPTableImageItem*)itemWithImage:(NSString*)imageurl text:(NSString*)string color:(UIColor*)textcolor
{
    return [self itemWithImage:imageurl text:string font:nil color:textcolor DefaultImage:nil url:nil];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+ (GPTableImageItem*)itemWithImage:(NSString*)imageurl text:(NSString*)string color:(UIColor*)textcolor url:(NSString*)url
{
    return [self itemWithImage:imageurl text:string font:nil color:textcolor DefaultImage:nil url:url];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+ (GPTableImageItem*)itemWithImage:(NSString*)imageurl text:(NSString*)string font:(UIFont*)font url:(NSString*)url
{
    return [self itemWithImage:imageurl text:string font:font color:[UIColor blackColor] DefaultImage:nil url:url];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+ (GPTableImageItem*)itemWithImage:(NSString*)imageurl text:(NSString*)string font:(UIFont*)font color:(UIColor*)textcolor 
                      DefaultImage:(UIImage*)image url:(NSString*)url
{
    return [self itemWithImage:imageurl text:string font:font color:textcolor DefaultImage:image properties:nil url:url];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+ (GPTableImageItem*)itemWithImage:(NSString*)imageurl text:(NSString*)string font:(UIFont*)font color:(UIColor*)textcolor 
                      DefaultImage:(UIImage*)image properties:(NSDictionary*)props url:(NSString*)url
{
    GPTableImageItem* item = [[[GPTableImageItem alloc] init] autorelease];
    item.text = string;
    item.font = font;
    item.color = textcolor;
    item.ImageURL = imageurl;
    item.TextAlignment = UITextAlignmentLeft;
    item.NavURL = url;
    item.DefaultImage = image;
    item.Properties = props;
    //NSLog(@"url: %@",url);
    return item;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+ (GPTableImageItem*)itemWithImageData:(UIImage*)imageData text:(NSString*)string URL:(NSString*)url size:(CGSize)size round:(NSInteger)rounding
{
    GPTableImageItem* item = [[[GPTableImageItem alloc] init] autorelease];
    item.text = string;
    item.imageData = imageData;
    item.TextAlignment = UITextAlignmentLeft;
    item.NavURL = url;
    item.imageSize = size;
    item.imageRounding = rounding;
    return item;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(NSManagedObject*)saveItemToDisk:(NSManagedObjectContext*)ctx entityName:(NSString *)entityName
{
    GPTableItem* item = (GPTableItem*)[super saveItemToDisk:ctx entityName:entityName];
    item.imageData = UIImagePNGRepresentation(self.imageData);
    item.imageURL = self.ImageURL;
    return item;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+(id)restoreItemFromDisk:(NSManagedObject*)object
{
    if([object isKindOfClass:[GPTableItem class]])
    {
        GPTableItem* objectItem = (GPTableItem*)object;
        GPTableImageItem* item = [GPTableImageItem itemWithImage:objectItem.imageURL text:objectItem.text];
        item.NavURL = objectItem.navURL;
        item.imageData = [UIImage imageWithData:objectItem.imageData];
        return item;
    }
    return nil;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@end
