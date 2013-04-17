//
//  AppDelegate.h
//  TimeClock
//
//  Created by Sylvain FAY-CHATELARD on 28/03/13.
//  Copyright (c) 2013 Dviance. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UIViewController *viewController;

+(UIViewController*)topMostController;

@end
