//
//  AppDelegate.m
//  OTHistogram
//
//  Created by Eric Yeh on 12/11/2.
//  Copyright (c) 2012年 Ortery Technologies, Inc. All rights reserved.
//

#import "AppDelegate.h"
#define BEST_BYTE_ALIGNMENT 16
#define COMPUTE_BEST_BYTES_PER_ROW(bpr)		( ( (bpr) + (BEST_BYTE_ALIGNMENT-1) ) & ~(BEST_BYTE_ALIGNMENT-1) )

#pragma MainCode
@implementation AppDelegate
//NSImageView
@synthesize oriImage, dstImage, tmpImage;
@synthesize modePopUpButton, layerButton;
@synthesize histogramLayer;
@synthesize histogramDataInfo;

- (void)dealloc
{
    [histogramDataInfo release];
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    NSImage *nImage = [[NSImage alloc]initByReferencingFile:@"/Users/Eric/Pictures/lion-256height.jpg"];
    self.oriImage.image = nImage;
//    [cpView setImageForHistogram:self.oriImage.image withHistogramChannel:kOTHistogramChannel_Gamma];
    [nImage release];
    [self drawImageToTmpImageview];
    
    CALayer *layer2 = [CALayer layer];
    layer2.needsDisplayOnBoundsChange = YES;
    layer2.frame = CGRectMake(0, 0, 200, 200);
    [self.dstImage.layer addSublayer:layer2];
    histogramDataInfo = [[HistogramData alloc]init];
    histogramDataInfo.delegate = self;
    
//    [self.layerButton addItemWithTitle:[[histogramLayer.layer sublayers] ];
    for (int i = 0; i < [[histogramLayer.layer sublayers] count]; i++) {
        CALayer *tmpLayer =[[histogramLayer.layer sublayers] objectAtIndex:i];
        NSString *name = [tmpLayer name];
        [self.layerButton addItemWithTitle: name];
        [self.layerButton itemAtIndex:i].tag = i;
    }
}


//- (void)drawInContext:(CGContextRef)context
//{
//    [super drawInContext:context];
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    CGColorRef aColor = CGColorCreateFromNSColor([NSColor redColor], colorSpace);
//    CGColorRef bColor = CGColorCreateFromNSColor([NSColor blackColor], colorSpace);
//
//    CGContextAddRect(context, CGRectMake(10, 10, 100, 100));
//    CGContextSetFillColorWithColor(context, aColor); //內容色
//    
//    CGContextSetLineWidth(context, 10);
//    CGContextSetStrokeColorWithColor(context, bColor); //線色
//    CGContextDrawPath(context, kCGPathFillStroke);
//}
//- (void)drawLayer:(CALayer *)theLayer
//        inContext:(CGContextRef)theContext
//{
//    CGMutablePathRef thePath = CGPathCreateMutable();
//    
//    CGPathMoveToPoint(thePath,NULL,15.0f,15.f);
//    CGPathAddCurveToPoint(thePath,
//                          NULL,
//                          15.f,250.0f,
//                          295.0f,250.0f,
//                          295.0f,15.0f);
//    
//    CGContextBeginPath(theContext);
//    CGContextAddPath(theContext, thePath );
//    
//    CGContextSetLineWidth(theContext,
//                          [[theLayer valueForKey:@"lineWidth"] floatValue]);
//    CGContextStrokePath(theContext);
//    
//    // release the path
//    CFRelease(thePath);
//}
void drawStrokedAndFilledRects(CGContextRef context)
{
	// Make a CGRect that has its origin at (40,40)
	// with a width of 130 units and height of 100 units.
	CGRect ourRect = CGRectMake(10, 10, 130, 100);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef aColor = CGColorCreateFromNSColor([NSColor redColor], colorSpace);
    CGColorRef bColor = CGColorCreateFromNSColor([NSColor blackColor], colorSpace);
    
	// Set the fill color to an opaque blue.
	CGContextSetFillColorWithColor(context, bColor);
	// Fill the rect.
	CGContextFillRect(context, ourRect);
    
	// Set the stroke color to an opaque green.
	CGContextSetStrokeColorWithColor(context, aColor);
	// Stroke the rect with a line width of 10 units.
	CGContextStrokeRectWithWidth(context, ourRect, 10);
    
	// Save the current graphics state.
	CGContextSaveGState(context);
    // Translate the coordinate system origin to the right
    // by 200 units.
    CGContextTranslateCTM(context, 200, 0);
    // Stroke the rect with a line width of 10 units.
    CGContextStrokeRectWithWidth(context, ourRect, 10);
    // Fill the rect.
    CGContextFillRect(context, ourRect);
	// Restore the graphics state to the previously saved
	// graphics state. This restores all graphics state
	// parameters to those in effect during the last call
	// to CGContextSaveGState. In this example that restores
	// the coordinate system to that in effect prior to the
	// call to CGContextTranslateCTM.
	CGContextRestoreGState(context);
}

