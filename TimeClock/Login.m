//
//  Login.m
//  TimeClock
//
//  Created by Sylvain FAY-CHATELARD on 30/03/13.
//  Copyright (c) 2013 Dviance. All rights reserved.
//

#import "Login.h"
#import "Dashboard.h"

@interface Login ()

@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) IBOutlet UIView *contentView;

@property (strong, nonatomic) IBOutlet UITextField *username;
@property (strong, nonatomic) IBOutlet UITextField *password;

@property (strong, nonatomic) IBOutlet UIButton *connexion;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activity;

-(IBAction)connexion:(id)sender;

@end

@implementation Login

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /* Header */
    [_headerView.layer setBorderWidth:1.];
    [_headerView.layer setBorderColor:[[UIColor colorWithRed:201./255. green:205./255. blue:208./255. alpha:1.] CGColor]];
    
    /* Content */
    [_contentView.layer setBorderWidth:1.];
    [_contentView.layer setBorderColor:[[UIColor colorWithRed:201./255. green:205./255. blue:208./255. alpha:1.] CGColor]];
    
    /* Connexion */
    [_connexion setBackgroundImage:[[UIImage imageNamed:@"connexion"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] forState:UIControlStateNormal];
    [_connexion setBackgroundImage:[[UIImage imageNamed:@"connexion_active"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] forState:UIControlStateHighlighted];
}

- (void)tryLogin
{
    NSDictionary *data = [self loadFromDisk];
    if (data && [data objectForKey:@"user"] != nil && [data objectForKey:@"pass"] != nil)
    {
        [_username setText:[data objectForKey:@"user"]];
        
        if (![[data objectForKey:@"pass"] isEqual:@""])
        {
            [_password setText:[data objectForKey:@"pass"]];
            [self connexion:nil];
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if (textField == _username)
        [_password becomeFirstResponder];
    else
    {
        [self connexion:nil];
        [textField resignFirstResponder];
    }
    return YES;
}

- (IBAction)connexion:(id)sender
{
    [_activity startAnimating];
    [_connexion setTitle:@"" forState:UIControlStateNormal];
    
    [self performSelectorInBackground:@selector(login) withObject:nil];
}

- (void)login
{
    [self loginWithUsername:[_username text] andPassword:[_password text]];
}

- (void)loginWithUsername:(NSString*)username andPassword:(NSString*)password
{
    NSURL *url = [NSURL URLWithString:API_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:20.0];
    
    [request setHTTPMethod:@"POST"];
    NSString *postString = [NSString stringWithFormat:@"action=login&username=%@&password=%@", username, password];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    //NSString *url = [NSString stringWithFormat:@"%@?action=login&username=%@&password=%@", API_URL, username, password];
    //NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    
    if (data == nil)
    {
        [self performSelectorOnMainThread:@selector(showError:) withObject:@"Une erreur est survenue durant la connexion" waitUntilDone:NO];
        return;
    }
    
    NSError *err = nil;
    NSDictionary *res = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
    
    if ([[res objectForKey:@"success"] intValue] != -1)
    {
        [self performSelectorOnMainThread:@selector(openDashboard) withObject:nil waitUntilDone:NO];
    }
    else
    {
        [self performSelectorOnMainThread:@selector(showError:) withObject:[res objectForKey:@"message"] waitUntilDone:NO];
    }
}

- (void)openDashboard
{
    Dashboard *dashboard = [[Dashboard alloc] initWithNibName:@"Dashboard" bundle:nil];
    if (!IS_IPHONE_5)
    {
        dashboard = [[Dashboard alloc] initWithNibName:@"Dashboard4" bundle:nil];
    }
    [dashboard setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [dashboard setUsername:[_username text]];
    [dashboard setPassword:[_password text]];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:dashboard];
    [navigationController setNavigationBarHidden:YES];
    
    [self presentViewController:navigationController animated:YES completion:^(void) {
        
        [_activity stopAnimating];
        [_connexion setTitle:@"Connexion" forState:UIControlStateNormal];
        
        [self saveToDisk];
        [_password setText:@""];
    }];
}

- (void)showError:(NSString*)message
{
    [_activity stopAnimating];
    [_connexion setTitle:@"Connexion" forState:UIControlStateNormal];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithString:message] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    alert=nil;
}

- (void)saveToDisk
{
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    [data setValue:[_username text] forKey:@"user"];
    [data setValue:[_password text] forKey:@"pass"];
    
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"users"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSDictionary*)loadFromDisk
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"users"];
}

@end
