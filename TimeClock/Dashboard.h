//
//  Dashboard.h
//  TimeClock
//
//  Created by Sylvain FAY-CHATELARD on 09/09/13.
//  Copyright (c) 2013 Sylvain FAY-CHATELARD. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Clock.h"

@interface Dashboard : UIViewController <ClockDelegate>

@property (strong, nonatomic) IBOutlet Clock *clock;

-(void)refreshView;

@end
