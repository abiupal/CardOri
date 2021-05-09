#import "CardSettingView.h"
#import "Controller.h"

@implementation CardSettingView

enum { CELL = 24, SIDE = 50, BASE_Y = 70 };
- (void)dealloc
{
	int i;
	for( i = 0; i < RMAX; ++i )
	{
		[_selectRect[i] release];
	}
	
	[super dealloc];
}

- (void)viewDidMoveToWindow 
{
	[[self window] setAcceptsMouseMovedEvents:YES];
	[[self window] makeFirstResponder:self]; 
	
	NSRect r = NSMakeRect(SIDE, BASE_Y -CELL, CELL * 3, CELL);
	int i = 0;
	_selectRect[i] = [[mySelectRect alloc]initWithBase:r view:self];
	[_selectRect[i] retain];
	r = NSMakeRect(SIDE, BASE_Y, CELL, CELL);
	for( i = RCURSOR; i < RMAX; ++i )
	{
		_selectRect[i] = [[mySelectRect alloc]initWithBase:r view:self];
		[_selectRect[i] retain];
	}
	[_selectRect[RTOUSHI] setColors:
		     [NSColor colorWithDeviceRed:0.6 green:0.9 blue:0.3 alpha:0.4]
		fill:[NSColor colorWithDeviceRed:0.6 green:0.9 blue:0.3 alpha:0.2] ];
	[_selectRect[RCURSOR] setColors:
		     [NSColor colorWithDeviceRed:0.9 green:0.6 blue:0.3 alpha:0.4]
		fill:[NSColor colorWithDeviceRed:0.9 green:0.6 blue:0.3 alpha:0.2] ];
	[_selectRect[RSELECT] setColors:
		     [NSColor colorWithDeviceRed:0.3 green:0.6 blue:0.9 alpha:0.8]
		fill:[NSColor colorWithDeviceRed:0.3 green:0.6 blue:0.9 alpha:0.4] ];
	[_selectRect[RFUNC] setColors:
		     [NSColor colorWithDeviceRed:0.9 green:0.3 blue:0.3 alpha:0.6]
		fill:[NSColor colorWithDeviceRed:0.9 green:0.3 blue:0.3 alpha:0.3] ];
}

- (void) setDatas:(id)controller data:(GlobalData *)data card:(NSMutableArray *)card;
{
	_controller = controller;
	_page = _pages = 0;
	_print = FALSE;
	_aCY = card;
	_data = data;
	_font = [[NSFont systemFontOfSize:18] retain];
	_sFont = [[NSFont systemFontOfSize:10] retain];
	
	_selectRectNumber = RCURSOR;
	_colorSelectYarn = -1;
}

- (id) initWithDatas:(GlobalData *)data card:(NSMutableArray *)card pixelData:(NSImage *)img printInfo:(NSPrintInfo *)pi
{
	NSRect frame;
	
	[self setDatas:nil data:data card:card];
	
	if( img != nil )
		_pixelData = img;
	
	_pages = 0;
	_paperSize = [pi paperSize];
	_printWidth = _paperSize.width- [pi leftMargin] - [pi rightMargin];
	_printWidth -= (360.0 / 25.4);
	float scale = [[[pi dictionary] objectForKey:NSPrintScalingFactor]
                     floatValue];
	_printWidth /= scale;
	_print = TRUE;
	
	frame.origin = NSMakePoint( 0, 0 );
	frame.size.width = [self width];
	frame.size.height = _paperSize.height;
	
	self = [super initWithFrame:frame];
	
	
	return self;
}


- (BOOL)knowsPageRange:(NSRangePointer)range
{	 	 
     range->location = 1;
     range->length = _pages;
	 
     return YES;
}

