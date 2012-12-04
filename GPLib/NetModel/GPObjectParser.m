//
//  GPObjectParser.m
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
    for(NSString* key in mappingDict)
    {
        NSString* checkKey = key;
        NSRange range = [key rangeOfString:@":resource"];
        if(range.location != NSNotFound)
        {
            NSString* prefix = [checkKey substringToIndex:range.location];
            if([url rangeOfString:prefix].location == NSNotFound)
                continue;
            NSString* startString = [key substringWithRange:NSMakeRange(range.location-1, 1)];
            NSString* endString = [key substringWithRange:NSMakeRange(range.location+range.length, 1)];
            NSRange start = [compareURL rangeOfString:startString options:NSBackwardsSearch];
            NSRange end = [compareURL rangeOfString:endString options:NSBackwardsSearch];
            start.location += 1;
            NSString* find = [compareURL substringWithRange:NSMakeRange(start.location, end.location-start.location)];
            checkKey = [key stringByReplacingOccurrencesOfString:@":resource" withString:find];
        }
        if([compareURL hasSuffix:checkKey])
        {
            mapping = [mappingDict objectForKey:key];
            break;
        }
    }
    if(mapping)
        return [self parseResponse:response mapping:mapping];
    return nil;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(id)parseResponse:(id)response mapping:(GPObjectMapping*)mapping
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
    {
        if(mapping.parseKey)
        {
            id findResponse = [response objectForKey:mapping.parseKey];
            if(findResponse)
                return [self parseResponse:findResponse mapping:mapping];
        }
        return [mapping objectFromDict:response];
    }
    return nil;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
@end

@implementation GPObjectMapping

@synthesize parseKey;
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
-(void)mapInverseKey:(NSString*)key toMapping:(GPObjectMapping*)mapping
{
    if(!mappingDict)
        mappingDict = [[NSMutableDictionary alloc] init];
    [mappingDict setValue:mapping forKey:key];
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
            if([value isKindOfClass:[NSNull class]])
                value = nil;
            keyName = key;
        }
        else if([keyName isKindOfClass:[GPObjectMapKey class]])
        {
            GPObjectMapKey* mapKey = (GPObjectMapKey*)keyName;
            if(mapKey.prefix)
            {
                id sufKey = [entry valueForKeyPath:mapKey.key];
                if([sufKey isKindOfClass:[NSNull class]])
                    value = nil;
                else
                    value = [NSString stringWithFormat:@"%@%@",mapKey.prefix,sufKey];
            }
            else
            {
                id args[mapKey.keys.count];
                NSUInteger index = 0;
                for ( id item in mapKey.keys )
                    args[ index++ ] = [entry valueForKeyPath:item];
                value = [[[NSString alloc] initWithFormat:mapKey.url arguments:(va_list)args] autorelease];
            }
            keyName = key;
        }
        else if(entry)
        {
            GPObjectMapping* mapping = [mappingDict objectForKey:key];
            value = [[GPObjectParser sharedParser] parseResponse:[entry valueForKeyPath:key] mapping:mapping];
            keyName = key;
            NSRange range = [keyName rangeOfString:@"." options:NSBackwardsSearch];
            if(range.location != NSNotFound)
                keyName = [keyName substringFromIndex:range.location+1];
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
///////////////////////////////////////////////////////////////////////////////////////////////////
+(GPObjectMapKey*)mapFormatKey:(NSString*)format keys:(NSArray*)keys
{
    GPObjectMapKey* mapKey = [[[GPObjectMapKey alloc] init] autorelease];
    mapKey.url = format;
    mapKey.keys = keys;
    return mapKey;
}

@end
///////////////////////////////////////////////////////////////////////////////////////////////////
