//
//  HistogramData.m
//  OTPieViewExam
//
//  Created by Hank0272 on 12/11/15.
//  Copyright (c) 2012年 Ortery Technology, Inc. All rights reserved.
//

#import "HistogramData.h"
@interface HistogramData ()
{
    NSDictionary *gammaDictionary, *redDictionary, *greenDictionary, *blueDictionary;
    int maxGammaValue, maxRedValue, maxGreenValue, maxBlueValue;
}
//@property (nonatomic, assign) HistogramLayerDrawing *layerDrawing;
@property (assign) id dataSource;
@property (nonatomic, readwrite, copy) NSDictionary *gammaDictionary;
@property (nonatomic, readwrite, copy) NSDictionary *redDictionary;
@property (nonatomic, readwrite, copy) NSDictionary *greenDictionary;
@property (nonatomic, readwrite, copy) NSDictionary *blueDictionary;
@end

@implementation HistogramData
//@synthesize layerDrawing;
@synthesize dataSource;
@synthesize gammaDictionary, redDictionary, greenDictionary, blueDictionary;
//@synthesize delegate = _delegate;

- (id)init
{
    if (self = [super init]) {
        // Initialization code here.
        self.gammaDictionary = [NSMutableDictionary dictionary];
        self.redDictionary = [NSMutableDictionary dictionary];
        self.greenDictionary = [NSMutableDictionary dictionary];
        self.blueDictionary = [NSMutableDictionary dictionary];
        maxGammaValue = 0, maxRedValue = 0, maxGreenValue = 0, maxBlueValue = 0;
//        self.layerDrawing = [[HistogramLayerDrawing alloc]init];
        
    }
    return self;
}

- (void)dealloc {
//    [layerDrawing release];
    [self.gammaDictionary release];
    [self.redDictionary release];
    [self.greenDictionary release];
    [self.blueDictionary release];
	[super dealloc];
}

- (void)drawHistogram:(kOTHistogram_Channel)channel
{
    NSDictionary *tmpDictionary;
    int tmpValue;
    switch (channel) {
        case kOTHistogramChannel_Red:
            tmpDictionary = [redDictionary copy];
            tmpValue = maxRedValue;
            break;
        case kOTHistogramChannel_Green:
            tmpDictionary = [greenDictionary copy];
            tmpValue = maxGreenValue;
            break;
        case kOTHistogramChannel_Blue:
            tmpDictionary = [blueDictionary copy];
            tmpValue = maxBlueValue;
            break;
        default:
            tmpDictionary = [gammaDictionary copy];
            tmpValue = maxGammaValue;
            break;
    }

//    [layerDrawing dataSourceForHistogramChannel:tmpDictionary withChannel:channel withMaxValue:tmpValue];


//    if ([self.delegate respondsToSelector:@selector(dataSourceForHistogramChannel:withChannel:withMaxValue:)]) {
//        [self.delegate dataSourceForHistogramChannel:tmpDictionary withChannel:channel withMaxValue:tmpValue];
//    }

}

- (void)setHistogramDataToLayer:(HistogramLayerDrawing *)layerDraw withChannel:(kOTHistogram_Channel)channel
{
    NSDictionary *tmpDictionary;
    int tmpValue;
    switch (channel) {
        case kOTHistogramChannel_Red:
            tmpDictionary = [redDictionary copy];
            tmpValue = maxRedValue;
            break;
        case kOTHistogramChannel_Green:
            tmpDictionary = [greenDictionary copy];
            tmpValue = maxGreenValue;
            break;
        case kOTHistogramChannel_Blue:
            tmpDictionary = [blueDictionary copy];
            tmpValue = maxBlueValue;
            break;
        default:
            tmpDictionary = [gammaDictionary copy];
            tmpValue = maxGammaValue;
            break;
    }

    [layerDraw drawHistogramLayer:channel withDictionary:tmpDictionary withMaxValue:tmpValue];
    [tmpDictionary release];
}

