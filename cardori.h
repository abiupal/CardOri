/*
 *  cardori.h
 *  CardOri
 *
 *  Created by 武村 健二 on  07/03/02.
 *  Copyright 2007 Oriya Inc. All rights reserved.
 *
 */
 
#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

#import <OpenGL/OpenGL.h>
#import <OpenGL/gl.h>
#import <OpenGL/glu.h>
#import <OpenGL/CGLRenderers.h>



enum { ORDER_S = 1, ORDER_Z, MAX_CARDORDER = 255 };

typedef struct
{
	GLfloat r;
	GLfloat rgba[4];
	int     no;
} yarnData;

typedef struct
{
	int  ylength;
	GLfloat aspectX, aspectY, aspectZ;
	GLfloat xlength, angle;
	GLfloat xlineGap, ylineGap;
} viewData;


enum { R = 0, G, B, A };

@interface YarnData : NSObject
{
	GLfloat _radius;
	GLfloat _col[4];
	int _no;
}

- (id) initWithData:(int)no radius:(GLfloat)r r:(GLfloat)red g:(GLfloat)grn b:(GLfloat)blu a:(GLfloat)alp;
- (GLfloat *) colors;
- (int) no;
- (GLfloat) radius;
- (bool) checkSame:(GLfloat)radius r:(GLfloat)red g:(GLfloat)grn b:(GLfloat)blu a:(GLfloat)alp;
- (GLfloat) color:(int)rgba;
- (NSMutableArray *) arrayObject;
- (void) setArrayObject:(NSArray *)array;

@end

enum { POS_A = 0, POS_B, POS_C, POS_D, POS_X, POS_Y, FB_MAX = 32 };

@interface CardYarns : NSObject
{
	int _a, _b, _c, _d;
	int _order;
	int _fb[FB_MAX];
	NSMutableArray *_yarnArray;
}

- (id) initWithData:(int)order fb:(int *)fb yarnArray:(NSMutableArray *)d;
- (void) setOrder:(int)order;
- (void) setYarn:(int)pos yarnData:(int)n;
- (int) order;
- (int) fb:(int)pos;
- (int *)fb;
- (YarnData *)yarn:(int)pos;
- (NSString *)info;
- (int) a;
- (int) b;
- (int) c;
- (int) d;
- (NSMutableArray *) arrayObject;
- (void) setArrayObject:(NSArray *)array;

@end

enum { X = 100, Y, Z };

@interface GlobalData : NSObject
{
	float _version;
	int _ylength;
	GLfloat _aspectX, _aspectY, _aspectZ;
	GLfloat _xlength, _angle;
	GLfloat _xlineGap, _ylineGap;
	NSMutableData  *_cardOrder;
	YarnData *_x, *_y;
	NSMutableArray *_yarnArray;
}

- (void) initWithData:(viewData *)data;

- (NSMutableData *)cardOrder;
- (NSMutableArray *) yarnArray;
- (YarnData *)yarn:(int)select;
- (GLfloat)gap:(int)select;
- (GLfloat)xlength;
- (int)cards;
- (int)ylength;
- (GLfloat)aspect:(int)select;
- (GLfloat)angle;
- (int)realCardFromDispCard:(int)n;

- (void) setData:(viewData *)data;
- (void) setYarn:(int)select value:(YarnData *)d;
- (void) setGap:(int)select value:(GLfloat)f;
- (void) setLengthX:(GLfloat)f;
- (void) setCards:(int)i;
- (void) setLengthY:(int)i;
- (void) setAspect:(int)select value:(GLfloat)f;
- (void) addYarn:(GLfloat)radius r:(GLfloat)red g:(GLfloat)grn b:(GLfloat)blu a:(GLfloat)alp;
- (int) find:(GLfloat)radius r:(GLfloat)red g:(GLfloat)grn b:(GLfloat)blu a:(GLfloat)alp;
- (NSMutableArray *)arrayObject;
- (void) setArrayObject:(NSArray *)array;
@end

