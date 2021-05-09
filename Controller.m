#import "Controller.h"
#import "MyOpenGLView.h"
#import "CardSettingView.h"

@implementation Controller

- (IBAction)fDown:(id)sender
{
	NSString *cmd = [NSString stringWithFormat:@"func -down %d", [sender state]];
	
	if( [sender state] == NSOnState )
	{
		[_fUp setState:NSOffState];
		[_fSelect setState:NSOffState];
	}
	
	[self analyzeCommand:cmd];
}

- (IBAction)fGo:(id)sender
{
	NSRect s = [_cardSetting selectRect:RSELECT];
	NSRect d = [_cardSetting selectRect:RFUNC];
	
	/*
	NSString *str = [NSString stringWithFormat:@"SRC > %.2f, %.2f -> \n%.2f, %.2f\n",
		NSMinX(s), NSMinY(s), NSMaxX(s) -1, NSMaxY(s) -1];
	[self log:str];
	str = [NSString stringWithFormat:@"DST > %.2f, %.2f -> \n%.2f, %.2f\n",
		NSMinX(d), NSMinY(d), NSMaxX(d) -1, NSMaxY(d) -1];
	[self log:str];
	*/
	if( NSMinX(d) < 0.0 ) return;
	
	if( NSIntersectsRect( s, d ) == YES )
	{
		NSBeep();
		[[_cardSetting mySelectRect:RFUNC] clearRect];
		return;
	}
	// s = NSMakeRect( NSMinX(s), NSMinY(s), NSMaxX(s) -1, NSMaxY(s) -1 );
	// d = NSMakeRect( NSMinX(d), NSMinY(d), NSMaxX(d) -1, NSMaxY(d) -1 );
	[self funcS:(NSRect)s toD:(NSRect)d];
	
	[_cardSetting setNeedsDisplayInRect:[[_cardSetting mySelectRect:RFUNC] will] ];

}

- (IBAction)fReverse:(id)sender
{
	NSString *cmd = [NSString stringWithFormat:@"func -reverse %d", [sender state]];
	
	if( [sender state] == NSOnState )
	{
		[_fSelect setState:NSOffState];
	}
	
	[self analyzeCommand:cmd];
}

- (IBAction)fSame:(id)sender
{
	NSString *cmd = [NSString stringWithFormat:@"func -same %d", [sender state]];
	
	if( [sender state] == NSOnState )
	{
		[_fSelect setState:NSOffState];
	}
	
	[self analyzeCommand:cmd];
}

- (IBAction)fSelect:(id)sender;
{
	NSString *cmd = [NSString stringWithFormat:@"func -select %d", [sender state]];
	
	if( [sender state] == NSOnState )
	{
		[_fUp setState:NSOffState];
		[_fDown setState:NSOffState];
		[_fSame setState:NSOffState];
	}
	
	
	[self analyzeCommand:cmd];
}

- (IBAction)fUp:(id)sender;
{
	NSString *cmd = [NSString stringWithFormat:@"func -up %d", [sender state]];
	
	if( [sender state] == NSOnState )
	{
		[_fDown setState:NSOffState];
		[_fSelect setState:NSOffState];
	}
			
	[self analyzeCommand:cmd];
}

- (IBAction)inputCmd:(id)sender
{
	NSString *cmd = [sender stringValue];
	[self analyzeCommand:cmd];
	[sender setStringValue:@""];
	[sender setNeedsDisplay:YES];
}

- (IBAction)open:(id)sender;
{
	NSOpenPanel *openPanel;
	int i;
	
	openPanel = [NSOpenPanel openPanel];
	
	i = [openPanel runModalForTypes:[NSArray arrayWithObject:@"cardori"]];
	
	if (i != NSOKButton)
		return;
	
	if( _directory != nil ) [_directory release];
	_directory = [[openPanel directory] retain];
	
	NSArray *plist = [NSArray arrayWithContentsOfFile:[openPanel filename]];
	if( plist == nil )
	{
		NSBeep();
		return;
	}
	NSArray *a = [plist objectAtIndex:0];
	[_data setArrayObject:a];
	
	[_cardArray release];
	_cardArray = [[NSMutableArray array] retain];
	NSNumber *number = [plist objectAtIndex:1];
	int max = [number intValue];
	CardYarns *cy;
	for( i = 0; i < max; ++i )
	{
		a = [plist objectAtIndex:2 +i];
		cy = [[CardYarns alloc] initWithData:0 fb:nil yarnArray:[_data yarnArray]];
		[cy setArrayObject:a];
		[_cardArray addObject:cy];
	}
	
	[_view setDatas:_data card:_cardArray];
	[_cardSetting setDatas:self data:_data card:_cardArray];
	
	[_view setNeedsDisplay:YES];
	[_cardSetting setNeedsDisplay:YES];
	[[_tabView window] setTitleWithRepresentedFilename:[openPanel filename]];
}

