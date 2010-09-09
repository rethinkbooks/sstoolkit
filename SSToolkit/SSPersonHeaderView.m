//
//  SSPersonHeaderView.m
//  SSToolkit
//
//  Created by Sam Soffes on 9/8/10.
//  Copyright 2010 Sam Soffes. All rights reserved.
//

#import "SSPersonHeaderView.h"
#import "SSDrawingMacros.h"
#import "UIImage+SSToolkitAdditions.h"
#import <QuartzCore/QuartzCore.h>

static CGFloat kSSPersonHeaderViewImageWidth = 64.0;

@interface SSPersonHeaderView (PrivateMethods)
- (void)_updateImage;
@end

@implementation SSPersonHeaderView

@synthesize organization = _organization;
@synthesize imageView = _imageView;
@synthesize personName = _personName;
@synthesize companyName = _companyName;

#pragma mark NSObject

- (void)dealloc {
	[_imageView removeFromSuperview];
	[_imageView release];
	
	self.personName = nil;
	self.companyName = nil;
	[super dealloc];
}


#pragma mark UIView

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		self.backgroundColor = [UIColor groupTableViewBackgroundColor];
		self.opaque = YES;
		
		_organization = NO;
		
		_imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
		_imageView.clipsToBounds = YES;
		_imageView.layer.cornerRadius = 3.0;
		[self addSubview:_imageView];
		[self _updateImage];
	}
	return self;
}


- (void)layoutSubviews {
	_imageView.frame = CGRectMake(19.0, 15.0, kSSPersonHeaderViewImageWidth, kSSPersonHeaderViewImageWidth);
}


- (void)drawRect:(CGRect)rect {
//	96 215
	
	// Person name
	CGRect personNameRect = CGRectMake(96.0, 15.0, 215.0, kSSPersonHeaderViewImageWidth);
	UIFont *personNameFont = [UIFont boldSystemFontOfSize:18.0];
	UILineBreakMode personNameLineBreakMode = UILineBreakModeWordWrap;
	
	[[UIColor whiteColor] set];
	[_personName drawInRect:CGRectAddPoint(personNameRect, CGPointMake(0.0, 1.0)) withFont:personNameFont lineBreakMode:personNameLineBreakMode];
	
	[[UIColor blackColor] set];
	[_personName drawInRect:personNameRect withFont:personNameFont lineBreakMode:personNameLineBreakMode];

}


#pragma mark Private Methods

- (void)_updateImage {
	if (_imageView.image) {
		_imageView.layer.borderColor = [UIColor colorWithWhite:0.0 alpha:0.5].CGColor;
		_imageView.layer.borderWidth = 1.0;
		return;
	}
	
	_imageView.image = [UIImage imageNamed:(_organization ? @"images/ABPictureOrganization.png" : @"images/ABPicturePerson.png") bundle:@"SSToolkit.bundle"];
	_imageView.layer.borderColor = nil;
	_imageView.layer.borderWidth = 0.0;
}


#pragma mark Setters

- (void)setOrganization:(BOOL)org {
	if (_organization == org) {
		return;
	}
	
	_organization = org;
	
	[self _updateImage];
	[self setNeedsDisplay];
}


- (void)setImage:(UIImage *)image {
	self.imageView.image = image;
	[self _updateImage];
}


#pragma mark Getters

- (UIImage *)image {
	return self.imageView.image;
}

@end
