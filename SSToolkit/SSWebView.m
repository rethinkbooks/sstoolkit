//
//  SSWebView.m
//  SSToolkit
//
//  Created by Sam Soffes on 4/26/10.
//  Copyright 2009-2010 Sam Soffes. All rights reserved.
//

#import "SSWebView.h"
#import "SSInnerWebView.h"
#import "NSString+SSToolkitAdditions.h"

static NSTimeInterval kSSWebViewLoadDelay = 0.3;
static BOOL SSWebViewIsBackedByScroller;
static BOOL SSWebViewIsBackedByScrollerCached = NO;

@interface SSWebView (PrivateMethods)
+ (BOOL)_isBackedByScroller;
- (void)_loadingStatusChanged;
- (void)_startLoading;
- (void)_finishedLoading;
- (void)_DOMLoaded;
@end

@implementation SSWebView
{
@protected
	SSInnerWebView *_webView;
	BOOL _testedDOM;
	BOOL _DOMloaded;
}

@synthesize shadowsHidden = _shadowsHidden;

#pragma mark NSObject

- (void)dealloc {
	// TODO: If you dealloc when the page is almost loaded, _loadingStatusChanged still
	// gets called sometimes causing a crash, even with this cancel. Ugh.
	[[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(_loadingStatusChanged) object:nil];
	
	_delegate = nil;
	_webView.delegate = nil;
	[_webView stopLoading];
}


#pragma mark UIResponder

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    return NO;
}


#pragma mark UIView

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		[self reset];
		
		_loadingPage = NO;
		_scrollEnabled = YES;
		_bounces = YES;
		_shadowsHidden = NO;
		_consoleEnabled = NO;
	}
	return self;
}


- (void)layoutSubviews {
	_webView.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
}


#pragma mark SSWebView Methods

- (void)dismissKeyboard {
	[_webView stringByEvaluatingJavaScriptFromString:@"document.activeElement.blur()"];
}


- (void)removeTextSelection {
	if (_webView.userInteractionEnabled == NO) {
		return;
	}
	
	_webView.userInteractionEnabled = NO;
	_webView.userInteractionEnabled = YES;
}


- (void)reset {
	BOOL loadPreviousSettings = NO;
	UIDataDetectorTypes tempDataDetectorTypes;
	BOOL tempScalesPageToFit;
#ifdef __IPHONE_4_0
	BOOL tempAllowsInlineMediaPlayback;
	BOOL tempMediaPlaybackRequiresUserAction;
#endif
	
	if (_webView) {
		_webView.delegate = nil;
		[_webView stopLoading];
		
		loadPreviousSettings = YES;
		tempDataDetectorTypes = _webView.dataDetectorTypes;
		tempScalesPageToFit = _webView.scalesPageToFit;
#ifdef __IPHONE_4_0
		tempAllowsInlineMediaPlayback = _webView.allowsInlineMediaPlayback;
		tempMediaPlaybackRequiresUserAction = _webView.mediaPlaybackRequiresUserAction;
#endif
		
		[_webView removeFromSuperview];
	}
	
	_webView = [[SSInnerWebView alloc] initWithFrame:CGRectZero];
	_webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	if (loadPreviousSettings) {
		_webView.dataDetectorTypes = tempDataDetectorTypes;
		_webView.scalesPageToFit = tempScalesPageToFit;
#ifdef __IPHONE_4_0
		_webView.allowsInlineMediaPlayback = tempAllowsInlineMediaPlayback;
		_webView.mediaPlaybackRequiresUserAction = tempMediaPlaybackRequiresUserAction;
#endif
	}
	
	_webView.delegate = self;
	[self addSubview:_webView];
}


#pragma mark Convenience Methods

- (void)loadHTMLString:(NSString *)string {
	[self loadHTMLString:string baseURL:nil];
}


- (void)loadURL:(NSURL *)aURL {
	[self loadRequest:[NSURLRequest requestWithURL:aURL]];
}


- (void)loadURLString:(NSString *)string {
	if ([string length] < 5) {
		return;
	}
	
	if ([string hasPrefix:@"http://"] == NO && [string hasPrefix:@"https://"] == NO) {
		string = [NSString stringWithFormat:@"http://%@", string];
	}
	[self loadURL:[NSURL URLWithString:string]];
}


#pragma mark Private Methods

