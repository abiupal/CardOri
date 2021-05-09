/* CardSettingView */
#import "cardori.h"
#import "mySelectRect.h"

enum { RTOUSHI = 0, RCURSOR, RSELECT, RFUNC, RMAX };

@interface CardSettingView : NSView
{
	id _controller;
	GlobalData *_data;
	NSMutableArray *_aCY;
	NSFont *_font, *_sFont;
	NSSize _paperSize;
	float _printWidth, _nPageOneCell, _nPagesCell;
	int _pages, _page;
	BOOL _print;
	mySelectRect *_selectRect[RMAX];
	int _colorSelectYarn, _selectRectNumber;
	NSImage *_pixelData;
	NSPoint _mouseDownPoint;
}

- (void) setDatas:(id)controller data:(GlobalData *)data card:(NSMutableArray *)card;
- (id) initWithDatas:(GlobalData *)data card:(NSMutableArray *)card pixelData:(NSImage *)img printInfo:(NSPrintInfo *)pi;
- (void) checkPrintPages;
- (int) width;
- (void) setSelectRect:(NSPoint)pos type:(int)m;
- (void) setCursorPosition:(NSPoint)pos;
- (void) setYarnColor:(id)sender;
- (void) setSelectRectNumber:(int)n;
- (NSRect) selectRect:(int)n;
- (mySelectRect *) mySelectRect:(int)n;
@end
