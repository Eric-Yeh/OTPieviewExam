//
//  AppDelegate.m
//  OTHistogram
//
//  Created by Eric Yeh on 12/11/2.
//  Copyright (c) 2012年 Ortery Technologies, Inc. All rights reserved.
//

#import "AppDelegate.h"
#pragma Enhace NSColor

@interface NSColor(NSColorHexadecimalValue)
- (NSString *) hexadecimalValueOfAnNSColor;
+ (NSColor *) colorFromHexRGB:(NSString *) inColorString;
@end

@implementation NSColor(NSColorHexadecimalValue)

- (NSString *) hexadecimalValueOfAnNSColor
{
    double redFloatValue, greenFloatValue, blueFloatValue;
    int redIntValue, greenIntValue, blueIntValue;
    NSString *redHexValue, *greenHexValue, *blueHexValue;
    
    //Convert the NSColor to the RGB color space before we can access its components
    NSColor *convertedColor = [self colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    
    if(convertedColor)
    {
        // Get the red, green, and blue components of the color
        [convertedColor getRed:&redFloatValue green:&greenFloatValue blue:&blueFloatValue alpha:NULL];
        
        // Convert the components to numbers (unsigned decimal integer) between 0 and 255
        redIntValue = redFloatValue * 255.99999f;
        greenIntValue = greenFloatValue * 255.99999f;
        blueIntValue = blueFloatValue * 255.99999f;
        
        // Convert the numbers to hex strings
        redHexValue = [NSString stringWithFormat:@"%02x", redIntValue];
        greenHexValue = [NSString stringWithFormat:@"%02x", greenIntValue];
        blueHexValue = [NSString stringWithFormat:@"%02x", blueIntValue];
        
        // Concatenate the red, green, and blue components' hex strings together with a "#"
        return [NSString stringWithFormat:@"#%@%@%@", redHexValue, greenHexValue, blueHexValue];
    }
    return nil;
}
/// Html Color to NSColor
+ (NSColor *) colorFromHexRGB:(NSString *) inColorString
{
	NSColor *result = nil;
	unsigned int colorCode = 0;
	unsigned char redByte, greenByte, blueByte;
    
	if (nil != inColorString)
	{
		NSScanner *scanner = [NSScanner scannerWithString:inColorString];
		(void) [scanner scanHexInt:&colorCode];	// ignore error
	}
	redByte		= (unsigned char) (colorCode >> 16);
	greenByte	= (unsigned char) (colorCode >> 8);
	blueByte	= (unsigned char) (colorCode);	// masks off high bits
	result = [NSColor
              colorWithCalibratedRed:	(float)redByte	/ 0xff
              green:	(float)greenByte/ 0xff
              blue:	(float)blueByte	/ 0xff
              alpha:1.0];
	return result;
}
@end

#pragma MainCode
@implementation AppDelegate
//NSImageView
@synthesize oriImage, dstImage, tmpImage;

@synthesize modePopUpButton;

- (void)dealloc
{
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    NSImage *nImage = [[NSImage alloc]initByReferencingFile:@"/Users/Eric/Pictures/lion-256height.jpg"];
    self.oriImage.image = nImage;
    [cpView setImageForHistogram:self.oriImage.image withHistogramChannel:kOTHistogramChannel_Gamma];
    [nImage release];
    [self drawImageToTmpImageview];

}

- (IBAction)saveImageTo:(id)sender
{

    [self.dstImage.superview setWantsLayer:YES];
     NSBitmapImageRep *bmprep = [[self.oriImage.image representations] objectAtIndex:0];
    CALayer *layer1 = [CALayer layer];
    layer1.frame = CGRectMake(0, 0, 10, 10);
    layer1.contents = self.oriImage.image;
    [self.dstImage.layer addSublayer:layer1];


    CALayer *layer2 = [CALayer layer];
    layer2.frame = CGRectMake(10, 10, 40, 40);
    layer2.contents = (id) bmprep.CGImage;
    [self.dstImage.layer addSublayer:layer2];
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

- (IBAction)drawHistogram:(id)sender
{
    [self changeHistogram:nil];
}

- (IBAction)changeHistogram:(id)sender
{
    switch ([[self.modePopUpButton selectedItem] tag]) {
        case 1: //Red
            [cpView selectHistogramChannel: kOTHistogramChannel_Red];
            break;
            
        case 2: //Green
            [cpView selectHistogramChannel: kOTHistogramChannel_Green];
            break;
            
        case 3: //Blue
            [cpView selectHistogramChannel: kOTHistogramChannel_Blue];
            break;
            
        default: //RGB
            [cpView selectHistogramChannel: kOTHistogramChannel_Gamma];
            break;
    }
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
    self.dstImage.image = [[[NSImage alloc] initWithData:[cpView adjustHistogramValueOfData:[self.tmpImage.image TIFFRepresentation] withHistogramChannel:histogramChannel withValue:sliderFloatValue]]autorelease];
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

@end