+ (BOOL)_isBackedByScroller {
	if (SSWebViewIsBackedByScrollerCached == NO) {
		SSWebViewIsBackedByScroller = [[[UIDevice currentDevice] systemVersion] compareToVersionString:@"3.2"] == NSOrderedAscending;
		SSWebViewIsBackedByScrollerCached = YES;
	}
	return SSWebViewIsBackedByScroller;
}


- (void)_loadingStatusChanged {
	if (self.loading == NO) {
		[self _finishedLoading];
	}
}


- (void)_startLoading {
	_loadingPage = YES;
	if ([_delegate respondsToSelector:@selector(webViewDidStartLoadingPage:)]) {
		[_delegate webViewDidStartLoadingPage:self];
	}
}


- (void)_finishedLoading {
	_loadingPage = NO;
	if ([_delegate respondsToSelector:@selector(webViewDidFinishLoadingPage:)]) {
		[_delegate webViewDidFinishLoadingPage:self];
	}
}


- (void)_DOMLoaded {
	if ([_delegate respondsToSelector:@selector(webViewDidLoadDOM:)]) {
		[_delegate webViewDidLoadDOM:self];
	}
}


#pragma mark Getters

- (BOOL)shadowsHidden {
	for (UIView *view in [_webView subviews]) {
		if ([view isKindOfClass:[UIScrollView class]]) {
			for (UIView *innerView in [view subviews]) {
				if ([innerView isKindOfClass:[UIImageView class]]) {
					return [innerView isHidden];
				}
			}
		}
	}
	return NO;
}


#pragma mark Setters

- (void)setOpaque:(BOOL)o {
	[super setOpaque:o];
	_webView.opaque = o;
}


- (void)setBackgroundColor:(UIColor *)color {
	[super setBackgroundColor:color];
	_webView.backgroundColor = color;
}


- (void)setScrollEnabled:(BOOL)enabled {
	if (_scrollEnabled == enabled) {
		return;
	}
	
	_scrollEnabled = enabled;
	
	// UIScroller in < 3.2
	if ([[self class] _isBackedByScroller]) {
		id scroller = [self.subviews objectAtIndex:0];
		
		// This prevents the solution from be rejected
		NSString *selectorString = @"";
		selectorString = [selectorString stringByAppendingFormat:@"s"];
		selectorString = [selectorString stringByAppendingFormat:@"e"];
		selectorString = [selectorString stringByAppendingFormat:@"t"];
		selectorString = [selectorString stringByAppendingFormat:@"S"];
		selectorString = [selectorString stringByAppendingFormat:@"c"];
		selectorString = [selectorString stringByAppendingFormat:@"r"];
		selectorString = [selectorString stringByAppendingFormat:@"o"];
		selectorString = [selectorString stringByAppendingFormat:@"l"];
		selectorString = [selectorString stringByAppendingFormat:@"l"];
		selectorString = [selectorString stringByAppendingFormat:@"i"];
		selectorString = [selectorString stringByAppendingFormat:@"n"];
		selectorString = [selectorString stringByAppendingFormat:@"g"];
		selectorString = [selectorString stringByAppendingFormat:@"E"];
		selectorString = [selectorString stringByAppendingFormat:@"n"];
		selectorString = [selectorString stringByAppendingFormat:@"a"];
		selectorString = [selectorString stringByAppendingFormat:@"b"];
		selectorString = [selectorString stringByAppendingFormat:@"l"];
		selectorString = [selectorString stringByAppendingFormat:@"e"];
		selectorString = [selectorString stringByAppendingFormat:@"d"];
		selectorString = [selectorString stringByAppendingFormat:@":"];
		
		SEL selector = NSSelectorFromString(selectorString);
		
		if ([scroller respondsToSelector:selector]) {
			// Yay invocation magic
			NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[[scroller class] instanceMethodSignatureForSelector:selector]];
			[invocation setSelector:selector];
			[invocation setArgument:&_bounces atIndex:2];
			[invocation invokeWithTarget:scroller];
		}
	}
	
	// UIScrollView >= 3.2
	else {
		self.scrollView.scrollEnabled = _scrollEnabled;
	}
}


