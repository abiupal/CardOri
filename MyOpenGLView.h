/* MyOpenGLView */
#import "cardori.h"

@interface MyOpenGLView : NSOpenGLView
{
	SEL processFunc;
	
	GlobalData *_data;
	NSMutableArray *_aCY;
	BOOL _print;
}


- (void)drawYarnX:(GLfloat)length;
- (void)setDatas:(GlobalData *)data card:(NSMutableArray *)card;
- (id)initWithDatas:(GlobalData *)data card:(NSMutableArray *)card printInfo:(NSPrintInfo *)pi;
- (NSImage *)getImageFromRect:(NSRect)rect;

@end
