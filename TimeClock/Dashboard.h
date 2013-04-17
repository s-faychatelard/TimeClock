//
//  Dashboard.h
//  TimeClock
//
//  Created by Sylvain FAY-CHATELARD on 28/03/13.
//  Copyright (c) 2013 Dviance. All rights reserved.
//

#import "Clock.h"
#import "Settings.h"

@interface Dashboard : UIViewController <ClockDelegate, SettingsDelegate>

@property (strong, nonatomic) Clock *clock;

@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *password;

-(void)refreshView;

@end
