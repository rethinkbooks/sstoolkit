//
//  SSInnerWebView.m
//  SSToolkit
//
//  Created by Vladislav Glabai on 3/17/11.
//  Copyright 2011 Sam Soffes. All rights reserved.
//

#import "SSInnerWebView.h"


@implementation SSInnerWebView

@synthesize disableStandardActions = _disableStandardActions;

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if(self.disableStandardActions) {
        return NO;
    } else {
        return [super canPerformAction:action withSender:sender];
    }
}

@end
