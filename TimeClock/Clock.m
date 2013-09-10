//
//  Clock.m
//  AnalogClockWithImages
//
//  Created by Sylvain FAY-CHATELARD on 28/03/13.
//  Copyright (c) 2013 Dviance. All rights reserved.
//

#import "Clock.h"

#define degreesToRadians(deg) (deg / 180.0 * M_PI)

NSString * const ClockClockFace  = @"clock";
NSString * const ClockHourHand   = @"clock_hour_hand";
NSString * const ClockMinuteHand = @"clock_minute_hand";
NSString * const ClockSecondHand = @"clock_second_hand";

@interface Clock ()

@property (nonatomic, retain) NSTimer *clockUpdateTimer;
@property (nonatomic, retain) NSCalendar *calendar;
@property (nonatomic, retain) NSDate *now;

@property (nonatomic, retain) UIImageView *secondHandImageView;
@property (nonatomic, retain) UIImageView *minuteHandImageView;
@property (nonatomic, retain) UIImageView *hourHandImageView;
@property (nonatomic, retain) UIImageView *clockFaceImageView;

- (void)updateHoursHand;
- (void)updateMinutesHand;
- (void)updateSecondsHand;
- (int)hours;
- (int)minutes;
- (int)seconds;

@end

@implementation Clock

#pragma mark -
#pragma mark Initializers

- (void)setupInFrame:(CGRect)frame
{
    _calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    CGRect imageViewFrame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    
    _clockFaceImageView  = [[UIImageView alloc] initWithFrame:imageViewFrame];
    _hourHandImageView   = [[UIImageView alloc] initWithFrame:imageViewFrame];
    _minuteHandImageView = [[UIImageView alloc] initWithFrame:imageViewFrame];
    _secondHandImageView = [[UIImageView alloc] initWithFrame:imageViewFrame];
    
    [_clockFaceImageView setImage:[UIImage imageNamed:ClockClockFace]];
    [_hourHandImageView setImage:[UIImage imageNamed:ClockHourHand]];
    [_minuteHandImageView setImage:[UIImage imageNamed:ClockMinuteHand]];
    [_secondHandImageView setImage:[UIImage imageNamed:ClockSecondHand]];
    
    [self addSubview:_clockFaceImageView];
    [self addSubview:_hourHandImageView];
    [self addSubview:_minuteHandImageView];
    [self addSubview:_secondHandImageView];
}

#pragma mark -
#pragma marl Start and Stop the clock

- (void)start
{
	self.clockUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateClockTimeAnimated:) userInfo:nil repeats:YES];
    [self updateClockTimeAnimated:NO];
}

- (void)stop
{
	[self.clockUpdateTimer invalidate]; self.clockUpdateTimer = nil;
}

- (void)updateClockTimeAnimated:(BOOL)animated
{
    self.now = [NSDate date];
    
    if (animated) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    }
    
    [self updateHoursHand];
    [self updateMinutesHand];
    [self updateSecondsHand];
    
    if (animated) {
        [UIView commitAnimations];
    }
    
    if (_delegate)
    {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setLocale:[NSLocale currentLocale]];
        
        [formatter setDateFormat:@"HH"];
        int hour = [[formatter stringFromDate:[NSDate date]] intValue];
        
        [formatter setDateFormat:@"mm"];
        int minute = [[formatter stringFromDate:[NSDate date]] intValue];
        
        NSMutableString *time = [[NSMutableString alloc] initWithFormat:@"%d ", hour];
        
        if (hour == 0)
            [time appendString:@"heure"];
        else
            [time appendString:@"heures"];
        
        [time appendFormat:@" et %d ", minute];
        
        if (minute == 0)
            [time appendString:@"minute"];
        else
            [time appendString:@"minutes"];
        [_delegate itIs:time];
    }
}

- (void)updateHoursHand
{
    int degreesPerHour   = 30;
    
    int hours = [self hours];
    int minutes = [self minutes];
    
    int hoursFor12HourClock = hours < 12 ? hours : hours - 12;
    
    float rotationForHoursComponent  = hoursFor12HourClock * degreesPerHour;
    float rotationForMinuteComponent = minutes / 2;
    
    float totalRotation = rotationForHoursComponent + rotationForMinuteComponent;
    
    double hourAngle = degreesToRadians(totalRotation);
    
    self.hourHandImageView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, hourAngle);
}

- (void)updateMinutesHand
{
    int degreesPerMinute = 6;
    
    int minutes = [self minutes];
    
    double minutesAngle = degreesToRadians(minutes * degreesPerMinute);
    
    self.minuteHandImageView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, minutesAngle);
}

- (void)updateSecondsHand
{
    int degreesPerSecond = 6;
    
    int seconds = [self seconds];
    
    double secondsAngle = degreesToRadians(seconds * degreesPerSecond);
    
    self.secondHandImageView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, secondsAngle);
}

- (int)hours
{
    return [[self.calendar components:NSHourCalendarUnit fromDate:self.now] hour];
}

- (int)minutes
{
    return [[self.calendar components:NSMinuteCalendarUnit fromDate:self.now] minute];
}

- (int)seconds
{
    return [[self.calendar components:NSSecondCalendarUnit fromDate:self.now] second];;
}

@end
