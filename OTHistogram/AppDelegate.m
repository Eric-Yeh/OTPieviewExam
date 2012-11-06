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
//Dictionary
@synthesize colorDictionary, redDictionary, greenDictionary, blueDictionary;

@synthesize modePopUpButton;

- (void)dealloc
{
    [colorDictionary release];
    [redDictionary release];
    [greenDictionary release];
    [blueDictionary release];
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    maxColorValue = 0, maxRedValue = 0, maxGreenValue = 0, maxBlueValue = 0;
    NSImage *nImage = [[NSImage alloc]initByReferencingFile:@"/Users/Eric/Pictures/lion-256height.jpg"];
    [self loadColorToDictionary];
    self.oriImage.image = nImage;
    [nImage release];
    [self drawImageToTmpImageview];
}

- (IBAction)saveImageTo:(id)sender
{
    self.tmpImage.image.backgroundColor = [NSColor blueColor];
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
                [self loadColorToDictionary];
                NSBitmapImageRep *bmprep = [[self.oriImage.image representations] objectAtIndex:0];
                NSData *jpegData = [bmprep representationUsingType: NSPNGFileType properties: nil];
                self.dstImage.image = [[[NSImage alloc]initWithData:jpegData]autorelease];
                [jpegData writeToFile:@"/Users/Eric/Pictures/PNGTest/999.png" atomically:NO];
            });
        }

    }

}

- (void)loadColorToDictionary
{
//    self.oriImage.image.backgroundColor = [NSColor redColor];
//    NSColor *color = [NSColor colorWithCalibratedRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
//    NSLog(@"Color %@", [color hexadecimalValueOfAnNSColor]);
//    self.oriImage.image.backgroundColor = [NSColor clearColor];
    //    NSLog(@"Color1: %@, Color2: %@", color, self.oriImage.image.backgroundColor);

//    NSColor *color = [NSColor colorWithCalibratedRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
    NSBitmapImageRep *bmprep = [[self.oriImage.image representations] objectAtIndex:0];
    NSColor *backColor = [bmprep colorAtX:0 y:0];
    NSColor *tmpColor;
    int iColorCount = 0;
    
    NSMutableDictionary *mutRedDictionary = [NSMutableDictionary dictionary];
    NSMutableDictionary *mutGreenDictionary = [NSMutableDictionary dictionary];
    NSMutableDictionary *mutBlueDictionary = [NSMutableDictionary dictionary];
    
    for (int i = 0 ; i < 256; i++) {
        [mutRedDictionary setObject:[NSString stringWithFormat:@"0"] forKey:[NSString stringWithFormat:@"%d", i]];
        [mutGreenDictionary setObject:[NSString stringWithFormat:@"0"] forKey:[NSString stringWithFormat:@"%d", i]];
        [mutBlueDictionary setObject:[NSString stringWithFormat:@"0"] forKey:[NSString stringWithFormat:@"%d", i]];
    }
    
//    NSLog(@"Red:%@, Green:%@, Blue:%@", mutRedDictionary, mutGreenDictionary, mutBlueDictionary);
    maxColorValue = 0, maxRedValue = 0, maxGreenValue = 0, maxBlueValue = 0;
    for (int y = 0 ; y < self.oriImage.image.size.height; y++) {
        for (int x = 0 ; x < self.oriImage.image.size.width; x++) {
            tmpColor = [bmprep colorAtX:x y:y];
            [self setColorForDictionary:tmpColor forRedDictionary:mutRedDictionary forGreenDictionary:mutGreenDictionary forBlueDictionary:mutBlueDictionary];
//            if ([backColor isEqual:tmpColor]) {
//                [bmprep setColor:[NSColor brownColor] atX:x y:y];
//                iColorCount++;
//            }
        }
    }
    redDictionary = [mutRedDictionary copy];
    greenDictionary = [mutGreenDictionary copy];
    blueDictionary = [mutBlueDictionary copy];
    colorDictionary = [[self saveToColorDictionary:mutRedDictionary withGreenDictionary:mutGreenDictionary withBlueDictionary:mutBlueDictionary] copy];
    
    //[cpView setDictionaryToDraw:colorDictionary withMaxValue:maxColorValue];
}

- (IBAction)drawHistogram:(id)sender
{

    [self changeHistogram:nil];
}

