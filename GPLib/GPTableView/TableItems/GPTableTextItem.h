//
//  GPTableTextItem.h
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

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//I provide this for the base GPTableItems. There is also a coreData model you can pull into your app that will make this work.
// it should be under: NetModel/GPTableItem
@interface GPTableItem : NSManagedObject

@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSData * imageData;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSString * navURL;
@property (nonatomic, retain) NSNumber * rowHeight;
@property (nonatomic, retain) NSData * properties;
@property (nonatomic, retain) NSString * restoreClassName;

@end
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface GPTableTextItem : NSObject

@property(nonatomic,copy)NSString* text;
@property(nonatomic,copy)NSString* infoText;
@property(nonatomic,retain)UIFont* font;
@property(nonatomic,retain)UIColor* color;
@property(nonatomic,retain)UIColor* bevelLineColor; //adds a custom bevel line to the tablecells. I recommend: [UIColor colorWithWhite:0.7 alpha:0.15];
@property(nonatomic,retain)UIColor* backgroundColor;
@property(nonatomic,assign)UITextAlignment textAlignment;
@property(nonatomic,copy)NSString* navURL;
@property(nonatomic,assign)BOOL isChecked;

//notification badge
@property(nonatomic,copy)NSString* notificationText;
@property(nonatomic,retain)UIColor* notificationTextColor;
@property(nonatomic,retain)UIColor* notificationFillColor;

//for things that are not going to be displayed but are needed in the tablecell
@property(nonatomic,retain)NSDictionary* properties;

//ignore this, I just use it to figure certain style properties out
@property(nonatomic,assign)BOOL isGrouped;

//tag to find item in tableview.
@property(nonatomic, assign)NSInteger tag;

+ (GPTableTextItem*)itemWithText:(NSString*)string;
+ (GPTableTextItem*)itemWithText:(NSString*)string url:(NSString*)url;
+(GPTableTextItem*)itemWithText:(NSString*)string url:(NSString*)url properties:(NSDictionary*)props;
+ (GPTableTextItem*)itemWithText:(NSString*)string color:(UIColor*)textcolor;
+(GPTableTextItem*)itemWithText:(NSString*)string color:(UIColor*)textcolor font:(UIFont*)font;
+(GPTableTextItem*)itemWithText:(NSString*)string color:(UIColor*)textcolor font:(UIFont*)font url:(NSString*)url;
+(GPTableTextItem*)itemWithText:(NSString*)string font:(UIFont*)font url:(NSString*)url properties:(NSDictionary*)props;
+(GPTableTextItem*)itemWithText:(NSString*)string color:(UIColor*)textcolor font:(UIFont*)font url:(NSString*)url properties:(NSDictionary*)props;
+ (GPTableTextItem*)itemWithText:(NSString*)string color:(UIColor*)textcolor alignment:(UITextAlignment)align;
+ (GPTableTextItem*)itemWithText:(NSString*)string color:(UIColor*)textcolor alignment:(UITextAlignment)align url:(NSString*)url;
+ (GPTableTextItem*)itemWithText:(NSString*)string font:(UIFont*)font url:(NSString*)url;
+(GPTableTextItem*)itemWithText:(NSString*)string color:(UIColor*)textcolor background:(UIColor*)color url:(NSString*)url;
+ (GPTableTextItem*)itemWithText:(NSString*)string font:(UIFont*)font color:(UIColor*)textcolor alignment:(UITextAlignment)align url:(NSString*)url;
+ (GPTableTextItem*)itemWithText:(NSString*)string font:(UIFont*)font color:(UIColor*)textcolor alignment:(UITextAlignment)align url:(NSString*)url properties:(NSDictionary*)props;
+ (GPTableTextItem*)itemWithText:(NSString*)string font:(UIFont*)font color:(UIColor*)textcolor background:(UIColor*)color alignment:(UITextAlignment)align url:(NSString*)url properties:(NSDictionary*)props;

+ (GPTableTextItem*)itemWithText:(NSString*)string infoText:(NSString*)info url:(NSString*)url;

- (NSComparisonResult)compare:(GPTableTextItem*)otherObject;

-(void)saveItemToDisk:(NSManagedObject*)object;
+(id)restoreItemFromDisk:(NSManagedObject*)object;

//-(NSString*)getClassName;
//+(NSData*)encodeObject:(id)object keyName:(NSString*)key;
//+(id)decodeObject:(NSData*)data keyName:(NSString*)key;

@end
