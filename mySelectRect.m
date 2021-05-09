//
//  mySelectRect.m
//  CardOri
//
//  Created by 武村 健二 on  07/04/04.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "mySelectRect.h"


@implementation mySelectRect

- (void)dealloc
{
	[_frame release];
	[_fill release];
	
	[super dealloc];
}

- (id) initWithBase:(NSRect)base view:(NSView *)v
{
    self = [super init];
	if( self )
	{
		_inside = NO;
		_view = v;
		_base = base;
		_will = NSMakeRect( -1, -1, 1, 1 );
		_did = NSMakeRect( -1, -1, 1, 1 );
		_max = NSMakePoint( 1, 1 );
	}
	
	return self;
}

- (void) setMax:(NSPoint)m
{
	_max = m;
}

- (void) setColors:(NSColor *)frameColor fill:(NSColor *)fillColor
{
	_frame = [frameColor retain];
	_fill = [fillColor retain];
}

- (NSRect) rect
{
	float x, y, w, h;
	x = NSMinX(_will) -NSMinX(_base);
	y = NSMinY(_will) -NSMinY(_base);
	x /= NSWidth(_base);
	y /= NSHeight(_base);
	w = NSWidth(_will) / NSWidth(_base);
	h = NSHeight(_will) / NSHeight(_base);
	
	return NSMakeRect( x +1, y +1, w, h );
}

- (NSRect) will
{
	return _will;
}

- (NSRect) getRectX:(int)x Y:(int)y W:(int)w H:(int)h
{
	x--; y--;
	x *= NSWidth(_base);
	y *= NSHeight(_base);
	w *= NSWidth(_base);
	h *= NSHeight(_base);
	x += NSMinX(_base);
	y += NSMinY(_base);
	
	return NSMakeRect( x, y, w, h );
}

- (BOOL) inside
{
	return _inside;
}

- (NSPoint) mouse2Rect:(NSPoint)pos
{
	int x, y;
	pos.x -= NSMinX(_base);
	pos.y -= NSMinY(_base);
	
	pos.x /= NSWidth(_base) ;
	pos.y /= NSHeight(_base) ;
	x = (int)pos.x;
	y = (int)pos.y;
	if( pos.y < 0.0 )
		y = -1;
	if( _max.y <= y )
		y = -2;
	if( pos.x < 0.0 )
		x = -1;
	if( _max.x <= x )
		x = -2;
		
	if( x < 0.0 || y < 0.0 )
		_inside = NO;
	else
		_inside = YES;
	pos.x = x;
	pos.y = y;
	
	return pos;
}

- (void) selectRect:(NSPoint)pos type:(int)m
{
	pos = [self mouse2Rect:pos];
	int x = pos.x;
	int y = pos.y;
	if( x < 0.0 || y < 0.0 && m == MDOWN ) return;
	if( x == -1 ) x = 0;
	if( y == -1 ) y = 0;
	if( x == -2 ) x = _max.x -1;
	if( y == -2 ) y = _max.y -1;
		
	// if( x == _pre.x && y == _pre.y ) return;
	// _pre = NSMakePoint( x, y );
	
	NSRect r;
	if( 0.0 <= NSMinX(_did) && 0.0 <= NSMinY(_did) )
	{
		r = NSMakeRect( NSMinX(_did) -NSWidth(_base),
						NSMinY(_did) -NSHeight(_base),
						NSWidth(_did) +NSWidth(_base),
						NSHeight(_did) +NSHeight(_base) );
		[_view setNeedsDisplayInRect:r];
	}
	_did = _will;
	
	int w = NSWidth(_base);
	int h = NSHeight(_base);
	x *= w; x += NSMinX(_base);
	y *= h; y += NSMinY(_base);
	switch( m )
	{
	case MCURSOR:
		r = NSMakeRect( x, y, w, h );
		_downed = r;
		_will = r;
		r = NSMakeRect( x -w * 3, y -h * 3, w * 7, h * 7 );
		break;
		
	case MDOWN:
		r = NSMakeRect( x, y, w, h );
		_downed = r;
		_will = r;
		break;
		
	default:
		_will = NSUnionRect( _downed, NSMakeRect( x, y, w, h ) );
		if( NSContainsRect( _did, _will ) == YES )
			r = _will;
		else
			r = _did;
		r.origin.x -= w;
		r.origin.y -= h;
		r.size.width += w * 2;
		r.size.height += h * 2;
		break;
	}
	[_view setNeedsDisplayInRect:r];

}

- (void) drawSelectRect:(int)n
{
	if( 0.0 < NSMinX(_will) && 0.0 < NSMinY(_will) )
	{
		NSRect r;
		if( n )
		{
			r = NSMakeRect( 
				NSMinX(_will) -n,
				NSMinY(_will) -n,
				NSWidth( _will) +2 * n,
				NSHeight(_will) +2 * n );
		}
		else r = _will;
		
		[_fill set];
		NSRectFillUsingOperation( r, NSCompositeSourceOver );
			
		[_frame set];
		NSFrameRectWithWidthUsingOperation( r, 3.0, NSCompositeSourceOver );
	}
}

- (void) clearRect
{
	_will = NSMakeRect( -1, -1, 1, 1 );
	if( 0.0 <= NSMinX(_did) && 0.0 <= NSMinY(_did) )
	{
		NSRect r = NSMakeRect( NSMinX(_did) -NSWidth(_base),
						NSMinY(_did) -NSHeight(_base),
						NSWidth(_did) +NSWidth(_base),
						NSHeight(_did) +NSHeight(_base) );
		[_view setNeedsDisplayInRect:r];
	}
	_did = NSMakeRect( -1, -1, 1, 1 );
}
@end