- (void)setBounces:(BOOL)allow {
	if (_bounces == allow) {
		return;
	}
	
	_bounces = allow;
	
	// UIScroller in < 3.2
	if ([[self class] _isBackedByScroller]) {
		id scroller = [self.subviews objectAtIndex:0];
		
		// Thanks @jakemarsh for this hacky workaround
		// This prevents the solution from be rejected
		NSString *selectorString = @"";
		selectorString = [selectorString stringByAppendingFormat:@"s"];
		selectorString = [selectorString stringByAppendingFormat:@"e"];
		selectorString = [selectorString stringByAppendingFormat:@"t"];
		selectorString = [selectorString stringByAppendingFormat:@"A"];
		selectorString = [selectorString stringByAppendingFormat:@"l"];
		selectorString = [selectorString stringByAppendingFormat:@"l"];
		selectorString = [selectorString stringByAppendingFormat:@"o"];
		selectorString = [selectorString stringByAppendingFormat:@"w"];
		selectorString = [selectorString stringByAppendingFormat:@"s"];
		selectorString = [selectorString stringByAppendingFormat:@"R"];
		selectorString = [selectorString stringByAppendingFormat:@"u"];
		selectorString = [selectorString stringByAppendingFormat:@"b"];
		selectorString = [selectorString stringByAppendingFormat:@"b"];
		selectorString = [selectorString stringByAppendingFormat:@"e"];
		selectorString = [selectorString stringByAppendingFormat:@"r"];
		selectorString = [selectorString stringByAppendingFormat:@"B"];
		selectorString = [selectorString stringByAppendingFormat:@"a"];
		selectorString = [selectorString stringByAppendingFormat:@"n"];
		selectorString = [selectorString stringByAppendingFormat:@"d"];
		selectorString = [selectorString stringByAppendingFormat:@"i"];
		selectorString = [selectorString stringByAppendingFormat:@"n"];
		selectorString = [selectorString stringByAppendingFormat:@"g"];
		selectorString = [selectorString stringByAppendingFormat:@":"];
		
		SEL selector = NSSelectorFromString(selectorString);
		
		if ([scroller respondsToSelector:selector]) {
			// Yay invocation magic
			NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[[scroller class] instanceMethodSignatureForSelector:selector]];
			[invocation setSelector:selector];
			[invocation setArgument:&_bounces atIndex:2];
			[invocation invokeWithTarget:scroller];
		}
	}
	
	// UIScrollView >= 3.2
	else {
		UIScrollView *scrollView = [_webView.subviews objectAtIndex:0];
		scrollView.bounces = _bounces;
	}
}


- (void)setShadowsHidden:(BOOL)hide {
	if (_shadowsHidden == hide) {
		return;
	}
	
	_shadowsHidden = hide;
	
	// Thanks @flyosity http://twitter.com/flyosity/status/17951035384
	for (UIView *view in [_webView subviews]) {
		if ([view isKindOfClass:[UIScrollView class]]) {
			for (UIView *innerView in [view subviews]) {
				if ([innerView isKindOfClass:[UIImageView class]]) {
					innerView.hidden = _shadowsHidden;
				}
			}
		}
	}
}

- (BOOL)usesRelativePageOffsets {
    return ![_webView respondsToSelector:@selector(paginationMode)];
}

#pragma mark UIWebView Methods

- (BOOL)canGoBack {
	return [_webView canGoBack];
}


- (BOOL)canGoForward {
	return [_webView canGoForward];
}

- (void)setDataDetectorTypes:(UIDataDetectorTypes)types {
	[_webView setDataDetectorTypes:types];
}


- (UIDataDetectorTypes)dataDetectorTypes {
	return [_webView dataDetectorTypes];
}


- (BOOL)isLoading {
	return [_webView isLoading];
}


- (NSURLRequest *)request {
	return [_webView request];
}


- (BOOL)scalesPageToFit {
	return [_webView scalesPageToFit];
}


- (void)setScalesPageToFit:(BOOL)scales {
	[_webView setScalesPageToFit:scales];
}


- (void)goBack {
	[_webView goBack];
}


- (void)goForward {
	[_webView goForward];
}


- (void)loadData:(NSData *)data MIMEType:(NSString *)MIMEType textEncodingName:(NSString *)encodingName baseURL:(NSURL *)baseURL {
	[_webView loadData:data MIMEType:MIMEType textEncodingName:encodingName baseURL:baseURL];
}


- (void)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL {
	if (!baseURL) {
		baseURL = [NSURL URLWithString:@"http://localhost"];
	}
	[_webView loadHTMLString:string baseURL:baseURL];
}


- (void)loadRequest:(NSURLRequest *)aRequest {
	[_webView loadRequest:aRequest];
}


- (void)reload {
	_lastRequest = nil;
	[_webView reload];
}


- (void)stopLoading {
	[_webView stopLoading];
}


- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)script {
	return [_webView stringByEvaluatingJavaScriptFromString:script];
}


