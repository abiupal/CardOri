//
//  cardori.m
//  CardOri
//
//  Created by 武村 健二 on  07/03/06.
//  Copyright 2007 Oriya Inc. All rights reserved.
//

#import "cardori.h"

@implementation YarnData

- (id) initWithData:(int)no radius:(GLfloat)r r:(GLfloat)red g:(GLfloat)grn b:(GLfloat)blu a:(GLfloat)alp
{
    self = [super init];
	if( self )
	{
		_radius = r;
		_col[0] = red; _col[1] = grn; _col[2] = blu; _col[3] = alp;
		_no = no;
	}
	
	return self;
}

- (GLfloat *) colors
{
	return &_col[0];
}

- (int) no
{
	return _no;
}

- (GLfloat) radius
{
	return _radius;
}

- (bool) checkSame:(GLfloat)radius r:(GLfloat)red g:(GLfloat)grn b:(GLfloat)blu a:(GLfloat)alp
{
	bool b = FALSE;
	
	if( _radius == radius && _col[0] == red && _col[1] == grn && _col[2] == blu && _col[3] == alp )
		b = TRUE;
		
	return b;
}

- (GLfloat) color:(int)rgba
{
	return _col[rgba];
}

- (NSMutableArray *) arrayObject
{
	NSNumber *number;
	NSMutableArray *array = [NSMutableArray array];
	
	number = [NSNumber numberWithFloat:_radius];
	[array addObject:number];
	int i;
	for( i = 0; i < 4; ++i )
	{
		number = [NSNumber numberWithFloat:_col[i]];
		[array addObject:number];
	}
	number = [NSNumber numberWithInt:_no];
	[array addObject:number];
	
	return array;
}

- (void) setArrayObject:(NSArray *)array
{
	NSNumber *number;

	number = [array objectAtIndex:0];
	_radius = [number floatValue];
	int i;
	for( i = 0; i < 4; ++i )
	{
		number = [array objectAtIndex:1 +i];
		_col[i] = [number floatValue];
	}
	number = [array objectAtIndex:4];
	_no = [number intValue];
}

@end


@implementation CardYarns

- (id)initWithData:(int)order fb:(int *)fb yarnArray:(NSMutableArray *)d
{
    self = [super init];
	if( self )
	{
		_order = order;
		if( fb != nil )
			memcpy( &_fb[0], fb, sizeof(_fb));
		_yarnArray = d;
		_a = _b = _c = _d = -1;
	}
	
	return self;
}

- (void) setOrder:(int)order
{
	_order = order;
}

- (void) setYarn:(int)pos yarnData:(int)n
{
	switch( pos )
	{
	case POS_A: _a = n; break;
	case POS_B: _b = n; break;
	case POS_C: _c = n; break;
	case POS_D: _d = n; break;
	}
}

- (int) order
{
	return _order;
}

- (int)fb:(int)pos
{
	if( pos < 0 ) pos = 0;
	else if( FB_MAX <= pos ) pos = FB_MAX -1;
	
	return _fb[pos];
}

- (int *)fb
{
	return &_fb[0];
}

- (YarnData *)yarn:(int)pos
{
	int n = -1;
	
	switch( pos )
	{
	case POS_A: n = _a; break;
	case POS_B: n = _b; break;
	case POS_C: n = _c; break;
	case POS_D: n = _d; break;
	}
	
	return [_yarnArray objectAtIndex:n];
}

- (NSString *)info
{
	NSString *str;
	
	if( _order == ORDER_S )
	{
		str = [NSString stringWithFormat:@"%@ a:%d b:%d c:%d d:%d\n",
			[NSString stringWithUTF8String:"表"], _a +1,_b +1,_c +1,_d +1 ];
	}
	else
	{
		str = [NSString stringWithFormat:@"%@ a:%d b:%d c:%d d:%d\n",
			[NSString stringWithUTF8String:"裏"], _a +1,_b +1,_c +1,_d +1 ];
	}
	
	return str;
}
- (int) a
{
	return _a +1;
}

- (int) b
{
	return _b +1;
}
- (int) c
{
	return _c +1;
}
- (int) d
{
	return _d +1;
}

