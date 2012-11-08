//
//  CorePlotView.m
//  OTPieViewExam
//
//  Created by Hank0272 on 12/11/2.
//  Copyright (c) 2012年 Ortery Technology, Inc. All rights reserved.
//

#import "CorePlotView.h"
@interface CorePlotView()
{
    NSDictionary *histogrameDictionary;
    NSDictionary *gammaDictionary, *redDictionary, *greenDictionary, *blueDictionary;    
    NSBezierPath *boundingFrame;
    int maxVolume;
    int maxGammaValue, maxRedValue, maxGreenValue, maxBlueValue;
    BOOL draggingIndicator;
}
@property (nonatomic, copy) NSBezierPath *boundingFrame;
@property (nonatomic, readwrite, copy) NSDictionary *histogrameDictionary;
@property (nonatomic, readwrite, copy) NSDictionary *gammaDictionary;
@property (nonatomic, readwrite, copy) NSDictionary *redDictionary;
@property (nonatomic, readwrite, copy) NSDictionary *greenDictionary;
@property (nonatomic, readwrite, copy) NSDictionary *blueDictionary;
@property (assign) kOTHistogram_Channel otHistogramChannel;
@property (nonatomic) BOOL draggingIndicator;
@end

@implementation CorePlotView

@synthesize boundingFrame;
@synthesize histogrameDictionary;
@synthesize gammaDictionary, redDictionary, greenDictionary, blueDictionary;
@synthesize otHistogramChannel;
@synthesize draggingIndicator;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        self.histogrameDictionary = [NSMutableDictionary dictionary];
        self.gammaDictionary = [NSMutableDictionary dictionary];
        self.redDictionary = [NSMutableDictionary dictionary];
        self.greenDictionary = [NSMutableDictionary dictionary];
        self.blueDictionary = [NSMutableDictionary dictionary];
        maxGammaValue = 0, maxRedValue = 0, maxGreenValue = 0, maxBlueValue = 0;
    }
    return self;
}

- (void)dealloc {
    self.boundingFrame = nil;
    [self.histogrameDictionary release];
    [self.gammaDictionary release];
    [self.redDictionary release];
    [self.greenDictionary release];
    [self.blueDictionary release];
	[super dealloc];
}

- (void)setImageForHistogram:(NSImage *)image withHistogramChannel:(kOTHistogram_Channel)histogramColor
{
    NSBitmapImageRep *bmprep = [[image representations] objectAtIndex:0];
    NSColor *tmpColor;
    
    NSMutableDictionary *mutRedDictionary = [NSMutableDictionary dictionary];
    NSMutableDictionary *mutGreenDictionary = [NSMutableDictionary dictionary];
    NSMutableDictionary *mutBlueDictionary = [NSMutableDictionary dictionary];
    
    for (int i = 0 ; i < 256; i++) {
        [mutRedDictionary setObject:[NSString stringWithFormat:@"0"] forKey:[NSString stringWithFormat:@"%d", i]];
        [mutGreenDictionary setObject:[NSString stringWithFormat:@"0"] forKey:[NSString stringWithFormat:@"%d", i]];
        [mutBlueDictionary setObject:[NSString stringWithFormat:@"0"] forKey:[NSString stringWithFormat:@"%d", i]];
    }
    
    maxGammaValue = 0, maxRedValue = 0, maxGreenValue = 0, maxBlueValue = 0;
    for (int y = 0 ; y < image.size.height; y++) {
        for (int x = 0 ; x < image.size.width; x++) {
            tmpColor = [bmprep colorAtX:x y:y];
            
            [self setColorForDictionary:tmpColor forRedDictionary:mutRedDictionary forGreenDictionary:mutGreenDictionary forBlueDictionary:mutBlueDictionary];

        }
    }
    redDictionary = [mutRedDictionary copy];
    greenDictionary = [mutGreenDictionary copy];
    blueDictionary = [mutBlueDictionary copy];
    gammaDictionary = [[self saveToGammaDictionary:mutRedDictionary withGreenDictionary:mutGreenDictionary withBlueDictionary:mutBlueDictionary] copy];
    
    [self selectHistogramChannel:histogramColor];
}

- (void)selectHistogramChannel:(kOTHistogram_Channel)histogramColor
{
    switch (histogramColor) {
        case 1: //Red
            [self setDictionaryToDraw:redDictionary withMaxValue:maxRedValue withHistogramChannel:histogramColor];
            break;
            
        case 2: //Green
            [self setDictionaryToDraw:greenDictionary withMaxValue:maxGreenValue withHistogramChannel:histogramColor];
            break;
            
        case 3: //Blue
            [self setDictionaryToDraw:blueDictionary withMaxValue:maxBlueValue withHistogramChannel:histogramColor];
            break;
            
        default: //RGB
            [self setDictionaryToDraw:gammaDictionary withMaxValue:maxGammaValue withHistogramChannel:histogramColor];
            break;
    }
}

