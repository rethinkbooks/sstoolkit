//
//  UIApplication+SSToolkitAdditions.m
//  SSToolkit
//
//  Created by Sam Soffes on 10/20/10.
//  Copyright 2009-2010 Sam Soffes. All rights reserved.
//

#import "UIApplication+SSToolkitAdditions.h"

@implementation UIApplication (SSToolkitAdditions)

- (BOOL)isPirated {
	// This isn't bulletproof, but should catch a lot of cases. Thanks @marcoarment:
	// http://twitter.com/marcoarment/status/27965461020
	return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"SignerIdentity"] != nil;
}


- (void)setNetworkActivity:(BOOL)inProgress {
	// Ensure we're on the main thread
	if ([NSThread isMainThread] == NO) {
		[self performSelectorOnMainThread:@selector(_setNetworkActivityWithNumber:) withObject:[NSNumber numberWithBool:inProgress] waitUntilDone:NO];
		return;
	}
	
	[[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(_setNetworkActivityIndicatorHidden) object:nil];
	
	if (inProgress == YES) {
		if (self.networkActivityIndicatorVisible == NO) {
			self.networkActivityIndicatorVisible = inProgress;
		}
	} else {
		[self performSelector:@selector(_setNetworkActivityIndicatorHidden) withObject:nil afterDelay:0.3];
	}
}

@end


@interface UIApplication (MSPrivateAdditions)
- (void)_setNetworkActivityWithNumber:(NSNumber *)number;
- (void)_setNetworkActivityIndicatorHidden;
@end

@implementation UIApplication (MSPrivateAdditions)

- (void)_setNetworkActivityWithNumber:(NSNumber *)number {
	[self setNetworkActivity:[number boolValue]];	
}


- (void)_setNetworkActivityIndicatorHidden {
	self.networkActivityIndicatorVisible = NO;
}

@end