- (NSMutableArray *) arrayObject
{
	NSNumber *number;
	NSMutableArray *array = [NSMutableArray array];
	
	number = [NSNumber numberWithInt:_a];
	[array addObject:number];
	number = [NSNumber numberWithInt:_b];
	[array addObject:number];
	number = [NSNumber numberWithInt:_c];
	[array addObject:number];
	number = [NSNumber numberWithInt:_d];
	[array addObject:number];
	number = [NSNumber numberWithInt:_order];
	[array addObject:number];
	
	number = [NSNumber numberWithInt:FB_MAX];
	[array addObject:number];
	int i;
	for( i = 0; i < FB_MAX; ++i )
	{
		number = [NSNumber numberWithInt:_fb[i]];
		[array addObject:number];
	}
	
	return array;
}

- (void) setArrayObject:(NSArray *)array
{
	NSNumber *number;

	number = [array objectAtIndex:0];
	_a = [number intValue];
	number = [array objectAtIndex:1];
	_b = [number intValue];
	number = [array objectAtIndex:2];
	_c = [number intValue];
	number = [array objectAtIndex:3];
	_d = [number intValue];
	number = [array objectAtIndex:4];
	_order = [number intValue];
	number = [array objectAtIndex:5];
	int i, max = [number intValue];
	for( i = 0; i < max; ++i )
	{
		if( FB_MAX <= i ) break;
		number = [array objectAtIndex:6 +i];
		_fb[i] = [number intValue];
	}
}

@end

@implementation GlobalData

- (void) initWithData:(viewData *)data
{
    self = [super init];
	if( self )
	{
		_version = 0.11;
		_cardOrder = [[NSMutableData dataWithLength:144 * sizeof(unsigned long)] retain];
		_yarnArray = [[NSMutableArray array] retain];
		[self setData:data];
	}
}

- (void)dealloc
{
	[_cardOrder release];
	[_yarnArray release];
	
	[super dealloc];
}

- (void) setData:(viewData *)data
{
	_ylength = data->ylength;
	_aspectX = data->aspectX;
	_aspectY = data->aspectY;
	_aspectZ = data->aspectZ;
	_xlength = data->xlength;
	_angle = data->angle;
	_xlineGap = data->xlineGap;
	_ylineGap = data->ylineGap;
}

- (NSMutableData *) cardOrder
{
	return _cardOrder;
}

- (NSMutableArray *) yarnArray
{
	return _yarnArray;
}

- (YarnData *)yarn:(int)select
{
	if( select == X )
		return _x;
	if( select == Y )
		return _y;
		
	return nil;
}

- (GLfloat)gap:(int)select
{
	if( select == X )
		return _xlineGap;
	if( select == Y )
		return _ylineGap;
	
	return nil;
}

- (GLfloat)xlength
{
	return _xlength;
}

- (int)cards
{
	int i = [self xlength] / [self gap:X] -1;
	return i;
}

- (int)ylength
{
	return _ylength;
}

- (GLfloat)aspect:(int)select
{
	if( select == X )
		return _aspectX ;
	if( select == Y )
		return _aspectY ;
	if( select == Z )
		return _aspectZ ;
		
	return 0.0;
}

- (GLfloat)angle
{
	return _angle;
}


- (void) setYarn:(int)select value:(YarnData *)d
{
	if( select == X )
		_x = d;
	if( select == Y )
		_y = d;
}

- (void) setGap:(int)select value:(GLfloat)f
{
	if( select == X )
		_xlineGap = f;
	if( select == Y )
		_ylineGap = f;
}

- (void) setLengthX:(GLfloat)f
{
	_xlength = f;
}

- (void) setCards:(int)i
{
	float f = (i +1);
	f *= [self gap:X];
	[self setLengthX:f];
}

- (void) setLengthY:(int)i
{
	_ylength = i;
}

- (void) setAspect:(int)select value:(GLfloat)f;
{
	if( select == X )
		_aspectX = f;
	if( select == Y )
		_aspectY = f;
	if( select == Z )
		_aspectZ = f;
}

- (void) addYarn:(GLfloat)radius r:(GLfloat)red g:(GLfloat)grn b:(GLfloat)blu a:(GLfloat)alp
{
	int n = [self find:radius r:red g:grn b:blu a:alp];
	
	if( n < 0 )
	{
		YarnData *yd = [[YarnData alloc] initWithData:[_yarnArray count] radius:radius r:red g:grn b:blu a:alp];
		[_yarnArray addObject:yd];
	}
}

