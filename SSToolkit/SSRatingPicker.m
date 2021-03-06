//
//  SSRatingPicker.m
//  SSToolkit
//
//  Created by Sam Soffes on 2/2/11.
//  Copyright 2011 Sam Soffes. All rights reserved.
//

#import "SSRatingPicker.h"
#import "UIImage+SSToolkitAdditions.h"
#import "UIView+SSToolkitAdditions.h"

@interface SSRatingPicker (PrivateMethods)
- (void)_setNumberOfStarsWithTouch:(UITouch *)touch;
@end


@implementation SSRatingPicker

#pragma mark UIResponder

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	[self _setNumberOfStarsWithTouch:[touches anyObject]];
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[self _setNumberOfStarsWithTouch:[touches anyObject]];
}


#pragma mark UIView

- (id)initWithFrame:(CGRect)rect {
	if ((self = [super initWithFrame:rect])) {
        [self initSSRatingPicker];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self initSSRatingPicker];
    }
    return self;
}

- (void)initSSRatingPicker {
    self.emptyStarImage = [UIImage imageNamed:@"SSToolkit.bundle/gray-star.png" bundle:kSSToolkitBundleName];
    self.filledStarImage = [UIImage imageNamed:@"SSToolkit.bundle/orange-star.png" bundle:kSSToolkitBundleName];
    self.starSize = CGSizeMake(21.0f, 36.0f);
    self.starSpacing = 19.0f;
    self.numberOfStars = 0.0f;
    self.numberOfMediumStars = 0.0f;
    self.totalNumberOfStars = 5;

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.textColor = [UIColor colorWithRed:0.612f green:0.620f blue:0.624f alpha:1.0f];
    label.shadowColor = [UIColor whiteColor];
    label.shadowOffset = CGSizeMake(0.0f, 1.0f);
    label.backgroundColor = [UIColor clearColor];
    label.text = NSLocalizedString(@"Tap a Star to Rate", @"Rating picker tap a star");
    label.font = [UIFont boldSystemFontOfSize:12.0f];
    label.textAlignment = NSTextAlignmentCenter;
    self.textLabel = label;
    [self addSubview:label];
}

- (CGSize)sizeThatFits:(CGSize)size {
	return CGSizeMake(_starSize.width * (CGFloat)_totalNumberOfStars, _starSize.height);
}

- (void)layoutSubviews {
	_textLabel.frame = self.bounds;
}

