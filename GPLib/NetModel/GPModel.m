//
//  GPModel.m
//  GPLib
//
//  Created by Dalton Cherry on 10/18/12.
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

#import "GPModel.h"
#import "GPReachability.h"
#import <objc/runtime.h>

@implementation GPModel

@synthesize paging,page,isLoading,items,URL,delegate,primaryKey,entityName,migrationModelName;

///////////////////////////////////////////////////////////////////////////////////////////////////
-(id)init
{
    if(self = [super init])
    {
        self.page = 1;
        items = [[NSMutableArray alloc] init];
    }
    return self;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(id)initWithURL:(NSString*)url
{
    if(self = [super init])
    {
        self.page = 1;
        self.URL = url;
        items = [[NSMutableArray alloc] init];
    }
    return self;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)fetchFromNetwork
{
    if(self.URL)
    {
        [items removeAllObjects];
        isLoading = YES;
        NSString* hostName = [[NSURL URLWithString:self.URL] host];
        if(hostName && ![GPReachability isHostReachable:hostName])
        {
            page = 1;
            [self noConnect];
            return;
        }
        
        NSString* baseURL = @"";
        NSString* param = @"&";
        if([self.URL rangeOfString:@"?"].location == NSNotFound)
            param = @"?";
        if(self.paging)
            baseURL = [NSString stringWithFormat:@"%@%@page=%d",self.URL,param,page];
        else
            baseURL = self.URL;
        if(baseURL)
        {
            page++;
            [self performSelectorInBackground:@selector(fetchNetworkContent:) withObject:baseURL];
        }
        else
            [self networkFailed];
    }
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)fetchFromDisk
{
    [self fetchFromDisk:nil];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)fetchFromDisk:(NSArray*)sortDescriptors
{
    [self fetchFromDisk:sortDescriptors predicate:nil];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)fetchFromDisk:(NSArray*)sortDescriptors predicate:(NSPredicate*)predicate
{
    if(!lock)
        lock = [[NSLock alloc] init];
    [items removeAllObjects];
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithCapacity:2];
    if(sortDescriptors)
        [dict setValue:sortDescriptors forKey:@"sort"];
    if(predicate)
        [dict setValue:predicate forKey:@"search"];
    [self performSelectorInBackground:@selector(fetchDiskContent:) withObject:dict];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(NSArray*)findObjects:(NSPredicate*)predicate
{
    return [self findObjects:predicate entity:self.entityName];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(NSArray*)findObjects:(NSPredicate*)predicate entity:(NSString*)entityN
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityN inManagedObjectContext:[self objectCtx]];
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:entity];
    request.predicate = predicate;
    return [[self objectCtx] executeFetchRequest:request error:nil];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//returns true if object already exist in coreData
