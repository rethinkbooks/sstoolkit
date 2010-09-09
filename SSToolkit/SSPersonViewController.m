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
	[_rowCounts release];
	[_cellData release];
	[super dealloc];
}


#pragma mark Initializers

- (id)initWithPerson:(ABRecordRef)aPerson {
	if (self = [self init]) {
		_headerView = [[SSPersonHeaderView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 84.0)];
		_numberOfSections = 1;
		_rowCounts = [[NSMutableArray alloc] initWithCapacity:_numberOfSections];
		_cellData = [[NSMutableDictionary alloc] init];
		
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


#pragma mark Person

- (void)reload {
	self.displayedPerson = _displayedPerson;
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
	
	// TODO: Calculate number of sections
	_numberOfSections = 1;
	[_rowCounts removeAllObjects];
	
	// Get phone numbers
	ABMultiValueRef phoneNumbersRef = ABRecordCopyValue(_displayedPerson, kABPersonPhoneProperty);
	NSInteger phoneNumbersCount = ABMultiValueGetCount(phoneNumbersRef);
	[_rowCounts addObject:[NSNumber numberWithInteger:phoneNumbersCount]];
	CFRelease(phoneNumbersRef);
	
	for (NSInteger i = 0; i < phoneNumbersCount; i++) {
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];

		NSString *rawLabel = (NSString *)ABMultiValueCopyLabelAtIndex(phoneNumbersRef, i);
		NSString *label = nil;
		if ([rawLabel length] > 9 && [[rawLabel substringWithRange:NSMakeRange(0, 4)] isEqual:@"_$!<"]) {
			label = [rawLabel substringWithRange:NSMakeRange(4, [rawLabel length] - 8)];
		} else {
			label = [[rawLabel copy] autorelease];
		}
		[rawLabel release];
		
		if ([label isEqual:(NSString *)kABPersonPhoneIPhoneLabel] == NO) {
			label = [label lowercaseString];
		}
		
		NSString *phoneNumber = (NSString *)ABMultiValueCopyValueAtIndex(phoneNumbersRef, i);
		
		NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
									label, @"label",
									phoneNumber, @"value",
									nil];
		[phoneNumber release];
		[_cellData setObject:dictionary forKey:indexPath];
		[dictionary release];
	}
	
	[self.tableView reloadData];
}


#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return _numberOfSections;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[_rowCounts objectAtIndex:section] integerValue];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *value2CellIdentifier = @"value2CellIdentifier";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:value2CellIdentifier];
	if (!cell) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:value2CellIdentifier] autorelease];
	}
	
	NSDictionary *cellDictionary = [_cellData objectForKey:indexPath];
	
	cell.textLabel.text = [cellDictionary objectForKey:@"label"];
	cell.detailTextLabel.text = [cellDictionary objectForKey:@"value"];
	
	return cell;
}

@end
