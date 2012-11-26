//
//  GPObjectParser.h
//  TestApp
//
//  Created by Dalton Cherry on 11/26/12.
//  Copyright (c) 2012 Basement Krew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONKit.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
@interface GPObjectMapKey : NSObject

//simple class to add a prefix to a key value. Great for doing async image urls.
//example: would be like domain.com/image/image.png json only returns /image/image.png. You need to add the domain prefix.
@property(nonatomic,retain)NSString* prefix;
@property(nonatomic,retain)NSString* key;

+(GPObjectMapKey*)mapKey:(NSString*)key prefix:(NSString*)pre;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////
@interface GPObjectMapping : NSObject
{
    Class createClass;
    NSMutableDictionary* mappingDict;
}

//create a new mapping object with a class
-(id)initWithClass:(Class)objectClass;

//map a objectKey to an attribute
-(void)mapObjectKey:(GPObjectMapKey*)key toAttribute:(NSString*)attrib;

//map a key to an attribute
-(void)mapKey:(NSString*)key toAttribute:(NSString*)attrib;

//map a key to a class (basically another object within this object)
-(void)mapInverseKey:(NSString*)key toClass:(Class)childClass;

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