- (void)setDictionaryToDraw:(NSDictionary *)dictionary withMaxValue:(int)maxValue withHistogramChannel:(kOTHistogram_Channel)histogramChannel
{

    self.histogrameDictionary = [dictionary mutableCopy];
    maxVolume = maxValue;
    self.otHistogramChannel = histogramChannel;
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
    
    if (!self.histogrameDictionary) {
        return;
    }
    //畫背景用
    NSBezierPath *backgroundFrame = [[[NSBezierPath alloc] init] autorelease];
    [backgroundFrame appendBezierPathWithRect:NSMakeRect(0, 0, 320, 160)];
    [[NSColor whiteColor] set];
    [backgroundFrame fill];
    [backgroundFrame stroke];
    [backgroundFrame closePath];
    
    float borderXOffset = 0.0, borderYOffset = 20.0; //座標偏移，移動圖形用
    float borderYRedeem = 4.0; //座標補償，主要是變高變長用
    //畫外框
    NSBezierPath *borderFrame = [[[NSBezierPath alloc] init] autorelease];
    [borderFrame appendBezierPathWithRect:NSMakeRect(30 + borderXOffset , 30 + borderYOffset, 260, 100 + borderYRedeem)];
    [[NSColor blackColor] set];
    [borderFrame stroke];
    [borderFrame closePath];

    //畫每個值的量

    NSBezierPath *volumeFrame = [[[NSBezierPath alloc] init] autorelease];
    float volume;
    NSColor *histogramColor;
    switch (self.otHistogramChannel) {
        case  kOTHistogramChannel_Red:
            histogramColor = [NSColor redColor];
            break;

        case  kOTHistogramChannel_Green:
            histogramColor = [NSColor greenColor];
            break;
            
        case  kOTHistogramChannel_Blue:
            histogramColor = [NSColor blueColor];
            break;
        default:
            histogramColor = [NSColor grayColor];
            break;
    }
    float xOffset = 2.0, yOffset = 1.5; //長條的位移量
    for (int i = 0; i < 256; i++) {
        NSString *tmpColorStringValue = [self.histogrameDictionary objectForKey:[NSString stringWithFormat:@"%d", i]];
        int colorValue = [tmpColorStringValue intValue];
        volume = ((float)colorValue / maxVolume) * 100;
//        NSLog(@"volume: %f", volume);
        [volumeFrame moveToPoint:NSMakePoint(30 + i + xOffset + borderXOffset, 30 + yOffset + borderYOffset)];
        [volumeFrame lineToPoint:NSMakePoint(30 + i + xOffset + borderXOffset, 30 + volume + yOffset + borderYOffset)];
        [volumeFrame setLineWidth:0.25];
        [histogramColor set];
        [volumeFrame stroke];
    }
    [volumeFrame stroke];
    [volumeFrame closePath];
   
    NSBezierPath *borderOfLightShadow = [[[NSBezierPath alloc] init] autorelease];
    [borderOfLightShadow appendBezierPathWithRect:NSMakeRect(30, 10 + borderYOffset - 5 , 260, 20)];
    [[NSColor blackColor] set];
    [borderOfLightShadow stroke];
    [borderOfLightShadow closePath];

    NSGradient *gradient = [[[NSGradient alloc] initWithStartingColor:[NSColor blackColor] endingColor:[NSColor whiteColor]] autorelease];
    [gradient drawInBezierPath:borderOfLightShadow angle:0];
    
//    NSBezierPath *trianglePath = [[[NSBezierPath alloc] init] autorelease];
//    [trianglePath moveToPoint:NSMakePoint(0, 0)];
//    [trianglePath lineToPoint:NSMakePoint(5, 10)];
//    [trianglePath lineToPoint:NSMakePoint(10, 0)];
//    [trianglePath closePath];
//    NSAffineTransform *dragTransform = [NSAffineTransform transform];
//    float xRange = 25.0f, yRange = 12.0f ;
//    [dragTransform translateXBy:xRange yBy:yRange];
//    [trianglePath transformUsingAffineTransform:dragTransform];
//    [[NSColor blackColor] set];
//    [trianglePath setLineWidth:2.0];
//    [trianglePath stroke];
//    
//    [[NSColor lightGrayColor] set];
//    [trianglePath fill];
    
//    NSAffineTransform *transform = [NSAffineTransform transform];
//
//    [transform appendTransform:dragTransform];
//    NSBezierPath *trianglePath2 = [transform transformBezierPath:trianglePath];
//    trianglePath2 = [transform transformBezierPath:trianglePath];
//    [[NSColor blueColor] set];
//    [trianglePath2 setLineWidth:2.0];
//    [trianglePath2 stroke];
//    [[NSColor blackColor] set];
//    [trianglePath2 fill];
//    NSLog(@"%@", [dragTransform cu])
    
//    self.boundingFrame = trianglePath;
}
- (BOOL)mouseDownCanMoveWindow {
    return NO;
}

