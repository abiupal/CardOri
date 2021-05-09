#import "MyOpenGLView.h"
#import <Accelerate/Accelerate.h>

@implementation MyOpenGLView


- (void) initGL
{
	/*
	BOOL gpuProcessing;
	GLint fragmentGPUProcessing, vertexGPUProcessing;
	CGLGetParameter (CGLGetCurrentContext(), kCGLCPGPUFragmentProcessing,
                                         &fragmentGPUProcessing);
	CGLGetParameter(CGLGetCurrentContext(), kCGLCPGPUVertexProcessing,
                                         &vertexGPUProcessing);
	gpuProcessing = (fragmentGPUProcessing && vertexGPUProcessing) ? YES : NO;
	*/
	
	if( _print == TRUE )
		glClearColor(1.0f, 1.0f, 1.0f, 1.0f); 
	else
		glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
	
	glEnable(GL_DEPTH_TEST);	//デプスバッファを有効化
	glEnable(GL_CULL_FACE);
	glEnable( GL_POLYGON_SMOOTH );
	glHint( GL_POLYGON_SMOOTH_HINT,GL_DONT_CARE);
	glEnable(GL_BLEND);
	
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glShadeModel(GL_SMOOTH);
	glEnable(GL_LIGHTING);		//照明を有効化
	glEnable(GL_LIGHT0);		//光源0を設置
	glEnable(GL_LIGHT1);		//光源1を設置


	GLfloat light0pos[] = { 0.0, 3.0, 5.0, 1.0 };	//光源0の位置を設定
	GLfloat light1pos[] = { 5.0, 3.0, 0.0, 1.0 };	//光源1の位置を設定
	GLfloat light1col[] = { 0.5f, 0.5f, 0.5f, 1.0f };

	glLightfv(GL_LIGHT1, GL_DIFFUSE, light1col);	//光源1の色を設定
	glLightfv(GL_LIGHT0, GL_POSITION, light0pos);	//光源0の位置を設定
	glLightfv(GL_LIGHT1, GL_POSITION, light1pos);	//光源1の位置を設定
}

- (id) initWithFrame: (NSRect) frameRect
{
	/*
	NSOpenGLPixelFormatAttribute attrs[] =
	{
		NSOpenGLPFADepthSize, 1,
		NSOpenGLPFAAccelerated,
		0
	};*/
		NSOpenGLPixelFormatAttribute attrs[] =
		{
			NSOpenGLPFADoubleBuffer,
			NSOpenGLPFADepthSize, 32,
			NSOpenGLPFAStencilSize, 8,
			0
		};


	NSOpenGLPixelFormat* pixFmt = [[[NSOpenGLPixelFormat alloc] initWithAttributes:attrs] autorelease];

	self = [super initWithFrame:frameRect pixelFormat:pixFmt];
	
	processFunc = @selector(initGL); 
		
	return self;
}

- (id) initWithDatas:(GlobalData *)data card:(NSMutableArray *)card printInfo:(NSPrintInfo *)pi
{
	NSRect frame;
	NSOpenGLPixelFormatAttribute attrs[] =
	{
		NSOpenGLPFADepthSize, 1,
		NSOpenGLPFAAccelerated,
		0
	};

	[self setDatas:data card:card];
	
	NSSize paperSize = [pi paperSize];
	float printWidth = paperSize.width- [pi leftMargin] - [pi rightMargin];
	float scale = [[[pi dictionary] objectForKey:NSPrintScalingFactor]
                     floatValue];
	printWidth /= scale;
	_print = TRUE;
	
	frame.origin = NSMakePoint( 0, 0 );
	frame.size.width = paperSize.width;
	frame.size.height = paperSize.height;
	
	NSOpenGLPixelFormat* pixFmt = [[[NSOpenGLPixelFormat alloc] initWithAttributes:attrs] autorelease];

	self = [super initWithFrame:frame pixelFormat:pixFmt];
	processFunc = @selector(initGL);
	
	return self;
}



