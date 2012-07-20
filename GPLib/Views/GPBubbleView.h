//
//  GPBubbleView.h
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

@interface GPBubbleView : UIView

@property(nonatomic,assign)CGSize TriangleSize;
@property(nonatomic,assign)CGFloat BorderWidth;
@property(nonatomic,assign)CGFloat BorderRadius;
@property(nonatomic,retain)UIColor* BorderColor;
@property(nonatomic,retain)UIColor* FillColor;
@property(nonatomic,retain)UIColor* GradientColor;
@property(nonatomic,assign)BOOL adjustSubviews;
@property(nonatomic,retain)UILabel* textLabel;
@property(nonatomic,assign)BOOL drawGloss;
@property(nonatomic,assign)BOOL drawInsetShadow;

+(GPBubbleView*)textItem:(UIColor*)fill text:(NSString*)text;
+(GPBubbleView*)badgeItem:(NSString*)text;
-(UILabel*)textLabel;
-(void)updateBadgeText:(NSString*)text;

@end
