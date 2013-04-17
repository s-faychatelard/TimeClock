//
//  ViewController_iPad.m
//  TimeClock
//
//  Created by Sylvain FAY-CHATELARD on 02/04/13.
//  Copyright (c) 2013 Dviance. All rights reserved.
//

#import "ViewController_iPad.h"

@interface ViewController_iPad ()

@property (strong, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation ViewController_iPad

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[_webView scrollView] setBounces:NO];
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://timeclock.dvce.net"]]];
}

@end
