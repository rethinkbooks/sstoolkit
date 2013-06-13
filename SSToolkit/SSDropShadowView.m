//
//  SSDropShadowView.m
//  SSToolkit
//
//  Created by Arthur Dexter on 12/15/11.
//  Copyright (c) 2011 Rethink Books. All rights reserved.
//

#import "SSDropShadowView.h"
#import <QuartzCore/QuartzCore.h>

@implementation SSDropShadowView
{
    UIView *view_;
}

- (id)initWithView:(UIView *)view {
    self = [super initWithFrame:view.frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.layer.cornerRadius = 8.0f;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0.0f, 3.0f);
        self.layer.shadowOpacity = 0.5f;
        self.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                           cornerRadius:8.0f].CGPath;
        self.layer.shadowRadius = 12.0f;

        view_ = view;
        view.layer.cornerRadius = 8.0f;
        view.clipsToBounds = YES;
        [self addSubview:view_];
    }
    return self;
}

- (void)layoutSubviews {
    self.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                       cornerRadius:8.0f].CGPath;
    view_.frame = self.bounds;
}

@end