/* test for mouse clicks inside of the speedometer area of the view */
- (NSView *)hitTest:(NSPoint)aPoint {
	NSPoint local_point = [self convertPoint:aPoint fromView:[self superview]];
	if ( [self.boundingFrame containsPoint:local_point] ) {
		return self;
	}
	return nil;
}

/* re-calculate the speed value based on the mouse position for clicks
 in the speedometer area of the view. */
- (void)mouseDown:(NSEvent *)theEvent {
	NSPoint local_point = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	if ( [self.boundingFrame containsPoint:local_point] ) {
        
        /* set the dragging flag */
        
		[self setDraggingIndicator: YES];
	}
}

/* re-calculate the speed value based on the mouse position while the mouse
 is being dragged inside of the speedometer area of the view. */
- (void)mouseDragged:(NSEvent *)theEvent {
    NSPoint local_point = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    if ( [self.boundingFrame containsPoint:local_point] ) {
        NSLog(@"%@", NSStringFromPoint(local_point));
    }
//    NSAffineTransform *dragTransform = [NSAffineTransform transform];
//    float xRange, yRange;
//    if (local_point.x <= 25 ) {
//        xRange = 25;
//    } else if (local_point.x >= 295)
//    {
//        xRange = 295;
//    }
//    if (local_point.y != 15 ) {
//        yRange = 15;
//    }
//    NSLog(@"%@", NSStringFromPoint(NSMakePoint(xRange, yRange)));
//    [dragTransform translateXBy:xRange yBy:yRange];
//    [self.boundingFrame transformUsingAffineTransform:dragTransform];
//    [[NSColor redColor] set];
//    [self.boundingFrame setLineWidth:2.0];
//    [self.boundingFrame stroke];
//    
//    [[NSColor lightGrayColor] set];
//    [self.boundingFrame fill];
}

/* clear the dragging flag once the mouse is released. */
- (void)mouseUp:(NSEvent *)theEvent {
    
	[self setDraggingIndicator: NO];
}

#pragma Extra Method
- (NSData *)adjustHistogramValueOfData:(NSData *)data withHistogramChannel:(kOTHistogram_Channel)histogramChannel withValue:(float)floatValue
{
    float maxFloatValue = 255;
    float minFloatValue = 0;
    if (floatValue > maxFloatValue) {
        floatValue = maxFloatValue;
    } else if (floatValue < minFloatValue) {
        floatValue = minFloatValue;
    }
    CIImage *iImage = [CIImage imageWithData:data];
    CIFilter *filter1;
    NSNumber *intensityValue = [NSNumber numberWithFloat:(1 - (float)floatValue / 255)];
    CIColor *iColor;
    switch (histogramChannel) {
        case  kOTHistogramChannel_Red: //Red
            filter1 = [CIFilter filterWithName:@"CIColorMonochrome"];
            [filter1 setValue:iImage forKey:@"inputImage"];
            iColor = [CIColor colorWithRed:0.0f green:1.0f blue:1.0f];
            [filter1 setValue:iColor forKey:@"inputColor"];
            [filter1 setValue:intensityValue forKey:@"inputIntensity"];
            break;
            
        case  kOTHistogramChannel_Green: //Green
            filter1 = [CIFilter filterWithName:@"CIColorMonochrome"];
            [filter1 setValue:iImage forKey:@"inputImage"];
            iColor = [CIColor colorWithRed:1.0f green:0.0f blue:1.0f];
            [filter1 setValue:iColor forKey:@"inputColor"];
            [filter1 setValue:intensityValue forKey:@"inputIntensity"];
            break;
            
        case  kOTHistogramChannel_Blue: //Blue
            filter1 = [CIFilter filterWithName:@"CIColorMonochrome"];
            [filter1 setValue:iImage forKey:@"inputImage"];
            iColor = [CIColor colorWithRed:1.0f green:1.0f blue:0.0f];
            [filter1 setValue:iColor forKey:@"inputColor"];
            [filter1 setValue:intensityValue forKey:@"inputIntensity"];
            break;
            
        default: //RGB
            filter1 = [CIFilter filterWithName:@"CIColorControls"];
            [filter1 setValue:iImage forKey:@"inputImage"];
             NSNumber *powerValue = [NSNumber numberWithFloat:(((float)floatValue/255) - 1)];
            NSLog(@"value :%@", powerValue);
            [filter1 setValue:powerValue forKey:@"inputBrightness"];
            
            [filter1 setValue:[[[filter1 attributes]
                                objectForKey: @"inputContrast"]
                               objectForKey: @"CIAttributeIdentity"]
                       forKey: @"inputContrast"];
            [filter1 setValue:[[[filter1 attributes]
                                objectForKey: @"inputSaturation"]
                               objectForKey: @"CIAttributeIdentity"]
                       forKey: @"inputSaturation"];
            break;
    }
    NSBitmapImageRep *bmprep = [[[NSBitmapImageRep alloc] initWithCIImage:[filter1 valueForKey:@"outputImage"]]autorelease];
    return [bmprep representationUsingType:NSJPEGFileType properties:nil];
}

