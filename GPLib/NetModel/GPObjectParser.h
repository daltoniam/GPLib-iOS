//
//  GPObjectParser.h
//  TestApp
//
//  Created by Dalton Cherry on 11/26/12.
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

#import <Foundation/Foundation.h>
#import "JSONKit.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
@interface GPObjectMapKey : NSObject

//simple class to add a prefix to a key value. Great for doing async image urls.
//example: would be like domain.com/image/image.png json only returns /image/image.png. You need to add the domain prefix.
@property(nonatomic,retain)NSString* prefix;
@property(nonatomic,retain)NSString* key;

@property(nonatomic,retain)NSArray* keys;
@property(nonatomic,retain)NSString* url;

//map a key with a prefix
+(GPObjectMapKey*)mapKey:(NSString*)key prefix:(NSString*)pre;

//map a key with format. example: [GPObjectMapKey mapFormatKey:gp://comments/%@ keys:[NSArray arrayWithObject:@"item.show"]]
+(GPObjectMapKey*)mapFormatKey:(NSString*)format keys:(NSArray*)keys;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////
@interface GPObjectMapping : NSObject
{
    Class createClass;
    NSMutableDictionary* mappingDict;
}

@property(nonatomic,copy)NSString* parseKey;

//create a new mapping object with a class
-(id)initWithClass:(Class)objectClass;

//map a objectKey to an attribute
-(void)mapObjectKey:(GPObjectMapKey*)key toAttribute:(NSString*)attrib;

//map a key to an attribute
-(void)mapKey:(NSString*)key toAttribute:(NSString*)attrib;

//map a key to a class (basically another object within this object)
-(void)mapInverseKey:(NSString*)key toMapping:(GPObjectMapping*)mapping;

//used interally. Create objects from JSON data
-(id)objectFromClass:(Class)objectClass;
-(id)objectFromDict:(NSDictionary*)entry;
-(id)objectFromDict:(NSDictionary*)entry objectClass:(Class)objectClass;

//factory method to create a new object mapping
+(GPObjectMapping*)mappingWithClass:(Class)objectClass;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////
@interface GPObjectParser : NSObject
{
    NSMutableDictionary* mappingDict;
}

//singleton for parser
+(GPObjectParser*)sharedParser;

//add a object mapping and the url resource to identifer it off. tweets.json or whatever
-(void)addMapping:(GPObjectMapping*)map urlResource:(NSString*)url;

//parse a JSON string and return items created from them.
-(id)parseJSON:(NSString*)jsonString url:(NSString*)url;

@end
