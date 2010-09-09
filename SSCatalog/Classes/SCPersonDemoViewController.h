//
//  SCPersonDemoViewController.h
//  SSCatalog
//
//  Created by Sam Soffes on 9/8/10.
//  Copyright 2010 Sam Soffes. All rights reserved.
//

#import <AddressBookUI/AddressBookUI.h>

@interface SCPersonDemoViewController : UIViewController <ABPeoplePickerNavigationControllerDelegate> {

}

+ (NSString *)title;

- (void)pickPerson:(id)sender;

@end
