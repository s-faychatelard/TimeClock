//
//  AppDelegate.m
//  TimeClock
//
//  Created by Sylvain FAY-CHATELARD on 09/09/13.
//  Copyright (c) 2013 Sylvain FAY-CHATELARD. All rights reserved.
//

#import "AppDelegate.h"
#import "Login.h"
#import "Dashboard.h"
#import "ViewController.h"
@import CoreLocation;

NSString *BEACON_IDENTIFIER = @"com.dviance.timeclock.iBeacon";
NSString *BEACON_UUID = @"23542266-18D1-4FE4-B4A1-23F8195B9D39";

@interface AppDelegate () <UIApplicationDelegate, CLLocationManagerDelegate>

@property CLLocationManager *locationManager;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    // This location manager will be used to notify the user of region state transitions.
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self updateMonitoredRegion];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)setUsername:(NSString *)username
{
    _username = username;
    
    [[NSUserDefaults standardUserDefaults] setValue:_username forKey:@"username"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setPassword:(NSString *)password
{
    _password = password;
    
    [[NSUserDefaults standardUserDefaults] setValue:_password forKey:@"password"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    NSString *signType;
    if(state == CLRegionStateInside)
    {
        NSLog(NSLocalizedString(@"You're inside the region", @""));
        signType = @"signin";
    }
    else if(state == CLRegionStateOutside)
    {
        NSLog(NSLocalizedString(@"You're outside the region", @""));
        signType = @"signout";
    }
    else
    {
        return;
    }
    
    NSURL *url = [NSURL URLWithString:API_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5.0];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [request setHTTPMethod:@"POST"];
    NSString *postString = [NSString stringWithFormat:@"action=%@&username=%@&password=%@", signType, [appDelegate username], [appDelegate password]];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    if (data == nil)
    {
        return;
    }
    
    NSError *err = nil;
    NSDictionary *res = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
    if (err || !res || [[res objectForKey:@"success"] intValue] != 0) return;
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    if(state == CLRegionStateInside)
    {
        notification.alertBody = NSLocalizedString(@"You've been logged in", @"");
    }
    else if(state == CLRegionStateOutside)
    {
        notification.alertBody = NSLocalizedString(@"You've been logged out", @"");
    }
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    
    UIViewController *rootViewController = self.window.rootViewController;
    if ([rootViewController isKindOfClass:[Login class]])
    {
        Login *login = (Login*)rootViewController;
        if ([login dashboard])
        {
            ViewController *viewController = (ViewController*)[login dashboard];
            UIViewController *vc = [[viewController navigationController] visibleViewController];
            if ([vc respondsToSelector:@selector(refreshView)]) {
                Dashboard *dashboard = (Dashboard*)vc;
                [dashboard refreshView];
            }
        }
        NSLog(@"The app is open on ViewController");
    }
}

- (void)updateMonitoredRegion
{
    // if region monitoring is enabled, update the region being monitored
    CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:[NSUUID UUID] identifier:BEACON_IDENTIFIER];
    
    if(region != nil)
    {
        [self.locationManager stopMonitoringForRegion:region];
    }
    
    region = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:BEACON_UUID] identifier:BEACON_IDENTIFIER];
    
    if(region)
    {
        region.notifyOnEntry = YES;
        region.notifyOnExit = YES;
        region.notifyEntryStateOnDisplay = YES;
        
        [self.locationManager startMonitoringForRegion:region];
    }
    
    //CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:[NSUUID UUID] identifier:BeaconIdentifier];
    //[self.locationManager stopMonitoringForRegion:region];
}

@end
