//
//  Clock.h
//  AnalogClockWithImages
//
//  Created by Sylvain FAY-CHATELARD on 28/03/13.
//  Copyright (c) 2013 Dviance. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ClockDelegate <NSObject>

@optional
- (void)itIs:(NSString*)time;

@end

@interface Clock : UIView

@property (strong, nonatomic) id<ClockDelegate> delegate;

- (id)initWithFrame:(CGRect)frame;
- (void)start;
- (void)stop;
- (void)updateClockTimeAnimated:(BOOL)animated;

@end