- (void) setDatas:(GlobalData *)data card:(NSMutableArray *)card
{
	_data = data;
	_aCY = card;
	_print = FALSE;
}

- (void) drawYarnX:(GLfloat)length
{
	// return;
	// length += [[_data yarn:X] radius] * [_data gap:X]);
	
	glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, [[_data yarn:X] colors] );//物体色を設定
	
	glBegin( GL_QUAD_STRIP );
	GLUquadricObj *quad; 		//オブジェクトポインタを準備
	quad = gluNewQuadric();
	
	/* 面の塗り潰しを指定する（線画ではなく陰影をつけた円柱を描く）*/
	gluQuadricDrawStyle(quad, GLU_FILL); // GLU_SILHOUETTE);
	/* スムースシェーディングを行うよう設定する */
	gluQuadricNormals(quad, GLU_SMOOTH);
	gluCylinder( quad, [[_data yarn:X] radius] /2, [[_data yarn:X] radius] /2, length, 24, 24 );
	
	gluDeleteQuadric(quad);
  	glEnd() ;  
}

- (void) polarView:(GLdouble)dist twist:(GLdouble)t elevation:(GLdouble)e azimuth:(GLdouble)a
{
	glTranslated( 0.0, 0.0, dist );
	glRotated( -t, 0.0, 0.0, 1.0 );
	glRotated( -e, 1.0, 0.0, 0.0 );
	glRotated( a, 0.0, 0.0, 1.0 );
}