- (IBAction)changeBackgroundColor:(id)sender
{
//    self.dstImage.image.backgroundColor = [NSColor clearColor];
//    NSImage *nImage = [[NSImage alloc]initByReferencingFile:@"/Users/Eric/Pictures/ebay.png"];
//    self.dstImage.image = nImage;
//    [nImage release];
    float dpi = 72;
    size_t width = 15 * dpi, height = 15 * dpi, bitsPerComponent = 8, numComps = 4;
    // Compute the minimum number of bytes in a given scanline.
    size_t bytesPerRow = width* bitsPerComponent/8 * numComps;
    
    // This bitmapInfo value specifies that we want the format where alpha is
    // premultiplied and is the last of the components. We use this to produce
    // RGBA data.
    CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedLast;
    
    // Round to nearest multiple of BEST_BYTE_ALIGNMENT for optimal performance.
    bytesPerRow = COMPUTE_BEST_BYTES_PER_ROW(bytesPerRow);
    
    // Allocate the data for the bitmap.
    char *data = malloc( bytesPerRow * height );
    
    // Create the bitmap context. Characterize the bitmap data with the
    // Generic RGB color space.
    CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    CGContextRef bitmapContext = CGBitmapContextCreate(
                                                       data, width, height, bitsPerComponent, bytesPerRow,
                                                       colorSpace, bitmapInfo);
    
    // Clear the destination bitmap so that it is completely transparent before
    // performing any drawing. This is appropriate for exporting PNG data or
    // other data formats that capture alpha data. If the destination output
    // format doesn't support alpha then a better choice would be to paint
    // to white.
    CGContextClearRect( bitmapContext, CGRectMake(0, 0, width, height) );
    
    // Scale the coordinate system so that 72 units are dpi pixels.
    CGContextScaleCTM( bitmapContext, dpi/72, dpi/72 );
    
    // Perform the requested drawing.
    drawStrokedAndFilledRects(bitmapContext);
    
    // Create a CGImage object from the drawing performed to the bitmapContext.
    CGImageRef image = CGBitmapContextCreateImage(bitmapContext);
    
    // Release the bitmap context object and free the associated raster memory.
    CGContextRelease(bitmapContext);
    free(data);

    [self.dstImage.superview setWantsLayer:YES];    
    CALayer *layer2 = [CALayer layer];
    layer2.frame = CGRectMake(0, 0, 200, 200);
    layer2.contents = (id)image;
    [self.dstImage.layer addSublayer:layer2];
}

- (IBAction)saveImageTo:(id)sender
{

    HistogramData *data = [[HistogramData alloc] init];
    [data setImageForHistogram:self.oriImage.image toSize:NSMakeSize(640, 480)];
    [data drawHistogram:kOTHistogramChannel_Blue];
    [data release];
/*
    [self.dstImage.superview setWantsLayer:YES];
    CALayer *layer1 = [CALayer layer];
    layer1.frame = CGRectMake(20, 15, 40, 40);
    layer1.contents = self.oriImage.image;
    [layer1 setPosition:CGPointMake(60, 60)];
    [self.dstImage.layer addSublayer:layer1];
*/

    //    CGContextSetRGBStrokeColor(borderContext, 0.0f, 0.0f, 0.0f, 1.0f);
    //    CGContextAddRect(borderContext, CGRectMake(30 + borderXOffset , 30 + borderYOffset, 260, 100 + borderYRedeem));
//    [self drawStars:borderContext];

    
//     NSBitmapImageRep *bmprep = [[self.oriImage.image representations] objectAtIndex:0];
//    CALayer *layer1 = [CALayer layer];
//    layer1.frame = CGRectMake(0, 0, 10, 10);
//    layer1.contents = self.oriImage.image;
//    [self.dstImage.layer addSublayer:layer1];
//
//
//    CALayer *layer2 = [CALayer layer];
//    layer2.frame = CGRectMake(10, 10, 40, 40);
//    layer2.contents = (id) bmprep.CGImage;
//    [self.dstImage.layer addSublayer:layer2];
}

- (IBAction)openImageFrom:(id)sender
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseFiles:YES];
    [openPanel setCanChooseDirectories:YES];
    NSString *initPath = @"/Users/Eric/Pictures/PNGTest/";
    [openPanel setDirectoryURL:[NSURL fileURLWithPath:initPath]];
    [openPanel setAllowsMultipleSelection:NO];
    [openPanel setAllowedFileTypes:[NSArray arrayWithObject:@"jpg"]];
    if ([openPanel runModal] == NSOKButton)
    {
        for (NSURL *fileURL in [openPanel URLs])
        {
            NSString *strPath = [fileURL path];
            self.oriImage.image = [[[NSImage alloc] initWithContentsOfFile:strPath] autorelease];
            [self drawImageToTmpImageview];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                NSBitmapImageRep *bmprep = [[self.oriImage.image representations] objectAtIndex:0];
                NSData *jpegData = [bmprep representationUsingType: NSPNGFileType properties: nil];
                self.dstImage.image = [[[NSImage alloc]initWithData:jpegData]autorelease];
                [jpegData writeToFile:@"/Users/Eric/Pictures/PNGTest/999.png" atomically:NO];
            });
        }
    }
}

