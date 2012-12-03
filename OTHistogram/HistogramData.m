//
//  HistogramData.m
//  OTPieViewExam
//
//  Created by Hank0272 on 12/11/15.
//  Copyright (c) 2012年 Ortery Technology, Inc. All rights reserved.
//

#import "HistogramData.h"

@implementation HistogramData

@synthesize histogramDrawLayer;

- (id)initWithHistogramLayerDrawing:(HistogramLayerDrawing *)drawLayer
{
    if (self = [super init]) {
        histogramDrawLayer = drawLayer;
    }
    return self;
}

- (void)dealloc {
	[super dealloc];
}
#pragma mark work with Delegate
- (void)_dataInfoToDrawLayer
{
    [self setHistogramDataToChannel:kOTHistogramChannel_Red];
    [self setHistogramDataToChannel:kOTHistogramChannel_Green];
    [self setHistogramDataToChannel:kOTHistogramChannel_Blue];
    [self setHistogramDataToChannel:kOTHistogramChannel_Gamma];
    [histogramDrawLayer makesChannelVisible:kOTHistogramChannel_All];
}

- (void)setHistogramDataToChannel:(kOTHistogram_Channel)channel;
{
    [histogramDrawLayer drawHistogramLayer:channel];
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
    histogramDrawLayer.redDictionary = [mutRedDictionary copy];
    histogramDrawLayer.greenDictionary = [mutGreenDictionary copy];
    histogramDrawLayer.blueDictionary = [mutBlueDictionary copy];
    histogramDrawLayer.gammaDictionary = [[self saveToGammaDictionary:mutRedDictionary withGreenDictionary:mutGreenDictionary withBlueDictionary:mutBlueDictionary] copy];
    histogramDrawLayer.maxRedValue = maxRedValue;
    histogramDrawLayer.maxGreenValue = maxGreenValue;
    histogramDrawLayer.maxBlueValue = maxBlueValue;
    histogramDrawLayer.maxGammaValue = maxGammaValue;
}

- (void)resizedNSImage:(NSImage *)image toSize:(NSSize)size
{
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
    [reSizeImage lockFocus];
    [image drawInRect:NSMakeRect(0, 0, newSize.width, newSize.height) fromRect:NSMakeRect(0, 0, image.size.width, image.size.height) operation:NSCompositeSourceOver fraction:1.0f];
    [reSizeImage unlockFocus];
    NSBitmapImageRep *bitmapRep = [[[NSBitmapImageRep alloc] initWithData:[reSizeImage TIFFRepresentation]]autorelease];
    
//    NSLog(@"%f %f", bitmapRep.size.width, bitmapRep.size.height);
    //把 reSizeImage 給資料端做運算
    [self setHistogramData:bitmapRep];
    [self _dataInfoToDrawLayer];
}

- (void)resizedCGImage:(NSBitmapImageRep *)bmprep toSize:(CGRect)thumbRect
{
    if (thumbRect.size.height <= 0 && thumbRect.size.width <= 0) {
        return;
    }
    //等比例縮放
    NSSize newSize = NSMakeSize( bmprep.size.width, bmprep.size.height);
    if (bmprep.size.width > thumbRect.size.width) {
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
        alphaInfo = kCGImageAlphaNoneSkipLast;//kCGImageAlphaPremultipliedLast kCGImageAlphaNoneSkipLast
    
    CGContextRef bitmap = CGBitmapContextCreate(
                                                NULL,
                                                thumbRect.size.width,
                                                thumbRect.size.height,
                                                CGImageGetBitsPerComponent(imageRef),
                                                4 * thumbRect.size.width, 
                                                CGImageGetColorSpace(imageRef),
                                                alphaInfo
                                                );
    CGContextSetInterpolationQuality(bitmap, kCGInterpolationNone);//這麼威，不要弄就好了
    CGContextDrawImage(bitmap, CGRectMake(thumbRect.origin.x, thumbRect.origin.y, thumbRect.size.width, thumbRect.size.height), imageRef);
    
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    NSBitmapImageRep *bitmapRep = [[[NSBitmapImageRep alloc] initWithCGImage:ref]autorelease];
    CGContextRelease(bitmap);
    CGImageRelease(ref);

//    NSLog(@"%f %f", bitmapRep.size.width, bitmapRep.size.height);
    [self setHistogramData:bitmapRep];
    [self _dataInfoToDrawLayer];
}

- (NSBitmapImageRep *)adjustHistogramValueForImage:(NSBitmapImageRep *)bmprep withHistogramChannel:(kOTHistogram_Channel)histogramChannel withValue:(float)floatValue
{

    if (floatValue > kOT_SliderValue_MAX) {
        floatValue = kOT_SliderValue_MAX;
    } else if (floatValue < kOT_SliderValue_MIN) {
        floatValue = kOT_SliderValue_MIN;
    }
    CIImage *iImage = [CIImage imageWithCGImage:bmprep.CGImage];
    CIFilter *filter1;
    NSNumber *intensityValue = [NSNumber numberWithFloat:(1 - (float)floatValue / kOT_SliderValue_MAX)];
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
            NSNumber *powerValue = [NSNumber numberWithFloat:(((float)floatValue/kOT_SliderValue_MAX) - 1)];
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


#pragma mark Private Method
- (void)setColorForDictionary:(NSColor *)color forRedDictionary:(NSMutableDictionary *)mtRedDictionary forGreenDictionary:(NSMutableDictionary *)mtGreenDictionary forBlueDictionary:(NSMutableDictionary *)mtBlueDictionary
{
    float redFloatValue, greenFloatValue, blueFloatValue;
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