- (NSColor*) getPixelColorAtLocation:(CGPoint)point withCGImage:(CGImageRef)cgImage
{
	NSColor *color = nil;
//	CGImageRef inImage = cgImage;
	// Create off screen bitmap context to draw the image into. Format ARGB is 4 bytes for each pixel: Alpa, Red, Green, Blue
    
	CGContextRef cgctx  = CGBitmapContextCreate( nil, CGImageGetWidth(cgImage), CGImageGetHeight(cgImage), 8, CGImageGetWidth(cgImage) * 4, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedFirst);//[self createARGBBimapContextFromImage:inImage];
	if (cgctx == NULL) { return nil; /* error */ }
    
    size_t w = CGImageGetWidth(cgImage);
	size_t h = CGImageGetHeight(cgImage);
	CGRect rect = {{0,0}, {w,h}};
    
	// Draw the image to the bitmap context. Once we draw, the memory
	// allocated for the context for rendering will then contain the
	// raw image data in the specified color space.
	CGContextDrawImage(cgctx, rect, cgImage);
    
	// Now we can get a pointer to the image data associated with the bitmap
	// context.
//	unsigned char* data = CGBitmapContextGetData (cgctx);
    unsigned char* data = (NSData*) CGDataProviderCopyData(CGImageGetDataProvider(cgImage));
	if (data != NULL) {
		//offset locates the pixel in the data from x,y.
		//4 for 4 bytes of data per pixel, w is width of one row of data.
		int offset = 4 * ((w * round(point.y)) + round(point.x));
		int alpha =  data[offset];
		int red = data[offset + 1];
		int green = data[offset + 2];
		int blue = data[offset + 3];
		NSLog(@"offset: %i colors: RGB A %i %i %i  %i", offset, red, green, blue, alpha);
		color = [NSColor colorWithCalibratedRed:(red / 255.0f) green:(green / 255.0f) blue:(blue / 255.0f) alpha:(alpha / 255.0f)];
	}
	// When finished, release the context
	CGContextRelease(cgctx);
	// Free image data memory for the context
	if (data) { free(data); }
    
	return color;
}

- (CGContextRef) createARGBBitmapContextFromImage:(CGImageRef) inImage
{
	
	CGContextRef    context = NULL;
	CGColorSpaceRef colorSpace;
	void *          bitmapData;
	int             bitmapByteCount;
	int             bitmapBytesPerRow;
	
	// Get image width, height. We'll use the entire image.
	size_t pixelsWide = CGImageGetWidth(inImage);
	size_t pixelsHigh = CGImageGetHeight(inImage);
	
	// Declare the number of bytes per row. Each pixel in the bitmap in this
	// example is represented by 4 bytes; 8 bits each of red, green, blue, and
	// alpha.
	bitmapBytesPerRow   = (int)(pixelsWide * 4);
	bitmapByteCount     = (int)(bitmapBytesPerRow * pixelsHigh);
	
	// Use the generic RGB color space.
	colorSpace = CGColorSpaceCreateDeviceRGB();
    
	if (colorSpace == NULL)
	{
		fprintf(stderr, "Error allocating color space\n");
		return NULL;
	}
	
	// Allocate memory for image data. This is the destination in memory
	// where any drawing to the bitmap context will be rendered.
	bitmapData = malloc( bitmapByteCount );
	if (bitmapData == NULL)
	{
		fprintf (stderr, "Memory not allocated!");
		CGColorSpaceRelease( colorSpace );
		return NULL;
	}
	
	// Create the bitmap context. We want pre-multiplied ARGB, 8-bits
	// per component. Regardless of what the source image format is
	// (CMYK, Grayscale, and so on) it will be converted over to the format
	// specified here by CGBitmapContextCreate.
	context = CGBitmapContextCreate (bitmapData,
									 pixelsWide,
									 pixelsHigh,
									 8,      // bits per component
									 bitmapBytesPerRow,
									 colorSpace,
									 kCGImageAlphaPremultipliedFirst);
	if (context == NULL)
	{
		free (bitmapData);
		fprintf (stderr, "Context not created!");
	}
	
	// Make sure and release colorspace before returning
	CGColorSpaceRelease( colorSpace );
	
	return context;
}


