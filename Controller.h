/* Controller */
#import "cardori.h"

enum { fNONE = 1, fSELECT = 2, fSAME = 4, fREVERSE = 8, fUP = 0x10, fDOWN = 0x20};

typedef struct 
{
	int d[4];
} FUNCDATA;


@interface Controller : NSObject
{
    IBOutlet id _cardSetting;
    IBOutlet id _console;
    IBOutlet id _fDown;
    IBOutlet id _fReverse;
    IBOutlet id _fSame;
    IBOutlet id _fSelect;
    IBOutlet id _fUp;
    IBOutlet id _tabView;
    IBOutlet id _view;
    IBOutlet id _yAspect;
	
	GlobalData *_data;
	NSMutableArray *_cardArray;
	NSString *_directory;
	int _func;
}

- (IBAction)fDown:(id)sender;
- (IBAction)fGo:(id)sender;
- (IBAction)fReverse:(id)sender;
- (IBAction)fSame:(id)sender;
- (IBAction)fSelect:(id)sender;
- (IBAction)fUp:(id)sender;
- (IBAction)inputCmd:(id)sender;
- (IBAction)open:(id)sender;
- (IBAction)print:(id)sender;
- (IBAction)save:(id)sender;
- (IBAction)yAspect:(id)sender;

- (void)log:(id)str;
- (void)logWithTagI:(const char *)utf8 value:(int)value;
- (void)logWithTagF:(const char *)utf8 value:(float)value;
- (void)logWithTagS:(const char *)utf8 value:(NSString *)value;

- (void)analyzeCommand:(NSString *)cmd;
- (int)findCard:(int)a b:(int)b c:(int)c d:(int)d order:(int)t;
- (void)setCardOrder:(int)order a:(int)a b:(int)b c:(int)c d:(int)d order:(int)t;
- (void)reverseCardToushi:(int)order;
- (void)increaseYarnNumber:(int)order abcd:(int)n;
- (void) funcCopy:(int)pos s:(FUNCDATA *)pS d:(FUNCDATA *)pD option:(int)op;
- (void) funcS:(NSRect)s toD:(NSRect)d;

- (NSImage *) imageFromOpenGLView:(NSOpenGLView *)view;

@end
