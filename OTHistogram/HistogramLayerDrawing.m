//
//  HistogramLayerDrawing.m
//  OTPieViewExam
//
//  Created by Hank0272 on 12/11/15.
//  Copyright (c) 2012年 Ortery Technology, Inc. All rights reserved.
//
//這是直接與 Layer 的 Delegate 配合使用 
#import "HistogramLayerDrawing.h"

@interface NSView (sliderBorderLayer)
- (BOOL)otck_mouse:(NSPoint)point inCGRect:(CGRect)rect;
@end

@implementation NSView (sliderBorderLayer)
- (BOOL)otck_mouse:(NSPoint)point inCGRect:(CGRect)rect
{
    return [self mouse:point inRect:NSRectFromCGRect(rect)];
}
@end

@interface HistogramLayerDrawing ()
{
    kOTHistogram_Channel otHistogramChannel;
    CALayer *boraderLayer, *gradientRectLayer, *gammaLayer, *redLayer, *greenLayer, *blueLayer, *sliderLayer;    
    BOOL isSliderClick;
//    kOTHistogram_Layer otHistogramLayer;
//    id <HistogramDataSource> _delegate;
}
@property (nonatomic, readwrite, copy) NSDictionary *histogrameDictionary;
@property (nonatomic, readwrite, copy) CALayer *boraderLayer, *gradientRectLayer, *gammaLayer, *redLayer, *greenLayer, *blueLayer, *sliderLayer;
@property (assign) kOTHistogram_Channel otHistogramChannel;
//@property (assign) kOTHistogram_Layer otHistogramLayer;
//@property (assign) id <HistogramDataSource> delegate;
@end


@implementation HistogramLayerDrawing
@synthesize histogrameDictionary;
@synthesize boraderLayer, gradientRectLayer, gammaLayer, redLayer, greenLayer, blueLayer, sliderLayer;
@synthesize otHistogramChannel;
//@synthesize otHistogramLayer;
//@synthesize delegate = _delegate;


#pragma mark Retina Display Support
- (void)scaleDidChange:(NSNotification *)n
{
    [self _updateContentScale];
}

- (void)viewDidMoveToWindow
{
    // Retina Display support
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(scaleDidChange:)
                                                 name:@"NSWindowDidChangeBackingPropertiesNotification"
                                               object:[self window]];
    
    // immediately update scale after the view has been added to a window
    [self _updateContentScale];
}

- (void)removeFromSuperview
{
    [super removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NSWindowDidChangeBackingPropertiesNotification" object:[self window]];
}

- (void)_updateContentScale
{
    if (![self window]) return;
    
    CALayer *rootLayer = self.layer;
    if ([rootLayer respondsToSelector:@selector(contentsScale)]) {
        CGFloat scale = [(id)[self window] backingScaleFactor];
        [(id)self.layer setContentsScale:scale];
        [(id)self.boraderLayer setContentsScale:scale];
        [(id)self.gradientRectLayer setContentsScale:scale];
        [(id)self.gammaLayer setContentsScale:scale];
        [(id)self.redLayer setContentsScale:scale];
        [(id)self.greenLayer setContentsScale:scale];
        [(id)self.blueLayer setContentsScale:scale];
        [(id)self.sliderLayer setContentsScale:scale];
    }
}

#pragma mark Mouse Events

- (void)mouseDown:(NSEvent *)theEvent
{
    NSPoint lastLocation = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    
    BOOL result = [self otck_mouse:lastLocation inCGRect:self.sliderLayer.frame];
    if (result) {
        [self _moveCropMarkerLayerToPoint:lastLocation];
        isSliderClick = YES;
    }
}

- (void)mouseUp:(NSEvent *)theEvent
{
	[super mouseUp:theEvent];
	NSPoint lastLocation = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    
    BOOL result = [self otck_mouse:lastLocation inCGRect:self.sliderLayer.frame];
    if (result)
        [self _moveCropMarkerLayerToPoint:lastLocation];
    isSliderClick = NO;

}

- (void)mouseDragged:(NSEvent *)theEvent
{
	[super mouseDragged:theEvent];
	NSPoint lastLocation = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    
//    BOOL result = [self otck_mouse:lastLocation inCGRect:self.sliderLayer.frame];
    if (isSliderClick)
        [self _moveCropMarkerLayerToPoint:lastLocation];
}

- (void)_moveCropMarkerLayerToPoint:(NSPoint)point
{
    CGPoint insetPoint = OTHistogramSliderRange(NSPointToCGPoint(point), self.sliderLayer.frame, CGRectMake(self.gradientRectLayer.frame.origin.x, self.gradientRectLayer.frame.origin.y - self.sliderLayer.frame.size.height / 2 + 2, self.gradientRectLayer.frame.size.width - self.sliderLayer.frame.size.width / 2 + 4, 0));
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	self.sliderLayer.position = insetPoint;
	[CATransaction commit];
    
    [self.sliderLayer setNeedsDisplay];
}

static CGPoint OTHistogramSliderRange(CGPoint lastMouseLocation, CGRect childRect, CGRect parentRect)
{
    CGPoint point = lastMouseLocation;
    if (point.x < parentRect.origin.x)
        point.x = parentRect.origin.x;
    if (point.y < parentRect.origin.y)
        point.y = parentRect.origin.y;
    if (point.x > (parentRect.origin.x + parentRect.size.width))
        point.x = parentRect.origin.x + parentRect.size.width;
    if (point.y > (parentRect.origin.y + parentRect.size.height))
        point.y = parentRect.origin.y + parentRect.size.height;

    return point;
}
#pragma mark ---------------
- (void)_layerinit
{
    [self setWantsLayer:YES];
    boraderLayer = [[CALayer alloc]init];
    gradientRectLayer = [[CALayer alloc]init];
    gammaLayer = [[CALayer alloc]init];
    redLayer = [[CALayer alloc]init];
    greenLayer = [[CALayer alloc]init];
    blueLayer = [[CALayer alloc]init];
    sliderLayer = [[CALayer alloc]init];
    
    boraderLayer.name = @"BoraderLayer";
    gradientRectLayer.name = @"GradientRectLayer";
    gammaLayer.name = @"GammaLayer";
    redLayer.name = @"RedLayer";
    greenLayer.name = @"GreenLayer";
    blueLayer.name = @"BlueLayer";
    sliderLayer.name = @"SliderLayer";
    
    [boraderLayer setDelegate:self];
    [gradientRectLayer setDelegate:self];
    [gammaLayer setDelegate:self];
    [redLayer setDelegate:self];
    [greenLayer setDelegate:self];
    [blueLayer setDelegate:self];
    [sliderLayer setDelegate:self];
    [self.layer setBackgroundColor:CGColorCreateFromNSColor([NSColor whiteColor],CGColorSpaceCreateDeviceRGB())];
    
    boraderLayer.frame = CGRectMake(30, 30, 260, 160);
    [self.layer addSublayer:boraderLayer];
    
    gradientRectLayer.frame = CGRectMake(30, 30, 260, 15);
    [self.layer addSublayer:gradientRectLayer];
    
    redLayer.frame = CGRectMake(31, 60, 256, 130);
    [self.layer addSublayer:redLayer];
    
    greenLayer.frame = CGRectMake(31, 60, 256, 130);
    [self.layer addSublayer:greenLayer];

    blueLayer.frame = CGRectMake(31, 60, 256, 130);
    [self.layer addSublayer:blueLayer];

    gammaLayer.frame = CGRectMake(31, 60, 256, 130);
    [self.layer addSublayer:gammaLayer];

    sliderLayer.frame = CGRectMake(23, 17, 15, 15);
    [self.layer addSublayer:sliderLayer];
    
    [boraderLayer setNeedsDisplay];
    [gradientRectLayer setNeedsDisplay];
    [gammaLayer setNeedsDisplay];
    [redLayer setNeedsDisplay];
    [greenLayer setNeedsDisplay];
    [blueLayer setNeedsDisplay];
    [sliderLayer setNeedsDisplay];

    [boraderLayer setHidden:NO];
    [gradientRectLayer setHidden:NO];
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
    [gradientRectLayer release]; gradientRectLayer = nil;
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
        } else if (layer == gradientRectLayer) {
            [self drawGradientRectLayer:context];
        }
        else if (layer == sliderLayer) {
            [self drawSliderLayer:context];
        }
//        NSLog(@"%@", layer.name);
    }
}

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
    CGContextAddRect(context, CGRectMake(0 , 30, 256, 100));
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context, borderColor); //線色
    CGContextStrokePath(context);
}