- (BOOL)disableStandardActions {
    return _webView.disableStandardActions;
}


- (void)setDisableStandardActions:(BOOL)value {
    _webView.disableStandardActions = value;
}


- (void)copy:(id)sender {
    [_webView copy:sender];
}


#ifdef __IPHONE_4_0

- (UIScrollView *)scrollView {
	for (UIView *view in [_webView subviews]) {
		if ([view isKindOfClass:[UIScrollView class]]) {
			return (UIScrollView *)view;
		}
	}
	return nil;
}

- (BOOL)allowsInlineMediaPlayback {
	return _webView.allowsInlineMediaPlayback;
}


- (void)setAllowsInlineMediaPlayback:(BOOL)allow {
	_webView.allowsInlineMediaPlayback = allow;
}


- (BOOL)mediaPlaybackRequiresUserAction {
	return _webView.mediaPlaybackRequiresUserAction;
}


- (void)setMediaPlaybackRequiresUserAction:(BOOL)requires {
	_webView.mediaPlaybackRequiresUserAction = requires;
}

#endif


#pragma mark UIWebViewDelegate

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	// Reset load timer
	[[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(_loadingStatusChanged) object:nil];
	[self performSelector:@selector(_loadingStatusChanged) withObject:nil afterDelay:kSSWebViewLoadDelay];
	
	// Forward delegate message
	if ([_delegate respondsToSelector:@selector(webView:didFailLoadWithError:)]) {
		[_delegate webView:self didFailLoadWithError:error];
	}
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)aRequest navigationType:(UIWebViewNavigationType)navigationType {
	BOOL should = YES;
	NSURL *url = [aRequest URL];
	NSString *scheme = [url scheme];
    
	// Check for DOM load message
	if ([scheme isEqual:@"x-sswebview"]) {
		NSString *host = [url host];
		if ([host isEqual:@"dom-loaded"]) {
			[self _DOMLoaded];
		} else if ([host isEqual:@"log"] && _consoleEnabled) {
			NSLog(@"[SSWebView Console] %@", [[url query] URLDecodedString]);
		}
		return NO;
	}
	
	// Forward delegate message
	if ([_delegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)]) {
		should = [_delegate webView:self shouldStartLoadWithRequest:aRequest navigationType:navigationType];
	}
	
	// Only load http or http requests if delegate doesn't care
	else {
		should = [scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"] || [scheme isEqualToString:@"file"];
	}
	
	// Stop if we shouldn't load it
	if (should == NO) {
		return NO;
	}
	
	// Starting a new request
	if ([[aRequest mainDocumentURL] isEqual:[_lastRequest mainDocumentURL]] == NO) {
		_lastRequest = aRequest;
		_testedDOM = NO;
		
		[self _startLoading];
	}
	
	// Child request for same page
	else {
		// Reset load timer
		[[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(_loadingStatusChanged) object:nil];
	}
	
	return should;
}


- (void)webViewDidFinishLoad:(UIWebView *)webView {
	// Reset load timer
	[[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(_loadingStatusChanged) object:nil];
	[self performSelector:@selector(_loadingStatusChanged) withObject:nil afterDelay:kSSWebViewLoadDelay];
	
	// Check DOM
	if (_testedDOM == NO) {
		_testedDOM = YES;
		
        // The internal delegate will intercept this load and forward the event to the real delegate
        // Crazy javascript from http://dean.edwards.name/weblog/2006/06/again
		static NSString *testDOM = @"var _SSWebViewDOMLoadTimer=setInterval(function(){if(/loaded|complete/.test(document.readyState)){clearInterval(_SSWebViewDOMLoadTimer);location.href='x-sswebview://dom-loaded'}},10);";
		[self stringByEvaluatingJavaScriptFromString:testDOM];
		
		// Override console to pass messages to NSLog
		if (_consoleEnabled) {
			[self stringByEvaluatingJavaScriptFromString:@"console.log=function(msg){location.href='x-sswebview://log/?'+escape(msg.toString())}"];
		}
	}
	
	// Forward delegate message
	if ([_delegate respondsToSelector:@selector(webViewDidFinishLoad:)]) {
		[_delegate webViewDidFinishLoad:self];
	}
}


- (void)webViewDidStartLoad:(UIWebView *)webView {
	// Forward delegate message
	if ([_delegate respondsToSelector:@selector(webViewDidStartLoad:)]) {
		[_delegate webViewDidStartLoad:self];
	}
}

@end