- (void) drawRect: (NSRect) rect
{
	// Cocoa:コンテキストの切り替え
	[ [ self openGLContext ] makeCurrentContext ]; 
	// Cocoa:描画セット
	// [[self openGLContext] setView:self];
		
  //視野の設定-------------------------------------------------------------------
	GLfloat z = 2.0;
	glMatrixMode(GL_PROJECTION);			//現在の行列を視点モードに設定
	glLoadIdentity();						//行列を初期化
	gluPerspective (30, (double)rect.size.width/rect.size.height, 1.0, 50.0);	//視野の設定
	glTranslatef( 0.0f,0.0f, -z);								//視点の移動
	// gluLookAt([_data aspect:X], [_data aspect:Y], [_data aspect:Z], 0.0, 0.0, 0.0, 0.0, 1.0, 0.0);	//視点と視線の設定
	[self polarView:-[_data aspect:Y] twist:90.0 elevation:-90.0 azimuth:0.0];
	
  //オブジェクト描画準備----------------------------------------------------------
	
	glMatrixMode(GL_MODELVIEW);				//現在の行列をオブジェクトモードに設定
	glLoadIdentity();						//行列を初期化
	
	if (processFunc)
	{
		[self performSelector: processFunc];
		processFunc = nil;
	}
	
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);		//画面のクリア
	//----------------------------------------------------------------------------

	//オブジェクト描画-------------------------------------------------------------
	
	GLfloat spec_col[] = { 0.6, 0.6, 0.6, 1.0 };	//鏡面反射成分を定義
	GLfloat shininess[] = {20.0};					//鏡面係数を定義

	glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, spec_col);//鏡面光を設定
	glMaterialfv(GL_FRONT_AND_BACK, GL_SHININESS, shininess);//鏡面係数を設定
	
	
	GLfloat f, inr, outr, gridY = 0.0;
	int i, j, k, l = -1;
	int fr, bk, ifb, zeroCount = 0;
	int straghtCount = 1;
	bool straight = FALSE;
	unsigned long *co = (unsigned long *)[[_data cardOrder] bytes];
	CardYarns *c = [_aCY objectAtIndex:co[0]];
		
	gridY = [[_data yarn:X] radius] * [_data gap:Y] * 0.5;
	fr = bk = ifb = 0;
	k = [_data cards];
	for( i = 0; i < [_data ylength]; ++i )
	{
		glPushMatrix();
		
		glTranslatef( [[_data yarn:X] radius] * -([_data ylength] /2) * [_data gap:Y], 0.0, [_data xlength] / -2 );
		glTranslatef( [[_data yarn:X] radius] * [_data gap:Y] * i + straghtCount * gridY, 0.0, 0.0 );
		[self drawYarnX:[_data xlength]];
		
		/* 070529:rotate fixed */
		if( fr < [c fb:ifb] && (ifb + 1) % 2 )
		{
			if( fr == 0 )
			{
				--i;
				goto JUMP_1ST;
			}
		}
		else if( bk < [c fb:ifb] && !((ifb + 1) % 2) )
		{
			if( bk == 0 )
			{
				--i;
				goto JUMP_1ST;
			}
		}
		/* 070529:rotate fixed end */
		
		if( 0 < [c fb:ifb] )
		{
			if( (ifb + 1) % 2 )
			{
				l++;
				if( 3 < l ) l = 0;
			}
			else
			{
				l--;
				if( l < 0 ) l = 3;
			}
			zeroCount = 0;
		}
		else
			zeroCount++;
		
		for( j = 0; j < k; ++j )
		{
			if( [[_data cardOrder] length] <= j ) break;
			c = [_aCY objectAtIndex:co[j]];
			
			glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, [[c yarn:l] colors] );
			
			glTranslatef( 0.0, 0.0, [_data gap:X] ); // [[_data yarn:X] radius] * [_data gap:X] );
			
			if( fr < [c fb:ifb] && (ifb + 1) % 2 )
			{
				f = [_data angle];
				if( [c order] == ORDER_Z ) f *= -1;
				
				straight = FALSE;
			}
			else if( bk < [c fb:ifb] && !((ifb + 1) % 2) )
			{
				f = [_data angle];
				if( [c order] == ORDER_S ) f *= -1;
				
				straight = FALSE;
			}
			else if ( fr == [c fb:ifb] && (ifb + 1) % 2 )
			{
				f = [[_data yarn:X] radius];
				if( [c order] == ORDER_Z ) f *= -1;
				if( zeroCount % 2 )
					f *= -1;
				
				straight = TRUE;
			}
			else if ( bk == [c fb:ifb] && !((ifb +1) % 2) )
			{
				f = [[_data yarn:X] radius];
				if(	[c order] == ORDER_S ) f *= -1;
				if( zeroCount % 2 )
					f *= -1;
				
				straight = TRUE;
			}
			
			if( straight == TRUE )
			{				
				if( !j )
				{	/* 070530:straght fixed */
					glTranslatef( gridY * 1.5, 0.0,-[_data gap:X] );
					[self drawYarnX:[_data xlength]];
					glTranslatef( gridY * -1.5, 0.0, [_data gap:X] );
					glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, [[c yarn:l] colors] );
				}
				
				/* 070529:rotate fixed */
				inr = 0.045;
				outr = gridY * 1.1;
				outr *= 2;
				glTranslatef( gridY + [[_data yarn:X] radius], -2 * [[_data yarn:X] radius], f ); // ???? <-
				/* 070529:rotate fixed:end */
				
				/* 070530:straght fixed */
				if( !j ) straghtCount++;
			}
			else
			{
				inr = 0.03;
				outr = gridY * 1.55;
				glTranslatef( gridY, 0.0, 0.0 );
				glRotated( f, 0.0, 1.0, 0.0 );
				
			}
			
			/* 内径：糸の太さ　外径：リングのサイズ */
			glutSolidTorus(inr, outr, 10, 36);
			
			f *= -1;
			if( straight == TRUE )
				glTranslatef( -(gridY + [[_data yarn:X] radius]), 2 * [[_data yarn:X] radius], f );
			else
			{
				glRotated( f, 0.0, 1.0, 0.0 );
				glTranslatef( -gridY, 0.0, 0.0 );
			}
		}
	JUMP_1ST:
		
		glPopMatrix();
				
		if( (ifb + 1) % 2 )
		{
			fr++;
			if( [c fb:ifb] < fr )
			{
				ifb++;
				fr = 0;
			}
		}
		else
		{
			bk++;
			if( [c fb:ifb] < bk )
			{
				ifb++;
				bk = 0;
			}
		}
		if( FB_MAX < ifb ) ifb = 0;
		if( [c fb:ifb] < 0 ) ifb = 0;
	}
	glPushMatrix();
		
	glTranslatef( [[_data yarn:X] radius] * -([_data ylength] /2) * [_data gap:Y], 0.0, [_data xlength] / -2 );
	glTranslatef( [[_data yarn:X] radius] * [_data gap:Y] * i + straghtCount * gridY, 0.0, 0.0 );
	[self drawYarnX:[_data xlength]];
	glPopMatrix();
	
	
	/* 背景面 *
	f = 20.0;
	GLfloat black[] = { 1.0, 1.0, 1.0, 1.0 };
	glMaterialfv(GL_FRONT, GL_AMBIENT, black );
	glBegin( GL_QUADS );
	glVertex3f( -f, 0.0, -f );
	glVertex3f( f, 0.0, -f );
	glVertex3f( f, 0.0, f );
	glVertex3f( -f, 0.0, f );
	glEnd();
	*/
	
	
		/* 座標軸 *
	GLfloat lineN = 3.0;
	GLfloat lineR[] = { 1.0, 0.0, 0.0, 1.0 };
	GLfloat lineG[] = { 0.0, 1.0, 0.0, 1.0 };
	GLfloat lineB[] = { 0.0, 0.0, 1.0, 1.0 };
	glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, lineR);//物体色を設定
	glBegin(GL_LINES);
	glVertex3d(-lineN, 0.0, 0.0);
	glVertex3d(lineN, 0.0, 0.0);
	glEnd();
	glBegin(GL_TRIANGLES);
	glVertex3d(lineN, 0.0, 0.0);
	glVertex3d(lineN - (lineN / 10.0), (lineN / 10.0), 0.0);
	glVertex3d(lineN - (lineN / 10.0), -(lineN / 10.0), 0.0);
	glEnd();
	glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, lineG);//物体色を設定
	glBegin(GL_LINES);
	glVertex3d(0.0, -lineN, 0.0);
	glVertex3d(0.0, lineN, 0.0);
	glEnd();
	glBegin(GL_TRIANGLES);
	glVertex3d(0.0, lineN, 0.0);
	glVertex3d((lineN / 10.0), lineN - (lineN / 10.0), 0.0);
	glVertex3d(-(lineN / 10.0), lineN - (lineN / 10.0), 0.0);
	glEnd();
	glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, lineB);//物体色を設定
	glBegin(GL_LINES);
	glVertex3d(0.0, 0.0,-lineN);
	glVertex3d(0.0, 0.0, lineN);
	glEnd();
	glBegin(GL_TRIANGLES);
	glVertex3d(0.0, 0.0, lineN);
	glVertex3d((lineN / 10.0), 0.0, lineN - (lineN / 10.0));
	glVertex3d(-(lineN / 10.0), 0.0, lineN - (lineN / 10.0));
	glEnd();
	* 座標軸 終了 */
		
	// glFlush();	// 描画の実行
	
	// Cocoa:バッファ入れ替え
	[ [ self openGLContext ] flushBuffer ];
	// [super drawRect:rect]; 
}

