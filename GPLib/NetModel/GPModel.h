//
//  GPModel.h
//  GPLib
//
//  Created by Dalton Cherry on 12/22/11.
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
//

#import "GPHTTPRequest.h"

@protocol GPModelDelegate <NSObject>

@optional

/**
 * Received when a request is finished. Implmented by GPTableViewController to hide loading label.
 */
- (void)modelFinished:(GPHTTPRequest *)request;
- (void)modelFailed:(GPHTTPRequest *)request;
- (void)noConnection;

@end

@interface GPModel : NSObject<GPHTTPRequestDelegate>
{
    NSMutableArray* items;
    NSMutableArray* sections;
    id<GPModelDelegate> _delegate;
    int page;
    BOOL isLoading;
    BOOL isFinished;
    BOOL killBackgroundThread;
    NSThread* backgroundThread;
}
@property (nonatomic, retain) NSString* URL;
@property (nonatomic, assign) id<GPModelDelegate> delegate;
@property (nonatomic, assign) NSMutableArray* items;
@property (nonatomic, assign) NSMutableArray* sections;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, assign) BOOL isFinished;

-(void)loadModel:(BOOL)more;
-(void)quitModel;
-(BOOL)enablePaging;
-(BOOL)autoLoad;
- (void)requestFinished:(GPHTTPRequest *)request;
- (void)requestFailed:(GPHTTPRequest *)request;
- (id)initWithURLString:(NSString*)url;
-(void)setupinit;
-(void)noConnect;
-(NSString*)reachURL;
-(void)cachePolicy:(GPHTTPRequest*)request;
-(void)onPost:(NSDictionary*)entries;

@end