- (void)setColorForDictionary:(NSColor *)color forRedDictionary:(NSMutableDictionary *)mtRedDictionary forGreenDictionary:(NSMutableDictionary *)mtGreenDictionary forBlueDictionary:(NSMutableDictionary *)mtBlueDictionary
{
    double redFloatValue, greenFloatValue, blueFloatValue;
    [color getRed:&redFloatValue green:&greenFloatValue blue:&blueFloatValue alpha:NULL];
    int redIntValue, greenIntValue, blueIntValue;
    redIntValue = redFloatValue * 255.99999f;
    greenIntValue = greenFloatValue * 255.99999f;
    blueIntValue = blueFloatValue * 255.99999f;
    //    NSLog(@"R: %d, G: %d, B: %d", redIntValue, greenIntValue, blueIntValue);
    
    NSString *tmpRedStringValue = [mtRedDictionary objectForKey:[NSString stringWithFormat:@"%d", redIntValue]];
    int tmpRedValue = [tmpRedStringValue intValue];
    tmpRedValue++;
    if (tmpRedValue > maxRedValue) {
        maxRedValue = tmpRedValue;
    }
    [mtRedDictionary setObject:[NSString stringWithFormat:@"%d", tmpRedValue] forKey:[NSString stringWithFormat:@"%d", redIntValue]];
    
    NSString *tmpGreenStringValue = [mtGreenDictionary objectForKey:[NSString stringWithFormat:@"%d", greenIntValue]];
    int tmpGreenValue = [tmpGreenStringValue intValue];
    tmpGreenValue++;
    if (tmpGreenValue > maxGreenValue) {
        maxGreenValue = tmpGreenValue;
    }
    [mtGreenDictionary setObject:[NSString stringWithFormat:@"%d", tmpGreenValue] forKey:[NSString stringWithFormat:@"%d", greenIntValue]];
    
    
    NSString *tmpBlueStringValue = [mtBlueDictionary objectForKey:[NSString stringWithFormat:@"%d", blueIntValue]];
    int tmpBlueValue = [tmpBlueStringValue intValue];
    tmpBlueValue++;
    if (tmpBlueValue > maxBlueValue) {
        maxBlueValue = tmpBlueValue;
    }
    [mtBlueDictionary setObject:[NSString stringWithFormat:@"%d", tmpBlueValue] forKey:[NSString stringWithFormat:@"%d", blueIntValue]];
}

- (NSMutableDictionary *)saveToGammaDictionary:(NSMutableDictionary *)mtRedDictionary withGreenDictionary:(NSMutableDictionary *)mtGreenDictionary withBlueDictionary:(NSMutableDictionary *)mtBlueDictionary
{
    NSMutableDictionary *mutGammaDictionary = [NSMutableDictionary dictionary];
    for (int i = 0 ; i < 256 ; i++) {
        NSString *tmpRedStringValue = [mtRedDictionary objectForKey:[NSString stringWithFormat:@"%d", i]];
        int tmpRedValue = [tmpRedStringValue intValue];
        
        NSString *tmpGreenStringValue = [mtGreenDictionary objectForKey:[NSString stringWithFormat:@"%d", i]];
        int tmpGreenValue = [tmpGreenStringValue intValue];
        
        
        NSString *tmpBlueStringValue = [mtBlueDictionary objectForKey:[NSString stringWithFormat:@"%d", i]];
        int tmpBlueValue = [tmpBlueStringValue intValue];
        
        int tmpSum = tmpRedValue + tmpGreenValue + tmpBlueValue;
        if (tmpSum > maxGammaValue) {
            maxGammaValue = tmpSum;
        }
        
        [mutGammaDictionary setObject:[NSString stringWithFormat:@"%d", tmpSum] forKey:[NSString stringWithFormat:@"%d", i]];
    }
    return mutGammaDictionary;
}

@end
