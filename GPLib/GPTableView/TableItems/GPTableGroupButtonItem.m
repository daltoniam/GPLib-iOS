//
//  GPTableGroupButtonItem.m
//  GPLib
//
//  Created by Dalton Cherry on 12/10/12.
//  Copyright (c) 2012 Lightspeed Systems. All rights reserved.
//

#import "GPTableGroupButtonItem.h"

@implementation GPTableGroupButtonItem

@synthesize leftButtonText,rightButtonText,leftSelector,rightSelector,leftTag,rightTag;

+(GPTableGroupButtonItem*)itemWithLeft:(NSString*)left leftSel:(SEL)lsel leftTag:(int)ltag right:(NSString*)right rightSel:(SEL)rsel rightTag:(int)rtag
{
    GPTableGroupButtonItem* item = [[[GPTableGroupButtonItem alloc] init] autorelease];
    item.rightButtonText = right;
    item.leftButtonText = left;
    item.rightSelector = rsel;
    item.leftSelector = lsel;
    item.rightTag = rtag;
    item.leftTag = ltag;
    return item;
}

@end
