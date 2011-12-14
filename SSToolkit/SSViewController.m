//
//  SSViewController.m
//  SSToolkit
//
//  Created by Sam Soffes on 7/14/10.
//  Copyright 2009-2010 Sam Soffes. All rights reserved.
//

#import "SSViewController.h"
#import "UIImage+SSToolkitAdditions.h"
#import "UIView+SSToolkitAdditions.h"
#import <QuartzCore/QuartzCore.h>


static CGFloat const kSSViewControllerModalPadding = 22.0f;
static CGSize const kSSViewControllerDefaultContentSizeForViewInCustomModal = {540.0f, 620.0f};


@interface SSViewController (PrivateMethods)
- (void)_cleanUpModal;
- (void)_presentModalAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
- (void)_dismissModalAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
- (void)_dismissVignetteAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
- (void)_vignetteButtonTapped:(id)sender;
- (CGPoint)_modalOriginOffset;
- (CGRect)_modalContainerBackgroundViewOffScreenRect;
@end


@implementation SSViewController

@synthesize modalParentViewController = _modalParentViewController;
@synthesize customModalViewController = _customModalViewController;
@synthesize dismissCustomModalOnVignetteTap = _dismissCustomModalOnVignetteTap;
@synthesize contentSizeForViewInCustomModal = _contentSizeForViewInCustomModal;
@synthesize originOffsetForViewInCustomModal = _originOffsetForViewInCustomModal;

#pragma mark NSObject

- (id)init {
    if ((self = [super init])) {
        _dismissCustomModalOnVignetteTap = NO;
        _contentSizeForViewInCustomModal = kSSViewControllerDefaultContentSizeForViewInCustomModal;
        _originOffsetForViewInCustomModal = CGPointZero;
    }
    return self;
}


- (void)dealloc {
    [self _cleanUpModal];
    [super dealloc];
}

#pragma mark UIViewController

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
    CGAffineTransform transform;
    switch (interfaceOrientation) {
        case UIInterfaceOrientationPortrait:
            transform = CGAffineTransformMakeRotation(0.0f);
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            transform = CGAffineTransformMakeRotation(M_PI);
            break;
        case UIInterfaceOrientationLandscapeLeft:
            transform = CGAffineTransformMakeRotation(-M_PI_2);
            break;
        case UIInterfaceOrientationLandscapeRight:
            transform = CGAffineTransformMakeRotation(M_PI_2);
            break;
    }
    _modalContainerBackgroundView.transform = transform;
}


- (void)viewWillAppear:(BOOL)animated {
    [self layoutViews];
}

#pragma mark Layout

- (void)layoutViews {
    [self layoutViewsWithOrientation:self.interfaceOrientation];
}


- (void)layoutViewsWithOrientation:(UIInterfaceOrientation)orientation {
    if (!_customModalViewController) {
        return;
    }

    UIWindow *window = _modalContainerBackgroundView.window;
    CGPoint originOffset = [self _modalOriginOffset];
    _modalContainerBackgroundView.frame = CGRectMake(originOffset.x + CGRectGetMidX(window.bounds) - CGRectGetWidth(_modalContainerBackgroundView.frame) / 2.0f,
                                                     originOffset.y + CGRectGetMidY(window.bounds) - CGRectGetHeight(_modalContainerBackgroundView.frame) / 2.0f,
                                                     CGRectGetWidth(_modalContainerBackgroundView.frame),
                                                     CGRectGetHeight(_modalContainerBackgroundView.frame));
}

#pragma mark Modal

- (void)presentCustomModalViewController:(UIViewController<SSModalViewController> *)viewController {
    [self presentCustomModalViewController:viewController animated:YES];
}


