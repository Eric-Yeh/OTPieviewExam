//
//  HistogramLayer.m
//  OTPieViewExam
//
//  Created by Hank0272 on 12/11/14.
//  Copyright (c) 2012年 Ortery Technology, Inc. All rights reserved.
//

#import "HistogramLayer.h"
#define BEST_BYTE_ALIGNMENT 16
#define COMPUTE_BEST_BYTES_PER_ROW(bpr)		( ( (bpr) + (BEST_BYTE_ALIGNMENT-1) ) & ~(BEST_BYTE_ALIGNMENT-1) )
@interface HistogramLayer()
{
    NSDictionary *histogrameDictionary;
    CGImageRef borderCGImage, gammaCGImage, redCGImage, greenCGImage, blueCGImage, sliderCGImage;
    int maxValue;
    float borderXOffset, borderYOffset; //座標偏移，移動圖形用
    float borderYRedeem; //座標補償，主要是變高變長用
    BOOL draggingIndicator;
}
@property (nonatomic, copy) NSBezierPath *boundingFrame;
@property (nonatomic, readwrite, copy) NSDictionary *histogrameDictionary;
@property (assign) CGImageRef borderCGImage;
@property (assign) CGImageRef gammaCGImage;
@property (assign) CGImageRef redCGImage;
@property (assign) CGImageRef greenCGImage;
@property (assign) CGImageRef blueCGImage;
@property (assign) CGImageRef sliderCGImage;
@property (assign) kOTHistogram_Channel otHistogramChannel;
@property (assign) kOTHistogram_Layer otHistogramLayer;
@property (nonatomic) BOOL draggingIndicator;
@end

@implementation HistogramLayer
@synthesize boundingFrame;
@synthesize histogrameDictionary;
@synthesize borderCGImage, gammaCGImage, redCGImage, greenCGImage, blueCGImage, sliderCGImage;
@synthesize otHistogramChannel;
@synthesize otHistogramLayer;
@synthesize draggingIndicator;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        self.histogrameDictionary = [NSMutableDictionary dictionary];
        borderXOffset = 0.0, borderYOffset = 20.0; //座標偏移，移動圖形用
        borderYRedeem = 4.0; //座標補償，主要是變高變長用
        maxValue = 0;
    }
    
    return self;
}
/*
- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}
*/
- (NSImage *)drawAllyer
{
/*
    redCGImage = [self drawHistogramLayer:kOTHistogramLayer_Red withDictionary:nil withMaxValue:nil];
    greenCGImage = [self drawHistogramLayer:kOTHistogramLayer_Green withDictionary:nil withMaxValue:nil];
    blueCGImage = [self drawHistogramLayer:kOTHistogramLayer_Blue withDictionary:nil withMaxValue:nil];
    gammaCGImage = [self drawHistogramLayer:kOTHistogramLayer_Gamma withDictionary:nil withMaxValue:nil];
    sliderCGImage = [self drawHistogramLayer:kOTHistogramLayer_Slider withDictionary:nil withMaxValue:nil];
    borderCGImage = [self drawHistogramLayer:kOTHistogramLayer_Border withDictionary:nil withMaxValue:nil];
*/    
    NSView *view = [[[NSView alloc] init]autorelease];
    [view setWantsLayer:YES];
    CALayer *borderLayer = [CALayer layer];
    borderLayer.frame = CGRectMake(0, 0, 320, 160);
    borderLayer.contents = (id) borderCGImage;
    [view.layer addSublayer:borderLayer];
    
    NSImage *image = [[[NSImage alloc] initWithSize:NSMakeSize(320, 160)]autorelease];
    
    return image;
}

