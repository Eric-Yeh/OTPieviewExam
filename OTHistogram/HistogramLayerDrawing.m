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

    kOTHistogram_Channel otHistogramChannel;
    kOTHistogram_Layer otHistogramLayer;
//    id <HistogramDataSource> _delegate;
}
@property (nonatomic, readwrite, copy) NSDictionary *histogrameDictionary;

@property (assign) kOTHistogram_Channel otHistogramChannel;
@property (assign) kOTHistogram_Layer otHistogramLayer;
//@property (assign) id <HistogramDataSource> delegate;
@end


@implementation HistogramLayerDrawing
@synthesize histogrameDictionary;
@synthesize boraderLayer, gammaLayer, redLayer, greenLayer, blueLayer, sliderLayer;
@synthesize otHistogramChannel;
@synthesize otHistogramLayer;
//@synthesize delegate = _delegate;

- (void)_layerinit
{
    [self setWantsLayer:YES];
    boraderLayer = [[CALayer alloc]init];
    gammaLayer = [[CALayer alloc]init];
    redLayer = [[CALayer alloc]init];
    greenLayer = [[CALayer alloc]init];
    blueLayer = [[CALayer alloc]init];
    sliderLayer = [[CALayer alloc]init];
    
    boraderLayer.name = @"BoraderLayer";
    gammaLayer.name = @"GammaLayer";
    redLayer.name = @"RedLayer";
    greenLayer.name = @"GreenLayer";
    blueLayer.name = @"BlueLayer";
    sliderLayer.name = @"SliderLayer";
    
    [boraderLayer setDelegate:self];
    [gammaLayer setDelegate:self];
    [redLayer setDelegate:self];
    [greenLayer setDelegate:self];
    [blueLayer setDelegate:self];
    [sliderLayer setDelegate:self];
    [self.layer setBackgroundColor:CGColorCreateFromNSColor([NSColor whiteColor],CGColorSpaceCreateDeviceRGB())];
//    backgroundLayer.frame = self.frame;
//    [backgroundLayer setBackgroundColor:CGColorCreateFromNSColor([NSColor whiteColor],
//                                                        CGColorSpaceCreateDeviceRGB())];
//    [self.layer addSublayer:backgroundLayer];
    
    boraderLayer.frame = CGRectMake(30, 30, 260, 160);
    [self.layer addSublayer:boraderLayer];
    
    redLayer.frame = CGRectMake(31, 60, 260, 130);
    [self.layer addSublayer:redLayer];
    
    greenLayer.frame = CGRectMake(31, 60, 260, 130);
    [self.layer addSublayer:greenLayer];

    blueLayer.frame = CGRectMake(31, 60, 260, 130);
    [self.layer addSublayer:blueLayer];

    gammaLayer.frame = CGRectMake(31, 60, 260, 130);
    [self.layer addSublayer:gammaLayer];

    sliderLayer.frame = CGRectMake(26, 18, 12, 12);
    [self.layer addSublayer:sliderLayer];
    
    [boraderLayer setNeedsDisplay];
    [gammaLayer setNeedsDisplay];
    [redLayer setNeedsDisplay];
    [greenLayer setNeedsDisplay];
    [blueLayer setNeedsDisplay];
    [sliderLayer setNeedsDisplay];

    [boraderLayer setHidden:NO];
    [gammaLayer setHidden:NO];
    [redLayer setHidden:NO];
    [greenLayer setHidden:NO];
    [blueLayer setHidden:NO];
    [sliderLayer setHidden:NO];
    self.histogrameDictionary = [NSMutableDictionary dictionary];
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _layerinit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _layerinit];
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
    [self.histogrameDictionary release];
    [super dealloc];
}