-(BOOL)processSaveObject:(id)object
{
    NSString* entity = self.entityName;
    if([object respondsToSelector:@selector(entityName)])
        entity = [object performSelector:@selector(entityName)];
    if([object respondsToSelector:@selector(saveItemToDisk:ctx:)] && entity)
    {
        BOOL save = YES;
        if([self.delegate respondsToSelector:@selector(modelShouldSaveObject:object:)])
            save = [self.delegate modelShouldSaveObject:self object:object];
        if(save)
        {
            BOOL create = YES;
            NSString* priKey = self.primaryKey;
            if([object respondsToSelector:@selector(primaryKey)])
                priKey = [object performSelector:@selector(primaryKey)];
            if(priKey)
            {
                if([object respondsToSelector:NSSelectorFromString(priKey)])
                {
                    NSString* objectKey = [object performSelector:NSSelectorFromString(priKey)];
                    NSArray* array = [self findObjects:[NSPredicate predicateWithFormat:@"%K == %@",priKey,objectKey] entity:entity];
                    if(array.count > 0)
                        create = NO;
                    for(NSManagedObject* managedObject in array)
                        [object performSelector:@selector(saveItemToDisk:ctx:) withObject:managedObject withObject:[self objectCtx]];
                }
            }
            if(create)
            {
                NSManagedObject* managedObject = [NSEntityDescription insertNewObjectForEntityForName:entity inManagedObjectContext:[self objectCtx]];
                [object performSelector:@selector(saveItemToDisk:ctx:) withObject:managedObject withObject:[self objectCtx]];
            }
            return !create;
        }
    }
    return NO;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)saveObject:(id)object
{
    if(!lock)
        lock = [[NSLock alloc] init];
    [lock lock];
    [self processSaveObject:object];
    [[self objectCtx] save:nil];
    [lock unlock];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)saveObjects:(NSArray*)array clearDups:(BOOL)clear
{
    if(!lock)
        lock = [[NSLock alloc] init];
    [lock lock];
    NSMutableArray* mutArray = nil;
    if(clear)
        mutArray = [NSMutableArray array];
    for(id object in array)
    {
        if([self processSaveObject:object] && clear)
            [mutArray addObject:object];
    }
    if(clear)
    {
        if([array isKindOfClass:[NSMutableArray class]])
            [(NSMutableArray*)array removeObjectsInArray:mutArray];
    }
    NSError* error = nil;
    if(![[self objectCtx] save:&error])
        NSLog(@"unable to save items to entity: %@ error: %@",self.entityName,[error userInfo]);
    [lock unlock];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)saveObjects:(NSArray*)array
{
    if(self.primaryKey)
        [self saveObjects:array clearDups:YES];
    else
        [self saveObjects:array clearDups:NO];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)deleteObjects:(NSPredicate*)predicate
{
    if(self.entityName)
    {
        if(!lock)
            lock = [[NSLock alloc] init];
        [self performSelectorInBackground:@selector(deleteDiskThread:) withObject:predicate];
    }
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//subclass stuff
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)cachePolicy:(GPHTTPRequest*)request
{
    [request setCacheTimeout:5];
    [request setCacheModel:GPHTTPCacheCustomTime];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//override to make this do stuff!!!
-(void)networkFinished:(GPHTTPRequest*)request
{
    if(finishedBlock)
        finishedBlock(self,NO);
    [self performSelectorOnMainThread:@selector(finished:) withObject:[NSNumber numberWithBool:NO] waitUntilDone:YES];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//override if you want a different DB name
-(NSString*)databaseName
{
    /*const char* className = class_getName([self class]);
    NSString* identifier = [[[NSString alloc] initWithBytesNoCopy:(char*)className
                                                           length:strlen(className)
                                                         encoding:NSASCIIStringEncoding freeWhenDone:NO] autorelease];
    return [identifier lowercaseString];*/
    return @"gpmodel";
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)styleRestoredObject:(id)object
{
    
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setFinishBlock:(GPModelBlock)completeBlock
{
    [finishedBlock release];
	finishedBlock = [completeBlock copy];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//private stuff
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)fetchNetworkContent:(NSString*)url
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    GPHTTPRequest *request = [GPHTTPRequest requestWithString:url];
    [self cachePolicy:request];
    [request startSync];
    if(request.statusCode >= 400)
        [self networkFailed];
    else
        [self networkFinished:request];
    [pool drain];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)fetchDiskContent:(NSDictionary*)params
{
    if(self.entityName)
    {
        NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
        [lock lock];
        NSEntityDescription *entity = [NSEntityDescription entityForName:self.entityName inManagedObjectContext:[self objectCtx]];
        
        // Setup the fetch request
        NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
        [request setEntity:entity];
        
        NSArray* sortDescriptors = [params objectForKey:@"sort"];
        NSPredicate* predicate = [params objectForKey:@"search"];
        
        [request setSortDescriptors:sortDescriptors];
        request.predicate = predicate;
        
        NSArray *managedItems = [[self objectCtx] executeFetchRequest:request error:nil];
        for(NSManagedObject* object in managedItems)
        {
            Class class = [self getRestoreClass:object];
            if(!class)
                class = self.restoreClass;
            if(class)
            {
                if([class respondsToSelector:@selector(restoreItemFromDisk:)])
                {
                    id item = [class performSelector:@selector(restoreItemFromDisk:) withObject:object];
                    if(item)
                    {
                        [self styleRestoredObject:item];
                        [items addObject:item];
                    }
                }
            }
        }
        if(finishedBlock)
            finishedBlock(self,YES);
        [self performSelectorOnMainThread:@selector(finished:) withObject:[NSNumber numberWithBool:YES] waitUntilDone:YES];
        [lock unlock];
        [pool drain];
    }
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(Class)getRestoreClass:(id)object
{
    if([object respondsToSelector:@selector(restoreClassName)])
    {
        NSString* className = [object performSelector:@selector(restoreClassName)];
        if(className)
            return NSClassFromString(className);
    }
    return nil;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)deleteDiskThread:(NSPredicate*)predicate
{
    if(self.entityName)
    {
        NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
        [lock lock];
        NSEntityDescription *entity = [NSEntityDescription entityForName:self.entityName inManagedObjectContext:[self objectCtx]];
        
        // Setup the fetch request
        NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
        [request setEntity:entity];
        request.predicate = predicate;
        
        NSArray *managedItems = [[self objectCtx] executeFetchRequest:request error:nil];
        for(NSManagedObject* object in managedItems)
            [[self objectCtx] deleteObject:object];
        [[self objectCtx] save:nil];
        [lock unlock];
        [pool drain];
    }
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)noConnect
{
    isLoading = NO;
    if ([self.delegate respondsToSelector:@selector(modelnoConnection:)])
        [self.delegate modelnoConnection:self];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)networkFailed
{
    isLoading = NO;
    if ([self.delegate respondsToSelector:@selector(modelDidFail:)])
        [self.delegate modelDidFail:self];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)finished:(NSNumber*)boolNum
{
    isLoading = NO;
    if ([self.delegate respondsToSelector:@selector(modelDidFinish:fromDisk:)])
        [self.delegate modelDidFinish:self fromDisk:[boolNum boolValue]];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)dealloc
{
    [items release];
    [persistentStoreCoordinator release];
    [managedObjectModel release];
    [objectCtx release];
    [lock release];
    if (finishedBlock)
    {
		[finishedBlock release];
		finishedBlock = nil;
	}
    [super dealloc];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//core data stuff
///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSManagedObjectContext*)objectCtx
{
    if (objectCtx)
        return objectCtx;
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator)
    {
        objectCtx = [[NSManagedObjectContext alloc] init];
        [objectCtx setPersistentStoreCoordinator:coordinator];
    }
    return objectCtx;
}
/////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSManagedObjectModel *)managedObjectModel
{
    if (managedObjectModel)
        return managedObjectModel;
    if(self.migrationModelName)
    {
        NSString *path = [[NSBundle mainBundle] pathForResource:self.migrationModelName ofType:@"momd"];
        NSURL *momURL = [NSURL fileURLWithPath:path];
        managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:momURL];
    }
    else
        managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];
    return managedObjectModel;
}
/////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (persistentStoreCoordinator != nil)
        return persistentStoreCoordinator;
    
    NSString* dbName = [NSString stringWithFormat:@"%@.sqlite",[self databaseName]];
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent:dbName]];
    
    NSDictionary *options = nil;
    if(self.migrationModelName)
    {
        options = [NSDictionary dictionaryWithObjectsAndKeys:
                   [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                   [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    }
    
    NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error])
    {
        NSLog(@"error: %@ userInfo: %@",error,[error userInfo]);
        static BOOL didReload;
        if(!didReload)
        {
            NSString* dbName = [NSString stringWithFormat:@"%@.sqlite",[self databaseName]];
            NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent:dbName]];
            [[NSFileManager defaultManager] removeItemAtPath:storeUrl.path error:nil];
            [persistentStoreCoordinator release];
            persistentStoreCoordinator = nil;
            [managedObjectModel release];
            managedObjectModel = nil;
            [self persistentStoreCoordinator];
            didReload = YES;
        }
    }
    
    return persistentStoreCoordinator;
}
/////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)applicationDocumentsDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)clearDisk
{
    NSString* dbName = [NSString stringWithFormat:@"%@.sqlite",[self databaseName]];
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent:dbName]];
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    NSPersistentStore* store = [coordinator persistentStoreForURL:storeUrl];
    [coordinator removePersistentStore:store error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:storeUrl.path error:nil];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//public
/////////////////////////////////////////////////////////////////////////////////////////////////////
+(void)clearDiskStorage
{
    GPModel* model = [[[GPModel alloc] init] autorelease];
    [model clearDisk];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
@end
