//
//  SSPersonViewController.h
//  SSToolkit
//
//  Created by Sam Soffes on 9/8/10.
//  Copyright 2010 Sam Soffes. All rights reserved.
//

#import <AddressBook/AddressBook.h>

@interface SSPersonViewController : UITableViewController {

	ABAddressBookRef _addressBook;
	ABRecordRef _displayedPerson;
}

@property (nonatomic, assign) ABAddressBookRef addressBook;
@property (nonatomic, assign) ABRecordRef displayedPerson;

- (id)initWithPerson:(ABRecordRef)aPerson;
- (id)initWithPerson:(ABRecordRef)aPerson addressBook:(ABAddressBookRef)anAddressBook;

@end