- (void)print:(id)sender
{
	[[NSPrintOperation printOperationWithView:self] runOperation];
}

/*
- (BOOL)isOpaque
{
	//we want the superview to control the drawing/updating of these views
	return NO;
}*/

static void OpenGLNoError( )
{
    while( glGetError() != GL_NO_ERROR )
	{
		;
	} // while
} // OpenGLNoError

//------------------------------------------------------------------------

static void OpenGLDisableCapabilitiesForCopy( )
{
	glDisable(GL_COLOR_TABLE);
	glDisable(GL_CONVOLUTION_1D);
	glDisable(GL_CONVOLUTION_2D);
	glDisable(GL_HISTOGRAM);
	glDisable(GL_MINMAX);
	glDisable(GL_POST_COLOR_MATRIX_COLOR_TABLE);
	glDisable(GL_POST_CONVOLUTION_COLOR_TABLE);
	glDisable(GL_SEPARABLE_2D);
} // OpenGLDisableCapabilitiesForCopy

//------------------------------------------------------------------------

static void OpenGLPixelMap( )
{
	GLfloat values = 0.0f;
	
	glPixelMapfv(GL_PIXEL_MAP_R_TO_R, 1, &values);
	glPixelMapfv(GL_PIXEL_MAP_G_TO_G, 1, &values);
	glPixelMapfv(GL_PIXEL_MAP_B_TO_B, 1, &values);
	glPixelMapfv(GL_PIXEL_MAP_A_TO_A, 1, &values);
} // OpenGLPixelMap

