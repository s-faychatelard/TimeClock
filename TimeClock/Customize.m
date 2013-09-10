//
//  Customize.m
//  TimeClock
//
//  Created by Sylvain FAY-CHATELARD on 10/09/13.
//  Copyright (c) 2013 Sylvain FAY-CHATELARD. All rights reserved.
//

#import "Customize.h"

#import "AppDelegate.h"

#define NB_DAY_BACK 8

@interface Customize ()

@property (strong, nonatomic) IBOutlet UITextField *date;
@property (strong, nonatomic) IBOutlet UITextField *hour;
@property (strong, nonatomic) IBOutlet UITextField *minute;

@property (strong, nonatomic) IBOutlet UIButton *signIn;
@property (strong, nonatomic) IBOutlet UIButton *signOut;

@property (strong, nonatomic) UIPickerView *pickerView;
@property (strong, nonatomic) NSMutableArray *days;

-(IBAction)signIn:(id)sender;
-(IBAction)signOut:(id)sender;

@end

@implementation Customize

- (void)viewDidLoad
{
    [super viewDidLoad];
	
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
    
#define PICKER_HEIGHT 140
    
    _pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, 320, PICKER_HEIGHT)];
    [_pickerView setBackgroundColor:[UIColor colorWithRed:257./255. green:257./255. blue:257./255. alpha:1.]];
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

- (void)sendForAction:(int)action
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSMutableString *request = [[NSMutableString alloc] init];
    [request appendFormat:@"action=insert&username=%@&password=%@&type=%d&date=%d&hour=%@&minute=%@", [appDelegate username], [appDelegate password], action, [_days indexOfObject:[_date text]], [_hour text], [_minute text]];
    [self performSelectorInBackground:@selector(send:) withObject:request];
}

- (void)send:(NSString*)post
{
    NSURL *url = [NSURL URLWithString:API_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5.0];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
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
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Une erreur est survenue durant l'ajout.\nRéessayes un peu plus tard" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
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
            return 190;
        default:
            return 52;
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}

@end
