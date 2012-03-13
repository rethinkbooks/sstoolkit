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
#import "SSDropShadowView.h"
#import <QuartzCore/QuartzCore.h>

static CGSize const kSSViewControllerDefaultContentSizeForViewInCustomModal = {540.0f, 620.0f};


@interface SSViewController (PrivateMethods)
- (void)_cleanUpModal;
- (void)_presentModalAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
- (void)_dismissModalAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
- (void)_dismissVignetteAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
- (void)_vignetteButtonTapped:(id)sender;
- (CGPoint)_modalDropShadowViewCenter;
- (CGRect)_modalContainerBackgroundViewOffScreenRect;
- (CGAffineTransform)_transformForOrientation:(UIInterfaceOrientation)interfaceOrientation;
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
    _modalDropShadowView.transform = [self _transformForOrientation:interfaceOrientation];
    [self layoutViewsWithOrientation:interfaceOrientation];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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
    _modalDropShadowView.center = [self _modalDropShadowViewCenter];
}

#pragma mark Modal

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

    _vignetteButton = [[UIButton alloc] initWithFrame:window.bounds];
    [_vignetteButton setImage:[UIImage imageNamed:@"SSViewControllerModalVignetteiPad.png"
                                           bundle:kSSToolkitBundleName]
                     forState:UIControlStateNormal];
    _vignetteButton.adjustsImageWhenHighlighted = NO;
    _vignetteButton.alpha = 0.0f;
    _vignetteButton.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [window addSubview:_vignetteButton];
    [_vignetteButton fadeIn];

    CGSize modalSize = kSSViewControllerDefaultContentSizeForViewInCustomModal;
    if ([_customModalViewController respondsToSelector:@selector(contentSizeForViewInCustomModal)]) {
        modalSize = [_customModalViewController contentSizeForViewInCustomModal];
    }
    _customModalViewController.view.frame = CGRectMake(0.0f, 0.0f, modalSize.width, modalSize.height);

    _modalDropShadowView = [[SSDropShadowView alloc] initWithView:_customModalViewController.view];
    _modalDropShadowView.center = [self _modalDropShadowViewCenter];
    _modalDropShadowView.transform = [self _transformForOrientation:self.interfaceOrientation];
    [window addSubview:_modalDropShadowView];

    _modalDropShadowView.frame = [self _modalContainerBackgroundViewOffScreenRect];
    [UIView beginAnimations:@"com.samsoffes.sstoolkit.ssviewcontroller.present-modal" context:self];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:animated ? 0.5 : 0.0];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(_presentModalAnimationDidStop:finished:context:)];
    [self layoutViews];
    [UIView commitAnimations];
}


- (void)dismissCustomModalViewControllerAnimated:(BOOL)animated {
    [self customModalWillDisappear:animated];    
    
    [UIView beginAnimations:@"com.samsoffes.sstoolkit.ssviewcontroller.dismiss-modal" context:self];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:animated ? 0.4 : 0.0];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(_dismissModalAnimationDidStop:finished:context:)];
    _modalDropShadowView.frame = [self _modalContainerBackgroundViewOffScreenRect];
    [UIView commitAnimations];

    [UIView beginAnimations:@"com.samsoffes.sstoolkit.ssviewcontroller.remove-vignette" context:self];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDelay:animated ? 0.2 : 0.0];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(_dismissVignetteAnimationDidStop:finished:context:)];
    _vignetteButton.alpha = 0.0f;
    [UIView commitAnimations];
}


- (void)dismissCustomModalViewController {
    [self dismissCustomModalViewControllerAnimated:YES];
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
    [_modalDropShadowView removeFromSuperview];
    [_modalDropShadowView release];
    _modalDropShadowView = nil;

    [_vignetteButton removeFromSuperview];
    [_vignetteButton release];
    _vignetteButton = nil;

    [_customModalViewController release];
    _customModalViewController = nil;
}


- (void)_presentModalAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    BOOL animated = (animationID != nil);
    [self customModalDidAppear:animated];
    [_vignetteButton addTarget:self
                        action:@selector(_vignetteButtonTapped:)
              forControlEvents:UIControlEventTouchUpInside];
}


- (void)_dismissModalAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    BOOL animated = (animationID != nil);
    [self customModalDidDisappear:animated];
}


- (void)_dismissVignetteAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    [self _cleanUpModal];
}


- (void)_vignetteButtonTapped:(id)sender {
    if ([_customModalViewController respondsToSelector:@selector(dismissCustomModalOnVignetteTap)] && [_customModalViewController dismissCustomModalOnVignetteTap]) {
        [self dismissCustomModalViewControllerAnimated:YES];
    }
}


- (CGPoint)_modalDropShadowViewCenter {
    CGPoint originOffset = CGPointZero;
    if ([_customModalViewController respondsToSelector:@selector(originOffsetForViewInCustomModal)]) {
        originOffset = [_customModalViewController originOffsetForViewInCustomModal];
    }

    CGPoint center = _modalDropShadowView.window.center;
    switch (self.interfaceOrientation) {
        case UIInterfaceOrientationPortrait:
            center.x -= originOffset.x;
            center.y -= originOffset.y;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            center.x += originOffset.x;
            center.y += originOffset.y;
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            // TODO: implement
            break;
    }
    return center;
}


- (CGRect)_modalContainerBackgroundViewOffScreenRect {
    CGPoint originOffset = CGPointZero;
    if ([_customModalViewController respondsToSelector:@selector(originOffsetForViewInCustomModal)]) {
        originOffset = [_customModalViewController originOffsetForViewInCustomModal];
    }

    CGRect windowBounds = _modalDropShadowView.window.bounds;
    CGFloat midX = originOffset.x + CGRectGetMidX(windowBounds) - CGRectGetWidth(_modalDropShadowView.frame) / 2.0f;
    CGFloat midY = originOffset.x + CGRectGetMidY(windowBounds) - CGRectGetHeight(_modalDropShadowView.frame) / 2.0f;
    CGRect result = CGRectMake(0.0f, 0.0f,
                               CGRectGetWidth(_modalDropShadowView.frame),
                               CGRectGetHeight(_modalDropShadowView.frame));
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

- (CGAffineTransform)_transformForOrientation:(UIInterfaceOrientation)interfaceOrientation {
    switch (interfaceOrientation) {
        case UIInterfaceOrientationPortrait:
            return CGAffineTransformMakeRotation(0.0f);
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            return CGAffineTransformMakeRotation(M_PI);
            break;
        case UIInterfaceOrientationLandscapeLeft:
            return CGAffineTransformMakeRotation(-M_PI_2);
            break;
        case UIInterfaceOrientationLandscapeRight:
            return CGAffineTransformMakeRotation(M_PI_2);
            break;
    }
}


@end
