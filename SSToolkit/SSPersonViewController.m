//
//  SSPersonViewController.m
//  SSToolkit
//
//  Created by Sam Soffes on 9/8/10.
//  Copyright 2010 Sam Soffes. All rights reserved.
//

#import "SSPersonViewController.h"

@implementation SSPersonViewController

@synthesize addressBook = _addressBook;
@synthesize displayedPerson = _displayedPerson; 

#pragma mark NSObject

- (id)init {
	self = [super initWithStyle:UITableViewStyleGrouped];
	return self;
}


#pragma mark Initializers

- (id)initWithPerson:(ABRecordRef)aPerson {
	if (self = [self init]) {
		self.displayedPerson = aPerson;
	}
	return self;
}


- (id)initWithPerson:(ABRecordRef)aPerson addressBook:(ABAddressBookRef)anAddressBook {
	if (self = [self init]) {
		self.displayedPerson = aPerson;
		self.addressBook = anAddressBook;
	}
	return self;
}

@end