- (BOOL)isOpaque
{
    return YES;
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context
{
    //要如何接 Dictionary 的資料
    @synchronized (self){
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
        NSLog(@"%@", layer.name);
    }
}

//- (void)dataSourceForHistogramChannel:(NSDictionary *)dictionary withChannel:(kOTHistogram_Channel)channel withMaxValue:(int)max
//{
//    histogrameDictionary = [dictionary copy];
//    maxValue = max;
//    CALayer *tmpLayer;
//    switch (channel) {
//        case kOTHistogramChannel_Red:
//            tmpLayer = redLayer;
//            break;
//        case kOTHistogramChannel_Green:
//            tmpLayer = greenLayer;
//            break;
//        case kOTHistogramChannel_Blue:
//            tmpLayer = blueLayer;
//            break;
//        default:
//            tmpLayer = gammaLayer;
//            break;
//    }
//    [tmpLayer setNeedsDisplay];
//}

- (void)drawHistogramLayer:(kOTHistogram_Channel)channel withDictionary:(NSDictionary *)dictionary withMaxValue:(int)value
{
    self.histogrameDictionary = dictionary;
    maxValue = value;
    
    CALayer *tmpLayer;
    switch (channel) {
        case kOTHistogramChannel_Red:
            tmpLayer = redLayer;
            break;
        case kOTHistogramChannel_Green:
            tmpLayer = greenLayer;
            break;
        case kOTHistogramChannel_Blue:
            tmpLayer = blueLayer;
            break;
        default:
            tmpLayer = gammaLayer;
            break;
    }
    [tmpLayer setNeedsDisplay];
}

- (void)drawHistogrameChannel:(kOTHistogram_Channel)histogramChannel withDictionary:(NSDictionary *)dictionary withMaxValue:(int)value withContext:(CGContextRef)context
{
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef channelColor;
     switch (histogramChannel) {
         case kOTHistogramChannel_Red:
             channelColor = CGColorCreateFromNSColor([NSColor colorWithCalibratedRed:1.0 green:0.0 blue:0.0 alpha:0.5], colorSpace);
             break;
         case kOTHistogramChannel_Green:
             channelColor = CGColorCreateFromNSColor([NSColor colorWithCalibratedRed:0.0 green:1.0 blue:0.0 alpha:0.5], colorSpace);
             break;
         case kOTHistogramChannel_Blue:
             channelColor = CGColorCreateFromNSColor([NSColor colorWithCalibratedRed:0.0 green:0.0 blue:1.0 alpha:0.5], colorSpace);
             break;
         default:
             channelColor = CGColorCreateFromNSColor([NSColor colorWithCalibratedRed:0.5 green:0.5 blue:0.5 alpha:0.5], colorSpace);
             break;
     }
     
    CGContextSetLineWidth(context, 1.0f); //線寬
    
    CGContextSetStrokeColorWithColor(context, channelColor); //線色
    CGContextSetLineCap(context, kCGLineCapRound); //線的接點
    NSDictionary *tmpDictionary = [dictionary copy];
    //為什麼都是畫同一個？dictionary
//    NSLog(@"%@", tmpDictionary);
//        self.histogrameDictionary
    for (int i = 0; i < 256; i++) {
        NSString *tmpColorStringValue = [tmpDictionary objectForKey:[NSString stringWithFormat:@"%d", i]];
        int colorValue = [tmpColorStringValue intValue];
        value = ((float)colorValue / maxValue) * 100;
        //都從 (0,0) 開始畫，位置定義交給 CALayer
        CGContextMoveToPoint(context, i, 0);
        CGContextAddLineToPoint(context, i, value);
        CGContextStrokePath(context);
    }
    [dictionary release];
}

- (void)drawBorderLayer:(CGContextRef)context
{
    //底框
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef borderColor = CGColorCreateFromNSColor([NSColor blackColor], colorSpace);
    CGContextAddRect(context, CGRectMake(0 , 30, 260, 100));
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context, borderColor); //線色
    CGContextStrokePath(context);
    
    
    CGFloat colors [] = {
        0.0, 0.0, 0.0, 1.0,
        1.0, 1.0, 1.0, 1.0
    };
    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colors, NULL, 2);
    CGColorSpaceRelease(baseSpace), baseSpace = NULL;
    CGContextSaveGState(context);

    CGRect rect = CGRectMake(1 , 1, 258, 14);
    CGContextAddRect(context, rect);
    CGContextClip(context);
    
// 由上至下填色
//    CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
//    CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));

// 自左而右填色
    CGPoint startPoint = CGPointMake(1, 1);
    CGPoint endPoint = CGPointMake(258, 14);
    
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGGradientRelease(gradient), gradient = NULL;
    
    CGContextRestoreGState(context);
    CGContextAddRect(context, CGRectMake(0 , 0, 260, 15));
    CGContextSetLineWidth(context, 1.0);
    CGContextDrawPath(context, kCGPathStroke);
    
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
}

- (void)changeLayerPosition:(CALayer *)layerA withPosition:(CGPoint)position
{
    [layerA setNeedsDisplay];
}

- (void)changeChannel:(kOTHistogram_Channel)histogramChannel isHidden:(BOOL)hidden
{
    CALayer * layerA;
    switch (histogramChannel) {
        case kOTHistogramChannel_Red:
            layerA = redLayer;
            break;
        case kOTHistogramChannel_Green:
            layerA = greenLayer;
            break;
        case kOTHistogramChannel_Blue:
            layerA = blueLayer;
            break;
        default:
            layerA = gammaLayer;
            break;
    }
    [layerA setHidden:hidden];
}

@end