- (IBAction)print:(id)sender
{
	int tabIndex = [_tabView indexOfTabViewItem:[_tabView selectedTabViewItem]];
	/*
	if( tabIndex )
	{
		NSBeep();
		
		NSAlert *alert = [[NSAlert alloc] init];
		[alert addButtonWithTitle:@"OK"];
		[alert setMessageText:@"Select View and Print again."];
		[alert setInformativeText:@"Can not print from Card Info View."];
		[alert setAlertStyle:NSInformationalAlertStyle];
		[alert runModal];
		[alert release];
		return;
	}*/
	NSPrintInfo *pInfo = [NSPrintInfo sharedPrintInfo];
	[NSOpenGLContext clearCurrentContext];
	NSImage *img = nil;
	MyOpenGLView *glView = [[MyOpenGLView alloc] initWithDatas:_data card:_cardArray printInfo:pInfo];
	if( !tabIndex )
		img = [self imageFromOpenGLView:glView];

	CardSettingView *v = [[CardSettingView alloc] initWithDatas:_data card:_cardArray pixelData:img printInfo:pInfo];
	NSPrintOperation *pOp = [NSPrintOperation printOperationWithView:v printInfo:pInfo];
	[pOp setShowPanels:YES];
	[pOp runOperation];
}

- (IBAction)save:(id)sender
{
	NSSavePanel *savePanel;
	int i;
	
	savePanel = [NSSavePanel savePanel];
	[savePanel setRequiredFileType:@"cardori"];
	
	NSArray *names = [[[_tabView window] title] componentsSeparatedByString:@" "];
	i = [savePanel runModalForDirectory:_directory file:[names objectAtIndex:0]];
	
	if (i != NSOKButton)
		return;
		
	if( _directory != nil ) [_directory release];
	_directory = [[savePanel directory] retain];
	
	NSMutableArray *plist = [NSMutableArray array];
	[plist addObject:[_data arrayObject]];
	
	NSNumber *number = [NSNumber numberWithInt:[_cardArray count]];
	[plist addObject:number];
	CardYarns *cy;
	for( i = 0; i < [_cardArray count]; ++i )
	{
		cy = [_cardArray objectAtIndex:i];
		[plist addObject:[cy arrayObject]];
	}
	
    if ([plist writeToFile:[savePanel filename] atomically:YES] == NO)
         NSBeep();
	else
		[[_tabView window] setTitleWithRepresentedFilename:[savePanel filename]];
}