- (NSRect)rectForPage:(int)page
{
	int n = 0;
	int w = 0;
	
	if( _pixelData )
		page--;
	
	if( page == 2 )
		n = _nPageOneCell * CELL + SIDE ;
	else if( 2 < page )
		n = (_nPageOneCell + _nPagesCell * (page -2)) * CELL +SIDE;
	if( page == 1 )
		w = _nPageOneCell * CELL + SIDE ;
	else
		w = _nPagesCell * CELL;
		
	_page = page;
	
	NSRect bounds = [self bounds];
	return NSMakeRect( NSMinX(bounds) +n, NSMinY(bounds),
				w, NSHeight(bounds) );
}

- (void) checkPrintPages
{
	int i, w = SIDE;
	int max = [_data cards];
	
	for( i = 0; i < max; i += 3 )
	{
		if( _printWidth < (w + CELL * 3) || max <= (i +3) )
		{
			if( !_pages )
				_nPageOneCell = i;
			else if( _pages == 1 )
				_nPagesCell = i - _nPageOneCell;
				
			_pages++;
			if( max <= (i +3) && _printWidth < (w + CELL * 3) )
				_pages++;
			else
				w = CELL * 3;
		}
		else
			w += CELL * 3;
	}
	
	if( _pixelData )
		_pages++;
}

- (int) width
{
	int w = 0;
	
	if( _print == TRUE )
	{
		if( !_pages ) [self checkPrintPages];
		
		w = _printWidth * _pages;
	}
	else
		w = [_data cards] * CELL + SIDE * 2;
	
	return w;
}

- (void) setSelectRect:(NSPoint)pos type:(int)m
{
	if( _selectRectNumber == RCURSOR ) return;
		
	[_selectRect[_selectRectNumber] setMax:NSMakePoint( [_data cards], 4) ];
	[_selectRect[_selectRectNumber] selectRect:pos type:m];
}

- (void) setCursorPosition:(NSPoint)pos
{
	int i = [_data cards];
	[_selectRect[RCURSOR] setMax:NSMakePoint( i, 4) ];
	[_selectRect[RCURSOR] selectRect:pos type:MCURSOR];
	i /= 3;
	[_selectRect[RTOUSHI] setMax:NSMakePoint( i, 1) ];
	[_selectRect[RTOUSHI] selectRect:pos type:MCURSOR];
}

- (NSAttributedString *) stringCardRotate:(NSMutableDictionary *)attr
{
	NSString *str = [[NSString alloc] initWithUTF8String:"カード枚数"];
	str = [NSString stringWithFormat:@"%@ : %d", str, [_data cards] ];
	NSString *str2 = [[NSString alloc] initWithUTF8String:"　回転（後・前）"];
	str = [NSString stringWithFormat:@"%@  %@", str, str2 ];
	
	CardYarns *cy = [_aCY objectAtIndex:0];
	int x, *fb = [cy fb];
	for( x = 0; -1 < fb[x]; ++x )
	{
		/* 070530:rotate fixed */
		str = [NSString stringWithFormat:@"%@ : %d", str, fb[x]+1 ];
	}
	
	return [[[NSAttributedString alloc] initWithString:str attributes:attr] autorelease];
}

