//
//  GPTableImageItem.h
//  GPLib
//
//  Created by Dalton Cherry on 12/7/11.
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

#import "GPTableTextItem.h"

@interface GPTableImageItem : GPTableTextItem

@property(nonatomic,copy)NSString* imageURL;
@property(nonatomic,retain)UIImage* defaultImage;
@property(nonatomic,retain)UIImage* imageData;
@property(nonatomic,assign)CGSize imageSize;
@property(nonatomic,assign)NSInteger imageRounding;
@property(nonatomic,assign)UIViewContentMode contentMode;
@property(nonatomic,assign)BOOL topJustifyImage;
@property(nonatomic,assign)CGFloat imageBorderWidth;
@property(nonatomic,retain)UIColor* imageBorderColor;
@property(nonatomic,retain)NSData* gifData;

+ (GPTableImageItem*)itemWithImage:(NSString*)imageurl text:(NSString*)string;
+ (GPTableImageItem*)itemWithImage:(NSString*)imageurl text:(NSString*)string URL:(NSString*)url;
+ (GPTableImageItem*)itemWithImage:(NSString*)imageurl text:(NSString*)string DefaultImage:(UIImage*)image;
+ (GPTableImageItem*)itemWithImage:(NSString*)imageurl text:(NSString*)string DefaultImage:(UIImage*)image properties:(NSDictionary*)props url:(NSString*)url;
+ (GPTableImageItem*)itemWithImage:(NSString*)imageurl text:(NSString*)string url:(NSString*)url;
+ (GPTableImageItem*)itemWithImage:(NSString*)imageurl text:(NSString*)string color:(UIColor*)textcolor;
+ (GPTableImageItem*)itemWithImage:(NSString*)imageurl text:(NSString*)string color:(UIColor*)textcolor url:(NSString*)url;
+ (GPTableImageItem*)itemWithImage:(NSString*)imageurl text:(NSString*)string font:(UIFont*)font url:(NSString*)url;
+ (GPTableImageItem*)itemWithImage:(NSString*)imageurl text:(NSString*)string properties:(NSDictionary*)props url:(NSString*)url;
+ (GPTableImageItem*)itemWithImage:(NSString*)imageurl text:(NSString*)string font:(UIFont*)font color:(UIColor*)textcolor 
                      DefaultImage:(UIImage*)image url:(NSString*)url;
+ (GPTableImageItem*)itemWithImage:(NSString*)imageurl text:(NSString*)string font:(UIFont*)font color:(UIColor*)textcolor 
                      DefaultImage:(UIImage*)image properties:(NSDictionary*)props url:(NSString*)url;

+ (GPTableImageItem*)itemWithImageData:(UIImage*)imageData text:(NSString*)string URL:(NSString*)url size:(CGSize)size round:(NSInteger)rounding;

+ (GPTableImageItem*)itemWithText:(NSString*)text url:(NSString*)url;
@end