- (void)presentCustomModalViewController:(UIViewController<SSModalViewController> *)viewController animated:(BOOL)animated {
    if (_customModalViewController) {
        NSLog(@"ERROR: Attempt to present a modal view controller while one is already being shown.");
        return;
    }

    _customModalViewController = [viewController retain];
    if (_customModalViewController == nil) {
        NSLog(@"ERROR: Attempt to present a nil modal view controller");
        return;
    }

    UIWindow *window = self.view.window;
    _customModalViewController.modalParentViewController = self;

    CGSize modalSize = kSSViewControllerDefaultContentSizeForViewInCustomModal;
    if ([_customModalViewController respondsToSelector:@selector(contentSizeForViewInCustomModal)]) {
        modalSize = [_customModalViewController contentSizeForViewInCustomModal];
    }

    if (_vignetteButton == nil) {
        _vignetteButton = [[UIButton alloc] initWithFrame:window.bounds];
        [_vignetteButton setImage:[UIImage imageNamed:@"SSViewControllerModalVignetteiPad.png"
                                               bundle:kSSToolkitBundleName]
                         forState:UIControlStateNormal];
        _vignetteButton.adjustsImageWhenHighlighted = NO;
        _vignetteButton.alpha = 0.0f;
        _vignetteButton.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    }
    [window addSubview:_vignetteButton];
    [_vignetteButton fadeIn];

    if (_modalContainerBackgroundView == nil) {
        UIImage *modalBackgroundImage = [[UIImage imageNamed:@"SSViewControllerFormBackground.png" bundle:kSSToolkitBundleName] stretchableImageWithLeftCapWidth:43 topCapHeight:45];
        _modalContainerBackgroundView = [[UIImageView alloc] initWithImage:modalBackgroundImage];
        _modalContainerBackgroundView.autoresizesSubviews = NO;
        _modalContainerBackgroundView.userInteractionEnabled = YES;
    }
    _modalContainerBackgroundView.frame = CGRectMake(0.0f, 0.0f,
                                                     modalSize.width + 2.0f * kSSViewControllerModalPadding,
                                                     modalSize.height + 2.0f * kSSViewControllerModalPadding);
    [window addSubview:_modalContainerBackgroundView];

    if (_modalContainerView == nil) {
        _modalContainerView = [[UIView alloc] initWithFrame:CGRectMake(kSSViewControllerModalPadding,
                                                                       kSSViewControllerModalPadding,
                                                                       modalSize.width,
                                                                       modalSize.height)];
        _modalContainerView.layer.cornerRadius = 5.0f;
        _modalContainerView.clipsToBounds = YES;
        [_modalContainerBackgroundView addSubview:_modalContainerView];
    }
    UIView *modalView = _customModalViewController.view;
    modalView.frame = CGRectMake(0.0f, 0.0f, modalSize.width, modalSize.height);
    [_modalContainerView addSubview:modalView];

    _modalContainerBackgroundView.frame = [self _modalContainerBackgroundViewOffScreenRect];

    if ([_customModalViewController respondsToSelector:@selector(viewWillAppear:)]) {
        [_customModalViewController viewWillAppear:animated];
    }

    [self customModalWillAppear:animated];

    [UIView beginAnimations:@"com.samsoffes.sstoolkit.ssviewcontroller.present-modal" context:self];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:animated ? 0.5 : 0.0];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(_presentModalAnimationDidStop:finished:context:)];
    [self layoutViews];
    [UIView commitAnimations];
}


- (void)dismissCustomModalViewControllerAnimated:(BOOL)animated {
    if ([_customModalViewController respondsToSelector:@selector(viewWillDisappear:)]) {
        [_customModalViewController viewWillDisappear:animated];
    }

    [self customModalWillDisappear:animated];    
    
    [UIView beginAnimations:@"com.samsoffes.sstoolkit.ssviewcontroller.dismiss-modal" context:self];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:animated ? 0.4 : 0.0];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(_dismissModalAnimationDidStop:finished:context:)];
    _modalContainerBackgroundView.frame = [self _modalContainerBackgroundViewOffScreenRect];
    [UIView commitAnimations];

    [UIView beginAnimations:@"com.samsoffes.sstoolkit.ssviewcontroller.remove-vignette" context:self];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDelay:animated ? 0.2 : 0.0];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(_dismissVignetteAnimationDidStop:finished:context:)];
    _vignetteButton.alpha = 0.0f;
    [UIView commitAnimations];
}