- (void) drawRect:(NSRect)rect
{
	int w = [self width];
	NSRect r = [self frame];
	if ( [NSGraphicsContext currentContextDrawingToScreen] )
	{
		if( NSWidth(r) < w )
		{
			r.size.width = w;
			[self setFrame:r];
		}
		else if( w < NSWidth(r) )
		{
			r.size.width = NSWidth([[self superview] frame]);
			[self setFrame:r];
		}
	}
	
	[self lockFocus];
	
	[[NSColor whiteColor] set];
	NSRectFill( rect );
	
	
	NSString *str, *str2;
	NSAttributedString *attrStr;
	NSMutableDictionary *attr, *attrs;
	
	attr = [NSMutableDictionary dictionary];
	[attr setObject:_font forKey:NSFontAttributeName];
	attrs = [NSMutableDictionary dictionary];
	[attrs setObject:_sFont forKey:NSFontAttributeName];
	
	int x, y, strY = 10;
	int baseX = 0;
	int baseY = BASE_Y;
	int k = [_data cards];
	
	if( _print == TRUE )
	{
		/* 印刷用 */
		int st, ed;
		if( _page == 0 )
		{
			NSSize size = [_pixelData size];
			NSRect src = NSMakeRect( 0, 0, size.width, size.height );
			NSRect dst = NSMakeRect( 0, BASE_Y, size.width, (size.height) );
			if( _printWidth < size.width )
			{
				dst.size.width = _printWidth;
				dst.size.height = (_printWidth * NSHeight( src ) / NSWidth( src ) );
			}
			else
			{
				dst.size.width = ( NSWidth( src ) * NSHeight( dst ) / NSHeight( src ) );
			}
			NSLog( @"PaperWidth:%.4f mm, frameWidth:%.4f", _printWidth * 25.4 / 72.0, NSWidth(r) * 25.4 / 72.0 );
			NSLog( @"Src:%.4f, %.4f mm", NSWidth(src) * 25.4 / 72.0, NSHeight(src) * 25.4 / 72.0);
			NSLog( @"Dst:%.4f, %.4f mm", NSWidth(dst) * 25.4 / 72.0, NSHeight(dst) * 25.4 / 72.0);
			[_pixelData drawInRect:dst fromRect:src operation:NSCompositeSourceOver fraction:1.0];
			str = [NSString stringWithUTF8String:"%Y年%m月%d日%H時%M分"];
			NSCalendarDate *cd = [NSCalendarDate calendarDate];
			[cd setCalendarFormat:str];
			attrStr = [[[NSAttributedString alloc] initWithString:[cd description] attributes:attr] autorelease];
			[attrStr drawAtPoint:NSMakePoint( 0, baseY /4 ) ];
			attrStr = [self stringCardRotate:attr];
			[attrStr drawAtPoint:NSMakePoint( 0, baseY * 3 / 5 ) ];
			
			return;
		}
		else if( _page == 1 )
		{
			st = 1;
			ed = _nPageOneCell;
		}
		else
		{
			st = _nPageOneCell + 1 + (_page -2) * _nPagesCell;
			ed = st + _nPagesCell -1;
			if( k < ed ) ed = k;
		}
		
		baseX = NSMinX(rect);
		baseY += BASE_Y;
		strY += BASE_Y;
		
		str = [[NSString alloc] initWithUTF8String:"頁"];
		str2 = [[NSString alloc] initWithUTF8String:"　カード番号"];
			
		attrStr = [[[NSAttributedString alloc] initWithString:
				[NSString stringWithFormat:@"%@:%d%@:%d - %d", str, _page, str2, st, ed  ]
				attributes:attr] autorelease];
		[attrStr drawAtPoint:NSMakePoint( SIDE - CELL +baseX, BASE_Y /2 ) ];
	}
	
	attrStr = [[[NSAttributedString alloc] initWithString:
				[NSString stringWithUTF8String:"SML 表通し:"]
				attributes:attr] autorelease];
	[attrStr drawAtPoint:NSMakePoint( SIDE - CELL +baseX, strY ) ];
	attrStr = [[[NSAttributedString alloc] initWithString:
				[NSString stringWithUTF8String:"LMS 裏通し:"]
				attributes:attr] autorelease];
	[attrStr drawAtPoint:NSMakePoint( SIDE + CELL * 6 +baseX, strY ) ];
	
	
	/* 矢印 */
	int asize = CELL / 2;
	NSBezierPath *sameArrow;
	sameArrow = [NSBezierPath bezierPath];
	[sameArrow moveToPoint:NSMakePoint( asize, asize /2)];
	[sameArrow lineToPoint:NSMakePoint( asize - asize /3, asize - asize /3)];
	[sameArrow lineToPoint:NSMakePoint( asize - asize /3, asize /3)];
	[sameArrow moveToPoint:NSMakePoint( asize, asize /2)];
	[sameArrow lineToPoint:NSMakePoint( 0, asize /2)];
	[sameArrow closePath];
	NSBezierPath *downArrow;
	downArrow = [NSBezierPath bezierPath];
	[downArrow moveToPoint:NSMakePoint( asize -asize * 2/5, asize /6)];
	[downArrow lineToPoint:NSMakePoint( asize, 0)];
	[downArrow lineToPoint:NSMakePoint( asize -asize /6, asize * 2/5)];
	[downArrow moveToPoint:NSMakePoint( asize, 0)];
	[downArrow lineToPoint:NSMakePoint( 0, asize)];
	[downArrow closePath];
	NSBezierPath *upArrow;
	upArrow = [NSBezierPath bezierPath];
	[upArrow moveToPoint:NSMakePoint( asize -asize * 2/5, asize - asize /6)];
	[upArrow lineToPoint:NSMakePoint( asize, asize)];
	[upArrow lineToPoint:NSMakePoint( asize - asize /6, asize -asize * 2/5 )];
	[upArrow moveToPoint:NSMakePoint( 0, 0)];
	[upArrow lineToPoint:NSMakePoint( asize, asize)];
	[upArrow closePath];
	
	NSBezierPath *uraArrow;
	uraArrow = [NSBezierPath bezierPath];
	[uraArrow moveToPoint:NSMakePoint( asize -asize /2, 0)];
	[uraArrow lineToPoint:NSMakePoint( asize, 0)];
	[uraArrow lineToPoint:NSMakePoint( asize, asize /2)];
	[uraArrow moveToPoint:NSMakePoint( asize, 0)];
	[uraArrow lineToPoint:NSMakePoint( 0, asize)];
	[uraArrow closePath];
	NSBezierPath *omoteArrow;
	omoteArrow = [NSBezierPath bezierPath];
	[omoteArrow moveToPoint:NSMakePoint( asize -asize /2, asize)];
	[omoteArrow lineToPoint:NSMakePoint( asize, asize)];
	[omoteArrow lineToPoint:NSMakePoint( asize, asize -asize /2)];
	[omoteArrow moveToPoint:NSMakePoint( 0, 0)];
	[omoteArrow lineToPoint:NSMakePoint( asize, asize)];
	[omoteArrow closePath];
	/* 矢印 終了 */
	
	NSPoint checkPos;
	NSRect checkRect;
	
	/* 柄立て表 */
	for( y = 0; y < 4; ++y )
	{
		switch( y )
		{
		case 0:
			attrStr = [[[NSAttributedString alloc] initWithString:@"D" attributes:attr] autorelease];
			break;
		case 1:
			attrStr = [[[NSAttributedString alloc] initWithString:@"C" attributes:attr] autorelease];
			break;
		case 2:
			attrStr = [[[NSAttributedString alloc] initWithString:@"B" attributes:attr] autorelease];
			break;
		case 3:
			attrStr = [[[NSAttributedString alloc] initWithString:@"A" attributes:attr] autorelease];
			break;
		}
		checkPos = NSMakePoint( SIDE / 2 + 7, baseY + y * CELL +1 );
		[attrStr drawAtPoint:checkPos ];
		checkPos = NSMakePoint( SIDE + k * CELL + 5, baseY + y * CELL +1 );
		[attrStr drawAtPoint:checkPos ];
		
		NSFrameRectWithWidth( NSMakeRect( SIDE -CELL, baseY + y * CELL, CELL, CELL +1 ), 1 );
		for( x = 0; x < k; ++x )
		{
			if( (x +1) % 3 == 0 )
			{
				NSFrameRectWithWidth( NSMakeRect( SIDE + x * CELL, baseY + y * CELL, CELL, CELL +1 ), 1 );
				if( y == 3 )
				{
					attrStr = [[[NSAttributedString alloc] initWithString:
						[NSString stringWithFormat:@"%3d", (x +1)] attributes:attrs]
						autorelease];
					[attrStr drawAtPoint:NSMakePoint( SIDE + x * CELL + 5, baseY + (y +1) * CELL +1 ) ];
				}
			}
			else
				NSFrameRectWithWidth( NSMakeRect( SIDE + x * CELL, baseY + y * CELL, CELL +1, CELL +1 ), 1 );
			
			if( x == k / 2)
				NSFrameRectWithWidth( NSMakeRect( SIDE + x * CELL, baseY + (y -1) * CELL, 3, CELL * 3 ), 3 );
		}
		checkRect = NSMakeRect( SIDE + x * CELL, baseY + y * CELL, CELL, CELL +1 );
		NSFrameRectWithWidth( checkRect, 1 );
	}
	NSFrameRectWithWidth( NSMakeRect( SIDE -CELL -1, baseY -1, CELL * (x + 2), (CELL +1) * y -1 ), 1 );
	
	NSAffineTransform *at = [NSAffineTransform transform];
	
	/* 説明箇所 */
	[at translateXBy:SIDE + CELL * 3 + CELL /2 +baseX yBy:strY +3];
	[omoteArrow transformUsingAffineTransform:at];
	[omoteArrow fill];
	[omoteArrow stroke];
	at = [NSAffineTransform transform];
	[at translateXBy:-(SIDE + CELL * 3 + CELL /2 +baseX) yBy:-strY -3];
	[omoteArrow transformUsingAffineTransform:at];
	
	at = [NSAffineTransform transform];
	[at translateXBy:SIDE + CELL * 10 +CELL /2 +baseX yBy:strY +3];
	[uraArrow transformUsingAffineTransform:at];
	[uraArrow fill];
	[uraArrow stroke];
	at = [NSAffineTransform transform];
	[at translateXBy:-(SIDE + CELL * 10 +CELL /2 +baseX) yBy:-strY -3];
	[uraArrow transformUsingAffineTransform:at];
	at = [NSAffineTransform transform];
	[at translateXBy:SIDE +5 -CELL yBy:baseY - CELL *3 /4];
	/* 説明箇所　終 */
	
	[omoteArrow transformUsingAffineTransform:at];
	[uraArrow transformUsingAffineTransform:at];
	
	at = [NSAffineTransform transform];
	[at translateXBy:SIDE yBy:baseY];
	[sameArrow transformUsingAffineTransform:at];
	[upArrow transformUsingAffineTransform:at];
	[downArrow transformUsingAffineTransform:at];
	
	at = [NSAffineTransform transform];
	[at translateXBy:CELL / -4 yBy:CELL /4];
	[sameArrow transformUsingAffineTransform:at];
	at = [NSAffineTransform transform];
	[at translateXBy:CELL / -4 yBy:CELL / -4];
	[upArrow transformUsingAffineTransform:at];
	at = [NSAffineTransform transform];
	[at translateXBy:CELL / -4 yBy:CELL / -4];
	[downArrow transformUsingAffineTransform:at];

	
	CardYarns *cy;
	unsigned long *p = (unsigned long *)[[_data cardOrder] bytes];
	int pre[4];
	memset( &pre, 0, sizeof(pre));
	for( x = 0; x < k; ++x )
	{
		cy = [_aCY objectAtIndex:p[[_data realCardFromDispCard:x]]];
		
		checkRect = NSMakeRect( SIDE + (x +1) * CELL -1, baseY -CELL, 2, CELL );
		if( (x +1) % 3 == 0 )
		{
			if( [cy order] == ORDER_S )
			{
				at = [NSAffineTransform transform];
				[at translateXBy:CELL * x yBy:0];
				[omoteArrow transformUsingAffineTransform:at];
				[omoteArrow fill];
				[omoteArrow stroke];
				at = [NSAffineTransform transform];
				[at translateXBy:CELL * -x yBy:0];
				[omoteArrow transformUsingAffineTransform:at];
			}
			else
			{
				at = [NSAffineTransform transform];
				[at translateXBy:CELL * x yBy:0];
				[uraArrow transformUsingAffineTransform:at];
				[uraArrow fill];
				[uraArrow stroke];
				at = [NSAffineTransform transform];
				[at translateXBy:CELL * -x yBy:0];
				[uraArrow transformUsingAffineTransform:at];
			}			
			NSFrameRectWithWidth( checkRect, 1 );
		}
		
		if( pre[0] == [cy d] && pre[1] == [cy c] && pre[2] == [cy b] && pre[3] == [cy a] )
		{
			at = [NSAffineTransform transform];
			[at translateXBy:x * CELL yBy:CELL];
			[sameArrow transformUsingAffineTransform:at];
			[sameArrow fill];
			[sameArrow stroke];
			at = [NSAffineTransform transform];
			[at translateXBy: -(x * CELL) yBy:-CELL];
			[sameArrow transformUsingAffineTransform:at];
			[attr setObject:[NSColor grayColor]  forKey:NSForegroundColorAttributeName];
		}
		else if( pre[0] == [cy c] && pre[1] == [cy b] && pre[2] == [cy a] && pre[3] == [cy d] )
		{
			at = [NSAffineTransform transform];
			[at translateXBy:x * CELL yBy:CELL];
			[upArrow transformUsingAffineTransform:at];
			[upArrow fill];
			[upArrow stroke];
			at = [NSAffineTransform transform];
			[at translateXBy: -(x * CELL) yBy:-CELL];
			[upArrow transformUsingAffineTransform:at];
			[attr setObject:[NSColor grayColor]  forKey:NSForegroundColorAttributeName];
		}
		else if( pre[0] == [cy a] && pre[1] == [cy d] && pre[2] == [cy c] && pre[3] == [cy b] )
		{
			at = [NSAffineTransform transform];
			[at translateXBy:x * CELL yBy:CELL];
			[downArrow transformUsingAffineTransform:at];
			[downArrow fill];
			[downArrow stroke];
			at = [NSAffineTransform transform];
			[at translateXBy: -(x * CELL) yBy:-CELL];
			[downArrow transformUsingAffineTransform:at];
			[attr setObject:[NSColor grayColor]  forKey:NSForegroundColorAttributeName];
		}
		
		/*
		checkPos = NSMakePoint( SIDE + x * CELL + 5, baseY +1 );
		if( NSPointInRect( checkPos, rect ) == YES )
		{ */
			for( y = 0; y < 4; ++y )
			{
				switch( y )
				{
				case 0: pre[y] = [cy d]; break;
				case 1: pre[y] = [cy c]; break;
				case 2: pre[y] = [cy b]; break;
				case 3: pre[y] = [cy a]; break;
				}
				attrStr = [[[NSAttributedString alloc] initWithString:
					[NSString stringWithFormat:@"%d", pre[y]] attributes:attr]
					autorelease];
				checkPos = NSMakePoint( SIDE + x * CELL + 5, baseY + y * CELL +1 );
				[attrStr drawAtPoint:checkPos ];
			}
		// }
		[attr setObject:[NSColor blackColor]  forKey:NSForegroundColorAttributeName];
		[[NSColor blackColor] set];
	}
	/* 柄立て表 終了 */
	
	
	baseY += (y * CELL) + CELL;
	
	/* 糸情報 */
	NSMutableArray *yArray = [_data yarnArray];
	YarnData *yd;
	for( y = 0; y < [yArray count]; ++y )
	{		
		yd = [yArray objectAtIndex:y];
		[[NSColor colorWithCalibratedRed:[yd color:R] green:[yd color:G] blue:[yd color:B] alpha:[yd color:A]] set];
		NSRectFill( NSMakeRect( SIDE + CELL /2, baseY + y * CELL, CELL * k - CELL/2, CELL / 2 ) );
		
		if( (y +1) % 5 == 0 )
		{
			[[NSColor blackColor] set];
			NSFrameRect( NSMakeRect( SIDE + CELL/2, baseY + y * CELL + CELL /4, CELL * k -CELL/2, 2 ) );
		}
		
		attrStr = [[[NSAttributedString alloc] initWithString:
			[NSString stringWithFormat:@"%d", y +1] attributes:attr] autorelease];
		[attrStr drawAtPoint:NSMakePoint( SIDE / 2 + 7 +baseX, baseY + y * CELL -3 ) ];
		[attrStr drawAtPoint:NSMakePoint( SIDE + k * CELL + 5, baseY + y * CELL -3 ) ];
	}
	/* 糸情報 終了 */
	
	baseY += (y * CELL);
	
	/* カード枚数と回転 */
	/*
	str = [[NSString alloc] initWithUTF8String:"カード枚数"];
	str = [NSString stringWithFormat:@"%@ : %d", str, k ];
	str2 = [[NSString alloc] initWithUTF8String:"　回転（前・後）"];
	str = [NSString stringWithFormat:@"%@  %@", str, str2 ];
	
	cy = [_aCY objectAtIndex:0];
	int *fb = [cy fb];
	for( x = 0; -1 < fb[x]; ++x )
	{
		str = [NSString stringWithFormat:@"%@ : %d", str, fb[x] ];
	}
	attrStr = [[[NSAttributedString alloc] initWithString:str attributes:attr] autorelease];
	*/
	attrStr = [self stringCardRotate:attr];
	[attrStr drawAtPoint:NSMakePoint( SIDE - CELL +baseX, baseY ) ];
	
	/* 日付の追加 */
	if( _print == YES )
	{
		baseY += CELL;
		str = [[NSString alloc] initWithUTF8String:"%Y年%m月%d日%H時%M分"];
		NSCalendarDate *cd = [NSCalendarDate calendarDate];
		[cd setCalendarFormat:str];
		attrStr = [[[NSAttributedString alloc] initWithString:[cd description] attributes:attr] autorelease];
		[attrStr drawAtPoint:NSMakePoint( baseX, baseY ) ];
	}
	
	
	/* カーソル */
	for( k = 0; k <= RCURSOR; ++k )
	{
		if( _print == TRUE ) break;
		
		[_selectRect[k] drawSelectRect:-4];
	}
	/* 選択 */
	for( k = RCURSOR +1; k <= _selectRectNumber; ++k )
	{
		if( _print == TRUE ) break;
		
		[_selectRect[k] drawSelectRect:0];
	}
	[self unlockFocus];
}

