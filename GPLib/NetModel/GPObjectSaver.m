//
//  GPObjectSaver.m
//  TestApp
//
//  Created by Dalton Cherry on 11/26/12.
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
//this class is pretty amazing, it 

#import "GPObjectSaver.h"
#import <objc/runtime.h>

@implementation GPObjectSaver


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+(void)saveItemToDisk:(NSManagedObject*)managedObject object:(id)object
{
    if(object && managedObject)
    {
        NSArray* propArray = [self getPropertiesOfClass:[object class]];
        for(NSString* propName in propArray)
        {
            if([managedObject respondsToSelector:NSSelectorFromString(propName)])
            {
                id value = [object valueForKey:propName];
                if([value isKindOfClass:[NSDictionary class]] || [value isKindOfClass:[NSArray class]])
                    [managedObject setValue:[GPObjectSaver encodeObject:value keyName:propName] forKeyPath:propName];
                else if([value isKindOfClass:[UIImage class]])
                    [managedObject setValue:UIImagePNGRepresentation(value) forKeyPath:propName];
                else if(value)
                    [managedObject setValue:value forKeyPath:propName];
            }
        }
        if([managedObject respondsToSelector:@selector(restoreClassName)])
            [managedObject setValue:[GPObjectSaver getClassName:[object class]] forKeyPath:@"restoreClassName"];
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+(id)restoreItemFromDisk:(NSManagedObject*)managedObject objectClass:(Class)objectClass
{
    if([managedObject isKindOfClass:[NSManagedObject class]])
    {
        id object = [[[objectClass alloc] init] autorelease];
        NSArray* propArray = [self getPropertiesOfClass:[managedObject class]];
        for(NSString* propName in propArray)
        {
            if([object respondsToSelector:NSSelectorFromString(propName)])
            {
                id value = [managedObject valueForKey:propName];
                if([value isKindOfClass:[NSData class]])
                {
                    id decodeObject = [GPObjectSaver decodeObject:value keyName:propName];
                    if(!decodeObject)
                        decodeObject = [UIImage imageWithData:value];
                    if(!decodeObject)
                        decodeObject = value;
                    [object setValue:decodeObject forKeyPath:propName];
                }
                else
                    [object setValue:value forKeyPath:propName];
            }
        }
        return object;
    }
    return nil;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+(NSArray*)getPropertiesOfClass:(Class)objectClass
{
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(objectClass, &outCount);
    NSMutableArray* gather = [NSMutableArray arrayWithCapacity:outCount];
    for(i = 0; i < outCount; i++)
    {
        objc_property_t property = properties[i];
        NSString* propName = [NSString stringWithUTF8String:property_getName(property)];
        [gather addObject:propName];
    }
    free(properties);
    if([objectClass superclass] && [objectClass superclass] != [NSObject class])
        [gather addObjectsFromArray:[GPObjectSaver getPropertiesOfClass:[objectClass superclass]]];
    return gather;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+(NSString*)getClassName:(Class)objectClass
{
    const char* className = class_getName(objectClass);
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
}

@end
