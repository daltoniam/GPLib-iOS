//
//  GPParserModel.m
//  GPLib
//
//  Created by Dalton Cherry on 11/26/12.
//  Copyright (c) 2012 Lightspeed Systems. All rights reserved.
//

#import "GPParserModel.h"
#import "GPObjectParser.h"
#import "GPTableMoreItem.h"

@implementation GPParserModel

///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)networkFinished:(GPHTTPRequest *)request
{
    GPObjectParser* parser = [GPObjectParser sharedParser];
    id response = [parser parseJSON:[request responseString] url:request.URL.absoluteString];
    if([response isKindOfClass:[NSArray class]])
    {
        [self.items addObjectsFromArray:response];
        if([response count] > 0 && self.paging)
            [self.items addObject:[GPTableMoreItem itemWithLoading:@"" isAutoLoad:YES]];
    }
    else
        [self.items addObject:response];
    [super networkFinished:request];
}
///////////////////////////////////////////////////////////////////////////////////////////////////

@end