- (IBAction)changeHistogram:(id)sender
{
    if (maxColorValue == 0) {
        [self loadColorToDictionary];
    }
    int modeButtonIndex = (int)[[self.modePopUpButton selectedItem] tag];
//    NSLog(@"========\n Index: %d", modeButtonIndex);
    switch (modeButtonIndex) {
        case 1: //Red
            [cpView setDictionaryToDraw:redDictionary withMaxValue:maxRedValue withHistogramColor:kOTHistogramColor_Red];
            break;
            
        case 2: //Green
            [cpView setDictionaryToDraw:greenDictionary withMaxValue:maxGreenValue withHistogramColor:kOTHistogramColor_Green];
            break;
            
        case 3: //Blue
            [cpView setDictionaryToDraw:blueDictionary withMaxValue:maxBlueValue withHistogramColor:kOTHistogramColor_Blue];
            break;
            
        default: //RGB
            [cpView setDictionaryToDraw:colorDictionary withMaxValue:maxColorValue withHistogramColor:kOTHistogramColor_RGB];
            break;
    }

}

- (IBAction)changeSliderValue:(id)sender
{
    int modeButtonIndex = (int)[[self.modePopUpButton selectedItem] tag];
    float sliderFloatValue = [sender floatValue];
    CIImage *iImage = [CIImage imageWithData:[self.tmpImage.image TIFFRepresentation]];
    CIFilter *filter1;
    NSNumber *intensityValue = [NSNumber numberWithFloat:(1 - (float)sliderFloatValue/255)];
    CIColor *iColor;
    switch (modeButtonIndex) {
        case 1: //Red
            filter1 = [CIFilter filterWithName:@"CIColorMonochrome"];
            [filter1 setValue:iImage forKey:@"inputImage"];
            iColor = [CIColor colorWithRed:0.0f green:1.0f blue:1.0f];
            [filter1 setValue:iColor forKey:@"inputColor"];
            [filter1 setValue:intensityValue forKey:@"inputIntensity"];
            break;
            
        case 2: //Green
            filter1 = [CIFilter filterWithName:@"CIColorMonochrome"];
            [filter1 setValue:iImage forKey:@"inputImage"];
            iColor = [CIColor colorWithRed:1.0f green:0.0f blue:1.0f];
            [filter1 setValue:iColor forKey:@"inputColor"];
            [filter1 setValue:intensityValue forKey:@"inputIntensity"];
            break;
            
        case 3: //Blue
            filter1 = [CIFilter filterWithName:@"CIColorMonochrome"];
            [filter1 setValue:iImage forKey:@"inputImage"];
            iColor = [CIColor colorWithRed:1.0f green:1.0f blue:0.0f];
            [filter1 setValue:iColor forKey:@"inputColor"];
            [filter1 setValue:intensityValue forKey:@"inputIntensity"];
            break;
            
        default: //RGB
            filter1 = [CIFilter filterWithName:@"CIGammaAdjust"];
            [filter1 setValue:iImage forKey:@"inputImage"];
            NSNumber *powerValue = [NSNumber numberWithFloat:(4 - ((float)sliderFloatValue/255 * 4) + 0.75)];
            NSLog(@"number: %@", powerValue);
            [filter1 setValue:powerValue forKey:@"inputPower"];

            break;
    }
    NSBitmapImageRep *bmprep = [[NSBitmapImageRep alloc] initWithCIImage:[filter1 valueForKey:@"outputImage"]];
    self.dstImage.image = [[[NSImage alloc] initWithData:[bmprep representationUsingType:NSJPEGFileType properties:nil]]autorelease];
 
    [bmprep release];
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

- (NSMutableDictionary *)saveToColorDictionary:(NSMutableDictionary *)mtRedDictionary withGreenDictionary:(NSMutableDictionary *)mtGreenDictionary withBlueDictionary:(NSMutableDictionary *)mtBlueDictionary
{
    NSMutableDictionary *mutColorDictionary = [NSMutableDictionary dictionary];
    for (int i = 0 ; i < 256 ; i++) {
        NSString *tmpRedStringValue = [mtRedDictionary objectForKey:[NSString stringWithFormat:@"%d", i]];
        int tmpRedValue = [tmpRedStringValue intValue];
        
        NSString *tmpGreenStringValue = [mtGreenDictionary objectForKey:[NSString stringWithFormat:@"%d", i]];
        int tmpGreenValue = [tmpGreenStringValue intValue];

        
        NSString *tmpBlueStringValue = [mtBlueDictionary objectForKey:[NSString stringWithFormat:@"%d", i]];
        int tmpBlueValue = [tmpBlueStringValue intValue];
        
        int tmpSum = tmpRedValue + tmpGreenValue + tmpBlueValue;
        if (tmpSum > maxColorValue) {
            maxColorValue = tmpSum;
        }
        
        [mutColorDictionary setObject:[NSString stringWithFormat:@"%d", tmpSum] forKey:[NSString stringWithFormat:@"%d", i]];
    }
    return mutColorDictionary;
}

@end

