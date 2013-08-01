//
//  NSDate+Additions.m
//
//  Created by Dalton Cherry on 2/20/12.
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

#import "NSDate+Additions.h"

@implementation NSDate (Additions)


#define MINUTE 60
#define HOUR   (60 * MINUTE)
#define DAY    (24 * HOUR)
#define FIVE_DAYS (5 * DAY)
#define WEEK   (7 * DAY)
#define MONTH  (30.5 * DAY)
#define YEAR   (365 * DAY)

NSLocale* CurrentLocale(void);

///////////////////////////////////////////////////////////////////////////////////////////////////
NSLocale* CurrentLocale() 
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSArray* languages = [defaults objectForKey:@"AppleLanguages"];
    if (languages.count > 0) 
    {
        NSString* currentLanguage = [languages objectAtIndex:0];
        return [[[NSLocale alloc] initWithLocaleIdentifier:currentLanguage] autorelease];
    } 
    else 
        return [NSLocale currentLocale];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)formatTime 
{
    static NSDateFormatter* formatter = nil;
    if (nil == formatter) 
    {
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"h:mm a";
        formatter.locale = CurrentLocale();
    }
    return [formatter stringFromDate:self];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)formatDateTime 
{
    NSTimeInterval diff = abs([self timeIntervalSinceNow]);
    if (diff < DAY)
        return [self formatTime];
        
    else if (diff < FIVE_DAYS) 
    {
        static NSDateFormatter* formatter = nil;
        if (nil == formatter) 
        {
            formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"EEE h:mm a";
            formatter.locale = CurrentLocale();
        }
        return [formatter stringFromDate:self];
        
    } 
    else 
    {
        static NSDateFormatter* formatter = nil;
        if (nil == formatter) 
        {
            formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"MMM d h:mm a";
            formatter.locale = CurrentLocale();
        }
        return [formatter stringFromDate:self];
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)formatRelativeTime 
{
    NSTimeInterval elapsed = abs([self timeIntervalSinceNow]);
    if (elapsed <= 1)
        return NSLocalizedString(@"just a moment ago", nil);
    
    else if (elapsed < MINUTE) 
    {
        int seconds = (int)(elapsed);
        return [NSString stringWithFormat:@"%d seconds ago", seconds];
    } 
    else if (elapsed < 2*MINUTE)
        return NSLocalizedString(@"about a minute ago",nil);
        
    else if (elapsed < HOUR) 
    {
        int mins = (int)(elapsed/MINUTE);
        return [NSString stringWithFormat:@"%d %@", mins,NSLocalizedString(@"minutes ago",nil)];
        
    } 
    else if (elapsed < HOUR*1.5)
        return NSLocalizedString(@"about an hour ago",nil);
        
    else if (elapsed < DAY) 
    {
        int hours = (int)((elapsed+HOUR/2)/HOUR);
        return [NSString stringWithFormat:@"%d %@", hours,NSLocalizedString(@"hours ago",nil)];
    } else 
        return [self formatDateTime];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)formatMailTime
{
    NSTimeInterval diff = abs([self timeIntervalSinceNow]);
    if (diff < DAY)
        return [self formatTime];
    static NSDateFormatter* formatter = nil;
    if (!formatter)
    {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setTimeStyle:NSDateFormatterNoStyle];
        [formatter setDateStyle:NSDateFormatterShortStyle];
        formatter.locale = CurrentLocale();
        [formatter setDoesRelativeDateFormatting:YES];
    }
    return [formatter stringFromDate:self];
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@end
