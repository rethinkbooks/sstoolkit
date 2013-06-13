//
//  UIViewController+SSToolkitAdditions.m
//  SSToolkit
//
//  Created by Sam Soffes on 6/21/10.
//  Copyright 2009-2010 Sam Soffes. All rights reserved.
//

#import "UIViewController+SSToolkitAdditions.h"

@implementation UIViewController (SSToolkitAdditions)

- (void)displayError:(NSError *)error {
	if (!error) {
		return;
	}
	
	[self displayErrorString:[error localizedDescription]];
}


- (void)displayErrorString:(NSString *)string {
	if (!string || [string length] < 1) {
		return;
	}
	// LLLLLL
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Alert error title") message:string delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
}

@end