//------------------------------------------------------------------------

static void OpenGLPixelStore( NSPoint *origin, NSRect *rect1, NSRect *rect2 )
{
	glPixelStorei(GL_PACK_SWAP_BYTES, 0);
	glPixelStorei(GL_PACK_LSB_FIRST, 0);
	glPixelStorei(GL_PACK_IMAGE_HEIGHT, 0);
	glPixelStoref(GL_PACK_ROW_LENGTH, NSWidth(*rect2)); 
	glPixelStoref(GL_PACK_SKIP_PIXELS, origin->x);
	glPixelStoref(GL_PACK_SKIP_ROWS, NSHeight(*rect2) - (origin->y + NSHeight(*rect1)));
	glPixelStorei(GL_PACK_SKIP_IMAGES, 0);
} // OpenGLPixelStore

//------------------------------------------------------------------------

static void OpenGLPixelTransfer( )
{
	glPixelTransferi(GL_MAP_COLOR, 0);
	glPixelTransferf(GL_RED_SCALE, 1.0f);
	glPixelTransferf(GL_RED_BIAS, 0.0f);
	glPixelTransferf(GL_GREEN_SCALE, 1.0f);
	glPixelTransferf(GL_GREEN_BIAS, 0.0f);
	glPixelTransferf(GL_BLUE_SCALE, 1.0f);
	glPixelTransferf(GL_BLUE_BIAS, 0.0f);
	glPixelTransferf(GL_ALPHA_SCALE, 1.0f);
	glPixelTransferf(GL_ALPHA_BIAS, 0.0f);
	glPixelTransferf(GL_POST_COLOR_MATRIX_RED_SCALE, 1.0f);
	glPixelTransferf(GL_POST_COLOR_MATRIX_RED_BIAS, 0.0f);
	glPixelTransferf(GL_POST_COLOR_MATRIX_GREEN_SCALE, 1.0f);
	glPixelTransferf(GL_POST_COLOR_MATRIX_GREEN_BIAS, 0.0f);
	glPixelTransferf(GL_POST_COLOR_MATRIX_BLUE_SCALE, 1.0f);
	glPixelTransferf(GL_POST_COLOR_MATRIX_BLUE_BIAS, 0.0f);
	glPixelTransferf(GL_POST_COLOR_MATRIX_ALPHA_SCALE, 1.0f);
	glPixelTransferf(GL_POST_COLOR_MATRIX_ALPHA_BIAS, 0.0f);
} // OpenGLPixelTransfer

//------------------------------------------------------------------------

static inline void OpenGLReadRGBAPixels( NSRect *rect, GLvoid *pixels )
{
	GLint    x      = (GLint) NSMinX(*rect);
	GLint    y      = (GLint) NSMinY(*rect);
	GLsizei  width  = (GLsizei) NSWidth(*rect);
	GLsizei  height = (GLsizei) NSHeight(*rect);
	GLenum   format = GL_RGBA;
	GLenum   type   = GL_UNSIGNED_BYTE;

	glReadPixels( x, y, width, height, format, type, pixels );
} // OpenGLReadRGBAPixels

//------------------------------------------------------------------------

