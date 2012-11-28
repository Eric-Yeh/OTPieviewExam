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
    int histogramLayerIndex;
}
@property (assign) id dataSource;
@property (nonatomic, readwrite, copy) NSDictionary *gammaDictionary;
@property (nonatomic, readwrite, copy) NSDictionary *redDictionary;
@property (nonatomic, readwrite, copy) NSDictionary *greenDictionary;
@property (nonatomic, readwrite, copy) NSDictionary *blueDictionary;
@end

@implementation HistogramData
@synthesize dataSource;
@synthesize gammaDictionary, redDictionary, greenDictionary, blueDictionary;
@synthesize delegate;


- (id)init
{
    if (self = [super init]) {
        // Initialization code here.
        self.gammaDictionary = [NSMutableDictionary dictionary];
        self.redDictionary = [NSMutableDictionary dictionary];
        self.greenDictionary = [NSMutableDictionary dictionary];
        self.blueDictionary = [NSMutableDictionary dictionary];
        maxGammaValue = 0, maxRedValue = 0, maxGreenValue = 0, maxBlueValue = 0;
        self.delegate = self;
    }
    return self;
}

- (void)dealloc {
    [gammaDictionary release]; gammaDictionary = nil;
    [redDictionary release]; redDictionary = nil;
    [greenDictionary release]; greenDictionary = nil;
    [blueDictionary release]; blueDictionary = nil;
	[super dealloc];
}
#pragma mark work with Delegate
- (void)_dataInfoToDrawLayer:(HistogramLayerDrawing *)drawLayer
{
    //用 Delegate 方式，讓每一層能被畫到
    histogramLayerIndex = 0 ;
    [self setHistogramDataToLayer:drawLayer withChannel:kOTHistogramChannel_Red];
}

- (void)histogramDrawingLayerFinish:(HistogramLayerDrawing *)drawLayer
{
    histogramLayerIndex++;
    switch (histogramLayerIndex) {
        case 1:
            [self setHistogramDataToLayer:drawLayer withChannel:kOTHistogramChannel_Green];
            break;
        case 2:
            [self setHistogramDataToLayer:drawLayer withChannel:kOTHistogramChannel_Blue];
            break;
        default:
            [self setHistogramDataToLayer:drawLayer withChannel:kOTHistogramChannel_Gamma];
            [drawLayer makesChannelVisible:kOTHistogramChannel_Gamma];
            break;
    }
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

#pragma mark get image color info
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
}


- (void)setHistogramData:(NSBitmapImageRep *)bmprep withLayer:(HistogramLayerDrawing *)drawLayer
{
    drawLayer.delegate = self.delegate;
    [self setHistogramData:bmprep];
    [self _dataInfoToDrawLayer:drawLayer];
}

- (void)setImageForHistogram:(NSImage *)image toSize:(NSSize)size withLayer:(HistogramLayerDrawing *)drawLayer
{
    drawLayer.delegate = self.delegate;
    //大張圖和小張圖的資訊是差不多，但小一點的圖計算比較快
    if (size.height <= 0 && size.width <= 0) {
        return;
    }
    NSSize newSize = NSMakeSize( image.size.width, image.size.height);
    if (image.size.width > size.width) {
        newSize.width =  size.width;
        newSize.height = image.size.height * size.width / image.size.width;
    }
    if (image.size.height > size.height) {
        newSize.height = size.height;
        newSize.width = image.size.width * size.height / image.size.height;
    }
    
    NSImage *reSizeImage = [[[NSImage alloc] initWithSize:NSMakeSize(newSize.width, newSize.height)] autorelease];
    //    NSLog(@"%f, %f", reSizeImage.size.width, reSizeImage.size.height);
    [reSizeImage lockFocus];
    [image drawInRect:NSMakeRect(0, 0, newSize.width, newSize.height) fromRect:NSMakeRect(0, 0, image.size.width, image.size.height) operation:NSCompositeSourceOver fraction:1.0f];
    [reSizeImage unlockFocus];
    NSBitmapImageRep *bitmapRep = [[[NSBitmapImageRep alloc] initWithData:[reSizeImage TIFFRepresentation]]autorelease];
    
    //把 reSizeImage 給資料端做運算
    [self setHistogramData:bitmapRep];
    [self _dataInfoToDrawLayer:drawLayer];
}

- (void)resizedImage:(NSBitmapImageRep *)bmprep toSize:(CGRect)thumbRect withLayer:(HistogramLayerDrawing *)drawLayer
{
    drawLayer.delegate = self.delegate;
    //等比例縮放
    NSSize newSize = NSMakeSize( bmprep.size.width, bmprep.size.height);
    if (thumbRect.size.width > thumbRect.size.width) {
        newSize.width =  thumbRect.size.width;
        newSize.height = bmprep.size.height * thumbRect.size.width / bmprep.size.width;
    }
    if (bmprep.size.height > thumbRect.size.height) {
        newSize.height = thumbRect.size.height;
        newSize.width = bmprep.size.width * thumbRect.size.height / bmprep.size.height;
    }
    
    CGImageRef imageRef = bmprep.CGImage;
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef);
    
    if (alphaInfo == kCGImageAlphaNone)
        alphaInfo = kCGImageAlphaPremultipliedLast;// kCGImageAlphaNoneSkipLast
    
    CGContextRef bitmap = CGBitmapContextCreate(
                                                NULL,
                                                thumbRect.size.width,
                                                thumbRect.size.height,
                                                CGImageGetBitsPerComponent(imageRef),
                                                4 * thumbRect.size.width, 
                                                CGImageGetColorSpace(imageRef),
                                                alphaInfo
                                                );
    
    CGContextDrawImage(bitmap, CGRectMake(thumbRect.origin.x, thumbRect.origin.y, thumbRect.size.width, thumbRect.size.height), imageRef);
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    NSImage *reSizeImage = [[[NSImage alloc] initWithCGImage:ref size:NSMakeSize(newSize.width, newSize.height)]autorelease];
    
    CGContextRelease(bitmap);
    CGImageRelease(ref);
    NSBitmapImageRep *bitmapRep = [[[NSBitmapImageRep alloc] initWithData:[reSizeImage TIFFRepresentation]]autorelease];
//    NSLog(@"%f %f", bitmapRep.size.width, bitmapRep.size.height);
    [self setHistogramData:bitmapRep];
    [self _dataInfoToDrawLayer:drawLayer];
}

- (NSBitmapImageRep *)adjustHistogramValueForImage:(NSBitmapImageRep *)bmprep withHistogramChannel:(kOTHistogram_Channel)histogramChannel withValue:(float)floatValue
{
    float maxFloatValue = 255;
    float minFloatValue = 0;
    if (floatValue > maxFloatValue) {
        floatValue = maxFloatValue;
    } else if (floatValue < minFloatValue) {
        floatValue = minFloatValue;
    }
    CIImage *iImage = [CIImage imageWithCGImage:bmprep.CGImage];
    CIFilter *filter1;
    NSNumber *intensityValue = [NSNumber numberWithFloat:(1 - (float)floatValue / maxFloatValue)];
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
            NSNumber *powerValue = [NSNumber numberWithFloat:(((float)floatValue/maxFloatValue) - 1)];
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
    NSBitmapImageRep *bmpOutImage = [[[NSBitmapImageRep alloc] initWithCIImage:[filter1 valueForKey:@"outputImage"]]autorelease];
    return bmpOutImage;
}

//- (void)sliderLayerValueChange:(float)value
//{
//    NSLog(@"%f", value);
//}

#pragma mark Private Method
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


@end