- (void) mouseDown:(NSEvent*)event
{
    NSPoint point = [event locationInWindow];
	_mouseDownPoint = point;
    point = [self convertPoint:point fromView:nil];
	
	/* 糸の色替え */
	float y = point.y;
	y -= (BASE_Y + (4 * CELL));
	_colorSelectYarn = y / CELL -1;
	
	NSColorPanel *cp = [NSColorPanel sharedColorPanel];
	if( 0 <= _colorSelectYarn && _colorSelectYarn < [[_data yarnArray] count] )
	{
		YarnData *yd = [[_data yarnArray] objectAtIndex:_colorSelectYarn];
		[[NSApplication sharedApplication] orderFrontColorPanel:cp];
		[cp setTarget:self];
		[cp setAction:@selector(setYarnColor:)];
		[cp setContinuous:YES];
		[cp setColor:[NSColor colorWithCalibratedRed:[yd color:R] green:[yd color:G] blue:[yd color:B] alpha:[yd color:A]]];
	}
	else
	{
		_colorSelectYarn = -1;
		[cp close];
	}
	/* 糸の色替え 終了 */
	
	if( _selectRectNumber != RCURSOR )
		[self setSelectRect:point type:MDOWN];
}

- (void) mouseDragged: (NSEvent *)event
{
    NSPoint point = [event locationInWindow];
    point = [self convertPoint:point fromView:nil];
	/*
    point = [[self superview] convertPoint:point fromView:nil];
	NSLog( @"Super > %.2f, %.2f", point.x, point.y );
	NSLog( @"Frame > Min:%.2f, %.2f  Max:%.2f, %.2f",NSMinX(r),NSMinY(r),NSMaxX(r),NSMaxY(r));
	NSLog( @"Frame > width:%.2f",w);
	NSScroller *scl = [[[self superview] superview] horizontalScroller];
	NSLog( @"Scroll > Value:%.2f", [scl floatValue]);
	float w = NSWidth([[self superview] frame]);
	float pos = point.x - ((NSWidth([self frame]) -w) * [scl floatValue]);
	NSLog( @"View > Min:%.2f, %.2f  Max:%.2f, %.2f",NSMinX(r),NSMinY(r),NSMaxX(r),NSMaxY(r));
	NSLog( @"View Start > Width:%.2f", (NSWidth(r) -w) * [scl floatValue] );
	NSLog( @"View > %.2f, %.2f", point.x, point.y );
	*/
	[self autoscroll:event];
	
	if( _selectRectNumber != RCURSOR )
		[self setSelectRect:point type:MDRAG];
	else
		[self setCursorPosition:point];
}

