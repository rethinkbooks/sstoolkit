//
//  TCRemoteImageViewDemoViewController.m
//  TWCatalog
//
//  Created by Sam Soffes on 10/9/09.
//  Copyright 2009 Tasteful Works, Inc. All rights reserved.
//

#import "TCRemoteImageViewDemoViewController.h"
#import "TWToolkit/TWLoadingView.h"
#import "TWToolkit/UIView+fading.h"

@implementation TCRemoteImageViewDemoViewController

#pragma mark -
#pragma mark Class Methods
#pragma mark -

+ (TCRemoteImageViewDemoViewController *)setup {
	return [[TCRemoteImageViewDemoViewController alloc] initWithNibName:nil bundle:nil];
}


#pragma mark -
#pragma mark NSObject
#pragma mark -

- (void)dealloc {
	[remoteImageView release];
	[loadingView release];
	[super dealloc];
}


#pragma mark -
#pragma mark UIViewController
#pragma mark -

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.title = @"Image View";
	self.view.backgroundColor = [UIColor whiteColor];
	
	remoteImageView = [[TWRemoteImageView alloc] initWithFrame:CGRectMake(20.0, 20.0, 280.0, 280.0)];
	remoteImageView.placeholderImageView.image = [UIImage imageNamed:@"placeholder.png"];
	remoteImageView.URL = [NSURL URLWithString:@"http://farm3.static.flickr.com/2421/3534460712_3930f69415.jpg"];
	[self.view addSubview:remoteImageView];
	
	loadingView  = [[TWLoadingView alloc] initWithFrame:CGRectMake(20.0, 340.0, 280.0, 20.0)];
	[self.view addSubview:loadingView];
}


#pragma mark -
#pragma mark TWImageViewDelegate
#pragma mark -


@end
