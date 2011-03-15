//
//  SSDrawingMacros.m
//  SSToolkit
//
//  Created by Sam Soffes on 8/20/10.
//  Copyright 2009-2010 Sam Soffes. All rights reserved.
//

#import "SSDrawingMacros.h"

CGFloat SSFLimit(CGFloat f, CGFloat min, CGFloat max) {
	return fminf(fmaxf(f, min), max);
}


CGRect CGRectSetX(CGRect rect, CGFloat x) {
	return CGRectMake(x, rect.origin.y, rect.size.width, rect.size.height);
}


CGRect CGRectSetY(CGRect rect, CGFloat y) {
	return CGRectMake(rect.origin.x, y, rect.size.width, rect.size.height);
}


CGRect CGRectSetWidth(CGRect rect, CGFloat width) {
	return CGRectMake(rect.origin.x, rect.origin.y, width, rect.size.height);
}


CGRect CGRectSetHeight(CGRect rect, CGFloat height) {
	return CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, height);
}


CGRect CGRectSetOrigin(CGRect rect, CGPoint origin) {
	return CGRectMake(origin.x, origin.y, rect.size.width, rect.size.height);
}


CGRect CGRectSetSize(CGRect rect, CGSize size) {
	return CGRectMake(rect.origin.x, rect.origin.y, size.width, size.height);
}


CGRect CGRectSetZeroOrigin(CGRect rect) {
	return CGRectMake(0.0f, 0.0f, rect.size.width, rect.size.height);
}


CGRect CGRectSetZeroSize(CGRect rect) {
	return CGRectMake(rect.origin.x, rect.origin.y, 0.0f, 0.0f);
}


CGSize CGSizeAspectScaleToSize(CGSize size, CGSize toSize) {
	// Probably a more efficient way to do this...
	CGFloat aspect = 1.0f;
	
	if (size.width > toSize.width) {
		aspect = toSize.width / size.width;
	}
	
	if (size.height > toSize.height) {
		aspect = fminf(toSize.height / size.height, aspect);
	}
	
	return CGSizeMake(size.width * aspect, size.height * aspect);
}


CGRect CGRectAddPoint(CGRect rect, CGPoint point) {
	return CGRectMake(rect.origin.x + point.x, rect.origin.y + point.y, rect.size.width, rect.size.height);
}


extern CGMutablePathRef SSRoundedRectPath(CGRect rect, CGFloat cornerRadius) {
	CGPoint min = CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect));
	CGPoint mid = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
	CGPoint max = CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect));
	
	CGMutablePathRef path = CGPathCreateMutable();
	
	CGPathMoveToPoint(path, NULL, min.x, mid.y);
	CGPathAddArcToPoint(path, NULL, min.x, min.y, mid.x, min.y, cornerRadius);
	CGPathAddArcToPoint(path, NULL, max.x, min.y, max.x, mid.y, cornerRadius);
	CGPathAddArcToPoint(path, NULL, max.x, max.y, mid.x, max.y, cornerRadius);
	CGPathAddArcToPoint(path, NULL, min.x, max.y, min.x, mid.y, cornerRadius);
	
	return path;
}


void SSDrawRoundedRect(CGContextRef context, CGRect rect, CGFloat cornerRadius) {
	CGPoint min = CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect));
	CGPoint mid = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
	CGPoint max = CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect));
	
	CGContextMoveToPoint(context, min.x, mid.y);
	CGContextAddArcToPoint(context, min.x, min.y, mid.x, min.y, cornerRadius);
	CGContextAddArcToPoint(context, max.x, min.y, max.x, mid.y, cornerRadius);
	CGContextAddArcToPoint(context, max.x, max.y, mid.x, max.y, cornerRadius);
	CGContextAddArcToPoint(context, min.x, max.y, min.x, mid.y, cornerRadius);
	
	CGContextClosePath(context);
	CGContextFillPath(context);
}


CGGradientRef SSGradientWithColors(UIColor *topColor, UIColor *bottomColor) {
	return SSGradientWithColorsAndLocations(topColor, bottomColor, 0.0f, 1.0f);
}


CGGradientRef SSGradientWithColorsAndLocations(UIColor *topColor, UIColor *bottomColor, CGFloat topLocation, CGFloat bottomLocation) {
	CGFloat locations[] = {
		topLocation,
		bottomLocation
	};
	
	CGColorRef topCGColor = topColor.CGColor;
	CGColorSpaceRef colorSpace = CGColorGetColorSpace(topCGColor);
	NSArray *colors = [[NSArray alloc] initWithObjects:(id)topCGColor, (id)bottomColor.CGColor, nil];
	CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)colors, locations);
	[colors release];
	
	return gradient;
}



void SSDrawGradientInRect(CGContextRef context, CGGradientRef gradient, CGRect rect) {
	CGContextSaveGState(context);
	CGContextClipToRect(context, rect);
	CGPoint start = CGPointMake(rect.origin.x, rect.origin.y);
	CGPoint end = CGPointMake(rect.origin.x, rect.origin.y + rect.size.height);
	CGContextDrawLinearGradient(context, gradient, start, end, 0);
	CGContextRestoreGState(context);
}
