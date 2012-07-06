//
//  SSViewController.h
//  SSToolkit
//
//  Created by Sam Soffes on 7/14/10.
//  Copyright 2009-2010 Sam Soffes. All rights reserved.
//

#import "SSModalViewController.h"

@class SSDropShadowView;

/**
 @brief UIViewController subclass that displaying custom modals and
 other nice enhancements.
 
 Note: Currently only iPad is supported.
 */
@interface SSViewController : UIViewController <SSModalViewController> {
    SSViewController *_modalParentViewController;
    BOOL _dismissCustomModalOnVignetteTap;
    CGSize _contentSizeForViewInCustomModal;
    CGPoint _originForViewInCustomModal;

@private
    UIViewController<SSModalViewController> *_customModalViewController;
    UIButton *_vignetteButton;
    SSDropShadowView *_modalDropShadowView;
    dispatch_block_t _dismissCompletion;
}

@property (nonatomic, assign) SSViewController *modalParentViewController;
@property (nonatomic, retain, readonly) UIViewController *customModalViewController;
@property (nonatomic, assign) BOOL dismissCustomModalOnVignetteTap;
@property (nonatomic, assign) CGSize contentSizeForViewInCustomModal;
@property (nonatomic, assign) CGPoint originOffsetForViewInCustomModal;

- (void)layoutViews;
- (void)layoutViewsWithOrientation:(UIInterfaceOrientation)orientation;

- (void)presentCustomModalViewController:(UIViewController<SSModalViewController> *)viewController animated:(BOOL)animated;
- (void)dismissCustomModalViewControllerAnimated:(BOOL)animated;
- (void)dismissCustomModalViewControllerAnimated:(BOOL)animated completion:(dispatch_block_t)completion;


- (void)customModalWillAppear:(BOOL)animated;
- (void)customModalDidAppear:(BOOL)animated;
- (void)customModalWillDisappear:(BOOL)animated;
- (void)customModalDidDisappear:(BOOL)animated;

@end
