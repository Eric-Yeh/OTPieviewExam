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
    NSImage *nImage = [[NSImage alloc]initByReferencingFile:@"/Users/Eric/Pictures/PNGTest/11.png"];
    //    [self.oriImage setImage:nImage];
    self.oriImage.image = nImage;
    [nImage release];
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
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                [self loadColorToDictionary];
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

    NSColor *color = [NSColor colorWithCalibratedRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
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
    
    //    NSLog(@"%@, %@, %@", mutRedDictionary, mutGreenDictionary, mutBlueDictionary);
    maxColorValue = 0, maxRedValue = 0, maxGreenValue = 0, maxBlueValue = 0;
    for (int y = 0 ; y < self.oriImage.image.size.height; y++) {
        for (int x = 0 ; x < self.oriImage.image.size.width; x++) {
            tmpColor = [bmprep colorAtX:x y:y];
            [self setColorForDictionary:mutRedDictionary withGreenDictionary:mutGreenDictionary withBlueDictionary:mutBlueDictionary withColor:tmpColor];
            if ([backColor isEqual:tmpColor]) {
                [bmprep setColor:[NSColor brownColor] atX:x y:y];
                iColorCount++;
            }
        }
    }
    redDictionary = mutRedDictionary;
    greenDictionary = greenDictionary;
    blueDictionary = blueDictionary;
    colorDictionary = [self saveToColorDictionary:mutRedDictionary withGreenDictionary:mutGreenDictionary withBlueDictionary:mutBlueDictionary];
//    NSLog(@"%@", colorDictionary);
//    NSLog(@"maxValue: %d", maxColorValue);
    
    [cpView setDictionaryToDraw:colorDictionary withMaxValue:maxColorValue];
    
    //    NSLog(@"backColor1: %@, Color2: %@, count: %i", backColor, tmpColor, iColorCount);
    NSData *jpegData = [bmprep representationUsingType: NSPNGFileType properties: nil];
    self.dstImage.image = [[[NSImage alloc]initWithData:jpegData]autorelease];
    [jpegData writeToFile:@"/Users/Eric/Pictures/PNGTest/999.png" atomically:NO];
}

#pragma Private Method
- (void)setColorForDictionary:(NSMutableDictionary *)mtRedDictionary withGreenDictionary:(NSMutableDictionary *)mtGreenDictionary withBlueDictionary:(NSMutableDictionary *)mtBlueDictionary withColor:(NSColor *)color
{
    double redFloatValue, greenFloatValue, blueFloatValue;
    [color getRed:&redFloatValue green:&greenFloatValue blue:&blueFloatValue alpha:NULL];
    int redIntValue, greenIntValue, blueIntValue;
    redIntValue = redFloatValue * 255.99999f;
    greenIntValue = greenFloatValue * 255.99999f;
    blueIntValue = blueFloatValue * 255.99999f;
    
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