- (void)drawGradientRectLayer:(CGContextRef)context
{
    CGFloat colors [] = {
        0.0, 0.0, 0.0, 1.0,
        1.0, 1.0, 1.0, 1.0
    };
    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colors, NULL, 2);
    CGColorSpaceRelease(baseSpace), baseSpace = NULL;
    CGContextSaveGState(context);
    
    CGRect rect = CGRectMake(1 , 0, 256, 14);
    CGContextAddRect(context, rect);
    CGContextClip(context);
    
    // 由上至下填色
    //    CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
    //    CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
    
    // 自左而右填色
    CGPoint startPoint = CGPointMake(0, 0);
    CGPoint endPoint = CGPointMake(256, 14);
    
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGGradientRelease(gradient), gradient = NULL;
    
    CGContextRestoreGState(context);
    CGContextAddRect(context, CGRectMake(1 , 0, 256, 15));
    CGContextSetLineWidth(context, 1.0);
    CGContextDrawPath(context, kCGPathStroke);
}

- (void)drawSliderLayer:(CGContextRef)context
{
    //三角型
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef borderColor = CGColorCreateFromNSColor([NSColor blackColor], colorSpace);
    
    CGPoint startPoint = CGPointMake(3, 3);
    
    CGContextSetLineWidth(context, 0.25); //線寬
    CGContextSetStrokeColorWithColor(context, borderColor); //線色
    CGContextSetFillColorWithColor(context, borderColor); //內容色
    CGContextSetLineCap(context, kCGLineCapRound); //線的接點
    CGContextMoveToPoint(context, 0 + startPoint.x, 0 + startPoint.y);
    CGContextAddLineToPoint(context, 5 + startPoint.x, 10 + startPoint.y);
    CGContextAddLineToPoint(context, 10 + startPoint.x, 0 + startPoint.y);
    CGContextSetStrokeColorWithColor(context, borderColor); //線色
    CGContextDrawPath(context, kCGPathFillStroke);
    CGContextStrokePath(context);
}

- (void)changeLayerPosition:(CALayer *)layerA withPosition:(CGPoint)position
{
    [layerA setNeedsDisplay];
}
- (void)makesAllChannelHidden
{
    [redLayer setHidden:YES];
    [greenLayer setHidden:YES];
    [blueLayer setHidden:YES];
    [gammaLayer setHidden:YES];
}

- (void)makesChannelVisible:(kOTHistogram_Channel)histogramChannel
{
    [self makesAllChannelHidden];
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
    [layerA setHidden:NO];
}

@end
