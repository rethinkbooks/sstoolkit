//
//  SSHUDView.h
//  SSToolkit
//
//  Created by Sam Soffes on 9/29/09.
//  Copyright 2009-2010 Sam Soffes. All rights reserved.
//

@interface SSHUDView : UIAlertView
	
@property (nonatomic, retain, readonly) UILabel *textLabel;
@property (nonatomic, retain, readonly) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, assign, getter=isLoading) BOOL loading;
@property (nonatomic, assign, getter=isSuccessful) BOOL successful;

- (id)initWithTitle:(NSString *)aTitle;
- (id)initWithTitle:(NSString *)aTitle loading:(BOOL)isLoading;
- (void)completeWithTitle:(NSString *)aTitle;
- (void)completeAndDismissWithTitle:(NSString *)aTitle;
- (void)failWithTitle:(NSString *)aTitle;
- (void)failAndDismissWithTitle:(NSString *)aTitle;
- (void)dismiss;
- (void)dismissAnimated:(BOOL)animated;

@end