- (IBAction)readHistogramData:(id)sender
{
    //[histogramDataInfo setImageForHistogram:self.oriImage.image toSize:NSMakeSize(640, 480)];
        NSBitmapImageRep *bitmapRep = [[[NSBitmapImageRep alloc] initWithData:[self.oriImage.image TIFFRepresentation]]autorelease];
//    [histogramDataInfo setHistogramData:bitmapRep];
//    [histogramDataInfo drawHistogram:kOTHistogramChannel_Gamma];
    
//    [histogramDataInfo setHistogramDataToLayer:histogramLayer withChannel:kOTHistogramChannel_Blue];
    [histogramDataInfo setHistogramData:bitmapRep withLayer:histogramLayer];
}

- (IBAction)drawHistogram:(id)sender
{

    CALayer *tmpLayer = [[histogramLayer.layer sublayers] objectAtIndex:[[self.layerButton selectedItem] tag]];
//    [self changeHistogram:nil];
//    [histogramDataInfo drawHistogram:kOTHistogramChannel_Gamma];
    [histogramLayer changeLayerPosition:tmpLayer withPosition:CGPointMake(70, 70)];
}

- (IBAction)changeHistogram:(id)sender
{
    switch ([[self.modePopUpButton selectedItem] tag]) {
        case 1: //Red
            [histogramDataInfo drawHistogram:kOTHistogramChannel_Red];
            break;

        case 2: //Green
            [histogramDataInfo drawHistogram:kOTHistogramChannel_Green];
            break;

        case 3: //Blue
            [histogramDataInfo drawHistogram:kOTHistogramChannel_Blue];
            break;

        default: //RGB
            [histogramDataInfo drawHistogram:kOTHistogramChannel_Gamma];
            break;
    }

    
//    switch ([[self.modePopUpButton selectedItem] tag]) {
//        case 1: //Red
//            [cpView selectHistogramChannel: kOTHistogramChannel_Red];
//            break;
//            
//        case 2: //Green
//            [cpView selectHistogramChannel: kOTHistogramChannel_Green];
//            break;
//            
//        case 3: //Blue
//            [cpView selectHistogramChannel: kOTHistogramChannel_Blue];
//            break;
//            
//        default: //RGB
//            [cpView selectHistogramChannel: kOTHistogramChannel_Gamma];
//            break;
//    }
}

- (IBAction)changeSliderValue:(id)sender
{
    int modeButtonIndex = (int)[[self.modePopUpButton selectedItem] tag];
    float sliderFloatValue = [sender floatValue];
    kOTHistogram_Channel histogramChannel;
    switch (modeButtonIndex) {
        case 1: //Red
            histogramChannel =  kOTHistogramChannel_Red;
            break;
            
        case 2: //Green
            histogramChannel =  kOTHistogramChannel_Green;
            break;
            
        case 3: //Blue
            histogramChannel =  kOTHistogramChannel_Blue;
            break;
            
        default: //RGB
            histogramChannel =  kOTHistogramChannel_Gamma;
            
            break;
    }
    [histogramDataInfo adjustHistogramValueForData:[self.tmpImage.image TIFFRepresentation] withHistogramChannel:histogramChannel withValue:sliderFloatValue];
//    self.dstImage.image = [[[NSImage alloc] initWithData:[cpView adjustHistogramValueOfData:[self.tmpImage.image TIFFRepresentation] withHistogramChannel:histogramChannel withValue:sliderFloatValue]]autorelease];
}

#pragma Private Method
- (void)drawImageToTmpImageview
{
    NSImage *tempImage = [[NSImage alloc] initWithSize:NSMakeSize(self.tmpImage.frame.size.width, self.tmpImage.frame.size.height)];
    [tempImage lockFocus];
    [self.oriImage.image drawInRect:NSMakeRect(0, 0, 320, 240)  fromRect:NSMakeRect(0, 0, self.oriImage.image.size.width, self.oriImage.image.size.height) operation:NSCompositeSourceOver fraction:1.0];
    [tempImage unlockFocus];
    self.tmpImage.image = tempImage;
    [tempImage release];
}




- (void)drawInContext:(CGContextRef)context
{
    //    [super drawInContext:context];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef aColor = CGColorCreateFromNSColor([NSColor redColor], colorSpace);
    CGColorRef bColor = CGColorCreateFromNSColor([NSColor blackColor], colorSpace);
    
    CGContextAddRect(context, CGRectMake(10, 10, 100, 100));
    CGContextSetFillColorWithColor(context, aColor); //內容色
    
    CGContextSetLineWidth(context, 10);
    CGContextSetStrokeColorWithColor(context, bColor); //線色
    CGContextDrawPath(context, kCGPathFillStroke);
}
@end