- (CGImageRef)drawHistogramLayer:(kOTHistogram_Layer)otHistogramLayer withDictionary:(NSDictionary *)dictionary withMaxValue:(int)value
{
    
    //大小要怎麼設定比較方便？因為每一層的大小會不同：Gamma, Red, Green, Blue同一類、Border、slider各成一類
    //位置調整是在 CALayer裡調？
    size_t width = 260, height = 104, bitsPerComponent = 8, numComps = 4;
    size_t bytesPerRow = width * bitsPerComponent / 8 * numComps;
    
    CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedLast;
    
    bytesPerRow = COMPUTE_BEST_BYTES_PER_ROW(bytesPerRow);

    char *data = malloc( bytesPerRow * height );
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    CGContextRef bitmapContext = CGBitmapContextCreate( data, width, height,
                                                       bitsPerComponent, bytesPerRow,
                                                       colorSpace, bitmapInfo);

    CGContextClearRect( bitmapContext, CGRectMake(0, 0, width, height) );
    
    CGContextScaleCTM( bitmapContext, 1, 1 );
/*
    switch (otHistogramLayer) {
        case kOTHistogramLayer_Red:
            [self drawHistogrameChannel:kOTHistogramChannel_Red withDictionary:dictionary withMaxValue:value withContext:bitmapContext];
            break;
        case kOTHistogramLayer_Green:
            [self drawHistogrameChannel:kOTHistogramChannel_Green withDictionary:dictionary withMaxValue:value withContext:bitmapContext];
            break;
        case kOTHistogramLayer_Blue:
            [self drawHistogrameChannel:kOTHistogramChannel_Green withDictionary:dictionary withMaxValue:value withContext:bitmapContext];
            break;
        case kOTHistogramLayer_Gamma:
            [self drawHistogrameChannel:kOTHistogramLayer_Gamma withDictionary:dictionary withMaxValue:value withContext:bitmapContext];
            break;
        case kOTHistogramLayer_Slider:
            [self drawSliderLayer:bitmapContext];
            break;
        default:
            [self drawBorderLayer:bitmapContext];
            break;
    }
*/ 
    CGImageRef imageLayer = CGBitmapContextCreateImage(bitmapContext);
    CGContextRelease(bitmapContext);
    free(data);
    return imageLayer;
}

- (void)drawHistogrameChannel:(kOTHistogram_Channel)histogramChannel withDictionary:(NSDictionary *)dictionary withMaxValue:(int)value withContext:(CGContextRef)context
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef channelColor = NULL;

    switch (histogramChannel) {
        case kOTHistogramChannel_Red:
            channelColor = CGColorCreateFromNSColor([NSColor redColor], colorSpace);
            break;
        case kOTHistogramChannel_Green:
            channelColor = CGColorCreateFromNSColor([NSColor greenColor], colorSpace);
            break;
        case kOTHistogramChannel_Blue:
            channelColor = CGColorCreateFromNSColor([NSColor blueColor], colorSpace);
            break;
        default:
            channelColor = CGColorCreateFromNSColor([NSColor grayColor], colorSpace);
            break;
    }
 
    CGContextSetLineWidth(context, 0.25); //線寬
    
    CGContextSetStrokeColorWithColor(context, channelColor); //線色
    CGContextSetLineCap(context, kCGLineCapRound); //線的接點
    for (int i = 0; i < 256; i++) {
        NSString *tmpColorStringValue = [self.histogrameDictionary objectForKey:[NSString stringWithFormat:@"%d", i]];
        int colorValue = [tmpColorStringValue intValue];
        value = ((float)colorValue / maxValue) * 100;
        //都從 (0,0) 開始畫，位置定義交給 CALayer
        CGContextMoveToPoint(context, i, value);
        CGContextAddLineToPoint(context, i, value);
        CGContextStrokePath(context);
    }
    CGContextClosePath(context);
	CGContextRestoreGState(context);
}

- (void)drawBorderLayer:(CGContextRef)context
{
    //底框
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef borderColor = CGColorCreateFromNSColor([NSColor blackColor], colorSpace);    
    CGContextAddRect(context, CGRectMake(30 + borderXOffset , 30 + borderYOffset, 260, 100 + borderYRedeem));
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context, borderColor); //線色
    CGContextStrokePath(context);
    CGContextClosePath(context);
	CGContextRestoreGState(context);
}

- (void)drawSliderLayer:(CGContextRef)context
{
    //三角型
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef borderColor = CGColorCreateFromNSColor([NSColor blackColor], colorSpace);
    
    CGContextSetLineWidth(context, 0.25); //線寬
    
    CGContextSetStrokeColorWithColor(context, borderColor); //線色
    CGContextSetFillColorWithColor(context, borderColor); //內容色
    CGContextSetLineCap(context, kCGLineCapRound); //線的接點
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, 5, 10);
    CGContextAddLineToPoint(context, 10, 0);
    CGContextSetStrokeColorWithColor(context, borderColor); //線色
    CGContextDrawPath(context, kCGPathFillStroke);
    CGContextStrokePath(context);
    CGContextClosePath(context);
	CGContextRestoreGState(context);
}

#pragma Private Method
/*
CGColorRef CGColorCreateFromNSColor(NSColor *color, CGColorSpaceRef colorSpace)
{
    NSColor *deviceColor = [color colorUsingColorSpaceName:NSDeviceRGBColorSpace];
    CGFloat components[4];
    [deviceColor getRed:&components[0] green:&components[1] blue:&components[2] alpha:&components[3]];
    
    return CGColorCreate (colorSpace, components);
}
*/
@end
