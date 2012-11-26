//
//  GPTableTextItem.m
//  GPLib
//
//  Created by Dalton Cherry on 12/6/11.
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

#import "GPTableTextItem.h"
//#import <objc/runtime.h>
#import "GPObjectSaver.h"

@implementation GPTableTextItem

@synthesize color,text,TextAlignment,NavURL,font,Properties,backgroundColor,isChecked,infoText;
@synthesize notificationText,notificationFillColor,notificationTextColor,bevelLineColor,isGrouped,tag;

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+(GPTableTextItem*)itemWithText:(NSString*)string 
{
return [self itemWithText:string font:nil color:[UIColor blackColor] alignment:UITextAlignmentLeft url:nil];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+(GPTableTextItem*)itemWithText:(NSString*)string url:(NSString*)url
{
    return [self itemWithText:string font:nil color:[UIColor blackColor] alignment:UITextAlignmentLeft url:url];
}
+ (GPTableTextItem*)itemWithText:(NSString*)string color:(UIColor*)textcolor
{
    return [self itemWithText:string font:nil color:textcolor alignment:UITextAlignmentLeft url:nil];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+(GPTableTextItem*)itemWithText:(NSString*)string url:(NSString*)url properties:(NSDictionary*)props
{
    return [self itemWithText:string font:nil color:[UIColor blackColor] alignment:UITextAlignmentLeft url:url properties:props];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+(GPTableTextItem*)itemWithText:(NSString*)string font:(UIFont*)font url:(NSString*)url
{
    return [self itemWithText:string font:font color:[UIColor blackColor] alignment:UITextAlignmentLeft url:url];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+(GPTableTextItem*)itemWithText:(NSString*)string font:(UIFont*)font url:(NSString*)url properties:(NSDictionary*)props
{
    return [self itemWithText:string font:font color:[UIColor blackColor] alignment:UITextAlignmentLeft url:url properties:props];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+(GPTableTextItem*)itemWithText:(NSString*)string color:(UIColor*)textcolor properties:(NSDictionary*)props
{
    return [self itemWithText:string font:nil color:textcolor alignment:UITextAlignmentLeft url:nil];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+(GPTableTextItem*)itemWithText:(NSString*)string color:(UIColor*)textcolor font:(UIFont*)font
{
    return [self itemWithText:string font:font color:textcolor alignment:UITextAlignmentLeft url:nil];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+(GPTableTextItem*)itemWithText:(NSString*)string color:(UIColor*)textcolor font:(UIFont*)font url:(NSString*)url
{
    return [self itemWithText:string font:font color:textcolor alignment:UITextAlignmentLeft url:url];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+(GPTableTextItem*)itemWithText:(NSString*)string color:(UIColor*)textcolor font:(UIFont*)font url:(NSString*)url properties:(NSDictionary*)props
{
    return [self itemWithText:string font:font color:textcolor background:nil alignment:UITextAlignmentLeft url:url properties:props];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+(GPTableTextItem*)itemWithText:(NSString*)string color:(UIColor*)textcolor alignment:(UITextAlignment)align
{
    return [self itemWithText:string font:nil color:textcolor alignment:align url:nil];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+(GPTableTextItem*)itemWithText:(NSString*)string font:(UIFont*)font color:(UIColor*)textcolor alignment:(UITextAlignment)align url:(NSString*)url
{
    return [self itemWithText:string font:font color:textcolor alignment:align url:url properties:nil];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+(GPTableTextItem*)itemWithText:(NSString*)string color:(UIColor*)textcolor alignment:(UITextAlignment)align url:(NSString*)url
{
    return [self itemWithText:string font:nil color:textcolor alignment:align url:url properties:nil];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+(GPTableTextItem*)itemWithText:(NSString*)string color:(UIColor*)textcolor background:(UIColor*)color url:(NSString*)url
{
    return [self itemWithText:string font:nil color:textcolor background:color alignment:UITextAlignmentLeft url:url properties:nil];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+ (GPTableTextItem*)itemWithText:(NSString*)string font:(UIFont*)font color:(UIColor*)textcolor  alignment:(UITextAlignment)align url:(NSString*)url properties:(NSDictionary*)props
{
    return [self itemWithText:string font:font color:textcolor background:nil alignment:align url:url properties:props];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+ (GPTableTextItem*)itemWithText:(NSString*)string font:(UIFont*)font color:(UIColor*)textcolor background:(UIColor*)color alignment:(UITextAlignment)align url:(NSString*)url properties:(NSDictionary*)props
{
    GPTableTextItem* item = [[[GPTableTextItem alloc] init] autorelease];
    item.text = string;
    item.font = font;
    item.color = textcolor;
    item.TextAlignment = align;
    item.NavURL = url;
    item.Properties = props;
    item.backgroundColor = color;
    return item;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+ (GPTableTextItem*)itemWithText:(NSString*)string infoText:(NSString*)info url:(NSString*)url
{
    GPTableTextItem* item = [[[GPTableTextItem alloc] init] autorelease];
    item.text = string;
    item.infoText = info;
    item.NavURL = url;
    return item;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSComparisonResult)compare:(GPTableTextItem*)otherObject {
    return [self.text compare:otherObject.text];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(NSManagedObject*)saveItemToDisk:(NSManagedObjectContext*)ctx entityName:(NSString*)entityName
{
    if(entityName && ctx)
    {
        //GPTableItem* item = (GPTableItem*)[NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:ctx];
        //item.text = self.text;
        //item.navURL = self.NavURL;
        //item.Properties = [GPTableTextItem encodeObject:self.Properties keyName:@"properties"];
        //item.restoreClassName = [self getClassName];
        //return item;
        return [GPObjectSaver saveItemToDisk:ctx entityName:entityName object:self];
    }
    return nil;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+(GPTableTextItem*)restoreItemFromDisk:(NSManagedObject*)object
{
    if([object isKindOfClass:[NSManagedObject class]])
    {
        //GPTableItem* objectItem = (GPTableItem*)object;
        //GPTableTextItem* item = [GPTableTextItem itemWithText:objectItem.text];
        //item.NavURL = objectItem.navURL;
        //item.Properties = [GPTableTextItem decodeObject:objectItem.properties keyName:@"properties"];
        //return item;
        return [GPObjectSaver restoreItemFromDisk:object objectClass:[self class]];
    }
    return nil;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//helper functions for coreData stuff in GPModel
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*-(NSString*)getClassName
{
    const char* className = class_getName([self class]);
    NSString* identifier = [[[NSString alloc] initWithBytesNoCopy:(char*)className
                                                           length:strlen(className)
                                                         encoding:NSASCIIStringEncoding freeWhenDone:NO] autorelease];
    return identifier;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+(NSData*)encodeObject:(id)object keyName:(NSString*)key
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:object forKey:key];
    [archiver finishEncoding];
    [archiver release];
    return data;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+(id)decodeObject:(NSData*)data keyName:(NSString*)key
{
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    id object = [unarchiver decodeObjectForKey:key];
    [unarchiver finishDecoding];
    [unarchiver release];
    return object;
}*/
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@end


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation GPTableItem

@dynamic text;
@dynamic imageData;
@dynamic imageURL;
@dynamic navURL;
@dynamic rowHeight;
@dynamic properties;
@dynamic restoreClassName;

@end
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

