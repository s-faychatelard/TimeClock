//
//  ViewController.m
//  TimeClock
//
//  Created by Sylvain FAY-CHATELARD on 09/09/13.
//  Copyright (c) 2013 Sylvain FAY-CHATELARD. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIView *containerView;

@property (strong, nonatomic) IBOutlet UIButton *backButton;
@property (strong, nonatomic) IBOutlet UIButton *nextButton;

@property (readwrite) NSInteger controllerIndex;

@end

@implementation ViewController

- (void)viewDidLoad
{
    /* Header */
    [_titleLabel.layer setBorderWidth:.5];
    [_titleLabel.layer setBorderColor:[[UIColor colorWithRed:201./255. green:205./255. blue:208./255. alpha:1.] CGColor]];
    
    /* Content */
    [_containerView.layer setBorderWidth:.5];
    [_containerView.layer setCornerRadius:3.];
    [_containerView.layer setBorderColor:[[UIColor colorWithRed:201./255. green:205./255. blue:208./255. alpha:1.] CGColor]];
    
    /* Setup back/next button images */
    [_backButton setImage:[[_backButton imageForState:UIControlStateNormal] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [_nextButton setImage:[[_nextButton imageForState:UIControlStateNormal] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    
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

-(void)setupTitle
{
    [_backButton setEnabled:NO];
    [_nextButton setEnabled:NO];
    
    [UIView animateWithDuration:UINavigationControllerHideShowBarDuration/2. animations:^(void){
        [_titleLabel setAlpha:0.];
        switch (_controllerIndex) {
            case 0:
                [_backButton setAlpha:0.];
                break;
            case 2:
                [_nextButton setAlpha:0.];
                break;
        }
    } completion:^(BOOL finished){
        
        NSString *title = @"Timeclock";
        switch (_controllerIndex) {
            case 0:
                break;
            case 1:
                title = @"Paramètres";
                break;
            case 2:
                title = @"Custom Sign";
                break;
        }
        
        [_titleLabel setText:title];
        
        [UIView animateWithDuration:UINavigationControllerHideShowBarDuration/2. animations:^(void){
            [_titleLabel setAlpha:1.];
            if (_controllerIndex == 1) {
                [_backButton setAlpha:1.];
                [_nextButton setAlpha:1.];
            }
        }];
    }];
}

- (IBAction)back:(id)sender
{
    _controllerIndex--;
    
    [self setupTitle];
    
    CATransition* transition = [CATransition animation];
    transition.duration = UINavigationControllerHideShowBarDuration;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush; //kCATransitionFade; //kCATransitionMoveIn; //, kCATransitionPush, kCATransitionReveal, kCATransitionFade
    transition.subtype = kCATransitionFromLeft; //kCATransitionFromLeft, kCATransitionFromRight, kCATransitionFromTop, kCATransitionFromBottom
    [_navigationController.view.layer addAnimation:transition forKey:nil];
    [_navigationController popViewControllerAnimated:NO];
}

- (IBAction)next:(id)sender
{
    _controllerIndex++;
    
    [self setupTitle];
    
    CATransition* transition = [CATransition animation];
    transition.duration = UINavigationControllerHideShowBarDuration;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush; //kCATransitionMoveIn; //, kCATransitionPush, kCATransitionReveal, kCATransitionFade
    transition.subtype = kCATransitionFromRight; //kCATransitionFromLeft, kCATransitionFromRight, kCATransitionFromTop, kCATransitionFromBottom
    [_navigationController.view.layer addAnimation:transition forKey:nil];
    
    switch (_controllerIndex) {
        case 1:
            [_navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"Settings"] animated:NO];
            break;
        case 2:
            [_navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"Custom"] animated:NO];
            break;
    }
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [_backButton setEnabled:YES];
    [_nextButton setEnabled:YES];
}

@end
