//
//  GPTableGroupButtonItem.h
//  GPLib
//
//  Created by Dalton Cherry on 12/10/12.
//  Copyright (c) 2012 Lightspeed Systems. All rights reserved.
//

#import "GPTableTextItem.h"

@interface GPTableGroupButtonItem : GPTableTextItem

@property(nonatomic,copy)NSString* leftButtonText;
@property(nonatomic,copy)NSString* rightButtonText;

@property(nonatomic,assign)SEL leftSelector;
@property(nonatomic,assign)SEL rightSelector;

@property(nonatomic,assign)int leftTag;
@property(nonatomic,assign)int rightTag;

+(GPTableGroupButtonItem*)itemWithLeft:(NSString*)left leftSel:(SEL)lsel leftTag:(int)ltag right:(NSString*)right rightSel:(SEL)rsel rightTag:(int)rtag;

@end
