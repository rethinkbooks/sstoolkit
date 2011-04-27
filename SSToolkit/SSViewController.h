//
//  SSViewController.h
//  SSToolkit
//
//  Created by Sam Soffes on 7/14/10.
//  Copyright 2009-2010 Sam Soffes. All rights reserved.
//

#import "SSModalViewController.h"

/**
 @brief UIViewController subclass that displaying custom modals and
 other nice enhancements.
 
 Note: Currently only iPad is supported.
 */
@interface SSViewController : UIViewController <SSModalViewController> {

	SSViewController *_modalParentViewController;
	UIViewController<SSModalViewController> *_customModalViewController;
	BOOL _dismissCustomModalOnVignetteTap;
	CGSize _contentSizeForViewInCustomModal;
	CGPoint _originForViewInCustomModal;
	
@protected
	
	UIView *_modalContainerView;
	UIImageView *_modalContainerBackgroundView;
	UIButton *_vignetteButton;
    UIView *_modalRotatingContainerView;
}

@property (nonatomic, assign) SSViewController *modalParentViewController;
@property (nonatomic, retain, readonly) UIViewController *customModalViewController;
@property (nonatomic, assign) BOOL dismissCustomModalOnVignetteTap;
@property (nonatomic, assign) CGSize contentSizeForViewInCustomModal;
@property (nonatomic, assign) CGPoint originOffsetForViewInCustomModal;

- (void)layoutViews;
- (void)layoutViewsWithOrientation:(UIInterfaceOrientation)orientation;

- (void)presentCustomModalViewController:(UIViewController<SSModalViewController> *)viewController;
- (void)presentCustomModalViewController:(UIViewController<SSModalViewController> *)viewController animated:(BOOL)animated;
- (void)dismissCustomModalViewController;
- (void)dismissCustomModalViewController:(BOOL)animated;

- (void)customModalWillAppear:(BOOL)animated;
- (void)customModalDidAppear:(BOOL)animated;
- (void)customModalWillDisappear:(BOOL)animated;
- (void)customModalDidDisappear:(BOOL)animated;

@end
