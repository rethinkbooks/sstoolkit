//
//  SSSegmentedControl.m
//  SSToolkit
//
//  Created by Sam Soffes on 2/7/11.
//  Copyright 2011 Sam Soffes. All rights reserved.
//

#import "SSSegmentedControl.h"
#import "SSDrawingMacros.h"
#import "UIImage+SSToolkitAdditions.h"


@interface SSSegmentedControl()

- (void)setSelectedSegmentIndex:(NSInteger)selectedSegmentIndex sendAction:(BOOL)sendAction;

@end


@implementation SSSegmentedControl

@synthesize numberOfSegments = _numberOfSegments;
@synthesize selectedSegmentIndex = _selectedSegmentIndex;
@synthesize buttonImage = _buttonImage;
@synthesize highlightedButtonImage = _highlightedButtonImage;
@synthesize dividerImage = _dividerImage;
@synthesize highlightedDividerImage = _highlightedDividerImage;
@synthesize font = _font;
@synthesize textColor = _textColor;
@synthesize highlightedTextColor = _highlightedTextColor;
@synthesize textShadowColor = _textShadowColor;
@synthesize highlightedTextShadowColor = _highlightedTextShadowColor;
@synthesize textShadowOffset = _textShadowOffset;
@synthesize highlightedTextShadowOffset = _highlightedTextShadowOffset;
@synthesize textEdgeInsets = _textEdgeInsets;

#pragma mark NSObject

- (void)dealloc {
	[_items release];
	[_buttonImage release];
	[_highlightedButtonImage release];
	[_dividerImage release];
	[_highlightedDividerImage release];
	[_font release];
	[_textColor release];
	[_highlightedTextColor release];
	[_textShadowColor release];
	[_highlightedTextShadowColor release];
	[super dealloc];
}


#pragma mark UIResponder

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	CGFloat x = [touch locationInView:self].x;
	
	// Ignore touches that don't matter
	if (x < 0 || x > self.frame.size.width) {
		return;
	}
	
	NSInteger selectedSegmentIndex = (NSInteger)floorf((CGFloat)x / (self.frame.size.width / (CGFloat)[_items count]));
    [self setSelectedSegmentIndex:selectedSegmentIndex sendAction:YES];
}


#pragma mark UIView

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		self.backgroundColor = [UIColor clearColor];
		
		_items = [[NSMutableArray alloc] init];
		
		self.buttonImage = [[UIImage imageNamed:@"UISegmentBarButton.png" bundle:kSSToolkitBundleName] stretchableImageWithLeftCapWidth:6 topCapHeight:0];
		self.highlightedButtonImage = [[UIImage imageNamed:@"UISegmentBarButtonHighlighted.png" bundle:kSSToolkitBundleName] stretchableImageWithLeftCapWidth:6 topCapHeight:0];
		self.dividerImage = [UIImage imageNamed:@"UISegmentBarDivider.png" bundle:kSSToolkitBundleName];
		self.highlightedDividerImage = [UIImage imageNamed:@"UISegmentBarDividerHighlighted.png" bundle:kSSToolkitBundleName];
		self.selectedSegmentIndex = SSSegmentedControlNoSegment;
		
		_font = [[UIFont boldSystemFontOfSize:12.0f] retain];
		_textColor = [[UIColor whiteColor] retain];
		_highlightedTextColor = [_textColor retain];
		_textShadowColor = [[UIColor colorWithWhite:0.0f alpha:0.5f] retain];
		_highlightedTextShadowColor = [_textShadowColor retain];
		_textShadowOffset = CGSizeMake(0.0f, -1.0f);
		_highlightedTextShadowOffset = CGSizeMake(0.0f, -1.0f);
		_textEdgeInsets = UIEdgeInsetsMake(-1.0f, 0.0f, 0.0f, 0.0f);
	}
	return self;
}


- (void)drawRect:(CGRect)frame {
	
	static CGFloat dividerWidth = 1.0f;
	
	NSInteger count = (NSInteger)[_items count];
	CGSize size = frame.size;
	CGFloat segmentWidth = roundf((size.width - count - 1) / (CGFloat)count);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	for (NSInteger i = 0; i < count; i++) {
		CGContextSaveGState(context);
		
		id item = [_items objectAtIndex:(NSUInteger)i];
		
		CGFloat x = (segmentWidth * (CGFloat)i + (((CGFloat)i + 1) * dividerWidth));
		
		// Draw dividers
		if (i > 0) {
			
			NSInteger p  = i - 1;
			UIImage *dividerImage = nil;
			
			// Selected divider
			if ((p >= 0 && p == _selectedSegmentIndex) || i == _selectedSegmentIndex) {
				dividerImage = _highlightedDividerImage;
			}
			
			// Normal divider
			else {
				dividerImage = _dividerImage;
			}
			
			[dividerImage drawInRect:CGRectMake(x - 1.0f, 0.0f, dividerWidth, size.height)];
		}
		
		CGRect segmentRect = CGRectMake(x, 0.0f, segmentWidth, size.height);
		CGContextClipToRect(context, segmentRect);
		
		// Background
		UIImage *backgroundImage = nil;
		CGRect backgroundRect = segmentRect;
		if (_selectedSegmentIndex == i) {
			backgroundImage = _highlightedButtonImage;
		} else {
			backgroundImage = _buttonImage;
		}
		
		CGFloat capWidth = backgroundImage.leftCapWidth;
		
		// First segment
		if (i == 0) {
			backgroundRect = CGRectSetWidth(backgroundRect, backgroundRect.size.width + capWidth);
		}
		
		// Last segment
		else if (i == count - 1) {
			backgroundRect = CGRectMake(backgroundRect.origin.x - capWidth, backgroundRect.origin.y,
										backgroundRect.size.width + capWidth, backgroundRect.size.height);
		}
		
		// Middle segment
		else {
			backgroundRect = CGRectMake(backgroundRect.origin.x - capWidth, backgroundRect.origin.y,
										backgroundRect.size.width + capWidth + capWidth, backgroundRect.size.height);
		}
		
		[backgroundImage drawInRect:backgroundRect];
		
		// Strings
		if ([item isKindOfClass:[NSString class]]) {
			NSString *string = (NSString *)item;
			
			CGSize textSize = [string sizeWithFont:_font constrainedToSize:CGSizeMake(segmentWidth, size.height) lineBreakMode:UILineBreakModeTailTruncation];
			CGRect textRect = CGRectMake(x, roundf((size.height - textSize.height) / 2.0f), segmentWidth, size.height);
			textRect = UIEdgeInsetsInsetRect(textRect, _textEdgeInsets);

            if (_selectedSegmentIndex == i) {
                [_highlightedTextShadowColor set];
                [string drawInRect:CGRectAddPoint(textRect, CGPointMake(_highlightedTextShadowOffset.width, _highlightedTextShadowOffset.height)) withFont:_font lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentCenter];
            } else {
                [_textShadowColor set];
                [string drawInRect:CGRectAddPoint(textRect, CGPointMake(_textShadowOffset.width, _textShadowOffset.height)) withFont:_font lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentCenter];
            }
			
            if (_selectedSegmentIndex == i) {
                [_highlightedTextColor set];
            } else {
                [_textColor set];
            }
			[string drawInRect:textRect withFont:_font lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentCenter];
		}
		
		// TODO: Images
		
		CGContextRestoreGState(context);
	}
}


