//
//  GPTablePadItem.m
//  GPLib
//
//  Created by Dalton Cherry on 11/8/12.
//  Copyright (c) 2012 Lightspeed Systems. All rights reserved.
//

#import "GPTablePadItem.h"

@implementation GPTablePadItem

@synthesize padHeight;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+ (GPTablePadItem*)itemWithHeight:(int)height
{
    GPTablePadItem* item = [[[GPTablePadItem alloc] init] autorelease];
    item.padHeight = height;
    return item;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)saveItemToDisk:(NSManagedObject*)object ctx:(NSManagedObjectContext*)ctx
{
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+(GPTableTextItem*)restoreItemFromDisk:(NSManagedObject*)object
{
    return nil;
}


@end