typedef struct
{
	GLuint         imageBitsPerPixel;
	GLuint         imageBitsPerComponent;
	GLuint         imageSamplesPerPixel;
	GLuint         imageStorageSize;
	CGBitmapInfo   imageBitmapInfo;
	vImage_Buffer  imageBuffer;
} CGImageBitmap;

//------------------------------------------------------------------------

static GLvoid CGImageBitmapMemset( CGImageBitmap *imageBitmap )
{
	imageBitmap->imageBitsPerPixel     = 0;
	imageBitmap->imageBitsPerComponent = 0;
	imageBitmap->imageSamplesPerPixel  = 0;
	imageBitmap->imageBitmapInfo       = 0;
	imageBitmap->imageStorageSize      = 0;
	imageBitmap->imageBuffer.width     = 0;
	imageBitmap->imageBuffer.height    = 0;
	imageBitmap->imageBuffer.rowBytes  = 0;
	imageBitmap->imageBuffer.data      = NULL;
} // CGImageBitmapMemset

//------------------------------------------------------------------------

static BOOL CGImageBitmapMalloc( CGImageRef imageRef, CGImageBitmap *imageBitmap )
{
	BOOL  imageBitmapAllocated = NO;
	
	imageBitmap->imageBitsPerPixel     = 32;
	imageBitmap->imageBitsPerComponent = 8;
	imageBitmap->imageSamplesPerPixel  = 4;
	imageBitmap->imageBitmapInfo       = kCGImageAlphaPremultipliedLast; // RGBA
	imageBitmap->imageBuffer.width     = CGImageGetWidth( imageRef );
	imageBitmap->imageBuffer.height    = CGImageGetHeight( imageRef );
	imageBitmap->imageBuffer.rowBytes  = imageBitmap->imageBuffer.width * imageBitmap->imageSamplesPerPixel;
	imageBitmap->imageStorageSize      = imageBitmap->imageBuffer.rowBytes * imageBitmap->imageBuffer.height;
	imageBitmap->imageBuffer.data      = (GLvoid *)malloc( imageBitmap->imageStorageSize );
	
	if ( imageBitmap->imageBuffer.data != NULL )
	{
		imageBitmapAllocated = YES;
	} // if
	else
	{
		CGImageBitmapMemset( imageBitmap );
	} // else
	
	return imageBitmapAllocated;
} // CGImageBitmapMalloc

//------------------------------------------------------------------------

static BOOL CGImageBitmapFree( CGImageBitmap *imageBitmap )
{
	BOOL  imageBitmapFreed = NO;
	
	if ( imageBitmap->imageBuffer.data != NULL )
	{
		free( imageBitmap->imageBuffer.data );
		
		imageBitmapFreed = YES;
	} // if
	
	CGImageBitmapMemset( imageBitmap );
	
	return imageBitmapFreed;
} // CGImageBitmapFree

//------------------------------------------------------------------------

static CGContextRef CGImageBitmapContexMalloc( CGImageBitmap *imageBitmap )
{
	CGContextRef     imageContextRef    = NULL;
	CGColorSpaceRef  imageColorSpaceRef = CGColorSpaceCreateWithName( kCGColorSpaceGenericRGB );

	if ( imageColorSpaceRef != NULL )
	{
		imageContextRef = CGBitmapContextCreate( imageBitmap->imageBuffer.data, 
												 imageBitmap->imageBuffer.width, 
												 imageBitmap->imageBuffer.height, 
												 imageBitmap->imageBitsPerComponent,
												 imageBitmap->imageBuffer.rowBytes, 
												 imageColorSpaceRef, 
						 						 imageBitmap->imageBitmapInfo 
											   );
		
		CGColorSpaceRelease( imageColorSpaceRef );
	} // if

	return  imageContextRef;
} // CGImageBitmapContexMalloc

//------------------------------------------------------------------------

