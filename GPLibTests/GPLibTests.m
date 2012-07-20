//
//  GPLibTests.m
//  GPLibTests
//
//  Created by Dalton Cherry on 2/3/12.
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

#import "GPLibTests.h"

#import "GPNavigator.h"

@implementation GPLibTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}
////////////////////////////////////////////////////////////////////////////
/*- (void)testExample
{
    STFail(@"Unit tests are not implemented yet in GPLibTests");
}*/
////////////////////////////////////////////////////////////////////////////
//it is strongly recommmend you put this test in your application test. 
//This will valid all your URL navigation.
-(void)testGPNavigator
{
    for(NSString* url in [GPNavigator navigator].URLs)
    {
        if(![url isEqualToString:@"http"])
        {
            Class class = [[GPNavigator navigator].URLs objectForKey:url];
            NSURL* navURL = [NSURL URLWithString:url];
            NSString* params = [navURL.path stringByReplacingOccurrencesOfString:@"/" withString:@""];
            if([params isEqualToString:@""])
                params = @"init";
            SEL sel = NSSelectorFromString(params);
            STAssertTrue([class instancesRespondToSelector:sel], @"URL: %@ does not respond to Selector: %@",navURL.host,params);
        }
    }
}
////////////////////////////////////////////////////////////////////////////
-(void)testNavigator
{
    //TODO add navigator test
    //[[GPNavigator navigator] mapViewController:<#(Class)#> toURL:<#(NSString *)#>]
}
////////////////////////////////////////////////////////////////////////////
@end
