//
//  GPModel.h
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

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "GPHTTPRequest.h"

@class GPModel;

@protocol GPModelDelegate <NSObject>

@optional
//the model finished loading items from either disk or the network
-(void)modelDidFinish:(GPModel*)model fromDisk:(BOOL)disk;

//the model failed to load.
-(void)modelDidFail:(GPModel*)model;

//the model does not have a network connection to fetch the items.
-(void)modelnoConnection:(GPModel*)model;

//checks if it should save this item before saving to disk. This is needed to avoid saving duplicates to disk.
// return YES to save and NO to NOT save. Normally you would 
-(BOOL)modelShouldSaveObject:(GPModel*)model object:(id)object;

@end

typedef void (^GPModelBlock)(GPModel*,BOOL);

@interface GPModel : NSObject
{
    NSLock* lock;
    NSManagedObjectContext* objectCtx;
    NSManagedObjectModel* managedObjectModel;
    NSPersistentStoreCoordinator* persistentStoreCoordinator;
    GPModelBlock finishedBlock;
}

//this is the current page you are working with.
@property(nonatomic,assign)NSInteger page;

//this enables paging on the model.
@property(nonatomic,assign)BOOL paging;

//can check if the model is loading
@property(nonatomic,assign,readonly)BOOL isLoading;

//URL to fetch content from the network
@property(nonatomic,copy)NSString* URL;

//items you that are returned after data is loaded
@property(nonatomic,retain,readonly)NSMutableArray* items;

//the delegate
@property (nonatomic, assign) id<GPModelDelegate> delegate;

//set this to the entity name (name of your coreDataModel) of your core Data model. Default is nil, which means saving to disk does nothing
//if you are using the GPTableItem coreData model, set this to GPTableItem
@property (nonatomic, assign)NSString* entityName;

-(id)initWithURL:(NSString*)url;

//this will fetch new content off the network from URL property. It increments the page number if paging is enabled
-(void)fetchFromNetwork;

//fetch all objects stored on disk
-(void)fetchFromDisk;

//fetch all objects stored on disk, but pass in some sort descriptors
-(void)fetchFromDisk:(NSArray*)sortDescriptors;

//fetch all objects stored on disk, but pass in some sort descriptors and a search predicate
-(void)fetchFromDisk:(NSArray*)sortDescriptors predicate:(NSPredicate*)predicate;

//this adds a new object to disk.
-(void)saveObject:(id)object;

//this adds a new objects to disk.
-(void)saveObjects:(NSArray*)array;

//find and delete objects from disk.
-(void)deleteObjects:(NSPredicate*)predicate;

//set your cache policy for your network request
-(void)cachePolicy:(GPHTTPRequest*)request;

//subclass this to create your items
-(void)networkFinished:(GPHTTPRequest*)request;

//override if you want a different DB name. Default is to use className
-(NSString*)databaseName;

//use this to style your objects that have come from disk
-(void)styleRestoredObject:(id)object;

//used to access coreData
- (NSManagedObjectContext*)objectCtx;

//use this to set a block based finish
-(void)setFinishBlock:(GPModelBlock)completeBlock;

//use to clear a all contents of a DB from disk.
+(void)clearDiskStorage;

@end
