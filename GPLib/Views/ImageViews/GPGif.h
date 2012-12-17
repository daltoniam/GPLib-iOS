//
//  GPGif.h
//  TestApp
//
//  Created by Dalton Cherry on 12/17/12.
//  Copyright (c) 2012 Basement Krew. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GPGif : NSObject
{
    NSData* GIFpointer;
	NSData* GIFbuffer;
	NSMutableData* GIFscreen;
	NSMutableData* GIFglobal;
	NSMutableData* GIFframeHeader;
    
	NSMutableArray* GIFdelays;
	NSMutableArray* GIFframesData;
    
    int dataPointer;
    
    int GIFsorted;
	int GIFcolorS;
	int GIFcolorC;
	int GIFcolorF;
	int animatedGifDelay;
}
//returns the gif images
@property(nonatomic,retain)NSArray* images;

//the animation duration
@property(nonatomic,assign)CGFloat animationDuration;


//decodes into the gif data.
-(void)runDecoder:(NSData*)data;

//return if the data is a gif or not
+(BOOL)isGif:(NSData*)data;

+(GPGif*)decodeGif:(NSData*)data;

+(void)setupImageView:(UIImageView*)imgView gifObject:(GPGif*)gifObject;

+(void)imageView:(UIImageView*)imgView withData:(NSData*)gifData;

@end
