//
//  Settings.m
//  TimeClock
//
//  Created by Sylvain FAY-CHATELARD on 30/03/13.
//  Copyright (c) 2013 Dviance. All rights reserved.
//

#import "Settings.h"
#import "Custom.h"

@interface Settings ()

@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) IBOutlet UIView *contentView;

@property (strong, nonatomic) IBOutlet UILabel *userLbl;

@property (strong, nonatomic) IBOutlet UIButton *currentDay;
@property (strong, nonatomic) IBOutlet UIButton *previousDay;
@property (strong, nonatomic) IBOutlet UIButton *nextDay;
@property (strong, nonatomic) IBOutlet UIButton *disconnect;

@property (strong, nonatomic) IBOutlet UIButton *back;
@property (strong, nonatomic) IBOutlet UIButton *custom;

@property (strong, nonatomic) IBOutlet UIScrollView *signsScrollView;
@property (strong, nonatomic) NSArray *signs;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activity;

@property (strong, nonatomic) NSMutableDictionary *deleteButtons;
@property (strong, nonatomic) NSMutableArray *views;

@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *password;

@property (strong, nonatomic) NSDictionary *data;
@property (readonly) int dayIndex;

-(IBAction)back:(id)sender;
-(IBAction)openCustom:(id)sender;
-(IBAction)previousDay:(id)sender;
-(IBAction)nextDay:(id)sender;
-(IBAction)disconnect:(id)sender;

-(void)remove:(id)sender;

@end

