//
//  GPTablePadItem.h
//  GPLib
//
//  Created by Dalton Cherry on 11/8/12.
//  Copyright (c) 2012 Lightspeed Systems. All rights reserved.
//

#import "GPTableTextItem.h"

@interface GPTablePadItem : GPTableTextItem

@property(nonatomic,assign)NSInteger padHeight;

+ (GPTablePadItem*)itemWithHeight:(int)height;

@end
