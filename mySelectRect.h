//
//  mySelectRect.h
//  CardOri
//
//  Created by 武村 健二 on  07/04/04.
//  Copyright 2007 Oriya Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

enum { MUP = 10, MDRAG = 20, MDOWN = 30, MCURSOR };

@interface mySelectRect : NSObject
{
	NSView *_view;
	NSColor *_frame;
	NSColor *_fill;
	NSRect _will, _did, _downed, _base;
	NSPoint _max;
	BOOL _inside;
}

- (id) initWithBase:(NSRect)base view:(NSView *)v;
- (void) setMax:(NSPoint)m;
- (void) setColors:(NSColor *)frameColor fill:(NSColor *)fillColor;
- (NSRect) rect;
- (NSRect) will;
- (NSRect) getRectX:(int)x Y:(int)y W:(int)w H:(int)h;
- (BOOL) inside;
- (NSPoint) mouse2Rect:(NSPoint)pos;
- (void) selectRect:(NSPoint)pos type:(int)m;
- (void) drawSelectRect:(int)n;
- (void) clearRect;

@end
