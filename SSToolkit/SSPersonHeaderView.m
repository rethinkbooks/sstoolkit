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

static CGFloat kSSPersonHeaderViewImageSize = 64.0;

@interface SSPersonHeaderView (PrivateMethods)
- (void)_updateImage;
@end

@implementation SSPersonHeaderView

@synthesize organization = _organization;
@synthesize imageView = _imageView;
@synthesize personName = _personName;
@synthesize organizationName = _organizationName;

#pragma mark NSObject

- (void)dealloc {
	[_imageView removeFromSuperview];
	[_imageView release];
	
	self.personName = nil;
	self.organizationName = nil;
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
	_imageView.frame = CGRectMake(19.0, 15.0, kSSPersonHeaderViewImageSize, kSSPersonHeaderViewImageSize);
}


- (void)drawRect:(CGRect)rect {
	static CGFloat textX = 96.0;

	CGFloat width = self.frame.size.width - 105.0;
	CGSize constraintSize = CGSizeMake(width, 200.0);
	UILineBreakMode lineBreakMode = UILineBreakModeWordWrap;
	UIColor *textColor = [UIColor blackColor];
	UIColor *shadowTextColor = [UIColor whiteColor];
	UIFont *personNameFont = [UIFont boldSystemFontOfSize:18.0];
	UIFont *organizationNameFont = [UIFont systemFontOfSize:14.0];
	
	// Calculate sizes
	CGSize personNameSize = [_personName sizeWithFont:personNameFont constrainedToSize:constraintSize lineBreakMode:lineBreakMode];
	CGSize organizationNameSize = _organizationName ? [_organizationName sizeWithFont:organizationNameFont constrainedToSize:constraintSize lineBreakMode:lineBreakMode] : CGSizeZero;

	// Draw person name
	CGFloat personNameY = 15.0;
	if (_organizationName) {
		personNameY += roundf((kSSPersonHeaderViewImageSize - personNameSize.height - organizationNameSize.height) / 2.0);
	} else {
		personNameY += roundf((kSSPersonHeaderViewImageSize - personNameSize.height) / 2.0);
	}
	CGRect personNameRect = CGRectMake(textX, personNameY, personNameSize.width, personNameSize.height);
	
	[shadowTextColor set];
	[_personName drawInRect:CGRectAddPoint(personNameRect, CGPointMake(0.0, 1.0)) withFont:personNameFont lineBreakMode:lineBreakMode];
	
	[textColor set];
	[_personName drawInRect:personNameRect withFont:personNameFont lineBreakMode:lineBreakMode];
	
	// Draw organization name
	if (_organizationName) {
		CGFloat organizationNameY = personNameRect.origin.y + personNameRect.size.height;
		CGRect organizationNameRect = CGRectMake(textX, organizationNameY, organizationNameSize.width, organizationNameSize.height);
		
		[shadowTextColor set];
		[_organizationName drawInRect:CGRectAddPoint(organizationNameRect, CGPointMake(0.0, 1.0)) withFont:organizationNameFont lineBreakMode:lineBreakMode];

	
		[textColor set];
		[_organizationName drawInRect:organizationNameRect withFont:organizationNameFont lineBreakMode:lineBreakMode];
	}
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