- (void) mouseMoved: (NSEvent *)event
{
    NSPoint point = [event locationInWindow];
    point = [self convertPoint:point fromView:nil];
	[self setCursorPosition:point];
}

- (void) mouseUp:(NSEvent*)event
{
    NSPoint point = [event locationInWindow];
	BOOL upDownSame = NSEqualPoints( point, _mouseDownPoint);
		
    point = [self convertPoint:point fromView:nil];
	
	if( _selectRectNumber != RCURSOR )
			[self setSelectRect:point type:MDRAG];

	[self setCursorPosition:point];
			
	if( upDownSame == NO ) return;
	if( [_selectRect[RCURSOR] inside] == YES && _selectRectNumber == RCURSOR )
	{
		NSRect s = [self selectRect:RCURSOR];
		// NSLog( @"Cursor> %.2f, %.2f", NSMinX(s), NSMinY(s) );
		[_controller increaseYarnNumber:NSMinX(s) -1 abcd:(4-NSMinY(s))];
		s = [_selectRect[RCURSOR] getRectX:(int)NSMinX(s) -1 Y:1 W:3 H:4];
		[self setNeedsDisplayInRect:s];
	}
	if( [_selectRect[RTOUSHI] inside] == YES )
	{
		/* 通し替え */
		NSRect s = [self selectRect:RTOUSHI];
		// NSLog( @"Toushi> %.2f, %.2f", NSMinX(s), NSMinY(s) );
		[_controller reverseCardToushi:NSMinX(s) -1];
		[self setNeedsDisplayInRect:[_selectRect[RTOUSHI] will]];
	}
}

- (void) setYarnColor:(id)sender
{
	if( _colorSelectYarn < 0 ) return;
	
	YarnData *yd = [[_data yarnArray] objectAtIndex:_colorSelectYarn];
	float r, g, b, a;
	[[sender color] getRed:&r green:&g blue:&b alpha:&a];
	if( r != [yd color:R] || g != [yd color:G] || b != [yd color:B] || a != [yd color:A] )
	{		
		NSString *cmd = [NSString stringWithFormat:
			@"yarn -sColor %d %.3f %.3f %.3f %.3f",
			_colorSelectYarn +1, r, g, b, a];
		[_controller analyzeCommand:cmd];
	}
}

- (void) setSelectRectNumber:(int)n
{
	_selectRectNumber = n;
}

- (NSRect) selectRect:(int)n
{
	if( n < 0 ) n = 0;
	if( RMAX <= n ) n = RMAX -1;
	return [_selectRect[n] rect];
}

- (mySelectRect *) mySelectRect:(int)n
{
	if( n < 0 ) n = 0;
	if( RMAX <= n ) n = RMAX -1;
	return _selectRect[n];
}
@end
