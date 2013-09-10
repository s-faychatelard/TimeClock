//
//  Settings.m
//  TimeClock
//
//  Created by Sylvain FAY-CHATELARD on 10/09/13.
//  Copyright (c) 2013 Sylvain FAY-CHATELARD. All rights reserved.
//

#import "Settings.h"

#import "AppDelegate.h"

@interface Settings ()

@property (strong, nonatomic) IBOutlet UIButton *currentDay;
@property (strong, nonatomic) IBOutlet UIButton *previousDay;
@property (strong, nonatomic) IBOutlet UIButton *nextDay;
@property (strong, nonatomic) IBOutlet UIButton *disconnect;

@property (strong, nonatomic) IBOutlet UIScrollView *signsScrollView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activity;

@property (strong, nonatomic) NSArray *signs;
@property (strong, nonatomic) NSMutableArray *views;
@property (strong, nonatomic) NSMutableDictionary *deleteButtons;

@property (strong, nonatomic) NSDictionary *data;
@property (readwrite) NSInteger dayIndex;

@end

@implementation Settings

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [self drawLineInView:self.view andInRect:CGRectMake(10, _signsScrollView.frame.origin.y, _signsScrollView.frame.size.width - 20, 1)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self refreshView];
}

- (void)refreshView
{
    [_activity startAnimating];
    [self performSelectorInBackground:@selector(get) withObject:nil];
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
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)get
{
    NSURL *url = [NSURL URLWithString:API_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5.0];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [request setHTTPMethod:@"POST"];
    NSString *postString = [NSString stringWithFormat:@"action=journal&username=%@&password=%@&d=%d", [appDelegate username], [appDelegate password], _dayIndex];
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
    [_activity stopAnimating];
    
    if (dictionary == nil)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Une erreur est survenue durant la récupération des données.\nRéessayes un peu plus tard" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
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
        [action setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
        [action setTextColor:[UIColor colorWithRed:61./255. green:64./255. blue:71./255. alpha:1.]];
        [action setTextAlignment:NSTextAlignmentLeft];
        [action setText:[sign valueForKey:@"action"]];
        
        UILabel *tick = [[UILabel alloc] initWithFrame:CGRectMake(100, yOffset, 94, LABEL_HEIGHT)];
        [tick setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
        [tick setTextColor:[UIColor colorWithRed:61./255. green:64./255. blue:71./255. alpha:1.]];
        [tick setTextAlignment:NSTextAlignmentCenter];
        [tick setText:[sign valueForKey:@"tick"]];
        
        UIButton *delete = [[UIButton alloc] initWithFrame:CGRectMake(225, yOffset, 70, LABEL_HEIGHT)];
        [delete setBackgroundImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
        [delete setBackgroundImage:[UIImage imageNamed:@"delete_active"] forState:UIControlStateHighlighted];
        [delete setTitleShadowColor:[UIColor colorWithWhite:0. alpha:.24] forState:UIControlStateNormal];
        [[delete titleLabel] setShadowOffset:CGSizeMake(0, 1)];
        [[delete titleLabel] setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleFootnote]];
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
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [request setHTTPMethod:@"POST"];
    NSString *postString = [NSString stringWithFormat:@"action=remove&username=%@&password=%@&id=%@", [appDelegate username], [appDelegate password], id];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
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
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Une erreur est survenue durant la suppression.\nRéessayes un peu plus tard" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        alert=nil;
        return;
    }
    
    [self refreshView];
}

@end
