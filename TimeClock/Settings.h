//
//  Settings.h
//  TimeClock
//
//  Created by Sylvain FAY-CHATELARD on 30/03/13.
//  Copyright (c) 2013 Dviance. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SettingsDelegate

-(void)disconnect;

@end

@interface Settings : UIViewController

@property (strong, nonatomic) id<SettingsDelegate> delegate;

-(void)setUsername:(NSString*)username andPassword:(NSString*)password;

@end
