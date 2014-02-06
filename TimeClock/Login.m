//
//  Login.m
//  TimeClock
//
//  Created by Sylvain FAY-CHATELARD on 09/09/13.
//  Copyright (c) 2013 Sylvain FAY-CHATELARD. All rights reserved.
//

#import "Login.h"

#import "AppDelegate.h"

@interface Login ()

@property (strong, nonatomic) IBOutlet UIView *loginView;
@property (strong, nonatomic) IBOutlet UIView *loginLabelView;
@property (strong, nonatomic) IBOutlet UILabel *loginLabel;

@property (strong, nonatomic) IBOutlet UIButton *connexionButton;

@property (strong, nonatomic) IBOutlet UITextField *username;
@property (strong, nonatomic) IBOutlet UITextField *password;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *connexionActivity;

@end

@implementation Login

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    /* Header */
    [_loginLabelView.layer setBorderWidth:.5];
    [_loginLabelView.layer setBorderColor:[[UIColor colorWithRed:201./255. green:205./255. blue:208./255. alpha:1.] CGColor]];
    
    /* Content */
    [_loginView.layer setBorderWidth:.5];
    [_loginView.layer setBorderColor:[[UIColor colorWithRed:201./255. green:205./255. blue:208./255. alpha:1.] CGColor]];
    
    //[_username setText:@"Sylvain"];
    //[_password setText:@"sylvain01"];
    [_username setText:[[NSUserDefaults standardUserDefaults] valueForKey:@"username"]];
    [_password setText:[[NSUserDefaults standardUserDefaults] valueForKey:@"password"]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [_username setEnabled:YES];
    [_password setEnabled:YES];
    [_connexionButton setEnabled:YES];
    [_connexionActivity stopAnimating];
    [_connexionButton setTitle:@"Connexion" forState:UIControlStateNormal];
    
    if (![[_username text] isEqualToString:@""] && ![[_password text] isEqualToString:@""])
    {
        [self connexion:nil];
    }
}

- (IBAction)connexion:(id)sender
{
    if ([[_username text] isEqualToString:@""] && [[_password text] isEqualToString:@""])
    {
        return;
    }
    
    [_username setEnabled:NO];
    [_password setEnabled:NO];
    
    /*CGRect frame = _loginView.frame;
    frame.origin.y = 20;
    
    [UIView animateWithDuration:.25 animations:^(void){
        [_loginView setFrame:frame];
    }];*/
    
    [_connexionButton setEnabled:NO];
    [_connexionActivity startAnimating];
    [_connexionButton setTitle:@"" forState:UIControlStateNormal];
    
    [self performSelector:@selector(connect) withObject:nil afterDelay:5.];
}

- (void)connect
{
    NSURL *url = [NSURL URLWithString:API_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5.0];

    NSString *postString = [NSString stringWithFormat:@"action=login&username=%@&password=%@", [_username text], [_password text]];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    if (data == nil)
    {
        [self performSelectorOnMainThread:@selector(showError:) withObject:@"Une erreur est survenue durant la connexion" waitUntilDone:NO];
        return;
    }
    
    NSError *err = nil;
    NSDictionary *res = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
    
    if ([[res objectForKey:@"success"] intValue] != -1)
    {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate setUsername:[_username text]];
        [appDelegate setPassword:[_password text]];
        
        [_username setText:@""];
        [_password setText:@""];
        
        _dashboard = [self.storyboard instantiateViewControllerWithIdentifier:@"Dashboard"];
        [_dashboard setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
        
        [self presentViewController:_dashboard animated:YES completion:nil];
    }
    else
    {
        [self performSelectorOnMainThread:@selector(showError:) withObject:[res objectForKey:@"message"] waitUntilDone:NO];
    }
}

- (void)showError:(NSString*)message
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setUsername:@""];
    [appDelegate setUsername:@""];
    
    [_username setEnabled:YES];
    [_password setEnabled:YES];
    [_connexionButton setEnabled:YES];
    [_connexionActivity stopAnimating];
    [_connexionButton setTitle:@"Connexion" forState:UIControlStateNormal];
    
    [_password setText:@""];
    [_password becomeFirstResponder];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithString:message] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == _username || isPhone5) return;
    
    CGRect frame = _loginView.frame;
    frame.origin.y = 145 - textField.frame.origin.y;
    
    [UIView animateWithDuration:.25 animations:^(void){
        [_loginView setFrame:frame];
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _username) {
        [_password becomeFirstResponder];
    }
    else {
        [self connexion:_connexionButton];
    }
    
    return YES;
}

@end
