//
//  Custom.m
//  TimeClock
//
//  Created by Sylvain FAY-CHATELARD on 01/04/13.
//  Copyright (c) 2013 Dviance. All rights reserved.
//

#import "Custom.h"

#define NB_DAY_BACK 8

@interface Custom ()

@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) IBOutlet UIView *contentView;

@property (strong, nonatomic) IBOutlet UITextField *date;
@property (strong, nonatomic) IBOutlet UITextField *hour;
@property (strong, nonatomic) IBOutlet UITextField *minute;

@property (strong, nonatomic) IBOutlet UIButton *signIn;
@property (strong, nonatomic) IBOutlet UIButton *signOut;

@property (strong, nonatomic) UIPickerView *pickerView;
@property (strong, nonatomic) NSMutableArray *days;

-(IBAction)back:(id)sender;
-(IBAction)signIn:(id)sender;
-(IBAction)signOut:(id)sender;

@end

@implementation Custom

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /* Header */
    [_headerView.layer setBorderWidth:1.];
    [_headerView.layer setBorderColor:[[UIColor colorWithRed:201./255. green:205./255. blue:208./255. alpha:1.] CGColor]];
    
    /* Content */
    [_contentView.layer setBorderWidth:1.];
    [_contentView.layer setBorderColor:[[UIColor colorWithRed:201./255. green:205./255. blue:208./255. alpha:1.] CGColor]];
    
    /* Sign In */
    [_signIn setBackgroundImage:[[UIImage imageNamed:@"signin"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] forState:UIControlStateNormal];
    [_signIn setBackgroundImage:[[UIImage imageNamed:@"signin_active"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] forState:UIControlStateHighlighted];
    [_signIn setBackgroundImage:[[UIImage imageNamed:@"signin_disabled"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] forState:UIControlStateDisabled];
    
    /* Sign Out */
    [_signOut setBackgroundImage:[[UIImage imageNamed:@"signout"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] forState:UIControlStateNormal];
    [_signOut setBackgroundImage:[[UIImage imageNamed:@"signout_active"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] forState:UIControlStateHighlighted];
    [_signOut setBackgroundImage:[[UIImage imageNamed:@"signout_disabled"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] forState:UIControlStateDisabled];
    
    _days = [[NSMutableArray alloc] init];
    [_days addObject:@"Aujourd'hui"];
    [_days addObject:@"Hier"];
    for (int i=2; i<NB_DAY_BACK; i++) {
        NSDate *now = [NSDate dateWithTimeIntervalSinceNow:-i * 24 * 60 * 60];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setLocale:[NSLocale currentLocale]];
        
        NSMutableString *str = [[NSMutableString alloc] init];
        [formatter setDateFormat:@"EEEE"];
        [str appendString:[formatter stringFromDate:now]];
        
        [str appendString:@" "];
        
        [formatter setDateFormat:@"dd"];
        [str appendString:[formatter stringFromDate:now]];
        
        [str appendString:@"/"];
        
        [formatter setDateFormat:@"MM"];
        [str appendString:[formatter stringFromDate:now]];
        
        [_days addObject:str];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self refreshViewForNow];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (_pickerView != nil) return NO;
    
    #define PICKER_HEIGHT 180
    
    _pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, 320, PICKER_HEIGHT)];
    [_pickerView setShowsSelectionIndicator:YES];
    [_pickerView setDataSource:self];
    [_pickerView setDelegate:self];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
    
    [formatter setDateFormat:@"HH"];
    [_pickerView selectRow:[[_hour text] intValue] inComponent:1 animated:NO];
    
    [formatter setDateFormat:@"mm"];
    [_pickerView selectRow:[[_minute text] intValue] inComponent:2 animated:NO];
    
    [self.view addSubview:_pickerView];
    
    [UIView animateWithDuration:.25 animations:^(void){
        [_pickerView setFrame:CGRectMake(0, self.view.frame.size.height - PICKER_HEIGHT, 320, PICKER_HEIGHT)];
    }];
    
    return NO;
}

- (void)hideDatePicker
{
    [UIView animateWithDuration:.25 animations:^(void){
        [_pickerView setFrame:CGRectMake(0, self.view.frame.size.height, 320, PICKER_HEIGHT)];
    } completion:^(BOOL finished){
        [_pickerView removeFromSuperview];
        _pickerView = nil;
    }];
}

- (void)refreshViewForNow
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
    
    NSDate *now = [NSDate date];
    
    [formatter setDateFormat:@"HH"];
    NSString *hour = [formatter stringFromDate:now];
    
    [formatter setDateFormat:@"mm"];
    NSString *minute = [formatter stringFromDate:now];
    
    [_date setText:@"Aujourd'hui"];
    [_hour setText:hour];
    [_minute setText:minute];
}

- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)sendForAction:(int)action
{
    NSMutableString *request = [[NSMutableString alloc] init];
    [request appendFormat:@"action=insert&username=%@&password=%@&type=%d&date=%d&hour=%@&minute=%@", _username, _password, action, [_days indexOfObject:[_date text]], [_hour text], [_minute text]];
    [self performSelectorInBackground:@selector(send:) withObject:request];
}

- (void)send:(NSString*)post
{
    NSURL *url = [NSURL URLWithString:API_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:20.0];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    //NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:post]];
    
    if (data == nil)
    {
        [self performSelectorOnMainThread:@selector(finishedSendWithDictionary:) withObject:nil waitUntilDone:NO];
        return;
    }
    
    NSError *err = nil;
    NSDictionary *res = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
    
    [self performSelectorOnMainThread:@selector(finishedSendWithDictionary:) withObject:res waitUntilDone:NO];
}

- (void)finishedSendWithDictionary:(NSDictionary*)dictionary
{
    if (dictionary == nil || [[dictionary valueForKey:@"success"] intValue] == -1)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Une erreur est survenue durant l'ajout.\nRéessayes un peu plus tard ou va rager sur Sylvain" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        alert=nil;
        return;
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"OK" delegate:nil cancelButtonTitle:@"Fermer" otherButtonTitles:nil];
        [alert show];
        alert=nil;
        return;
    }
}

-(IBAction)signIn:(id)sender
{
    [self hideDatePicker];
    [self sendForAction:1];
}

-(IBAction)signOut:(id)sender
{
    [self hideDatePicker];
    [self sendForAction:2];
}

#pragma mark - UIPickerViewDelegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	switch (component) {
        case 0:
            [_date setText:[_days objectAtIndex:row]];
            break;
        case 1:
            [_hour setText:[NSString stringWithFormat:@"%d", row]];
            break;
        case 2:
            [_minute setText:[NSString stringWithFormat:@"%d", row]];
            break;
    }
}

#pragma mark - UIPickerViewDataSource

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch (component) {
        case 0:
            return [_days objectAtIndex:row];
        default:
            return [NSString stringWithFormat:@"%2d", row];
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	switch (component) {
        case 0:
            return NB_DAY_BACK;
        case 1:
            return 24;
        case 2:
            return 60;
    }
    return 0;
}


- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    switch (component) {
        case 0:
            return 218;
        default:
            return 38;
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}

@end
