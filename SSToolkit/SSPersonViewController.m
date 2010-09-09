//
//  SSPersonViewController.m
//  SSToolkit
//
//  Created by Sam Soffes on 9/8/10.
//  Copyright 2010 Sam Soffes. All rights reserved.
//

#import "SSPersonViewController.h"
#import "SSPersonHeaderView.h"

@implementation SSPersonViewController

@synthesize displayedPerson = _displayedPerson; 

#pragma mark NSObject

- (id)init {
	self = [super initWithStyle:UITableViewStyleGrouped];
	return self;
}


- (void)dealloc {
	[_headerView release];
	[super dealloc];
}


#pragma mark Initializers

- (id)initWithPerson:(ABRecordRef)aPerson {
	if (self = [self init]) {
		_headerView = [[SSPersonHeaderView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 79.0)];
		
		self.displayedPerson = aPerson;
	}
	return self;
}


#pragma mark UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.title = @"Info";
	
	self.tableView.tableHeaderView = _headerView;
}

#pragma mark Setters

- (void)setDisplayedPerson:(ABRecordRef)person {
	_displayedPerson = person;
	
	// Image
	if (ABPersonHasImageData(_displayedPerson)) {
		NSData *imageData = (NSData *)ABPersonCopyImageData(_displayedPerson);
		UIImage *image = [UIImage imageWithData:imageData];
		_headerView.image = image;
		[imageData release];
	} else {
		_headerView.image = nil;
	}
	
	// Name
	ABPropertyID nameProperties[] = {
		kABPersonPrefixProperty,
		kABPersonFirstNameProperty,
		kABPersonMiddleNameProperty,
		kABPersonLastNameProperty,
		kABPersonSuffixProperty
	};
	
	NSMutableArray *namePieces = [[NSMutableArray alloc] init];
	NSInteger total = sizeof(nameProperties) / sizeof(ABPropertyID);
	for (NSInteger i = 0; i < total; i++) {
		NSString *piece = (NSString *)ABRecordCopyValue(_displayedPerson, nameProperties[i]);
		if (piece) {
			[namePieces addObject:piece];
			[piece release];
		}
	}
	
	_headerView.personName = [namePieces componentsJoinedByString:@" "];
	[namePieces release];
	
	// Organization
	NSString *organizationName = (NSString *)ABRecordCopyValue(_displayedPerson, kABPersonOrganizationProperty);
	_headerView.organizationName = organizationName;
	[organizationName release];
}

@end
