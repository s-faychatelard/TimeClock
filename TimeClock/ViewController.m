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
@property (strong, nonatomic) UINavigationController *navigationController;

@property (strong, nonatomic) IBOutlet UIButton *backButton;
@property (strong, nonatomic) IBOutlet UIButton *nextButton;

@property (readwrite) NSInteger controllerIndex;

@end

@implementation ViewController

- (void)viewDidLoad
{
    /* Header */
    [_titleLabel.layer setBorderWidth:1.];
    [_titleLabel.layer setBorderColor:[[UIColor colorWithRed:201./255. green:205./255. blue:208./255. alpha:1.] CGColor]];
    
    /* Content */
    [_containerView.layer setBorderWidth:1.];
    [_containerView.layer setCornerRadius:3.];
    [_containerView.layer setBorderColor:[[UIColor colorWithRed:201./255. green:205./255. blue:208./255. alpha:1.] CGColor]];
    
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
    
    [UIView animateWithDuration:.2 animations:^(void){
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
            
            [UIView animateWithDuration:.1 animations:^(void){
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
    
    [_navigationController popViewControllerAnimated:YES];
}

- (IBAction)next:(id)sender
{
    _controllerIndex++;
    
    [self setupTitle];
    
    switch (_controllerIndex) {
        case 1:
            [_navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"Settings"] animated:YES];
            break;
        case 2:
            [_navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"Custom"] animated:YES];
            break;
    }
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [_backButton setEnabled:YES];
    [_nextButton setEnabled:YES];
}

@end