- (int)find:(GLfloat)radius r:(GLfloat)red g:(GLfloat)grn b:(GLfloat)blu a:(GLfloat)alp
{
	int i, n = -1;
	
	for( i = 0; i < [_yarnArray count]; ++i )
	{
		if( [[_yarnArray objectAtIndex:i] checkSame:radius r:red g:grn b:blu a:alp] == TRUE )
		{
			n = i;
			break;
		}
	}
	
	return n;
}

- (NSMutableArray *)arrayObject
{
	NSNumber *number;
	NSMutableArray *array = [NSMutableArray array];
	
	number = [NSNumber numberWithInt:_ylength];
	[array addObject:number];
	number = [NSNumber numberWithFloat:_aspectX];
	[array addObject:number];
	number = [NSNumber numberWithFloat:_aspectY];
	[array addObject:number];
	number = [NSNumber numberWithFloat:_aspectZ];
	[array addObject:number];
	number = [NSNumber numberWithFloat:_xlength];
	[array addObject:number];
	number = [NSNumber numberWithFloat:_angle];
	[array addObject:number];
	number = [NSNumber numberWithFloat:_xlineGap];
	[array addObject:number];
	number = [NSNumber numberWithFloat:_ylineGap];
	[array addObject:number];
	[array addObject:[_x arrayObject]];
	[array addObject:[_y arrayObject]];
	[array addObject:_cardOrder];
	/* from ver 0.11 */
	number = [NSNumber numberWithFloat:(_version * -1.0)];
	[array addObject:number];
	/* end ver 0.11 */
	number = [NSNumber numberWithInt:[_yarnArray count]];
	[array addObject:number];

	YarnData *yd;
	int i;
	for( i = 0; i < [_yarnArray count]; ++i )
	{
		yd = [_yarnArray objectAtIndex:i];
		[array addObject:[yd arrayObject]];
	}
	
	return array;
}

- (void) setArrayObject:(NSArray *)array
{
	NSNumber *number;
	unsigned int n = 0;
	float	version = 0.0;
	
	number = [array objectAtIndex:n++];
	_ylength = [number intValue];
	number = [array objectAtIndex:n++];
	_aspectX = [number floatValue];
	number = [array objectAtIndex:n++];
	_aspectY = [number floatValue];
	number = [array objectAtIndex:n++];
	_aspectZ = [number floatValue];
	number = [array objectAtIndex:n++];
	_xlength = [number floatValue];
	number = [array objectAtIndex:n++];
	_angle = [number floatValue];
	number = [array objectAtIndex:n++];
	_xlineGap = [number floatValue];
	number = [array objectAtIndex:n++];
	_ylineGap = [number floatValue];
	
	NSArray *a;
	a = [array objectAtIndex:n++];
	[_x setArrayObject:a];
	a = [array objectAtIndex:n++];
	[_y setArrayObject:a];

	[_cardOrder release];
	_cardOrder = [[array objectAtIndex:n++] retain];
	[_yarnArray release];
	_yarnArray = [[NSMutableArray array] retain];
	YarnData *yd;
	
	number = [array objectAtIndex:n++];
	int i, max;
	/* version check */
	version = [number floatValue];
	if( version < 0 )
	{
		version *= -1;		
		number = [array objectAtIndex:n++];
	}
	else
	{
		/* Here is no version data
		 * _cardOrder is (unsigned char)[]
		 * Convert to (unsigned long)[] */
		 NSData *old = [NSData dataWithData:_cardOrder];
		 [_cardOrder release];
		 
		 max = [old length];
		 _cardOrder = [[NSMutableData dataWithLength:max * sizeof(unsigned long)] retain];
		 unsigned char *s = (unsigned char *)[old bytes];
		 unsigned long *d = (unsigned long *)[_cardOrder bytes];
		 for( i = 0; i < max; ++i )
			d[i] = s[i];
	}
	max = [number intValue];
	for( i = 0; i < max; ++i )
	{
		a = [array objectAtIndex:n +i];
		yd = [[YarnData alloc] init];
		[yd setArrayObject:a];
		[_yarnArray addObject:yd];
	}
}

- (int)realCardFromDispCard:(int)n
{
	int l = [[self cardOrder] length];

	return l -(l -[self cards]) -n -1;
}

@end