@implementation Settings

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _dayIndex = 0;
    
    /* Header */
    [_headerView.layer setBorderWidth:1.];
    [_headerView.layer setBorderColor:[[UIColor colorWithRed:201./255. green:205./255. blue:208./255. alpha:1.] CGColor]];
    
    /* Content */
    [_contentView.layer setBorderWidth:1.];
    [_contentView.layer setBorderColor:[[UIColor colorWithRed:201./255. green:205./255. blue:208./255. alpha:1.] CGColor]];
    
    /* Disconnect */
    [_disconnect setBackgroundImage:[[UIImage imageNamed:@"signout"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] forState:UIControlStateNormal];
    [_disconnect setBackgroundImage:[[UIImage imageNamed:@"signout_active"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] forState:UIControlStateHighlighted];
    
    
    [_back setBackgroundImage:[[UIImage imageNamed:@"gray"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] forState:UIControlStateNormal];
    [_back setBackgroundImage:[[UIImage imageNamed:@"gray_active"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] forState:UIControlStateHighlighted];
    
    [_custom setBackgroundImage:[[UIImage imageNamed:@"gray"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] forState:UIControlStateNormal];
    [_custom setBackgroundImage:[[UIImage imageNamed:@"gray_active"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] forState:UIControlStateHighlighted];
    
    [self drawLineInView:self.view andInRect:CGRectMake(10, 150, self.view.frame.size.width - 20, 1)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_username != nil && ![_username isEqualToString:@""] && _password != nil && ![_password isEqualToString:@""])
    {
        [self refreshView];
    }
}

- (void)refreshView
{
    [_activity startAnimating];
    [self performSelectorInBackground:@selector(get) withObject:nil];
}

- (void)get
{
    NSURL *url = [NSURL URLWithString:API_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:20.0];
    
    [request setHTTPMethod:@"POST"];
    NSString *postString = [NSString stringWithFormat:@"action=journal&username=%@&password=%@&d=%d", _username, _password, _dayIndex];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    //NSString *url = [NSString stringWithFormat:@"%@?action=journal&username=%@&password=%@&d=%d", API_URL, _username, _password, _dayIndex];
    //NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    
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
    [_activity stopAnimating];
    
    if (dictionary == nil)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Une erreur est survenue durant la récupération des données.\nRéessayes un peu plus tard ou va rager sur Sylvain" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        alert=nil;
        return;
    }
    
    _data = dictionary;
    
    NSDictionary *journal = [_data valueForKey:@"journal"];

    [_currentDay setTitle:[journal valueForKey:@"current_day"] forState:UIControlStateNormal];
    
    if ([[[journal valueForKey:@"next_day"] valueForKey:@"id"] intValue] == -1)
    {
        [_nextDay setHidden:YES];
        [_nextDay setTitle:[[journal valueForKey:@"next_day"] valueForKey:@"text"] forState:UIControlStateNormal];
    }
    else
    {
        [_nextDay setHidden:NO];
        [_nextDay setTitle:[[journal valueForKey:@"next_day"] valueForKey:@"text"] forState:UIControlStateNormal];
    }
    
    if ([[[journal valueForKey:@"previous_day"] valueForKey:@"id"] intValue] == -1)
    {
        [_previousDay setHidden:YES];
        [_previousDay setTitle:[[journal valueForKey:@"previous_day"] valueForKey:@"text"] forState:UIControlStateNormal];
    }
    else
    {
        [_previousDay setHidden:NO];
        [_previousDay setTitle:[[journal valueForKey:@"previous_day"] valueForKey:@"text"] forState:UIControlStateNormal];
    }
    
    _signs = [journal objectForKey:@"signs"];
    
    [self clearViews];
    
    int yOffset = 10;
    #define LABEL_HEIGHT 25
    for (int i=0; i<[_signs count]; i++)
    {
        NSDictionary *sign = [_signs objectAtIndex:i];
        
        UILabel *action = [[UILabel alloc] initWithFrame:CGRectMake(15, yOffset, 72, LABEL_HEIGHT)];
        [action setTextColor:[UIColor colorWithRed:61./255. green:64./255. blue:71./255. alpha:1.]];
        [action setTextAlignment:NSTextAlignmentLeft];
        [action setText:[sign valueForKey:@"action"]];
        
        UILabel *tick = [[UILabel alloc] initWithFrame:CGRectMake(100, yOffset, 94, LABEL_HEIGHT)];
        [tick setTextColor:[UIColor colorWithRed:61./255. green:64./255. blue:71./255. alpha:1.]];
        [tick setTextAlignment:NSTextAlignmentCenter];
        [tick setText:[sign valueForKey:@"tick"]];
        
        UIButton *delete = [[UIButton alloc] initWithFrame:CGRectMake(225, yOffset, 70, LABEL_HEIGHT)];
        [delete setBackgroundImage:[[UIImage imageNamed:@"signout"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] forState:UIControlStateNormal];
        [delete setBackgroundImage:[[UIImage imageNamed:@"signout_active"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] forState:UIControlStateHighlighted];
        [delete setTitleShadowColor:[UIColor colorWithWhite:0. alpha:.24] forState:UIControlStateNormal];
        [[delete titleLabel] setShadowOffset:CGSizeMake(0, 1)];
        [[delete titleLabel] setFont:[UIFont systemFontOfSize:12.]];
        [delete setTitle:@"Supprimer" forState:UIControlStateNormal];
        
        [delete addTarget:self action:@selector(remove:) forControlEvents:UIControlEventTouchUpInside];
        
        [_deleteButtons setObject:[sign valueForKey:@"id"] forKey:[NSString stringWithFormat:@"%p", delete]];
        
        [_signsScrollView addSubview:action];
        [_signsScrollView addSubview:tick];
        [_signsScrollView addSubview:delete];
        
        UIView *v = [self drawLineInView:_signsScrollView andInRect:CGRectMake(5, yOffset + LABEL_HEIGHT + 5, _signsScrollView.frame.size.width - 10, 1)];
        
        [_views addObject:action];
        [_views addObject:tick];
        [_views addObject:delete];
        [_views addObject:v];
        
        yOffset += LABEL_HEIGHT + 10;
    }
    
    if ([_signs count] == 0)
    {
        UILabel *empty = [[UILabel alloc] initWithFrame:CGRectMake(0, 80, _signsScrollView.frame.size.width, LABEL_HEIGHT)];
        [empty setTextColor:[UIColor colorWithRed:61./255. green:64./255. blue:71./255. alpha:1.]];
        [empty setTextAlignment:NSTextAlignmentCenter];
        [empty setText:@"Aucune action enregistrée"];
        
        [_signsScrollView addSubview:empty];
        [_views addObject:empty];
    }
    
    [_signsScrollView setContentSize:CGSizeMake(0, yOffset)];
}

- (void)clearViews
{
    if (_views == nil)
    {
        _views = [[NSMutableArray alloc] init];
        _deleteButtons = [[NSMutableDictionary alloc] init];
        return;
    }
    for (int i=0; i<[_views count]; i++)
    {
        [[_views objectAtIndex:i] removeFromSuperview];
    }
    [_views removeAllObjects];
    [_deleteButtons removeAllObjects];
}

- (UIView*)drawLineInView:(UIView*)view andInRect:(CGRect)rect
{
    UIView *v = [[UIView alloc] initWithFrame:rect];
    [v setBackgroundColor:[UIColor colorWithRed:221./255. green:221./255. blue:221./255. alpha:1.]];
    [view addSubview:v];
    return v;
}

- (void)setUsername:(NSString*)username andPassword:(NSString *)password
{
    _username = username;
    _password = password;
    
    [_userLbl setText:[NSString stringWithFormat:@"Connecté en tant que %@", username]];
    
    [self refreshView];
}

- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)openCustom:(id)sender
{
    Custom *custom = [[Custom alloc] initWithNibName:@"Custom" bundle:nil];
    if (!IS_IPHONE_5)
    {
        custom = [[Custom alloc] initWithNibName:@"Custom4" bundle:nil];
    }
    [custom setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    
    [self.navigationController pushViewController:custom animated:YES];
    
    [custom setUsername:_username];
    [custom setPassword:_password];
}

- (IBAction)previousDay:(id)sender
{
    _dayIndex++;
    [self refreshView];
}

- (IBAction)nextDay:(id)sender
{
    _dayIndex--;
    [self refreshView];
}

- (IBAction)disconnect:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^(void) {
        if (_delegate)
            [_delegate disconnect];
    }];
}

- (void)remove:(id)sender
{
    [_activity startAnimating];
    [self performSelectorInBackground:@selector(removeId:) withObject:[_deleteButtons valueForKey:[NSString stringWithFormat:@"%p", sender]]];
}

- (void)removeId:(NSString*)id
{
    if (id == nil) return;
    
    NSURL *url = [NSURL URLWithString:API_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:20.0];
    
    [request setHTTPMethod:@"POST"];
    NSString *postString = [NSString stringWithFormat:@"action=remove&username=%@&password=%@&id=%@", _username, _password, id];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    //NSString *url = [NSString stringWithFormat:@"%@?action=remove&username=%@&password=%@&id=%@", API_URL, _username, _password, id];
    //NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    
    if (data == nil)
    {
        [self performSelectorOnMainThread:@selector(finishedRemove:) withObject:nil waitUntilDone:NO];
        return;
    }
    
    NSError *err = nil;
    NSDictionary *res = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
    
    [self performSelectorOnMainThread:@selector(finishedRemove:) withObject:res waitUntilDone:NO];
}

- (void)finishedRemove:(NSDictionary*)dictionary
{
    if (dictionary == nil || [[dictionary valueForKey:@"success"] intValue] == -1)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Une erreur est survenue durant la suppression.\nRéessayes un peu plus tard ou va rager sur Sylvain" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        alert=nil;
        return;
    }
    
    [self refreshView];
}

@end
