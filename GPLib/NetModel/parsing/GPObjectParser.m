//
//  GPObjectParser.m
//  TestApp
//
//  Created by Dalton Cherry on 11/26/12.
//  Copyright (c) 2012 Basement Krew. All rights reserved.
//

#import "GPObjectParser.h"

@implementation GPObjectParser

static GPObjectParser* sharedParser;
///////////////////////////////////////////////////////////////////////////////////////////////////
+(GPObjectParser*)sharedParser
{
    if(!sharedParser)
        sharedParser = [[GPObjectParser alloc] init];
    return sharedParser;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)addMapping:(GPObjectMapping *)map urlResource:(NSString *)url
{
    if(!mappingDict)
        mappingDict = [[NSMutableDictionary alloc] init];
    [mappingDict setValue:map forKey:url];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(id)parseJSON:(NSString*)jsonString url:(NSString*)url
{
    NSString* compareURL = url;
    NSRange range = [compareURL rangeOfString:@"?" options:NSBackwardsSearch];
    if(range.location != NSNotFound)
        compareURL = [compareURL substringToIndex:range.location];
    id response = [jsonString objectFromJSONString];
    GPObjectMapping* mapping = nil;
    for(id key in mappingDict)
    {
        if([compareURL hasSuffix:key])
        {
            mapping = [mappingDict objectForKey:key];
            break;
        }
    }
    if(mapping)
    {
        if([response isKindOfClass:[NSArray class]])
        {
            NSArray* entries = response;
            NSMutableArray* gather = [NSMutableArray arrayWithCapacity:entries.count];
            for(NSDictionary* entry in entries)
                [gather addObject:[mapping objectFromDict:entry]];
            return gather;
        }
        else if([response isKindOfClass:[NSDictionary class]])
            return [mapping objectFromDict:response];
    }
    return nil;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
@end

@implementation GPObjectMapping

///////////////////////////////////////////////////////////////////////////////////////////////////
+(GPObjectMapping*)mappingWithClass:(Class)objectClass
{
    return [[[GPObjectMapping alloc] initWithClass:objectClass] autorelease];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(id)initWithClass:(Class)objectClass
{
    if(self = [super init])
    {
        createClass = objectClass;
    }
    return self;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)mapKey:(NSString*)key toAttribute:(NSString*)attrib
{
    if(!mappingDict)
        mappingDict = [[NSMutableDictionary alloc] init];
    [mappingDict setValue:key forKey:attrib];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)mapObjectKey:(GPObjectMapKey*)key toAttribute:(NSString*)attrib
{
    if(!mappingDict)
        mappingDict = [[NSMutableDictionary alloc] init];
    [mappingDict setValue:key forKey:attrib];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)mapInverseKey:(NSString*)key toClass:(Class)childClass
{
    if(!mappingDict)
        mappingDict = [[NSMutableDictionary alloc] init];
    [mappingDict setValue:childClass forKey:key];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(id)objectFromClass:(Class)objectClass
{
    return [[[objectClass alloc] init] autorelease];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(id)objectFromDict:(NSDictionary*)entry
{
    return [self objectFromDict:entry objectClass:createClass];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(id)objectFromDict:(NSDictionary*)entry objectClass:(Class)objectClass
{
    id object = [self objectFromClass:objectClass];
    for(id key in mappingDict)
    {
        id value = nil;
        NSString* keyName = [mappingDict objectForKey:key];
        if([keyName isKindOfClass:[NSString class]])
        {
            value = [entry valueForKeyPath:keyName];
            keyName = key;
        }
        else if([keyName isKindOfClass:[GPObjectMapKey class]])
        {
            GPObjectMapKey* mapKey = (GPObjectMapKey*)keyName;
            value = [NSString stringWithFormat:@"%@%@",mapKey.prefix,[entry valueForKeyPath:mapKey.key]];
            keyName = key;
        }
        else
        {
            Class childClass = [mappingDict objectForKey:key];
            value = [self objectFromDict:[entry valueForKeyPath:key] objectClass:childClass];
            keyName = key;
        }
        if(value)
            [object setValue:value forKey:keyName];
    }
    return object;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
@end

///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation GPObjectMapKey

+(GPObjectMapKey*)mapKey:(NSString*)key prefix:(NSString*)pre
{
    GPObjectMapKey* mapKey = [[[GPObjectMapKey alloc] init] autorelease];
    mapKey.key = key;
    mapKey.prefix = pre;
    return mapKey;
}

@end
///////////////////////////////////////////////////////////////////////////////////////////////////
