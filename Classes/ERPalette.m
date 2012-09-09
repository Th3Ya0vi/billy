//
//  ERPalette.m
//  Billy
//
//  Created by Eugenijus on 2010-12-27.
//  Copyright 2010 Eugenijus Radlinskas. All rights reserved.
//

#import "ERPalette.h"

@implementation ERPalette

+ (UIColor *)toolbarTint {
	return [UIColor colorWithRed:183.0/255.0 green:41.0/255.0 blue:21.0/255.0 alpha:1.0];
}

+ (UIColor *)editRecordViewBackground {
	return [UIColor colorWithRed:51.0/255.0 green:53.0/255.0 blue:57.0/255.0 alpha:1.0];
}

+ (void)styleNavigationBar:(UINavigationBar *)navigationBar {
    [navigationBar setTintColor:[ERPalette toolbarTint]];
    if ([navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
        //iOS5 new UINavigationBar custom background.
        [navigationBar setBackgroundImage:[UIImage imageNamed: @"Bar.png"] forBarMetrics: UIBarMetricsDefault];
    }
}

@end
