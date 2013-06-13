//
//  SSRatingPickerViewController.h
//  SSToolkit
//
//  Created by Sam Soffes on 2/3/11.
//  Copyright 2011 Sam Soffes. All rights reserved.
//

#import "SSViewController.h"

@class SSRatingPickerScrollView;
@class SSRatingPicker;
@class SSTextField;
@class SSTextView;

@interface SSRatingPickerViewController : SSViewController

@property (nonatomic, retain, readonly) SSRatingPickerScrollView *scrollView;
@property (nonatomic, retain, readonly) SSRatingPicker *ratingPicker;
@property (nonatomic, retain, readonly) SSTextField *titleTextField;
@property (nonatomic, retain, readonly) SSTextView *reviewTextField;

@end
