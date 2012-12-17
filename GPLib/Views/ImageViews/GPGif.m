//
//  GPGif.m
//  TestApp
//
//  Created by Dalton Cherry on 12/17/12.
//  Copyright (c) 2012 Basement Krew. All rights reserved.
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

#import "GPGif.h"

@implementation GPGif

@synthesize images,animationDuration;

// http://en.wikipedia.org/wiki/Graphics_Interchange_Format#Example_.gif_file
// http://en.wikipedia.org/wiki/Graphics_Interchange_Format#Animated_.gif
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)runDecoder:(NSData*)gifData
{
    GIFpointer = gifData;
    [GIFbuffer release];
    [GIFglobal release];
    [GIFscreen release];
    [GIFdelays release];
    [GIFframesData release];
    
    GIFbuffer = [[NSMutableData alloc] init];
	GIFglobal = [[NSMutableData alloc] init];
	GIFscreen = [[NSMutableData alloc] init];
	GIFframeHeader = nil;
    
	GIFdelays = [[NSMutableArray alloc] init];
	GIFframesData = [[NSMutableArray alloc] init];
    
    // Reset file counters to 0
	dataPointer = 0;
    
    // GIF89a, throw away
    int length = 6;
    if ([GIFpointer length] >= dataPointer + length)
        dataPointer += length;
	[self GIFGetBytes: 7]; // Logical Screen Descriptor
    
    // Deep copy
	[GIFscreen setData: GIFbuffer];
    
    // Copy the read bytes into a local buffer on the stack
    // For easy byte access in the following lines.
    length = [GIFbuffer length];
	unsigned char aBuffer[length];
	[GIFbuffer getBytes:aBuffer length:length];
    
	if (aBuffer[4] & 0x80)
        GIFcolorF = 1;
    else
        GIFcolorF = 0;
    
	if (aBuffer[4] & 0x08)
        GIFsorted = 1;
    else
        GIFsorted = 0;
    
	GIFcolorC = (aBuffer[4] & 0x07);
	GIFcolorS = 2 << GIFcolorC;
    
	if (GIFcolorF == 1)
    {
		[self GIFGetBytes: (3 * GIFcolorS)];
		[GIFglobal setData:GIFbuffer]; // Deep copy
	}
    
	unsigned char bBuffer[1];
	while([self GIFGetBytes:1])
    {
        [GIFbuffer getBytes:bBuffer length:1];
        
        if (bBuffer[0] == 0x3B) // This is the end
            break;
        else if (bBuffer[0] == 0x21)
            [self GIFReadExtensions];
        else if(bBuffer[0] == 0x2C)
            [self GIFReadDescriptor];
	}
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[GIFframesData count]];
    for (int i = 0; i < [GIFframesData count]; i++)
        [array addObject: [self getFrameAsImageAtIndex:i]];
    self.images = array;
    
    double total = 0;
    for (int i = 0; i < [GIFdelays count]; i++)
        total += [[GIFdelays objectAtIndex:i] doubleValue];
    
    // GIFs store the delays as 1/100th of a second,
    // UIImageViews want it in seconds.
    self.animationDuration = total/100;
	// clean up stuff
	[GIFbuffer release];
    GIFbuffer = nil;
    
	[GIFscreen release];
    GIFscreen = nil;
    
	[GIFglobal release];
    GIFglobal = nil;
    
    
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)GIFReadExtensions
{
	// 21! But we still could have an Application Extension,
	// so we want to check for the full signature.
	unsigned char cur[1], prev[1];
    [self GIFGetBytes:1];
    [GIFbuffer getBytes:cur length:1];
    
	while (cur[0] != 0x00)
    {
        
		// TODO: Known bug, the sequence F9 04 could occur in the Application Extension, we
		//       should check whether this combo follows directly after the 21.
		if (cur[0] == 0x04 && prev[0] == 0xF9)
		{
			[self GIFGetBytes:5];
            
			unsigned char buffer[5];
			[GIFbuffer getBytes:buffer length:5];
            
			// We save the delays for easy access.
			[GIFdelays addObject:[NSNumber numberWithInt:(buffer[1] | buffer[2] << 8)]];
            
			if (GIFframeHeader == nil)
			{
			    unsigned char board[8];
				board[0] = 0x21;
				board[1] = 0xF9;
				board[2] = 0x04;
                
				for(int i = 3, a = 0; a < 5; i++, a++)
				{
					board[i] = buffer[a];
				}
                
				GIFframeHeader = [NSMutableData dataWithBytes:board length:8];
			}
            
			break;
		}
        
		prev[0] = cur[0];
        [self GIFGetBytes:1];
		[GIFbuffer getBytes:cur length:1];
	}
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void) GIFReadDescriptor
{
	[self GIFGetBytes:9];
    
    // Deep copy
	NSMutableData *GIF_screenTmp = [NSMutableData dataWithData:GIFbuffer];
    
	unsigned char aBuffer[9];
	[GIFbuffer getBytes:aBuffer length:9];
    
	if (aBuffer[8] & 0x80)
        GIFcolorF = 1;
    else
        GIFcolorF = 0;
    
	unsigned char GIF_code = GIFcolorC, GIF_sort = GIFsorted;
    
	if (GIFcolorF == 1)
    {
		GIF_code = (aBuffer[8] & 0x07);
        
		if (aBuffer[8] & 0x20)
            GIF_sort = 1;
        else
        	GIF_sort = 0;
	}
    
	int GIF_size = (2 << GIF_code);
    
	size_t blength = [GIFscreen length];
	unsigned char bBuffer[blength];
	[GIFscreen getBytes:bBuffer length:blength];
    
	bBuffer[4] = (bBuffer[4] & 0x70);
	bBuffer[4] = (bBuffer[4] | 0x80);
	bBuffer[4] = (bBuffer[4] | GIF_code);
    
	if (GIF_sort)
		bBuffer[4] |= 0x08;
    
    NSMutableData *GIF_string = [NSMutableData dataWithData:[@"GIF89a" dataUsingEncoding: NSUTF8StringEncoding]];
	[GIFscreen setData:[NSData dataWithBytes:bBuffer length:blength]];
    [GIF_string appendData: GIFscreen];
    
    
	if (GIFcolorF == 1)
    {
		[self GIFGetBytes:(3 * GIF_size)];
        [GIF_string appendData: GIFbuffer];
	}
    else
		[GIF_string appendData: GIFglobal];
    
	// Add Graphic Control Extension Frame (for transparancy)
	[GIF_string appendData:GIFframeHeader];
    
	char endC = 0x2c;
	[GIF_string appendBytes:&endC length:sizeof(endC)];
    
	size_t clength = [GIF_screenTmp length];
	unsigned char cBuffer[clength];
	[GIF_screenTmp getBytes:cBuffer length:clength];
    
	cBuffer[8] &= 0x40;
    
	[GIF_screenTmp setData:[NSData dataWithBytes:cBuffer length:clength]];
    
	[GIF_string appendData: GIF_screenTmp];
	[self GIFGetBytes:1];
	[GIF_string appendData: GIFbuffer];
    
	while (true)
    {
		[self GIFGetBytes:1];
		[GIF_string appendData: GIFbuffer];
        
		unsigned char dBuffer[1];
		[GIFbuffer getBytes:dBuffer length:1];
        
		long u = (long) dBuffer[0];
        
		if (u != 0x00)
        {
			[self GIFGetBytes:u];
			[GIF_string appendData: GIFbuffer];
        }
        else
            break;
        
	}
    
	endC = 0x3b;
	[GIF_string appendBytes:&endC length:sizeof(endC)];
    
	// save the frame into the array of frames
	[GIFframesData addObject:[GIF_string copy]];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/* Puts (int) length into the GIF_buffer from file, returns whether read was succesfull */
- (BOOL)GIFGetBytes:(int)length
{
    [GIFbuffer release]; // Release old buffer
    GIFbuffer = nil;
    
	if ([GIFpointer length] >= dataPointer + length) // Don't read across the edge of the file..
    {
		GIFbuffer = [[GIFpointer subdataWithRange:NSMakeRange(dataPointer, length)] retain];
        dataPointer += length;
		return YES;
	}
    else
        return NO;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSMutableData*)getFrameAsDataAtIndex:(int)index
{
	if (index < [GIFframesData count])
		return [GIFframesData objectAtIndex:index];
    return nil;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Use this to put a subframe on your GUI.
- (UIImage*) getFrameAsImageAtIndex:(int)index
{
    NSData *frameData = [self getFrameAsDataAtIndex: index];
    UIImage *image = nil;
    
    if (frameData != nil)
		image = [UIImage imageWithData:frameData];
    return image;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void) dealloc
{
    [GIFbuffer release];
    [GIFscreen release];
    [GIFglobal release];
    [GIFdelays release];
    [GIFframesData release];
	[super dealloc];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+(BOOL)isGif:(NSData*)data
{
    return YES;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+(GPGif*)decodeGif:(NSData*)data
{
    GPGif* gif = [[[GPGif alloc] init] autorelease];
    [gif runDecoder:data];
    return gif;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+(void)setupImageView:(UIImageView*)imgView gifObject:(GPGif*)gifObject
{
    [imgView setAnimationImages:gifObject.images];
    [imgView setImage:[gifObject.images objectAtIndex:0]];
    [imgView setAnimationRepeatCount:0];
    [imgView setAnimationDuration:gifObject.animationDuration];
    [imgView startAnimating];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+(void)imageView:(UIImageView*)imgView withData:(NSData*)gifData
{
    GPGif* gif = [GPGif decodeGif:gifData];
    [GPGif setupImageView:imgView gifObject:gif];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@end
