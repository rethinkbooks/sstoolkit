//
//  SSPersonViewController.m
//  SSToolkit
//
//  Created by Sam Soffes on 9/8/10.
//  Copyright 2010 Sam Soffes. All rights reserved.
//

#import "SSPersonViewController.h"
#import "SSPersonHeaderView.h"
#import "NSString+SSToolkitAdditions.h"

@interface SSPersonViewController (PrivateMethods)
+ (NSString *)_formatLabel:(NSString *)rawLabel;
@end

@implementation SSPersonViewController

@synthesize displayedPerson = _displayedPerson; 

#pragma mark Class Methods

+ (NSString *)_formatLabel:(NSString *)rawLabel {
	NSString *label = nil;
	
	// Strip weird wrapper
	if ([rawLabel length] > 9 && [[rawLabel substringWithRange:NSMakeRange(0, 4)] isEqual:@"_$!<"]) {
		label = [rawLabel substringWithRange:NSMakeRange(4, [rawLabel length] - 8)];
	} else {
		label = [[rawLabel copy] autorelease];
	}
	
	// Lowercase unless iPhone
	if ([label isEqual:(NSString *)kABPersonPhoneIPhoneLabel] == NO) {
		label = [label lowercaseString];
	}
	
	return label;
}


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
		_rowCounts = [[NSMutableArray alloc] init];
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
	NSInteger namePiecesTotal = sizeof(nameProperties) / sizeof(ABPropertyID);
	for (NSInteger i = 0; i < namePiecesTotal; i++) {
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

	// Multivalues
	_numberOfSections = 0;
	[_rowCounts removeAllObjects];
	ABPropertyID multiProperties[] = {
		kABPersonPhoneProperty,
		kABPersonEmailProperty,
		kABPersonURLProperty,
//		kABPersonAddressProperty
	};
	
	NSInteger multiPropertiesTotal = sizeof(multiProperties) / sizeof(ABPropertyID);
	for (NSInteger i = 0; i < multiPropertiesTotal; i++) {
		
		// Get values count
		ABMultiValueRef valuesRef = ABRecordCopyValue(_displayedPerson, multiProperties[i]);
		NSInteger valuesCount = ABMultiValueGetCount(valuesRef);
		
		if (valuesCount > 0) {
			_numberOfSections++;
			[_rowCounts addObject:[NSNumber numberWithInteger:valuesCount]];
		} else {
			CFRelease(valuesRef);
			continue;
		}
		
		// Loop through values
		for (NSInteger k = 0; k < valuesCount; k++) {
			NSIndexPath *indexPath = [NSIndexPath indexPathForRow:k inSection:_numberOfSections - 1];

			// Get label
			NSString *rawLabel = (NSString *)ABMultiValueCopyLabelAtIndex(valuesRef, k);
			NSString *label = [[self class] _formatLabel:rawLabel];
			[rawLabel release];
			
			// Get value
			NSString *value = (NSString *)ABMultiValueCopyValueAtIndex(valuesRef, k);
			
			// Get url
			NSString *urlString = nil;
			switch (i) {
				// Phone number
				case 0: {
					NSString *cleanedValue = [value stringByReplacingOccurrencesOfString:@" " withString:@""];
					cleanedValue = [cleanedValue stringByReplacingOccurrencesOfString:@"-" withString:@""];
					cleanedValue = [cleanedValue stringByReplacingOccurrencesOfString:@"(" withString:@""];
					cleanedValue = [cleanedValue stringByReplacingOccurrencesOfString:@")" withString:@""];
					urlString = [NSString stringWithFormat:@"tel://%@", value];
					break;
				}
				
				// Email
				case 1: {
					urlString = [NSString stringWithFormat:@"mailto:%@", value];
					break;
				}
				
				// URL
				case 2: {
					urlString = value;
					break;
				}
				
				// Address
				case 3: {
					urlString = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%@", [value URLEncodedString]];
				}
			}
			
			// Add dictionary to cell data
			NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
										label, @"label",
										value, @"value",
										[NSURL URLWithString:urlString], @"url",
										nil];
			[value release];
			[_cellData setObject:dictionary forKey:indexPath];
			[dictionary release];
		}
		
		CFRelease(valuesRef);
	}
	
	// Note
	NSString *note = (NSString *)ABRecordCopyValue(_displayedPerson, kABPersonNoteProperty);
	if (note) {
		_numberOfSections++;
		[_rowCounts addObject:[NSNumber numberWithInteger:1]];
		
		NSDictionary *noteDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
										@"notes", @"label",
										note, @"value",
										nil];
		[_cellData setObject:noteDictionary forKey:[NSIndexPath indexPathForRow:0 inSection:_numberOfSections - 1]];
		[noteDictionary release];
	}
	[note release];
	
	// Reload table
	if (_numberOfSections < 1) {
		_numberOfSections = 1;
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
	cell.selectionStyle = [[UIApplication sharedApplication] canOpenURL:[cellDictionary objectForKey:@"url"]] ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;
	
	return cell;
}


#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	NSDictionary *cellDictionary = [_cellData objectForKey:indexPath];
	[[UIApplication sharedApplication] openURL:[cellDictionary objectForKey:@"url"]];
}

@end