- (void)willMoveToSuperview:(UIView *)newSuperview {
	[super willMoveToSuperview:newSuperview];
		
	if (newSuperview) {
		[self addObserver:self forKeyPath:@"buttonImage" options:NSKeyValueObservingOptionNew context:nil];
		[self addObserver:self forKeyPath:@"highlightedButtonImage" options:NSKeyValueObservingOptionNew context:nil];
		[self addObserver:self forKeyPath:@"dividerImage" options:NSKeyValueObservingOptionNew context:nil];
		[self addObserver:self forKeyPath:@"highlightedDividerImage" options:NSKeyValueObservingOptionNew context:nil];
		[self addObserver:self forKeyPath:@"font" options:NSKeyValueObservingOptionNew context:nil];
		[self addObserver:self forKeyPath:@"textColor" options:NSKeyValueObservingOptionNew context:nil];
		[self addObserver:self forKeyPath:@"textShadowColor" options:NSKeyValueObservingOptionNew context:nil];
		[self addObserver:self forKeyPath:@"textShadowOffset" options:NSKeyValueObservingOptionNew context:nil];
		[self addObserver:self forKeyPath:@"textEdgeInsets" options:NSKeyValueObservingOptionNew context:nil];
	} else {
		[self removeObserver:self forKeyPath:@"buttonImage"];
		[self removeObserver:self forKeyPath:@"highlightedButtonImage"];
		[self removeObserver:self forKeyPath:@"dividerImage"];
		[self removeObserver:self forKeyPath:@"highlightedDividerImage"];
		[self removeObserver:self forKeyPath:@"font"];
		[self removeObserver:self forKeyPath:@"textColor"];
		[self removeObserver:self forKeyPath:@"textShadowColor"];
		[self removeObserver:self forKeyPath:@"textShadowOffset"];
		[self removeObserver:self forKeyPath:@"textEdgeInsets"];
	}
}


#pragma mark Initializer

- (id)initWithItems:(NSArray *)items {
	if ((self = [self initWithFrame:CGRectZero])) {
		NSInteger index = 0;
		for (id item in items) {
			if ([item isKindOfClass:[NSString class]]) {
				[self setTitle:item forSegmentAtIndex:(NSUInteger)index];
				index++;
			}
		}
	}
	return self;
}


#pragma mark Segments

- (void)setTitle:(NSString *)title forSegmentAtIndex:(NSUInteger)segment {
	if ((NSInteger)([_items count] - 1) < (NSInteger)segment) {
		[_items addObject:title];
	} else {
		[_items replaceObjectAtIndex:segment withObject:title];
	}
	
	[self setNeedsDisplay];
}


- (NSString *)titleForSegmentAtIndex:(NSUInteger)segment {
	if ([_items count] - 1 >= segment) {
		return nil;
	}
	
	id item = [_items objectAtIndex:segment];
	if ([item isKindOfClass:[NSString class]]) {
		return item;
	}
	
	return nil;
}


- (void)setSelectedSegmentIndex:(NSInteger)selectedSegmentIndex {
    [self setSelectedSegmentIndex:selectedSegmentIndex sendAction:NO];
}


- (void)setSelectedSegmentIndex:(NSInteger)selectedSegmentIndex sendAction:(BOOL)sendAction {
    _selectedSegmentIndex = selectedSegmentIndex;
    [self setNeedsDisplay];
    if (sendAction) {
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

#pragma mark NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqual:@"buttonImage"] || [keyPath isEqual:@"highlightedButtonImage"] ||
		[keyPath isEqual:@"dividerImage"] || [keyPath isEqual:@"highlightedDividerImage"] ||
		[keyPath isEqual:@"font"] || [keyPath isEqual:@"textColor"] || [keyPath isEqual:@"textShadowColor"] ||
		[keyPath isEqual:@"textShadowOffset"] || [keyPath isEqual:@"textEdgeInsets"]) {
		[self setNeedsDisplay];
		return;
	}
	
	[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

@end