static BOOL CGImageBitmapVerticalReflect( CGImageRef imageRef, CGImageBitmap *imageBitmap )
{
	BOOL          imageBitmapReflected = NO;
	CGContextRef  imageContextRef      = CGImageBitmapContexMalloc( imageBitmap );

	if ( imageContextRef != NULL )
	{
		CGRect imageRect = { { 0, 0 }, { imageBitmap->imageBuffer.width, imageBitmap->imageBuffer.height } };

		// The alpha will be added here
		
		CGContextDrawImage( imageContextRef, imageRect, imageRef );
		
		vImageVerticalReflect_ARGB8888( &(imageBitmap->imageBuffer), &(imageBitmap->imageBuffer), kvImageNoFlags );

		CGContextRelease( imageContextRef );
		
		imageBitmapReflected = YES;
	} // if bitmap context
	
	return imageBitmapReflected;
} // CGImageBitmapVerticalReflect

static CGImageRef CGImageGetFromCGImageBitmap( CGImageBitmap  *imageBitmap )
{
	CGImageRef imageRef = NULL;
	
	// Create a data provider
	
	CGDataProviderRef imageDataProvider = CGDataProviderCreateWithData(	NULL,
																		imageBitmap->imageBuffer.data,
																		imageBitmap->imageStorageSize,
																		NULL );
	if ( imageDataProvider != NULL )
	{
		// Create a color space for the image
		
		CGColorSpaceRef imageColorSpace = CGColorSpaceCreateWithName( kCGColorSpaceGenericRGB );

		if ( imageColorSpace != NULL )
		{
			// Create the actual image
			
			GLfloat                  *imageDecode            = NULL;
			bool                      imageShouldInterpolate = true;
			CGColorRenderingIntent    imageRenderingIntent   = kCGRenderingIntentDefault;
			
			imageRef = CGImageCreate(	imageBitmap->imageBuffer.width,
										imageBitmap->imageBuffer.height,
										imageBitmap->imageBitsPerComponent,
										imageBitmap->imageBitsPerPixel,
										imageBitmap->imageBuffer.rowBytes,
										imageColorSpace,
										imageBitmap->imageBitmapInfo,
										imageDataProvider,
										imageDecode,
										imageShouldInterpolate,
										imageRenderingIntent );

			// the image will retain the data provider & colorspace as needed, so we can release them now
			
			CGColorSpaceRelease( imageColorSpace );
		} //if
		
		CGDataProviderRelease( imageDataProvider );
	} // if
	
	return  imageRef;
} // CGImageGetFromCGImageBitmap

//------------------------------------------------------------------------

static NSImage *NSImageGetFromCGImage( CGImageRef imageRef )
{
	NSImage  *image = nil;
	
	if ( imageRef != NULL )
	{
		NSRect imageRect = NSMakeRect(0.0, 0.0, 0.0, 0.0);

		// Get the image dimensions
		
		imageRect.size.height = CGImageGetHeight( imageRef );
		imageRect.size.width  = CGImageGetWidth( imageRef );

		// Create a new image to receive the Quartz image data
		
		image = [[[NSImage alloc] initWithSize:imageRect.size] autorelease]; 
		
		if ( image != nil )
		{
			[image lockFocus];

				// Get the Quartz context and draw
				
				CGContextRef  imageContextRef = (CGContextRef) [[NSGraphicsContext currentContext] graphicsPort];
				
				if ( imageContextRef != NULL )
				{
					CGContextDrawImage( imageContextRef, *(CGRect*)&imageRect, imageRef );
				} // if
				
			[image unlockFocus];
		} // if
	} // if
	
	return image;
} // NSImageGetFromCGImage
static NSImage *NSImageGetFromCGImageAddAlphaAndVerticalReflect( CGImageRef imageRefSrc )
{
	NSImage *imageDst = nil;
	
	if ( imageRefSrc != NULL )
	{
		CGImageBitmap  imageBitmap;
		
		if ( CGImageBitmapMalloc( imageRefSrc, &imageBitmap ) )
		{
			if ( CGImageBitmapVerticalReflect( imageRefSrc, &imageBitmap ) )
			{
				CGImageRef  imageRefDst = CGImageGetFromCGImageBitmap( &imageBitmap );
				
				if ( imageRefDst != NULL )
				{
					imageDst = NSImageGetFromCGImage( imageRefDst );
					
					CGImageRelease( imageRefDst );
				} // if
			} // if image vertical reflect
		} // if bitmap data
	} // if image ref
	
	return  imageDst;
} // NSImageGetFromCGImageAddAlphaAndVerticalReflect