- (IBAction)yAspect:(id)sender
{
	NSString *cmd = [[[NSString alloc]
		initWithFormat:@"aspect y %.3f", [sender floatValue]]
		autorelease];
	
	[self analyzeCommand:cmd];
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed : ( NSApplication* )theApplication
{
    return YES;
}

- (void)dealloc
{
	if( _directory != nil )
		[_directory release];
	[_cardArray release];
	[_data release];
	[super dealloc];
}

- (void)awakeFromNib
{
	_directory = nil;
	
	viewData vd;
	memset( &vd, 0, sizeof(viewData));	
	vd.angle = 25.0;
	vd.aspectX = 0.001;
	vd.aspectY = 20.0;
	vd.aspectZ = 0.0;
	vd.ylength = 32;
	vd.ylineGap = 2.5;
	vd.xlineGap = 0.15;
	vd.xlength = 145 * vd.xlineGap; /* 145 = 144 cards + 1 */
	
	_data = [[GlobalData alloc] retain];
	[_data initWithData:&vd];
	
	YarnData *yd = [[YarnData alloc] initWithData:-1 radius:0.04 r:0.5 g:0.3 b:0.3 a:1.0];
	[_data setYarn:X value:yd];
	yd = [[YarnData alloc] initWithData:-1 radius:0.08 r:0.3 g:0.3 b:0.5 a:1.0];
	[_data setYarn:Y value:yd];
	[_data addYarn:[yd radius] r:0.0 g:0.25 b:0.5 a:1.0];
	[_data addYarn:[yd radius] r:0.25 g:0.5 b:0.75 a:1.0];
	[_data addYarn:[yd radius] r:0.5 g:0.5 b:0.8 a:1.0];
	[_data addYarn:[yd radius] r:0.41 g:0.38 b:0.2 a:1.0];
	[_data addYarn:[yd radius] r:0.62 g:0.57 b:0.2 a:1.0];
	[_data addYarn:[yd radius] r:0.87 g:0.8 b:0.4 a:1.0];
	[_data addYarn:[yd radius] r:0.55 g:0.8 b:0.6 a:1.0];
	/*
	[_data addYarn:[yd radius] r:0.1 g:0.1 b:0.5 a:1.0];
	[_data addYarn:[yd radius] r:0.1 g:0.5 b:0.1 a:1.0];
	[_data addYarn:[yd radius] r:0.1 g:0.1 b:0.5 a:1.0];
	[_data addYarn:[yd radius] r:0.5 g:0.5 b:0.1 a:1.0];
	[_data addYarn:[yd radius] r:0.5 g:0.1 b:0.5 a:1.0];
	[_data addYarn:[yd radius] r:0.1 g:0.5 b:0.5 a:1.0];
	*/
	
	int fb[FB_MAX];
	memset( fb, -1, sizeof(fb) );
	/* rotate:8 8 */
	fb[0] = 9;
	fb[1] = 9;
	
	CardYarns *cy = NULL;
	int i, j, n, d[4], bs = 30;
	_cardArray = [[NSMutableArray array] retain];
	for( i = 0; i < bs; ++i )
	{
		cy = [[CardYarns alloc] initWithData:ORDER_S fb:&fb[0] yarnArray:[_data yarnArray]];
		[_cardArray addObject:cy];
	}
	for( i = bs; i < bs * 2; ++i )
	{
		cy = [[CardYarns alloc] initWithData:ORDER_Z fb:&fb[0] yarnArray:[_data yarnArray]];
		[_cardArray addObject:cy];
	}
	
	for( j = 0; j < 2; ++j )
	{
		cy = [_cardArray objectAtIndex:0 + bs * j];
		[cy setYarn:POS_A yarnData:0];
		[cy setYarn:POS_B yarnData:0];
		[cy setYarn:POS_C yarnData:1];
		[cy setYarn:POS_D yarnData:1];
	
		d[0] = 2; d[1] = 1; d[2] = 4; d[3] = 3;
		for( i = 1; i < 1 +4; ++i )
		{
			cy = [_cardArray objectAtIndex:i + bs * j];
			[cy setYarn:POS_A yarnData:d[0]];
			[cy setYarn:POS_B yarnData:d[1]];
			[cy setYarn:POS_C yarnData:d[2]];
			[cy setYarn:POS_D yarnData:d[3]];
		
			n = d[0];
			d[0] = d[1];
			d[1] = d[2];
			d[2] = d[3];
			d[3] = n;
		}	
		cy = [_cardArray objectAtIndex:5 + bs * j];
		[cy setYarn:POS_A yarnData:6];
		[cy setYarn:POS_B yarnData:6];
		[cy setYarn:POS_C yarnData:6];
		[cy setYarn:POS_D yarnData:6];
	
		d[0] = 5; d[1] = 1; d[2] = 0; d[3] = 4;
		for( i = 6; i < 6 +4; ++i )
		{
			cy = [_cardArray objectAtIndex:i + bs * j];
			[cy setYarn:POS_A yarnData:d[0]];
			[cy setYarn:POS_B yarnData:d[1]];
			[cy setYarn:POS_C yarnData:d[2]];
			[cy setYarn:POS_D yarnData:d[3]];
		
			n = d[0];
			d[0] = d[1];
			d[1] = d[2];
			d[2] = d[3];
			d[3] = n;
		}
		cy = [_cardArray objectAtIndex:10 + bs * j];
		[cy setYarn:POS_A yarnData:0];
		[cy setYarn:POS_B yarnData:0];
		[cy setYarn:POS_C yarnData:0];
		[cy setYarn:POS_D yarnData:0];
		cy = [_cardArray objectAtIndex:11 + bs * j];
		[cy setYarn:POS_A yarnData:1];
		[cy setYarn:POS_B yarnData:1];
		[cy setYarn:POS_C yarnData:1];
		[cy setYarn:POS_D yarnData:1];
	
		d[0] = 1; d[1] = 3; d[2] = 4; d[3] = 2;
		for( i = 12; i < 12 +4; ++i )
		{
			cy = [_cardArray objectAtIndex:i + bs * j];
			[cy setYarn:POS_A yarnData:d[0]];
			[cy setYarn:POS_B yarnData:d[1]];
			[cy setYarn:POS_C yarnData:d[2]];
			[cy setYarn:POS_D yarnData:d[3]];
		
			n = d[0];
			d[0] = d[1];
			d[1] = d[2];
			d[2] = d[3];
			d[3] = n;
		}
		
		cy = [_cardArray objectAtIndex:16 + bs * j];
		[cy setYarn:POS_A yarnData:5];
		[cy setYarn:POS_B yarnData:4];
		[cy setYarn:POS_C yarnData:5];
		[cy setYarn:POS_D yarnData:4];
		
		cy = [_cardArray objectAtIndex:17 + bs * j];
		[cy setYarn:POS_A yarnData:1];
		[cy setYarn:POS_B yarnData:1];
		[cy setYarn:POS_C yarnData:0];
		[cy setYarn:POS_D yarnData:0];
		
		
		cy = [_cardArray objectAtIndex:18 + bs * j];
		[cy setYarn:POS_A yarnData:2];
		[cy setYarn:POS_B yarnData:1];
		[cy setYarn:POS_C yarnData:2];
		[cy setYarn:POS_D yarnData:1];
		
		
		d[0] = 5; d[1] = 2; d[2] = 1; d[3] = 6;
		for( i = 19; i < 19 +4; ++i )
		{
			cy = [_cardArray objectAtIndex:i + bs * j];
			[cy setYarn:POS_A yarnData:d[0]];
			[cy setYarn:POS_B yarnData:d[1]];
			[cy setYarn:POS_C yarnData:d[2]];
			[cy setYarn:POS_D yarnData:d[3]];
		
			n = d[0];
			d[0] = d[1];
			d[1] = d[2];
			d[2] = d[3];
			d[3] = n;
		}
	}
	unsigned long *co = (unsigned long *)[[_data cardOrder] bytes];
	
	co[0] = 19;
	co[1] = 20;
	co[2] = 21;
	co[3] = 22;
	co[4] = 19;
	co[5] = 20;
	for( i = 6; i < 12; ++i )
		co[i] = 18 +bs;
	for( i = 0; i < 12; ++i )
	{
		co[143 -i] = co[i];
		if( co[143 -i] < bs )
			co[143 -i] += bs;
		else
			co[143 -i] -= bs;
	}
	
	co += 12;
	for( i = 0; i < 60; ++i )
	{
		if( i == 11 || i == 12 || i == 17 || i == 18 || i == 41 || i == 42 )
		{
			co[i] = 5;
		}
		else if( i == 13 || i == 14 )
		{
			co[i] = 11;
		}
		else if( i == 15 || i == 16 )
		{
			co[i] = 10;
		}
		else if( 53 < i )
			co[i] = 17;
		else if( 42 < i )
		{
			co[43] = co[47] = co[51] = 3;
			co[44] = co[48] = co[52] = 4;
			co[45] = co[49] = co[53] = 1;
			co[46] = co[50] = 2;
			i = 53;
		}
		else if( 18 < i )
		{
			co[19] = co[23] = co[24] = co[28] = co[31] = co[35] = co[36] = co[40] = 6;
			co[20] = co[27] = co[32] = co[39] = 7;
			co[21] = co[26] = co[33] = co[38] = 8;
			co[22] = co[25] = co[29] = co[30] = co[34] = co[37] = 9;
			i = 40;
		}
		else if( 7 <= i )
		{
			co[6] = 12;
			co[7] = 15;
			co[8] = 14;
			co[9] = 14;
			co[10] = 15;
			co[11] = 12;
			co[12] = 11;
			i = 12;
		}
		else if( i < 7 )
			co[i] = 16;
	}
	
	for( i = 0; i < 60; ++i )
	{
		if( ( 6 <= i && i <=  8) ||
			(12 <= i && i <= 17) ||
			(24 <= i && i <= 29) ||
			(36 <= i && i <= 41) ||
			(54 <= i && i <= 59)
		  )
			co[i] += bs;
	}
	for( i = 0; i < 60; ++i )
	{
		co[60 +i] = co[59 -i];
		
		if( co[60 +i] == 17 )
			co[60 +i] = 0;
		if( co[60 +i] == 17 + bs )
			co[60 +i] = 0 +bs;
	}	
	for( i = 60; i < 120; ++i )
	{
		if( co[i] < bs ) co[i] += bs;
		else co[i] -= bs;
	}
	
	[_view setDatas:_data card:_cardArray];
	[_cardSetting setDatas:self data:_data card:_cardArray];
	[[_tabView window] setTitle:@"Unsaved.cardori"];
	_func = fNONE;
}

- (void)log:(id)str
{
    NSRange endRange;

    endRange.location = [[_console textStorage] length];
    endRange.length = 0;
    [_console replaceCharactersInRange:endRange withString:str];
    endRange.length = [str length];
    [_console scrollRangeToVisible:endRange];
	
	[_console setNeedsDisplay:YES];
}

- (void)logWithTagI:(const char *)utf8 value:(int)value
{
	NSString *tag = [[[NSString alloc] initWithUTF8String:utf8] autorelease];
	NSString *logStr = [[NSString stringWithFormat:@"%@ > %d\n", tag, value] autorelease];

	[self log:logStr];
}

- (void)logWithTagF:(const char *)utf8 value:(float)value
{
	NSString *tag = [[[NSString alloc] initWithUTF8String:utf8] autorelease];
	NSString *logStr = [[[NSString alloc]
		initWithFormat:@"%@ > %.3f\n", tag, value]
		autorelease];

	[self log:logStr];
}

- (void)logWithTagS:(const char *)utf8 value:(NSString *)value
{
	NSString *tag = [NSString stringWithUTF8String:utf8];
	NSString *logStr = [[[NSString alloc]
		initWithFormat:@"%@ > %@\n", tag, value]
		autorelease];

	[self log:logStr];
}
- (void)analyzeCommand:(NSString *)commandString
{
	NSArray *lists = [commandString componentsSeparatedByString:@" "];
	NSString *word = [lists objectAtIndex:0];
	float    f = 0.0;
	int      i = 0;
	CardYarns *cy;
	
	if( [word isEqualToString:@"help"] == YES )
	{
		word = [NSString stringWithUTF8String:"size <x/y> 変更\n\t [x:8.0-32.0] [y:11-250]"];
		[self logWithTagS:"サイズ" value:word];
		word = [NSString stringWithUTF8String:"gap <x/y> 変更\n\t [x/y:0.01-10.0]"];
		[self logWithTagS:"密度" value:word];
		word = [NSString stringWithUTF8String:"rotate -set 変更\n\t [i.e.:2 4 4 2]"];
		[self logWithTagS:"回転" value:word];
		word = [NSString stringWithUTF8String:"card -info 番号"];
		[self logWithTagS:"カード" value:word];
		word = [NSString stringWithUTF8String:"\tcard -sAll 番号\n\t A B C D 通し[0:表,1:裏]\n"];
		[self log:word];
		
	}
	else if( [word isEqualToString:@"func"] == YES && 2 < [lists count] )
	{
		word = [lists objectAtIndex:1];
		if( [word isEqualToString:@"-select"] == YES )
			i = fSELECT;
		else if( [word isEqualToString:@"-same"] == YES )
			i = fSAME;
		else if( [word isEqualToString:@"-up"] == YES )
			i = fUP;
		else if( [word isEqualToString:@"-down"] == YES )
			i = fDOWN;
		else if( [word isEqualToString:@"-reverse"] == YES )
			i = fREVERSE;
			
		word = [lists objectAtIndex:2];
		if( NSOffState == [word intValue] )
			_func -= i;
		else if( i == fSELECT )
			_func = i;
		else
		{
			if( _func == fSELECT )
				_func = 0;
			else if( i == fSAME )
				_func &= 0xf8;
			else if( i == fREVERSE )
				_func &0xf4;
			else
				_func &= 0x0f;
			_func += i;
		}
		
		if( _func & fSELECT )
			[_cardSetting setSelectRectNumber:RSELECT];
		else if( _func & fSAME )
			[_cardSetting setSelectRectNumber:RFUNC];
		else if( _func & fUP ) 
			[_cardSetting setSelectRectNumber:RFUNC];
		else if( _func & fDOWN )
			[_cardSetting setSelectRectNumber:RFUNC];
		else
			[_cardSetting setSelectRectNumber:RCURSOR];
	}
	else if( [word isEqualToString:@"aspect"] == YES && 2 < [lists count] )
	{
		word = [lists objectAtIndex:1];
		if( [word isEqualToString:@"y"] == YES )
		{
			f = [[lists objectAtIndex:2] floatValue];
			if( f < 0.1 ) f = 0.1;
			if( 50.0 < f ) f = 50.0;
			[_data setAspect:Y value:f];
			[_view setNeedsDisplay:YES];
			[self logWithTagF:"(I) aspect y CHANGED" value:f];
			[_yAspect setFloatValue:f];
		}
	}
	else if( [word isEqualToString:@"size"] == YES )
	{
		if( 2 < [lists count] )
		{
			word = [lists objectAtIndex:1];
			if( [word isEqualToString:@"y"] == YES )
			{
				i =	[[lists objectAtIndex:2] intValue];
				if( i < 11 ) i = 11;
				if( 250 < i ) i = 250;
				[_data setLengthY:i];
				[_view setNeedsDisplay:YES];
				[self logWithTagI:"(I) size:y CHANGED" value:i];
			}
			if( [word isEqualToString:@"x"] == YES )
			{
				i =	[[lists objectAtIndex:2] intValue];
				[_data setCards:i];
				[self logWithTagI:"size:x " value:[_data cards]];
				[_view setNeedsDisplay:YES];
				[_cardSetting setNeedsDisplay:YES];
				[self logWithTagI:"(I) size:x CHANGED" value:i];
			}
		}
		else
		{
			[self logWithTagI:"size:x " value:[_data cards]];
			[self logWithTagI:"size:y " value:[_data ylength]];
		}
	}
	else if( [word isEqualToString:@"gap"] == YES )
	{
		if( 2 < [lists count] )
		{
			word = [lists objectAtIndex:1];
			if( [word isEqualToString:@"x"] == YES )
			{
				f =	[[lists objectAtIndex:2] floatValue];
				if( f < 0.01 ) f = 0.01;
				if( 10.0 < f ) f = 10.0;
				i = [_data cards];
				[_data setGap:X value:f];
				[_data setCards:i];
				[_view setNeedsDisplay:YES];
				[self logWithTagF:"gap: x CHANGED" value:[_data gap:X]];
			}
			if( [word isEqualToString:@"y"] == YES )
			{
				f =	[[lists objectAtIndex:2] floatValue];
				if( f < 0.01 ) f = 0.01;
				if( 10.0 < f ) f = 10.0;
				[_data setGap:Y value:f];
				[_view setNeedsDisplay:YES];
				[self logWithTagF:"gap: y CHANGED" value:[_data gap:Y]];
			}
		}
		else
		{
			[self logWithTagF:"gap: x " value:[_data gap:X]];
			[self logWithTagF:"gap: y " value:[_data gap:Y]];
		}
	}
	else if( [word isEqualToString:@"info"] == YES )
	{
		[self log:@"Information --\n"];
		[self logWithTagF:"Twist angle " value:[_data angle]];
		[self logWithTagF:"aspect y " value:[_data aspect:Y]];
		[self logWithTagI:"size: x " value:[_data cards]];
		[self logWithTagI:"size: y " value:[_data ylength]];
		[self logWithTagF:"gap: x " value:[_data gap:X]];
		[self logWithTagF:"gap: y " value:[_data gap:Y]];
		[self logWithTagF:"radius(s): x " value:[[_data yarn:X] radius] /2];
		[self logWithTagF:"radius(s): y " value:[[_data yarn:Y] radius]];
		[self logWithTagF:"radius(a): x " value:[[_data yarn:X] radius] -0.005];
		[self logWithTagF:"radius(a): y " value:[[_data yarn:Y] radius] -0.01];
		i = [_cardArray count];
		[self logWithTagI:"card info " value:i];
		[self logWithTagI:"card number " value:[[_data cardOrder] length]];
		[self log:@"Information -- End --\n"];
	}
	else if( [word isEqualToString:@"rotate"] == YES && 2 < [lists count] )
	{
		int fb[FB_MAX];
		memset( fb,  -1, sizeof(fb) );
		word = [lists objectAtIndex:1];
		if( [word isEqualToString:@"-info"] == YES )
		{
		}
		if( [word isEqualToString:@"-set"] == YES && [lists count] <= 2 +FB_MAX )
		{
			for( i = 2; i < [lists count]; ++i )
			{
				/* 070530:rotate fixed */
				fb[i -2] = [[lists objectAtIndex:i] intValue] -1;
			}
			int m, n;
			m = n = 0;
			for( i = 0; i < FB_MAX /2; ++i )
			{
				m += fb[i *2 ];
				n += fb[i *2 +1];
			}
			if( m != n )
			{
				[self logWithTagI:"(E) Total Front Rotate " value:m];
				[self logWithTagI:"(E) Total Back Rotate " value:n];
				return;
			}
			
			for( i = 0; i < [_cardArray count]; ++i )
			{
				cy = [_cardArray objectAtIndex:i];
				memcpy( [cy fb], &fb[0], sizeof(fb) );
			}
			[_view setNeedsDisplay:YES];
			[_cardSetting setNeedsDisplay:YES];
		}
	}
	else if( [word isEqualToString:@"card"] == YES && 2 < [lists count] )
	{
		word = [lists objectAtIndex:1];
		
		i =	[[lists objectAtIndex:2] intValue];
		if( [_data cards] != [[_data cardOrder] length] )
			i = [_data cards] -i +1;
		i = [[_data cardOrder] length] -i;
		if( i < 0 || [[_data cardOrder] length] <= i )
		{
			[self logWithTagI:"(E) All Card Number " value:[[_data cardOrder] length]];
			[self logWithTagI:"(E) Input Set Card No." value:i +1];
			return;
		}
		
		if( [word isEqualToString:@"-info"] == YES )
		{
			unsigned long *co = (unsigned long *)[[_data cardOrder] bytes];
			[self logWithTagI:"Card No." value:	[[lists objectAtIndex:2] intValue]];
			cy = [_cardArray objectAtIndex:co[i]];
			word = [cy info];
			[self log:word];
		}
		else if( 4 < [lists count] )
		{
			unsigned long *co = (unsigned long *)[[_data cardOrder] bytes];
			int a, b, c, d, t, j;
			cy = [_cardArray objectAtIndex:co[i]];
			a = [cy a]; b = [cy b]; c = [cy c]; d = [cy d];
			t = [cy order];
			if( [word isEqualToString:@"-sAll"] == YES && 7 < [lists count] )
			{
				/* card -sAll N A B C D T */
				j =	[[lists objectAtIndex:3] intValue];
				if( j < 1 ) return;
				if( [[_data yarnArray] count] < j ) return;
				a = j;
				j =	[[lists objectAtIndex:4] intValue];
				if( j < 1 ) return;
				if( [[_data yarnArray] count] < j ) return;
				b = j;
				j =	[[lists objectAtIndex:5] intValue];
				if( j < 1 ) return;
				if( [[_data yarnArray] count] < j ) return;
				c = j;
				j =	[[lists objectAtIndex:6] intValue];
				if( j < 1 ) return;
				if( [[_data yarnArray] count] < j ) return;
				d = j;
				j =	[[lists objectAtIndex:7] intValue];
				if( j < 0 || 1 < j ) return;
				t = j +1;
			}
			else if( [word isEqualToString:@"-sA"] == YES )
			{
				j =	[[lists objectAtIndex:3] intValue];
				if( j < 1 ) return;
				if( [[_data yarnArray] count] < j ) return;
				a = j;
			}
			else if( [word isEqualToString:@"-sB"] == YES )
			{
				j =	[[lists objectAtIndex:3] intValue];
				if( j < 1 ) return;
				if( [[_data yarnArray] count] < j ) return;
				b = j;
			}
			else if( [word isEqualToString:@"-sC"] == YES )
			{
				j =	[[lists objectAtIndex:3] intValue];
				if( j < 1 ) return;
				if( [[_data yarnArray] count] < j ) return;
				c = j;
			}
			else if( [word isEqualToString:@"-sD"] == YES )
			{
				j =	[[lists objectAtIndex:3] intValue];
				if( j < 1 ) return;
				if( [_cardArray count] < j ) return;
				d = j;
			}
			else if( [word isEqualToString:@"-sT"] == YES )
			{
				j =	[[lists objectAtIndex:3] intValue];
				if( j < 0 || 1 < j ) return;
				t = j;
			}
			[self setCardOrder:i a:a b:b c:c d:d order:t];
			[_view setNeedsDisplay:YES];
			[ _cardSetting setNeedsDisplay:YES];
		}
	}
	else if( [word isEqualToString:@"yarn"] == YES && 2 < [lists count] )
	{
		word = [lists objectAtIndex:1];
		
		i =	[[lists objectAtIndex:2] intValue] -1;
		if( i < 0 || [[_data yarnArray] count] <= i )
		{
			[self logWithTagI:"(E) All Yarn Number " value:[[_data yarnArray] count]];
			[self logWithTagI:"(E) Input Set Yarn No." value:i +1];
			return;
		}
		YarnData *yd = [[_data yarnArray] objectAtIndex:i];
		if( [word isEqualToString:@"-sColor"] == YES && 6 < [lists count] )
		{
			float r, g, b, a;
			r = [[lists objectAtIndex:3] floatValue];
			g = [[lists objectAtIndex:4] floatValue];
			b = [[lists objectAtIndex:5] floatValue];
			a = [[lists objectAtIndex:6] floatValue];
			if( r < 0.0 || g < 0.0 || b < 0.0 || a < 0.0 ) return;
			if( 1.0 < r || 1.0 < g || 1.0 < b || 1.0 < a ) return;
			[yd colors][0] = r;
			[yd colors][1] = g;
			[yd colors][2] = b;
			[yd colors][3] = a;
			[_view setNeedsDisplay:YES];
			[_cardSetting setNeedsDisplay:YES];
		}
		
	}
	else
	{
		[self logWithTagS:"Unknown Command" value:commandString];
	}
}

- (int)findCard:(int)a b:(int)b c:(int)c d:(int)d order:(int)t
{
	CardYarns *cy;
	int i, bs = 30;  /* bs == 30 [self awakeFromNib] */
	
	for( i = 0; i < [_cardArray count]; ++i )
	{
		cy = [_cardArray objectAtIndex:i];
		if( t == [cy order] )
		{
			if( a == [cy a] && b == [cy b] && c == [cy c] && d == [cy d] )
				return i;
		
			if( [cy a] < 1 && [cy b] < 1 && [cy c] < 1 && [cy d] < 1 )
			{
				a--;b--;c--;d--;
				[cy setYarn:POS_A yarnData:a];
				[cy setYarn:POS_B yarnData:b];
				[cy setYarn:POS_C yarnData:c];
				[cy setYarn:POS_D yarnData:d];
			
			
				if( bs <= i ) bs *= -1;
				cy = [_cardArray objectAtIndex:i +bs];
				[cy setYarn:POS_A yarnData:a];
				[cy setYarn:POS_B yarnData:b];
				[cy setYarn:POS_C yarnData:c];
				[cy setYarn:POS_D yarnData:d];
				
				return i;
			}
		}
	}
	
	return -1;
}

// order: cardOrder Index
- (void) setCardOrder:(int)order a:(int)a b:(int)b c:(int)c d:(int)d order:(int)t
{
	unsigned long *co = (unsigned long *)[[_data cardOrder] bytes];
	int i = [self findCard:a b:b c:c d:d order:t];
	if( i < 0 )
	{
		CardYarns *cy = [_cardArray objectAtIndex:co[order]];
		int *fb = [cy fb];
		cy = [[CardYarns alloc] initWithData:ORDER_S fb:fb yarnArray:[_data yarnArray]];
		
		a--;b--;c--;d--;
		[cy setYarn:POS_A yarnData:a];
		[cy setYarn:POS_B yarnData:b];
		[cy setYarn:POS_C yarnData:c];
		[cy setYarn:POS_D yarnData:d];
		[_cardArray addObject:cy];
				
		cy = [[CardYarns alloc] initWithData:ORDER_Z fb:fb yarnArray:[_data yarnArray]];
		[cy setYarn:POS_A yarnData:a];
		[cy setYarn:POS_B yarnData:b];
		[cy setYarn:POS_C yarnData:c];
		[cy setYarn:POS_D yarnData:d];
		[_cardArray addObject:cy];
		i = [_cardArray count] -1;
		if( t == ORDER_S ) i--;
	}
	co[order] = i;
}

- (void)reverseCardToushi:(int)order
{
	order *= 3;
	/*
	NSString *str = [NSString stringWithFormat:@"Rev::TOUSHI > %d -> %d\n",
		order, order +2];
	[self log:str];
	*/
	unsigned long *p = (unsigned long *)[[_data cardOrder] bytes];
	int i, a, b, c, d, t, n[3], k;
	CardYarns *cy;
	for( i = 0; i < 3; ++i )
	{
		k = [_data realCardFromDispCard:(order +i)];
		cy = [_cardArray objectAtIndex:p[k]];
		a = [cy a]; b = [cy b]; c = [cy c]; d = [cy d];
		if( i == 0 )
		{
			t = [cy order];
			if(	t == ORDER_S )
				t = ORDER_Z;
			else
				t = ORDER_S;
		}
		n[i] = [self findCard:a b:b c:c d:d order:t];
		if( n[i] < 0 ) return;
		
		// NSLog(@"%d:%d->n[%d]:%d",k, p[k], i,n[i]);
	}
	
	for( i = 0; i < 3; ++i )
	{
		k = [_data realCardFromDispCard:(order +i)];
		p[k] = n[i];
	}
	/*
	[_view setNeedsDisplay:YES];
	[ _cardSetting setNeedsDisplay:YES];
	*/
}

- (void)increaseYarnNumber:(int)order abcd:(int)n
{
	unsigned long *p = (unsigned long *)[[_data cardOrder] bytes];
	int a, b, c, d, t;
	int k = [_data realCardFromDispCard:order];
	CardYarns *cy = [_cardArray objectAtIndex:p[k]];
	a = [cy a]; b = [cy b]; c = [cy c]; d = [cy d];
	t = [cy order];
	
	switch( n )
	{
	case POS_A: a++; break;
	case POS_B: b++; break;
	case POS_C: c++; break;
	case POS_D: d++; break;
	// NSLog( @"D:%d",d ); break;
	default:
		return;
	}
	n = [[_data yarnArray] count];
	if( n < a ) a = 1; if( n < b ) b = 1; if( n < c ) c = 1; if( n < d ) d = 1;
	
	// NSLog( @"abcd:%d, %d, %d, %d",a,b,c,d );
	[self setCardOrder:k a:a b:b c:c d:d order:t];
}

- (void) funcCopy:(int)pos s:(FUNCDATA *)pS d:(FUNCDATA *)pD option:(int)op
{
	if( _func & fUP )
	{
		op += pos;
		op %= 4;
	}
	else if( _func & fDOWN )
	{
		op = (pos -op);
		if( op < 0 ) op += 4;
	}
	else if( _func & fSAME )
	{
		op = pos;
	}

	pD->d[pos] = pS->d[op];
}

- (void) funcS:(NSRect)sr toD:(NSRect)dr
{
	int sMax = (int)(NSWidth(sr));
	FUNCDATA *pS, *src = malloc( sMax * sizeof(FUNCDATA));
	
	if( src == nil )
	{
		NSBeep();
		return;
	}
	
	// NSLog( @"SIZE s:%d", (int)(NSWidth(sr) * NSHeight(sr)) );
	// NSLog( @"SIZE d:%d", (int)(NSWidth(dr) * NSHeight(dr)) );
	int i, j, k;
	CardYarns *cy;
	unsigned long *p = (unsigned long *)[[_data cardOrder] bytes];
	for( i = NSMinX(sr); i < NSMaxX(sr); ++i )
	{
		// NSLog( @"i:%d", i );
		pS = &src[i - (int)NSMinX(sr)];
		k = [_data realCardFromDispCard:i -1];
		cy = [_cardArray objectAtIndex:p[k]];
		memset( pS, 0, sizeof(FUNCDATA));
		for( j = NSMinY(sr); j < NSMaxY(sr); ++j )
		{
			// NSLog( @"j:%d", j );
			switch( 4 -j )
			{
			case POS_A: pS->d[4 -j] = [cy a]; break;
			case POS_B: pS->d[4 -j] = [cy b]; break;
			case POS_C: pS->d[4 -j] = [cy c]; break;
			case POS_D: pS->d[4 -j] = [cy d]; break;
			}
		}
		// NSLog( @"S:%3d > %d, %d, %d, %d", i, pS[0], pS[1], pS[2], pS[3] );
	}
	
	if( _func & fREVERSE )
	{
		FUNCDATA *tmp = malloc( sMax * sizeof(FUNCDATA));
		if( tmp == nil )
		{
			free( src );
			NSBeep();
			return;
		}
		memcpy( tmp, src, sMax * sizeof(FUNCDATA));
		for( i = 0; i < sMax; ++i )
		{
			src[i] = tmp[sMax -i -1];
		}

		free( tmp );
	}
	
	FUNCDATA dst;
	int t, op;
	
	for( i = NSMinX(dr); i < NSMaxX(dr); ++i )
	{
		k = i - (int)NSMinX(dr);
		op = k / (int)NSWidth(sr);
		if( !(_func & fSAME) ) op++;
		op %= 4;
		k %= (int)NSWidth(sr);
		// NSLog( @"i:%3d, k:%d", i, k );
		pS = &src[k];
		k = [_data realCardFromDispCard:i -1];
		cy = [_cardArray objectAtIndex:p[k]];
		dst.d[0] = [cy a]; dst.d[1] = [cy b]; dst.d[2] = [cy c]; dst.d[3] = [cy d];
		t = [cy order];
		for( j = NSMinY(dr); j < NSMaxY(dr); ++j )
		{
			[self funcCopy:(4 -j) s:pS d:&dst option:op];
		}
		[self setCardOrder:k a:dst.d[0] b:dst.d[1] c:dst.d[2] d:dst.d[3] order:t];
	}
	
	free( src );
}

- (NSImage *) imageFromOpenGLView:(NSOpenGLView *)view 
{	
	NSImage* finalImage = [_view getImageFromRect:[view bounds]];

	return finalImage;
}
@end