- (void)customModalWillAppear:(BOOL)animated {
    // Can be overridden by a subclass
}


- (void)customModalDidAppear:(BOOL)animated {
    // Can be overridden by a subclass
}


- (void)customModalWillDisappear:(BOOL)animated {
    // Can be overridden by a subclass
}


- (void)customModalDidDisappear:(BOOL)animated {
    // Can be overridden by a subclass
}

#pragma mark Private Methods

- (void)_cleanUpModal {
    [_modalContainerView removeFromSuperview];
    [_modalContainerView release];
    _modalContainerView = nil;

    [_modalContainerBackgroundView removeFromSuperview];
    [_modalContainerBackgroundView release];
    _modalContainerBackgroundView = nil;

    [_vignetteButton removeFromSuperview];
    [_vignetteButton release];
    _vignetteButton = nil;

    [_customModalViewController release];
    _customModalViewController = nil;
}


- (void)_presentModalAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    BOOL animated = (animationID != nil);
    
    if ([_customModalViewController respondsToSelector:@selector(viewDidAppear:)]) {
        [_customModalViewController viewDidAppear:animated];
    }
    
    [self customModalDidAppear:animated];
    
    if ([_customModalViewController respondsToSelector:@selector(dismissCustomModalOnVignetteTap)] && [_customModalViewController dismissCustomModalOnVignetteTap]) {
        [_vignetteButton addTarget:self
                            action:@selector(_vignetteButtonTapped:)
                  forControlEvents:UIControlEventTouchUpInside];
    }
}


- (void)_dismissModalAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    BOOL animated = (animationID != nil);
        
    if ([_customModalViewController respondsToSelector:@selector(viewDidDisappear:)]) {
        [_customModalViewController viewDidDisappear:animated];
    }
    
    [self customModalDidDisappear:animated];
}


- (void)_dismissVignetteAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    [self _cleanUpModal];
}


- (void)_vignetteButtonTapped:(id)sender {
    [self dismissCustomModalViewControllerAnimated:YES];
}


- (CGPoint)_modalOriginOffset {
    CGPoint originOffset = CGPointZero;
    if ([_customModalViewController respondsToSelector:@selector(originOffsetForViewInCustomModal)]) {
        originOffset = [_customModalViewController originOffsetForViewInCustomModal];
    }
    return originOffset;
}


- (CGRect)_modalContainerBackgroundViewOffScreenRect {
    CGPoint originOffset = [self _modalOriginOffset];
    CGRect windowBounds = _modalContainerBackgroundView.window.bounds;
    CGFloat midX = originOffset.x + CGRectGetMidX(windowBounds) - CGRectGetWidth(_modalContainerBackgroundView.frame) / 2.0f;
    CGFloat midY = originOffset.x + CGRectGetMidY(windowBounds) - CGRectGetHeight(_modalContainerBackgroundView.frame) / 2.0f;
    CGRect result = CGRectMake(0.0f, 0.0f,
                               CGRectGetWidth(_modalContainerBackgroundView.frame),
                               CGRectGetHeight(_modalContainerBackgroundView.frame));
    switch (self.interfaceOrientation) {
        case UIInterfaceOrientationPortrait:
            result.origin.x = midX;
            result.origin.y = CGRectGetMaxY(windowBounds);
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            result.origin.x = midX;
            result.origin.y = CGRectGetMinY(windowBounds) - result.size.height;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            result.origin.x = CGRectGetMaxX(windowBounds);
            result.origin.y = midY;
            break;
        case UIInterfaceOrientationLandscapeRight:
            result.origin.x = CGRectGetMinX(windowBounds) - result.size.width;
            result.origin.y = midY;
            break;
    }
    return result;
}

@end
