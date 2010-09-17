//
//  SSPersonViewController.h
//  SSToolkit
//
//  Created by Sam Soffes on 9/8/10.
//  Copyright 2010 Sam Soffes. All rights reserved.
//

#import <AddressBook/AddressBook.h>

@class SSPersonHeaderView;
@class SSPersonFooterView;

@interface SSPersonViewController : UITableViewController {
	
	ABRecordRef _displayedPerson;
	
	SSPersonHeaderView *_headerView;
	SSPersonFooterView *_footerView;
	NSInteger _numberOfSections;
	NSMutableArray *_rowCounts;
	NSMutableDictionary *_cellData;
}

@property (nonatomic, assign) ABRecordRef displayedPerson;

- (id)initWithPerson:(ABRecordRef)aPerson;

- (void)editPerson:(id)sender;
- (void)deletePerson:(id)sender;

@end