//------------------------------------------------------------------------

- (void)copyPixelsTo: (GLvoid *)imageData sourceRect:(NSRect)srcRect baseView:(NSView *)view
{	
    NSRect    rect   = NSIntersectionRect([self bounds], srcRect);
	NSPoint   origin = [self convertPoint:rect.origin toView:view];
    GLvoid   *pixels = imageData;

    [self lockFocus];
	
		OpenGLNoError();
		
			glPushAttrib(GL_ALL_ATTRIB_BITS);
			
				glReadBuffer(GL_BACK);
				
				// OpenGLDisableCapabilitiesForCopy( );
				
				OpenGLPixelMap( );
				OpenGLPixelStore( &origin, &rect, &srcRect );
				OpenGLPixelTransfer( );
				
				OpenGLReadRGBAPixels( &rect, pixels );
								
			glPopAttrib();
		
		// Get rid of any error, in order to not mislead the rest of the app
		
		OpenGLNoError();
	
    [self unlockFocus];
} // copyPixelsTo

- (NSImage *)getImageFromRect:(NSRect)rect
{
   if( NSIsEmptyRect(rect) )
   {
        rect = [self bounds];
   } // if
   
	NSImage *image = nil;
	
	GLuint   imageWidth           = NSWidth( rect );
	GLuint   imageHeight          = NSHeight( rect );
	GLuint   imageSamplesPerPixel = 4;
	GLuint   imageRowBytes        = imageWidth * imageSamplesPerPixel;
	GLuint   imageStorageSize     = imageRowBytes * imageHeight;
	GLvoid  *imageData            = (GLvoid *)malloc( imageStorageSize );

	if ( imageData != NULL )
	{
		// Create a data provider
		
		CGDataProviderRef imageDataProvider = CGDataProviderCreateWithData(	NULL, imageData, imageStorageSize, NULL );
		
		if ( imageDataProvider != NULL )
		{
			// Create a color space for the image
			
			CGColorSpaceRef  imageColorSpace = CGColorSpaceCreateWithName( kCGColorSpaceGenericRGB );

			if ( imageColorSpace != NULL )
			{
				// Create an empty CGImageRef so that we may utilize OpenGL read pixels to copy the
				// pixels from OpenGL view into this newly created CGImageRef
				
				GLuint                    imageBitsPerPixel      = 32;
				GLuint                    imageBitsPerComponent  = 8;
				GLfloat                  *imageDecode            = NULL;
				bool                      imageShouldInterpolate = true;
				CGColorRenderingIntent    imageRenderingIntent   = kCGRenderingIntentDefault;
				CGBitmapInfo              imageBitmapInfo        = kCGImageAlphaNone; // For now RGB; but later we'll fix the alpha
			
				CGImageRef imageRef = CGImageCreate(	imageWidth,
														imageHeight,
														imageBitsPerComponent,
														imageBitsPerPixel,
														imageRowBytes,
														imageColorSpace,
														imageBitmapInfo,
														imageDataProvider,
														imageDecode,
														imageShouldInterpolate,
														imageRenderingIntent );

				
				if ( imageRef != NULL )
				{
					[self copyPixelsTo:imageData sourceRect:rect baseView:self];
					
					// Get an NSImage from CGImageRef, add alpha (RGBA from RGB) and
					// vertically reflect the image
					
					image = NSImageGetFromCGImageAddAlphaAndVerticalReflect( imageRef );
					
					CGImageRelease( imageRef );
				} // if
				
				CGColorSpaceRelease( imageColorSpace );
			} //if
			
			CGDataProviderRelease( imageDataProvider );
		} // if
	} // if
	
	return  image;
} // getImageFromRect

@end
