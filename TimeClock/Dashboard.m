//
//  Dashboard.m
//  TimeClock
//
//  Created by Sylvain FAY-CHATELARD on 09/09/13.
//  Copyright (c) 2013 Sylvain FAY-CHATELARD. All rights reserved.
//

#import "Dashboard.h"

#import "AppDelegate.h"

@interface Dashboard ()

@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UIButton *signIn;
@property (strong, nonatomic) IBOutlet UIButton *signOut;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *signInActivity;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *signOutActivity;

@property (strong, nonatomic) NSArray *titles;
@property (strong, nonatomic) NSArray *titleKeys;

@property (strong, nonatomic) NSDictionary *data;

-(void)sign:(NSString*)signType;
-(IBAction)toggleSign:(id)sender;

@end

@implementation Dashboard

- (void)viewDidLoad
{
    [super viewDidLoad];

	[_clock setupInFrame:_clock.frame];
    [_clock updateClockTimeAnimated:YES];
    [_clock setDelegate:self];
    [_clock start];

    _titles = @[
                @"Journée",
                @"Semaine en cours",
                @"Journée d'hier",
                @"Premier Sign in",
                @"Semaine dernière",
                @"Mois en cours"
                ];
    
    _titleKeys = @[
                   @"day",
                   @"week",
                   @"yesterday",
                   @"first_signin",
                   @"last_week",
                   @"month",
                   ];
    
    /* Content */
    [_tableView.layer setBorderWidth:.5];
    [_tableView.layer setBorderColor:[[UIColor colorWithRed:201./255. green:205./255. blue:208./255. alpha:1.] CGColor]];
    [_tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self refreshView];
}

- (void)refreshView
{
    [self performSelectorInBackground:@selector(get) withObject:nil];
}

- (void)get
{
    NSURL *url = [NSURL URLWithString:API_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:20.0];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [request setHTTPMethod:@"POST"];
    NSString *postString = [NSString stringWithFormat:@"action=get&username=%@&password=%@", [appDelegate username], [appDelegate password]];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    if (data == nil)
    {
        [self performSelectorOnMainThread:@selector(finishedGetWithDictionary:) withObject:nil waitUntilDone:NO];
        return;
    }
    
    NSError *err = nil;
    NSDictionary *res = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
    
    [self performSelectorOnMainThread:@selector(finishedGetWithDictionary:) withObject:res waitUntilDone:NO];
}

- (void)finishedGetWithDictionary:(NSDictionary*)dictionary
{
    if (dictionary == nil)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Une erreur est survenue durant la récupération des données.\nRéessayes un peu plus tard" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        alert=nil;
        return;
    }
    
    _data = dictionary;
    [_tableView reloadData];
    
    if ([[_data objectForKey:@"last_action"] intValue] == 1)
    {
        [_signIn setEnabled:NO];
        [_signOut setEnabled:YES];
    }
    else
    {
        [_signIn setEnabled:YES];
        [_signOut setEnabled:NO];
    }
}

- (void)sign:(NSString*)signType
{
    NSURL *url = [NSURL URLWithString:API_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5.0];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [request setHTTPMethod:@"POST"];
    NSString *postString = [NSString stringWithFormat:@"action=%@&username=%@&password=%@", signType, [appDelegate username], [appDelegate password]];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    if (data == nil)
    {
        [self performSelectorOnMainThread:@selector(result:) withObject:nil waitUntilDone:NO];
        return;
    }
    
    NSError *err = nil;
    NSDictionary *res = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
    
    [self performSelectorOnMainThread:@selector(result:) withObject:res waitUntilDone:NO];
}

- (void)result:(NSDictionary*)dictionary
{
    [_signIn setTitle:@"Sign In" forState:UIControlStateNormal];
    [_signOut setTitle:@"Sign Out" forState:UIControlStateNormal];
    
    [_signInActivity stopAnimating];
    [_signOutActivity stopAnimating];
    
    if ([[dictionary objectForKey:@"success"] intValue] == -1)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Une erreur est survenue durant le SignIn.\nRéessayes un peu plus tard" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        alert=nil;
        return;
    }
    
    [_signIn setEnabled:![_signIn isEnabled]];
    [_signOut setEnabled:![_signOut isEnabled]];
}

- (IBAction)toggleSign:(id)sender
{
    if (sender == _signIn)
    {
        [_signIn setTitle:@"" forState:UIControlStateNormal];
        [_signInActivity startAnimating];
        
        [self performSelectorInBackground:@selector(sign:) withObject:@"signin"];
    }
    else
    {
        [_signOut setTitle:@"" forState:UIControlStateNormal];
        [_signOutActivity startAnimating];
        
        [self performSelectorInBackground:@selector(sign:) withObject:@"signout"];
    }
    
    [self refreshView];
}

#pragma mark - TableView data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _titles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    cell.textLabel.text = [_titles objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = [_data objectForKey:[_titleKeys objectAtIndex:indexPath.row]];
    
    return cell;
}

#pragma mark - SettingsDelegate

- (void)disconnect
{
    NSDictionary *data = [[NSMutableDictionary alloc] initWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:@"users"]];
    
    if (data) {
        [data setValue:@"" forKey:@"pass"];
        
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"users"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - ClockDelegate

- (void)itIs:(NSString *)time
{
    [_timeLabel setText:time];
}

@end
