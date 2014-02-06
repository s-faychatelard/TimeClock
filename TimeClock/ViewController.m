//
//  ViewController.m
//  TimeClock
//
//  Created by Sylvain FAY-CHATELARD on 09/09/13.
//  Copyright (c) 2013 Sylvain FAY-CHATELARD. All rights reserved.
//

#import "ViewController.h"

#import "Customize.h"
#import "Settings.h"

const CGFloat UINavigationControllerChangeDuration = .35;

@interface ViewController () <UINavigationControllerDelegate, UIViewControllerTransitioningDelegate>

@property (strong, nonatomic) IBOutlet UILabel *dashboardLabel;
@property (strong, nonatomic) IBOutlet UILabel *settingsLabel;
@property (strong, nonatomic) IBOutlet UILabel *customLabel;

@property (strong, nonatomic) IBOutlet UIView *titleLabelView;
@property (strong, nonatomic) IBOutlet UIView *containerView;

@property (strong, nonatomic) IBOutlet UIButton *backButton;
@property (strong, nonatomic) IBOutlet UIButton *nextButton;

@property (readwrite) NSInteger controllerIndex;

@end

@implementation ViewController

- (void)viewDidLoad
{
    /* Header */
    [_titleLabelView.layer setBorderWidth:.5];
    [_titleLabelView.layer setBorderColor:[[UIColor colorWithRed:201./255. green:205./255. blue:208./255. alpha:1.] CGColor]];
    
    /* Content */
    [_containerView.layer setBorderWidth:.5];
    [_containerView.layer setBorderColor:[[UIColor colorWithRed:201./255. green:205./255. blue:208./255. alpha:1.] CGColor]];
    
    /* Setup back/next button images */
    [_backButton setImage:[[_backButton imageForState:UIControlStateNormal] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [_nextButton setImage:[[_nextButton imageForState:UIControlStateNormal] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    
    [_backButton setImage:[[_backButton imageForState:UIControlStateHighlighted] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateHighlighted];
    [_nextButton setImage:[[_nextButton imageForState:UIControlStateHighlighted] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateHighlighted];
    
    for (UIViewController *viewController in self.childViewControllers)
    {
        if ([viewController isKindOfClass:[UINavigationController class]])
        {
            _navigationController = (UINavigationController*)viewController;
            [_navigationController setDelegate:self];
        }
    }
    
    _controllerIndex = 0;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setupTitleAnimated:NO];
    
    [_dashboardLabel setFrame:CGRectMake(0, _dashboardLabel.frame.origin.y, _dashboardLabel.frame.size.width, _dashboardLabel.frame.size.height)];
    [_settingsLabel setFrame:CGRectMake(_dashboardLabel.frame.size.width, _settingsLabel.frame.origin.y, _settingsLabel.frame.size.width, _settingsLabel.frame.size.height)];
    [_customLabel setFrame:CGRectMake(_dashboardLabel.frame.size.width, _customLabel.frame.origin.y, _customLabel.frame.size.width, _customLabel.frame.size.height)];
}

-(void)setupTitleAnimated:(BOOL)animated
{
    CGFloat duration = (animated) ? UINavigationControllerChangeDuration : 0;
    
    [UIView animateWithDuration:duration animations:^(void){
        switch (_controllerIndex) {
            case 0:
                // Timeclock
                [_dashboardLabel setFrame:CGRectMake(0, _dashboardLabel.frame.origin.y, _dashboardLabel.frame.size.width, _dashboardLabel.frame.size.height)];
                [_settingsLabel setFrame:CGRectMake(_dashboardLabel.frame.size.width, _settingsLabel.frame.origin.y, _settingsLabel.frame.size.width, _settingsLabel.frame.size.height)];
                [_customLabel setFrame:CGRectMake(_dashboardLabel.frame.size.width*2, _customLabel.frame.origin.y, _customLabel.frame.size.width, _customLabel.frame.size.height)];
                break;
            case 1:
                // Paramètres
                [_dashboardLabel setFrame:CGRectMake(-_dashboardLabel.frame.size.width, _dashboardLabel.frame.origin.y, _dashboardLabel.frame.size.width, _dashboardLabel.frame.size.height)];
                [_settingsLabel setFrame:CGRectMake(0, _settingsLabel.frame.origin.y, _settingsLabel.frame.size.width, _settingsLabel.frame.size.height)];
                [_customLabel setFrame:CGRectMake(_dashboardLabel.frame.size.width, _customLabel.frame.origin.y, _customLabel.frame.size.width, _customLabel.frame.size.height)];
                break;
            case 2:
                // Custom
                [_dashboardLabel setFrame:CGRectMake(-_dashboardLabel.frame.size.width, _dashboardLabel.frame.origin.y, _dashboardLabel.frame.size.width, _dashboardLabel.frame.size.height)];
                [_settingsLabel setFrame:CGRectMake(-_dashboardLabel.frame.size.width, _settingsLabel.frame.origin.y, _settingsLabel.frame.size.width, _settingsLabel.frame.size.height)];
                [_customLabel setFrame:CGRectMake(0, _customLabel.frame.origin.y, _customLabel.frame.size.width, _customLabel.frame.size.height)];
                break;
        }
    } completion:nil];
    
    [UIView animateWithDuration:duration/2. delay:0. options:UIViewAnimationOptionCurveEaseInOut animations:^(void){
        switch (_controllerIndex) {
            case 0:
                
                [_dashboardLabel setAlpha:1.];
                [_settingsLabel setAlpha:0.];
                [_customLabel setAlpha:0.];
                
                [_backButton setAlpha:0.];
                break;
            case 1:
                
                [_dashboardLabel setAlpha:0.];
                [_settingsLabel setAlpha:1.];
                [_customLabel setAlpha:0.];
                
                break;
            case 2:
                
                [_dashboardLabel setAlpha:0.];
                [_settingsLabel setAlpha:0.];
                [_customLabel setAlpha:1.];
                
                [_nextButton setAlpha:0.];
                break;
        }
    } completion:^(BOOL finished){
        [UIView animateWithDuration:duration/2. delay:0. options:UIViewAnimationOptionCurveEaseInOut animations:^(void){
            if (_controllerIndex == 1) {
                [_backButton setAlpha:1.];
                [_nextButton setAlpha:1.];
            }
        }  completion:nil
         ];
    }];
}

- (IBAction)back:(id)sender
{
    _controllerIndex--;
    
    /*CATransition* transition = [CATransition animation];
    transition.duration = UINavigationControllerChangeDuration;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush; //kCATransitionFade; //kCATransitionMoveIn; //, kCATransitionPush, kCATransitionReveal, kCATransitionFade
    transition.subtype = kCATransitionFromLeft; //kCATransitionFromLeft, kCATransitionFromRight, kCATransitionFromTop, kCATransitionFromBottom
    [_navigationController.view.layer addAnimation:transition forKey:nil];*/
    [_navigationController popViewControllerAnimated:YES];
}

- (IBAction)next:(id)sender
{
    _controllerIndex++;
    
    /*CATransition* transition = [CATransition animation];
    transition.duration = UINavigationControllerChangeDuration;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush; //kCATransitionMoveIn; //, kCATransitionPush, kCATransitionReveal, kCATransitionFade
    transition.subtype = kCATransitionFromRight; //kCATransitionFromLeft, kCATransitionFromRight, kCATransitionFromTop, kCATransitionFromBottom
    [_navigationController.view.layer addAnimation:transition forKey:nil];*/
    
    switch (_controllerIndex) {
        case 1:
            [_navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"Settings"] animated:YES];
            break;
        case 2:
            [_navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"Custom"] animated:YES];
            break;
    }
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([viewController isKindOfClass:[Settings class]])
    {
        _controllerIndex = 1;
    }
    else if ([viewController isKindOfClass:[Customize class]])
    {
        _controllerIndex = 2;
    }
    else
    {
        _controllerIndex = 0;
    }
    
    [_backButton setEnabled:NO];
    [_nextButton setEnabled:NO];
    
    [self setupTitleAnimated:YES];
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [_backButton setEnabled:YES];
    [_nextButton setEnabled:YES];
}

@end
