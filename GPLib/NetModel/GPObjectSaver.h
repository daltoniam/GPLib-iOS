//
//  GPObjectSaver.h
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
// this class is amazing, it convert any objects properties to a coreData object and saves it. It can also restore the objects.
//made to work with GPModel needs for saving objects.

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface GPObjectSaver : NSObject

//gets all the property names of a class and its super class(es).
+(NSArray*)getPropertiesOfClass:(Class)objectClass;

//saves the object to disk.
+(void)saveItemToDisk:(NSManagedObject*)managedObject object:(id)object;

//restores the object from the disk and configures all the properties off the coreData property that name matches
+(id)restoreItemFromDisk:(NSManagedObject*)managedObject objectClass:(Class)objectClass;

//gets the class name.
+(NSString*)getClassName:(Class)objectClass;

//encodes a object to NSData (using NSArchiver) so it can be saved to disk.
+(NSData*)encodeObject:(id)object keyName:(NSString*)key;

//decodes a object from NSData to a object.
+(id)decodeObject:(NSData*)data keyName:(NSString*)key;

@end
