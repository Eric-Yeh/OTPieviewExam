//
//  HistogramLayerDrawing.m
//  OTPieViewExam
//
//  Created by Hank0272 on 12/11/15.
//  Copyright (c) 2012年 Ortery Technology, Inc. All rights reserved.
//
//這是直接與 Layer 的 Delegate 配合使用 
#import "HistogramLayerDrawing.h"

@interface HistogramLayerDrawing ()
{
    CALayer *boraderLayer, *gammaLayer, *redLayer, *greenLayer, *blueLayer, *sliderLayer;
    kOTHistogram_Channel otHistogramChannel;
    kOTHistogram_Layer otHistogramLayer;
}
@property (nonatomic, readwrite, copy) NSDictionary *histogrameDictionary;
@property (nonatomic, readwrite, copy) CALayer *boraderLayer, *gammaLayer, *redLayer, *greenLayer, *blueLayer, *sliderLayer;
@property (assign) kOTHistogram_Channel otHistogramChannel;
@property (assign) kOTHistogram_Layer otHistogramLayer;
@end


@implementation HistogramLayerDrawing
@synthesize histogrameDictionary;
@synthesize boraderLayer, gammaLayer, redLayer, greenLayer, blueLayer, sliderLayer;
@synthesize otHistogramChannel;
@synthesize otHistogramLayer;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        boraderLayer = [[CALayer alloc]init];
        gammaLayer = [[CALayer alloc]init];
        redLayer = [[CALayer alloc]init];
        greenLayer = [[CALayer alloc]init];
        blueLayer = [[CALayer alloc]init];
        sliderLayer = [[CALayer alloc]init];
        [self setWantsLayer:YES];
        [self.layer setDelegate:self];
        [boraderLayer setDelegate:self];
        [gammaLayer setDelegate:self];
        [redLayer setDelegate:self];
        [greenLayer setDelegate:self];
        [blueLayer setDelegate:self];
        [sliderLayer setDelegate:self];
        [boraderLayer setNeedsDisplay];
        [gammaLayer setNeedsDisplay];
        [redLayer setNeedsDisplay];
        [greenLayer setNeedsDisplay];
        [blueLayer setNeedsDisplay];
        [sliderLayer setNeedsDisplay];
    }
    return self;
}

- (void)dealloc
{
    [boraderLayer release]; boraderLayer = nil;
    [gammaLayer release]; gammaLayer = nil;
    [redLayer release]; redLayer = nil;
    [greenLayer release]; greenLayer = nil;
    [blueLayer release]; blueLayer = nil;
    [sliderLayer release]; sliderLayer = nil;
    [super dealloc];
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}

- (void)drawAllLayer
{
    self.layer.frame = CGRectMake(30, 60, 260, 160);
    [self.layer addSublayer:boraderLayer];
    self.layer.frame = CGRectMake(30, 60, 260, 130);
    [self.layer addSublayer:redLayer];
    self.layer.frame = CGRectMake(30, 60, 260, 130);
    [self.layer addSublayer:greenLayer];
    self.layer.frame = CGRectMake(30, 60, 260, 130);
    [self.layer addSublayer:blueLayer];
    self.layer.frame = CGRectMake(30, 60, 260, 130);
    [self.layer addSublayer:gammaLayer];
    self.layer.frame = CGRectMake(30, 25, 12, 12);
    [self.layer addSublayer:sliderLayer];
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context
{
    //要如何接 Dictionary 的資料
    if (layer == redLayer) {
        [self drawHistogrameChannel:kOTHistogramChannel_Red withDictionary:histogrameDictionary withMaxValue:maxValue withContext:context];
    } else if (layer == greenLayer) {
        [self drawHistogrameChannel:kOTHistogramChannel_Green withDictionary:histogrameDictionary withMaxValue:maxValue withContext:context];
    } else if (layer == blueLayer) {
        [self drawHistogrameChannel:kOTHistogramChannel_Blue withDictionary:histogrameDictionary withMaxValue:maxValue withContext:context];
    } else if (layer == gammaLayer) {
        [self drawHistogrameChannel:kOTHistogramChannel_Gamma withDictionary:histogrameDictionary withMaxValue:maxValue withContext:context];
    } else if (layer == boraderLayer) {
        [self drawBorderLayer:context];
    } else if (layer == sliderLayer) {
        [self drawSliderLayer:context];
    }
}

- (void)drawHistogrameChannel:(kOTHistogram_Channel)histogramChannel withDictionary:(NSDictionary *)dictionary withMaxValue:(int)value withContext:(CGContextRef)context
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef channelColor;
    
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
    CGContextAddRect(context, CGRectMake(0 , 0, 260, 100));
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

static CGColorRef CGColorCreateFromNSColor(NSColor *color, CGColorSpaceRef colorSpace)
{
    NSColor *deviceColor = [color colorUsingColorSpaceName:NSDeviceRGBColorSpace];
    CGFloat components[4];
    [deviceColor getRed:&components[0] green:&components[1] blue:&components[2] alpha:&components[3]];
    
    return CGColorCreate (colorSpace, components);
}
@end
