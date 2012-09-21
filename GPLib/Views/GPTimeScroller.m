//
//  GPTimeScroller.m
//  GPLib
//
//  Created by Dalton Cherry on 5/28/12.
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

#import "GPTimeScroller.h"
#import "UIImage+Additions.h"

@interface GPTimeScroller()

-(NSDateFormatter*)formatDate:(NSString*)dateFormat;

@end

@implementation GPTimeScroller

@synthesize delegate,timeLabel,dateLabel,enabled = _enabled;
////////////////////////////////////////////////////////////////////////////////////////////
-(id)init
{
    self.enabled = YES;
    //will need to change this to stretchableImageWithLeftCapWidth for iOS 4 support
    UIImage *background = [UIImage libraryImageNamed:@"timescroll_pointer.png"];
    if([background respondsToSelector:@selector(resizableImageWithCapInsets:)])
        background = [background resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 35.0f, 0.0f, 10.0f)];
    else
        background = [background stretchableImageWithLeftCapWidth:85 topCapHeight:0];
    //stretchableImageWithLeftCapWidth
    
     //UIImage *background = [[UIImage libraryImageNamed:@"timescroll_pointer.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 35.0f, 0.0f, 10.0f)];
    
    if (self = [super initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, background.size.height)]) 
    {
        calendar = [[NSCalendar currentCalendar] retain];
        self.frame = CGRectMake(0.0f, 0.0f, 320.0f, CGRectGetHeight(self.frame));
        self.alpha = 0.0f;
        self.transform = CGAffineTransformMakeTranslation(10.0f, 0.0f);
        
        backgroundView = [[UIImageView alloc] initWithImage:background];
        backgroundView.frame = CGRectMake(CGRectGetWidth(self.frame) - 80.0f, 0.0f, 80.0f, CGRectGetHeight(self.frame));
        [self addSubview:backgroundView];
        [backgroundView release];
        
        if([background respondsToSelector:@selector(resizableImageWithCapInsets:)])
            handContainer = [[UIView alloc] initWithFrame:CGRectMake(5.0f, 4.0f, 20.0f, 20.0f)];
        else
            handContainer = [[UIView alloc] initWithFrame:CGRectMake(2.0f, 4.0f, 20.0f, 20.0f)];
        //handContainer.contentStretch = CGRectMake(0.0f, 35.0f, 0.0f, 10.0f);
        [backgroundView addSubview:handContainer];
        
        hourHand = [[UIView alloc] initWithFrame:CGRectMake(8.0f, 0.0f, 4.0f, 20.0f)];
        UIImageView *hourImageView = [[UIImageView alloc] initWithImage:[UIImage libraryImageNamed:@"timescroll_hourhand.png"]];
        [hourHand addSubview:hourImageView];
        [hourImageView release];
        [handContainer addSubview:hourHand];
        [hourHand release];
        
        minuteHand = [[UIView alloc] initWithFrame:CGRectMake(8.0f, 0.0f, 4.0f, 20.0f)];
        UIImageView *minuteImageView = [[UIImageView alloc] initWithImage:[UIImage libraryImageNamed:@"timescroll_minutehand.png"]];
        [minuteHand addSubview:minuteImageView];
        [minuteImageView release];
        [handContainer addSubview:minuteHand];
        [minuteHand release];
        
        [handContainer release];
        
        timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(30.0f, 4.0f, 50.0f, 20.0f)];
        timeLabel.textColor = [UIColor whiteColor];
        timeLabel.shadowColor = [UIColor blackColor];
        timeLabel.shadowOffset = CGSizeMake(-0.5f, -0.5f);
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:9.0f];
        timeLabel.autoresizingMask = UIViewAutoresizingNone;
        [backgroundView addSubview:timeLabel];
        [timeLabel release];
        
        dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(30.0f, 9.0f, 100.0f, 20.0f)];
        dateLabel.textColor = [UIColor colorWithRed:179.0f green:179.0f blue:179.0f alpha:0.60f];
        dateLabel.shadowColor = [UIColor blackColor];
        dateLabel.shadowOffset = CGSizeMake(-0.5f, -0.5f);
        
        NSDate *today = [NSDate date];
        NSDateFormatter *dateFormatter = [self formatDate:@"h:mm a"];
        NSString *currentTime = [dateFormatter stringFromDate:today];
        dateLabel.text = currentTime;
        dateLabel.backgroundColor = [UIColor clearColor];
        dateLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:9.0f];
        dateLabel.alpha = 0.0f;
        [backgroundView addSubview:dateLabel];
        [dateLabel release];

        [self createFormatters];
    }
    return self;
}
////////////////////////////////////////////////////////////////////////////////////////////
-(NSDateFormatter*)formatDate:(NSString*)dateFormat
{
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setCalendar:calendar];
    [dateFormatter setTimeZone:calendar.timeZone];
    [dateFormatter setDateFormat:dateFormat];
    return dateFormatter;
}
////////////////////////////////////////////////////////////////////////////////////////////
- (void)createFormatters
{
    timeDateFormatter = [[self formatDate:@"h:mm a"] retain];   
    dayOfWeekDateFormatter =  [[self formatDate:@"cccc"] retain];
    monthDayDateFormatter = [[self formatDate:@"MMMM d"] retain]; 
    monthDayYearDateFormatter = [[self formatDate:@"MMMM d, yyyy"] retain]; 
}
////////////////////////////////////////////////////////////////////////////////////////////
- (void)captureScrollBar
{    
    tableView = [self.delegate tableViewForTimeScroller:self];
    self.frame = CGRectMake(CGRectGetWidth(self.frame) - 10.0f, 0.0f, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    
    for (id subview in [tableView subviews]) 
    {
        if ([subview isKindOfClass:[UIImageView class]]) 
        {
            UIImageView *imageView = (UIImageView *)subview;
            if (imageView.frame.size.width == 7.0f) 
            {
                imageView.clipsToBounds = NO;
                [imageView addSubview:self];
                scrollBar = imageView;
            }
        }
    }
    
}
////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewDidScroll 
{
    if(!self.enabled)
        return;
    
    if (!tableView || !scrollBar) 
        [self captureScrollBar];
    
    CGRect frame = self.frame;
    CGRect scrollBarFrame = scrollBar.frame;
    
    self.frame = CGRectMake(CGRectGetWidth(frame) * -1.0f,
                            (CGRectGetHeight(scrollBarFrame) / 2.0f) - (CGRectGetHeight(frame) / 2.0f),
                            CGRectGetWidth(frame),
                            CGRectGetHeight(frame));
    
    CGPoint point = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    point = [scrollBar convertPoint:point toView:tableView];
    
    UIView *view = [tableView hitTest:point withEvent:UIEventTypeTouches];
    
    if ([view.superview isKindOfClass:[UITableViewCell class]])
        [self updateDisplayWithCell:(UITableViewCell *)view.superview];
    
}
////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewDidEndDecelerating 
{
    CGRect newFrame = [scrollBar convertRect:self.frame toView:tableView.superview];
    self.frame = newFrame;
    [tableView.superview addSubview:self];
    
    [UIView animateWithDuration:0.3f delay:1.0f options:UIViewAnimationOptionBeginFromCurrentState  animations:^{
        self.alpha = 0.0f;
        self.transform = CGAffineTransformMakeTranslation(10.0f, 0.0f);
    } completion:^(BOOL finished) {
    }];
    
}

////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewWillBeginDragging 
{    
    CGRect selfFrame = self.frame;
    CGRect scrollBarFrame = scrollBar.frame;
    
    self.frame = CGRectMake(CGRectGetWidth(selfFrame) * -1.0f,
                            (CGRectGetHeight(scrollBarFrame) / 2.0f) - (CGRectGetHeight(selfFrame) / 2.0f),
                            CGRectGetWidth(selfFrame),
                            CGRectGetHeight(selfFrame));
    
    [scrollBar addSubview:self];
    
    [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState  animations:^{
        self.alpha = 1.0f;
        self.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
    }];
    
    
}

////////////////////////////////////////////////////////////////////////////////////////////
- (void)updateDisplayWithCell:(UITableViewCell *)cell 
{    
    NSDate *date = [self.delegate dateForCell:cell];
    
    if ([date isEqualToDate:lastDate])
        return;
    NSDate *today = [NSDate date];
    if(!date)
        date = today;
    if(!lastDate)
        lastDate = [[NSDate date] retain];
    
    NSDateComponents *dateComponents = [self componentsFormat:date];
    NSDateComponents *todayComponents = [self componentsFormat:today];    
    NSDateComponents *lastDateComponents = [self componentsFormat:lastDate]; 
    
    timeLabel.text = [timeDateFormatter stringFromDate:date];
    
    CGFloat currentHourAngle = 0.5f * ((lastDateComponents.hour * 60.0f) + lastDateComponents.minute);
    CGFloat newHourAngle = 0.5f * ((dateComponents.hour * 60.0f) + dateComponents.minute);
    
    CGFloat currentMinuteAngle = 6.0f * lastDateComponents.minute;
    CGFloat newMinuteAngle = 6.0f * dateComponents.minute;   
    
    currentHourAngle = currentHourAngle > 360 ? currentHourAngle - 360 : currentHourAngle;
    newHourAngle = newHourAngle > 360 ? newHourAngle - 360 : newHourAngle;
    
    currentMinuteAngle = currentMinuteAngle > 360 ? currentMinuteAngle - 360 : currentMinuteAngle;
    newMinuteAngle = newMinuteAngle > 360 ? newMinuteAngle - 360 : newMinuteAngle;
    
    static CGFloat hourPart[4];
    static CGFloat minutePart[4];
    
    [self computeHand:currentHourAngle newAngle:newHourAngle parts:hourPart date:date];
    [self computeHand:currentMinuteAngle newAngle:newMinuteAngle parts:minutePart date:date];
    
    [self animationHand:hourPart minutePart:minutePart];
    
    [lastDate release];
    lastDate = nil;
    lastDate = [date retain];
    
    
    CGRect backgroundFrame;
    CGRect timeLabelFrame;
    CGRect dateLabelFrame = dateLabel.frame;
    NSString *dateLabelString;
    NSString *timeLabelString = timeLabel.text;
    CGFloat dateLabelAlpha;
    
    if (dateComponents.year == todayComponents.year && dateComponents.month == todayComponents.month && dateComponents.day == todayComponents.day) 
    {
        dateLabelString = @"";
        backgroundFrame = CGRectMake(CGRectGetWidth(self.frame) - 80.0f, 0.0f, 80.0f, CGRectGetHeight(self.frame));
        timeLabelFrame = CGRectMake(30.0f, 4.0f, 100.0f, 20.0f);
        dateLabelAlpha = 0.0f;
    } 
    else if ((dateComponents.year == todayComponents.year) && (dateComponents.month == todayComponents.month) && (dateComponents.day == todayComponents.day - 1)) 
    {
        timeLabelFrame = CGRectMake(30.0f, 4.0f, 100.0f, 10.0f);
        dateLabelString = @"Yesterday";
        dateLabelAlpha = 1.0f;
        backgroundFrame = CGRectMake(CGRectGetWidth(self.frame) - 85.0f, 0.0f, 85.0f, CGRectGetHeight(self.frame));
    } 
    else if ((dateComponents.year == todayComponents.year) && [dateComponents respondsToSelector:@selector(weekOfYear)] && (dateComponents.weekOfYear == todayComponents.weekOfYear))
    {
        timeLabelFrame = CGRectMake(30.0f, 4.0f, 100.0f, 10.0f);                
        dateLabelString = [dayOfWeekDateFormatter stringFromDate:date];
        dateLabelAlpha = 1.0f;
        
        CGFloat width = 0.0f;
        if ([dateLabelString sizeWithFont:dateLabel.font].width < 50)
            width = 85.0f;
        else 
            width = 95.0f;
        
        backgroundFrame = CGRectMake(CGRectGetWidth(self.frame) - width, 0.0f, width, CGRectGetHeight(self.frame));
        
    } 
    else 
    {
        timeLabelFrame = CGRectMake(30.0f, 4.0f, 100.0f, 10.0f);
        dateLabelString = [monthDayYearDateFormatter stringFromDate:date];
        dateLabelAlpha = 1.0f;
        CGFloat width = [dateLabelString sizeWithFont:dateLabel.font].width + 50.0f;
        backgroundFrame = CGRectMake(CGRectGetWidth(self.frame) - width, 0.0f, width, CGRectGetHeight(self.frame));
    } 
    
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowAnimatedContent animations:^{
        
        timeLabel.frame = timeLabelFrame;
        dateLabel.frame = dateLabelFrame;
        dateLabel.alpha = dateLabelAlpha;
        timeLabel.text = timeLabelString;
        dateLabel.text = dateLabelString;
        backgroundView.frame = backgroundFrame;
        
    } completion:^(BOOL finished) {
    }];
    
}
////////////////////////////////////////////////////////////////////////////////////////////
-(NSDateComponents*)componentsFormat:(NSDate*)date
{
    return [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekOfYearCalendarUnit | NSWeekCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:date];
}
////////////////////////////////////////////////////////////////////////////////////////////
-(void)setParts:(CGFloat*)array currentAngle:(float)currentAngle part:(float)part
{
    array[0] = currentAngle + part;
    array[1] = array[0] + part;
    array[2] = array[1] + part;
    array[3] = array[2] + part;
    
    //for(int i = 0; i < 4; i++)
    //    NSLog(@"array[%d]: %f",i, array[i]);
}
////////////////////////////////////////////////////////////////////////////////////////////
-(void)animationHand:(CGFloat*)hour minutePart:(CGFloat*)minute
{
    animationIndex = 0;
    [self animate:hour minutePart:minute];
}
////////////////////////////////////////////////////////////////////////////////////////////
-(void)animate:(CGFloat*)hour minutePart:(CGFloat*)minute
{
    int i = animationIndex++;
    [UIView animateWithDuration:0.075f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseIn animations:^{
        
        hourHand.transform =  CGAffineTransformMakeRotation(hour[i] * (M_PI / 180.0f));
        minuteHand.transform =  CGAffineTransformMakeRotation(minute[i] * (M_PI / 180.0f));
        
    } completion:^(BOOL finished){
        if(finished && animationIndex < 4 && animationIndex != NSNotFound)
            [self animate:hour minutePart:minute];
    }];
}
////////////////////////////////////////////////////////////////////////////////////////////
-(void)computeHand:(CGFloat)currentAngle newAngle:(CGFloat)newAngle parts:(CGFloat*)parts date:(NSDate*)date
{
    if (newAngle > currentAngle && [date timeIntervalSinceDate:lastDate] > 0) 
    {
        CGFloat diff = newAngle - currentAngle;
        CGFloat part = diff / 4.0f;
        [self setParts:parts currentAngle:currentAngle part:part];
    } 
    else if (newAngle < currentAngle && [date timeIntervalSinceDate:lastDate] > 0)
    {
        CGFloat diff = (360 - currentAngle) + newAngle;
        CGFloat part = diff / 4.0f;
        [self setParts:parts currentAngle:currentAngle part:part];
        
    } 
    else if (newAngle > currentAngle && [date timeIntervalSinceDate:lastDate] < 0) 
    {
        CGFloat diff = ((currentAngle) * -1.0f) - (360 - newAngle);
        CGFloat part = diff / 4.0f;
        [self setParts:parts currentAngle:currentAngle part:part];
    } 
    else if (newAngle < currentAngle && [date timeIntervalSinceDate:lastDate] < 0) 
    {
        CGFloat diff = currentAngle - newAngle;
        CGFloat part = diff / 4;
        //minus
        [self setParts:parts currentAngle:currentAngle part:-part];
    } 
    else 
        parts[0] = parts[1] = parts[2] = parts[3] = currentAngle;
}
////////////////////////////////////////////////////////////////////////////////////////////
-(void)setEnabled:(BOOL)enable
{
    _enabled = enable;
    self.hidden = !enable;
}
////////////////////////////////////////////////////////////////////////////////////////////
-(void)dealloc
{
    [calendar release];
    [backgroundView release];
    [handContainer release];
    [hourHand release];
    [minuteHand release];
    [lastDate release];
    [timeDateFormatter release];   
    [dayOfWeekDateFormatter release];
    [monthDayDateFormatter release]; 
    [monthDayYearDateFormatter release];
    [super dealloc];
}
////////////////////////////////////////////////////////////////////////////////////////////
@end