- (void)setImageForHistogram:(NSImage *)image toSize:(NSSize)size
{
    //大張圖和小張圖的資訊是差不多，但小一點的圖計算比較快
    if (size.height <= 0 && size.width <= 0) {
        return;
    }
    NSSize newSize;
    if (image.size.width > size.width) {
        newSize.width =  size.width;
        newSize.height = image.size.height * size.width / image.size.width;
    }
    if (image.size.height > size.height) {
        newSize.height = size.height;
        newSize.width = image.size.width * size.height / image.size.height;
    }
    
    NSImage *reSizeImage = [[NSImage alloc] initWithSize:NSMakeSize(newSize.width, newSize.height)];
    [reSizeImage lockFocus];
    [image drawInRect:NSMakeRect(0, 0, newSize.width, newSize.height) fromRect:NSMakeRect(0, 0, image.size.width, image.size.height) operation:NSCompositeSourceOver fraction:1.0f];
    [reSizeImage unlockFocus];
    NSBitmapImageRep *bitmapRep = [[[NSBitmapImageRep alloc] initWithData:[reSizeImage TIFFRepresentation]]autorelease];
    
    //把 reSizeImage 給資料端做運算
    [self setHistogramData:bitmapRep];
    
    [reSizeImage release];
}

- (void)setHistogramData:(NSBitmapImageRep *)bmprep withLayer:(HistogramLayerDrawing *)drawLayer
{
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
    for (int y = 0 ; y < bmprep.size.height; y++) {
        for (int x = 0 ; x < bmprep.size.width; x++) {
            tmpColor = [bmprep colorAtX:x y:y];

            [self setColorForDictionary:tmpColor forRedDictionary:mutRedDictionary forGreenDictionary:mutGreenDictionary forBlueDictionary:mutBlueDictionary];
        }
    }
    redDictionary = [mutRedDictionary copy];
    greenDictionary = [mutGreenDictionary copy];
    blueDictionary = [mutBlueDictionary copy];
    gammaDictionary = [[self saveToGammaDictionary:mutRedDictionary withGreenDictionary:mutGreenDictionary withBlueDictionary:mutBlueDictionary] copy];
    [self setHistogramDataToLayer:drawLayer withChannel:kOTHistogramChannel_Red];
    [self setHistogramDataToLayer:drawLayer withChannel:kOTHistogramChannel_Green];
    [self setHistogramDataToLayer:drawLayer withChannel:kOTHistogramChannel_Blue];
    [self setHistogramDataToLayer:drawLayer withChannel:kOTHistogramChannel_Gamma];
}

- (void)setHistogramData:(NSBitmapImageRep *)bmprep
{
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
    for (int y = 0 ; y < bmprep.size.height; y++) {
        for (int x = 0 ; x < bmprep.size.width; x++) {
            tmpColor = [bmprep colorAtX:x y:y];
            
            [self setColorForDictionary:tmpColor forRedDictionary:mutRedDictionary forGreenDictionary:mutGreenDictionary forBlueDictionary:mutBlueDictionary];
        }
    }
    redDictionary = [mutRedDictionary copy];
    greenDictionary = [mutGreenDictionary copy];
    blueDictionary = [mutBlueDictionary copy];
    gammaDictionary = [[self saveToGammaDictionary:mutRedDictionary withGreenDictionary:mutGreenDictionary withBlueDictionary:mutBlueDictionary] copy];

    
//    [self drawHistogram:kOTHistogramChannel_Red];
//    [self drawHistogram:kOTHistogramChannel_Green];
//    [self drawHistogram:kOTHistogramChannel_Blue];
//    [self drawHistogram:kOTHistogramChannel_Gamma];
    
//    [self selectHistogramChannel:histogramColor];
}


#pragma Private Method
- (void)setColorForDictionary:(NSColor *)color forRedDictionary:(NSMutableDictionary *)mtRedDictionary forGreenDictionary:(NSMutableDictionary *)mtGreenDictionary forBlueDictionary:(NSMutableDictionary *)mtBlueDictionary
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

- (NSData *)adjustHistogramValueForData:(NSData *)data withHistogramChannel:(kOTHistogram_Channel)histogramChannel withValue:(float)floatValue
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
    return [bmprep representationUsingType:NSPNGFileType properties:nil];
}

@end
