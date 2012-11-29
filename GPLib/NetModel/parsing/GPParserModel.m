//
//  GPParserModel.m
//  GPLib
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

#import "GPParserModel.h"
#import "GPObjectParser.h"
#import "GPTableMoreItem.h"

@implementation GPParserModel

///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)networkFinished:(GPHTTPRequest *)request
{
    GPObjectParser* parser = [GPObjectParser sharedParser];
    id response = [parser parseJSON:[request responseString] url:request.URL.absoluteString];
    if([response isKindOfClass:[NSNull class]] || !response)
    {
        
    }
    else if([response isKindOfClass:[NSArray class]])
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