- (void)drawRect:(CGRect)rect {
	const CGRect bounds = self.bounds;
	CGFloat totalWidth = (_starSize.width * (CGFloat)_totalNumberOfStars) + 
						 (_starSpacing * (CGFloat)(_totalNumberOfStars - 1));
	CGPoint origin = CGPointMake(roundf((bounds.size.width - totalWidth) / 2.0f),
                                 roundf((bounds.size.height - self.starSize.height) / 2.0f));

    NSUInteger numberOfStars = roundf(_numberOfStars);
    if (numberOfStars > 0.0f) {
        for (NSUInteger i = 0; i < _totalNumberOfStars; i++) {
            UIImage *image = numberOfStars >= i + 1 ? _filledStarImage : _emptyStarImage;
            [image drawInRect:[self _starRectAtIndex:i withOrigin:origin]];
        }
    } else {
        NSUInteger numberOfMediumHalfStars = roundf(_numberOfMediumStars * 2);
        for (NSUInteger i = 0; i < _totalNumberOfStars; i++) {
            NSUInteger halfStarIndex = i * 2;
            UIImage *image;
            if (halfStarIndex + 1 < numberOfMediumHalfStars) {
                image = _mediumStarImage;
            } else if (halfStarIndex < numberOfMediumHalfStars) {
                image = _mediumStarHalfImage;
            } else {
                image = _emptyStarImage;
            }
            [image drawInRect:[self _starRectAtIndex:i withOrigin:origin]];
        }
	}
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
	[super willMoveToSuperview:newSuperview];
	
	if (newSuperview) {
		[self addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
		[self addObserver:self forKeyPath:@"totalNumberOfStars" options:NSKeyValueObservingOptionNew context:nil];
		[self addObserver:self forKeyPath:@"emptyStarImage" options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:@"mediumStarImage" options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:@"mediumStarHalfImage" options:NSKeyValueObservingOptionNew context:nil];
		[self addObserver:self forKeyPath:@"filledStarImage" options:NSKeyValueObservingOptionNew context:nil];
		[self addObserver:self forKeyPath:@"starSize" options:NSKeyValueObservingOptionNew context:nil];
		[self addObserver:self forKeyPath:@"starSpacing" options:NSKeyValueObservingOptionNew context:nil];
	} else {
		[self removeObserver:self forKeyPath:@"frame"];
		[self removeObserver:self forKeyPath:@"totalNumberOfStars"];
		[self removeObserver:self forKeyPath:@"emptyStarImage"];
        [self removeObserver:self forKeyPath:@"mediumStarImage"];
        [self removeObserver:self forKeyPath:@"mediumStarHalfImage"];
		[self removeObserver:self forKeyPath:@"filledStarImage"];
		[self removeObserver:self forKeyPath:@"starSize"];
		[self removeObserver:self forKeyPath:@"starSpacing"];
	}
}

- (void)setNumberOfMediumStars:(CGFloat)numberOfMediumStars {
    [self _setNumberOfMediumStars:numberOfMediumStars sendActions:NO];
}

- (void)setNumberOfStars:(CGFloat)numberOfStars {
    [self _setNumberOfStars:numberOfStars sendActions:NO];
}

#pragma mark Private Methods

- (void)_setNumberOfMediumStars:(CGFloat)numberOfMediumStars sendActions:(BOOL)sendActions {
    if (_numberOfMediumStars != numberOfMediumStars) {
        _numberOfMediumStars = numberOfMediumStars;
        if (sendActions) {
            [self sendActionsForControlEvents:UIControlEventValueChanged];
        }
        [self _reloadTextLabel];
        [self setNeedsDisplay];
    }
}

- (void)_setNumberOfStars:(CGFloat)numberOfStars sendActions:(BOOL)sendActions {
    if (_numberOfStars != numberOfStars) {
        _numberOfStars = numberOfStars;
        if (sendActions) {
            [self sendActionsForControlEvents:UIControlEventValueChanged];
        }
        [self _reloadTextLabel];
        [self setNeedsDisplay];
    }
}

- (void)_setNumberOfStarsWithTouch:(UITouch *)touch {
	CGPoint point = [touch locationInView:self];
	
	CGFloat totalWidth = (_starSize.width * (CGFloat)_totalNumberOfStars) + 
						 (_starSpacing * (CGFloat)(_totalNumberOfStars - 1));
	CGFloat left = roundf((self.frame.size.width - totalWidth) / 2.0f);
	
	if (point.x < left) {
		[self _setNumberOfStars:0.0f sendActions:YES];
		return;
	}
	
	if (point.x >= left + totalWidth) {
        [self _setNumberOfStars:_totalNumberOfStars sendActions:YES];
		return;
	}
	
	// TODO: Improve
    [self _setNumberOfStars:ceilf((point.x - left) / (_starSize.width + _starSpacing)) sendActions:YES];
}

- (CGRect)_starRectAtIndex:(NSUInteger)index withOrigin:(CGPoint)origin {
    return CGRectMake(origin.x + (_starSize.width + _starSpacing) * (CGFloat)index,
                      origin.y,
                      _starSize.width,_starSize.height);
}

- (void)_reloadTextLabel {
    if (self.numberOfStars > 0.0f || self.numberOfMediumStars > 0.0f) {
        if (_textLabel.alpha != 0.0f) {
            [UIView animateWithDuration:0.2
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 _textLabel.alpha = 0.0f;
                             } completion:^(BOOL finished) {
                                 if (finished) {
                                     _textLabel.hidden = YES;
                                 }
                             }];
        }
    } else {
        if (_textLabel.alpha == 0.0f) {
            _textLabel.hidden = NO;
            [UIView animateWithDuration:0.2
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 _textLabel.alpha = 1.0f;
                             } completion:NULL];
        }
    }
}

#pragma mark NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqual:@"frame"] || [keyPath isEqual:@"totalNumberOfStars"] || [keyPath isEqual:@"emptyStarImage"] ||
		[keyPath isEqual:@"mediumStarImage"] || [keyPath isEqual:@"mediumStarHalfImage"] || [keyPath isEqual:@"filledStarImage"] ||
        [keyPath isEqual:@"starSize"] || [keyPath isEqual:@"starSpacing"]) {
		[self setNeedsDisplay];
		return;
	}
	[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

@end
