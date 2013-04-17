//
//  Custom.h
//  TimeClock
//
//  Created by Sylvain FAY-CHATELARD on 28/03/13.
//  Copyright (c) 2013 Dviance. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Custom : UIViewController <UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *password;

@end
