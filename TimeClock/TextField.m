//
//  TextField.m
//  DSL
//
//  Created by Sylvain FAY-CHATELARD on 23/10/12.
//  Copyright (c) 2012 Sylvain FAY-CHATELARD. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "TextField.h"

@implementation TextField

// placeholder position
- (CGRect)textRectForBounds:(CGRect)bounds {
    bounds = CGRectMake(5, 0, bounds.size.width - 5 - 25, bounds.size.height);
    return CGRectInset(bounds , 0 , 0);
}

// text position
- (CGRect)editingRectForBounds:(CGRect)bounds {
    bounds = CGRectMake(5, 0, bounds.size.width - 5 - 25, bounds.size.height);
    return CGRectInset(bounds , 0 , 0);
}

- (void)layoutSubviews {
    
    CGRect frame = self.frame;
    frame.size.height = 40;
    [self setFrame:frame];
    
    //self.backgroundColor = [UIColor colorWithRed:250./255. green:250./255. blue:250./255. alpha:1.];
    
	CALayer *layer = self.layer;
	layer.cornerRadius = 3.;
	layer.borderWidth = 1.;
	layer.borderColor = [[UIColor colorWithRed:205./255. green:205./255. blue:205./255. alpha:1.] CGColor];
	[super layoutSubviews];
}

@end
