//
//  HistogramLayerDrawing.m
//  OTPieViewExam
//
//  Created by Hank0272 on 12/11/15.
//  Copyright (c) 2012年 Ortery Technology, Inc. All rights reserved.
//
//這是直接與 Layer 的 Delegate 配合使用 
#import "HistogramLayerDrawing.h"
#import <QuartzCore/QuartzCore.h>
@interface NSView (sliderBorderLayer)
- (BOOL)otck_mouse:(NSPoint)point inCGRect:(CGRect)rect;
@end

@implementation NSView (sliderBorderLayer)
- (BOOL)otck_mouse:(NSPoint)point inCGRect:(CGRect)rect
{
    return [self mouse:point inRect:NSRectFromCGRect(rect)];
}
@end


@implementation HistogramLayerDrawing
@synthesize gammaDictionary, redDictionary, greenDictionary, blueDictionary;
@synthesize boraderLayer, gradientRectLayer, gammaLayer, redLayer, greenLayer, blueLayer, sliderLayer;
@synthesize delegate = _delegate;
@synthesize sliderValue;
@synthesize maxGammaValue, maxRedValue, maxGreenValue, maxBlueValue;
@synthesize isNeedSlider;

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
        [self _dragSlider:lastLocation];
        isSliderClick = YES;
    }
}

- (void)mouseUp:(NSEvent *)theEvent
{
	[super mouseUp:theEvent];
	NSPoint lastLocation = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    
    BOOL result = [self otck_mouse:lastLocation inCGRect:self.sliderLayer.frame];
    if (result)
        [self _dragSlider:lastLocation];
    isSliderClick = NO;
}

- (void)mouseDragged:(NSEvent *)theEvent
{
	[super mouseDragged:theEvent];
	NSPoint lastLocation = [self convertPoint:[theEvent locationInWindow] fromView:nil];

    if (isSliderClick)
    {
        [self _dragSlider:lastLocation];
        sliderValue = self.sliderLayer.frame.origin.x - self.gradientRectLayer.frame.origin.x + 6.5;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"sliderChange" object:self];
    }
}

- (void)_initialSlider
{
    float dstPoint = self.gradientRectLayer.frame.origin.x + 1 + (self.gradientRectLayer.frame.size.width - self.sliderLayer.frame.size.width / 2 + 4);
    CGPoint moveToPoint = CGPointMake(dstPoint, self.gradientRectLayer.frame.origin.y - self.sliderLayer.frame.size.height / 2 + 1);
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	self.sliderLayer.position = moveToPoint;
	[CATransaction commit];
    
    [self setNeedSliderAdjustment:self.isNeedSlider];
}

- (void)_dragSlider:(NSPoint)point
{
    CGPoint insetPoint = OTHistogramSliderRange(NSPointToCGPoint(point), self.sliderLayer.frame, CGRectMake(self.gradientRectLayer.frame.origin.x + 1, self.gradientRectLayer.frame.origin.y - self.sliderLayer.frame.size.height / 2 + 1, self.gradientRectLayer.frame.size.width - self.sliderLayer.frame.size.width / 2 + 4, 0));
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	self.sliderLayer.position = insetPoint;
	[CATransaction commit];
    
    [self setNeedSliderAdjustment:self.isNeedSlider];
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
    self.gammaDictionary = [NSMutableDictionary dictionary];
    self.redDictionary = [NSMutableDictionary dictionary];
    self.greenDictionary = [NSMutableDictionary dictionary];
    self.blueDictionary = [NSMutableDictionary dictionary];
    maxGammaValue = 0, maxRedValue = 0, maxGreenValue = 0, maxBlueValue = 0;
    [self setWantsLayer:YES];
    isNeedSlider = NO;
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
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    [self.layer setBackgroundColor:CGColorCreateFromNSColor([NSColor whiteColor], colorSpace)];
    CGColorSpaceRelease(colorSpace);
    
    gradientRectLayer.frame = CGRectMake(30, 16, 260, 15);
    [self.layer addSublayer:gradientRectLayer];
    
    sliderLayer.frame = CGRectMake(gradientRectLayer.frame.origin.x + gradientRectLayer.bounds.size.width - 10, gradientRectLayer.frame.origin.y - gradientRectLayer.frame.size.height - 2, 15, 15);//23
    [self.layer addSublayer:sliderLayer];
    
    channelRect = CGRectMake(31, gradientRectLayer.frame.origin.y + gradientRectLayer.frame.size.height + 5, gradientRectLayer.frame.size.width - 4, 256);
    
    boraderLayer.frame = CGRectMake(channelRect.origin.x, channelRect.origin.y, channelRect.size.width + 2, channelRect.size.height + 2);
    [self.layer addSublayer:boraderLayer];
    
    redLayer.frame = channelRect;
    [self.layer addSublayer:redLayer];
    
    greenLayer.frame = channelRect;
    [self.layer addSublayer:greenLayer];

    blueLayer.frame = channelRect;
    [self.layer addSublayer:blueLayer];

    gammaLayer.frame = channelRect;
    [self.layer addSublayer:gammaLayer];
    
    [self setNeedSliderAdjustment:self.isNeedSlider];
    
    [boraderLayer setNeedsDisplay];
    [gammaLayer setNeedsDisplay];
    [redLayer setNeedsDisplay];
    [greenLayer setNeedsDisplay];
    [blueLayer setNeedsDisplay];

    [boraderLayer setHidden:NO];
    [gradientRectLayer setHidden:NO];
    [gammaLayer setHidden:NO];
    [redLayer setHidden:NO];
    [greenLayer setHidden:NO];
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
    _delegate = nil;
    [boraderLayer release]; boraderLayer = nil;
    [gradientRectLayer release]; gradientRectLayer = nil;
    [gammaLayer release]; gammaLayer = nil;
    [redLayer release]; redLayer = nil;
    [greenLayer release]; greenLayer = nil;
    [blueLayer release]; blueLayer = nil;
    [sliderLayer release]; sliderLayer = nil;
    [redDictionary release]; redDictionary = nil;
    [greenDictionary release]; greenDictionary = nil;
    [blueDictionary release]; blueDictionary = nil;
    [gammaDictionary release]; gammaDictionary = nil;
    [super dealloc];
}

- (BOOL)isOpaque
{
    return YES;
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context
{
    //要如何接 Dictionary 的資料
    @synchronized (self)
    {
        if (layer == redLayer) {
            [self drawHistogrameChannel:kOTHistogramChannel_Red withDictionary:redDictionary withMaxValue:maxRedValue withContext:context];
        } else if (layer == greenLayer) {
            [self drawHistogrameChannel:kOTHistogramChannel_Green withDictionary:greenDictionary withMaxValue:maxGreenValue withContext:context];
        } else if (layer == blueLayer) {
            [self drawHistogrameChannel:kOTHistogramChannel_Blue withDictionary:blueDictionary withMaxValue:maxBlueValue withContext:context];
        } else if (layer == gammaLayer) {
            [self drawHistogrameChannel:kOTHistogramChannel_Gamma withDictionary:gammaDictionary withMaxValue:maxGammaValue withContext:context];
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

- (void)drawHistogramLayer:(kOTHistogram_Channel)channel
{
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
    [self setNeedSliderAdjustment:self.isNeedSlider];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef channelColor;
    NSDictionary *tmpDictionary = [dictionary copy];
    
     switch (histogramChannel) {
         case kOTHistogramChannel_Red:
             channelColor = CGColorCreateFromNSColor([NSColor colorWithCalibratedRed:1.0 green:0.0 blue:0.0 alpha:0.5], colorSpace);
             maxValue = maxRedValue;
             break;
         case kOTHistogramChannel_Green:
             channelColor = CGColorCreateFromNSColor([NSColor colorWithCalibratedRed:0.0 green:1.0 blue:0.0 alpha:0.5], colorSpace);
             maxValue = maxGreenValue;
             break;
         case kOTHistogramChannel_Blue:
             channelColor = CGColorCreateFromNSColor([NSColor colorWithCalibratedRed:0.0 green:0.0 blue:1.0 alpha:0.5], colorSpace);
             maxValue = maxBlueValue;
             break;
         default:
             channelColor = CGColorCreateFromNSColor([NSColor colorWithCalibratedRed:0.5 green:0.5 blue:0.5 alpha:0.5], colorSpace);
             maxValue = maxGammaValue;
             break;
     }
    float lineWidth = 1.0f;
    CGContextSetLineWidth(context, lineWidth); //線寬
    
    CGContextSetStrokeColorWithColor(context, channelColor); //線色
    CGContextSetLineCap(context, kCGLineCapRound); //線的接點
    
    for (int i = 0; i < 256; i++) {
        NSString *tmpColorStringValue = [tmpDictionary objectForKey:[NSString stringWithFormat:@"%d", i]];
        int colorValue = [tmpColorStringValue intValue];
        value = ((float)colorValue / maxValue) * redLayer.bounds.size.height ;//100
        //都從 (0,0) 開始畫，位置定義交給 CALayer
        float gap = (float)i * lineWidth;
        CGContextMoveToPoint(context, gap, 0);
        CGContextAddLineToPoint(context, gap, value);
        CGContextStrokePath(context);
    }
    [dictionary release];
    if ([self.delegate respondsToSelector:@selector(histogramDrawingLayerFinish:)]) {
        [self.delegate histogramDrawingLayerFinish];
    }
}

- (void)drawBorderLayer:(CGContextRef)context
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    //格線
    CGColorRef gridColor = CGColorCreateFromNSColor([NSColor lightGrayColor], colorSpace);
    CGContextSetLineWidth(context, 1.0f);
    CGContextSetStrokeColorWithColor(context, gridColor); //線色
    for (int x = 0 ; x < 4 ; x++) {
        CGContextMoveToPoint(context, boraderLayer.bounds.size.width * x / 4, 0 );
        CGContextAddLineToPoint(context, boraderLayer.bounds.size.width * x / 4, boraderLayer.bounds.size.height);
        CGContextStrokePath(context);
    }
    for (int y = 0 ; y < 4; y++) {
        CGContextMoveToPoint(context, 0, boraderLayer.bounds.size.height * y / 4 );
        CGContextAddLineToPoint(context, boraderLayer.bounds.size.width, boraderLayer.bounds.size.height * y / 4);
        CGContextStrokePath(context);
    }
    //底框
    CGColorRef borderColor = CGColorCreateFromNSColor([NSColor blackColor], colorSpace);
    CGContextAddRect(context, CGRectMake(1 , 1, boraderLayer.bounds.size.width - 2, boraderLayer.bounds.size.height - 2 ));
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
    
    CGRect rect = CGRectMake(1 , 0, gradientRectLayer.bounds.size.width - 2, gradientRectLayer.bounds.size.height - 2 );
    CGContextAddRect(context, rect);
    CGContextClip(context);
    
    // 由上至下填色
    //    CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
    //    CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
    
    // 自左而右填色
    CGPoint startPoint = CGPointMake(0, 0);
    CGPoint endPoint = CGPointMake(gradientRectLayer.bounds.size.width - 8, gradientRectLayer.bounds.size.height - 2);
    
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGGradientRelease(gradient), gradient = NULL;
    
    CGContextRestoreGState(context);
    CGContextAddRect(context, CGRectMake(0 , 0, gradientRectLayer.bounds.size.width-1, gradientRectLayer.bounds.size.height - 1));
    CGContextSetLineWidth(context, 1.0f);
    CGContextDrawPath(context, kCGPathStroke);
}

- (void)drawSliderLayer:(CGContextRef)context
{
    //三角型
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef borderColor = CGColorCreateFromNSColor([NSColor blackColor], colorSpace);
    CGColorSpaceRelease(colorSpace);
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

- (void)setNeedSliderAdjustment:(BOOL)isNeed
{
    self.isNeedSlider = isNeed;
    [gradientRectLayer setNeedsDisplay];
    [sliderLayer setNeedsDisplay];
    if (self.isNeedSlider) {
        [gradientRectLayer setHidden:NO];
        [sliderLayer setHidden:NO];
    } else {
        [gradientRectLayer setHidden:YES];
        [sliderLayer setHidden:YES];
    }
}

- (void)makesAllChannelHidden:(BOOL)isHidden
{
    [redLayer setHidden:isHidden];
    [greenLayer setHidden:isHidden];
    [blueLayer setHidden:isHidden];
    [gammaLayer setHidden:isHidden];
}

- (void)makesChannelVisible:(kOTHistogram_Channel)histogramChannel
{
    [self makesAllChannelHidden:YES];
    CALayer * layerA;
    switch (histogramChannel) {
        case kOTHistogramChannel_Red:
            layerA = redLayer;
            [layerA setHidden:NO];
            break;
        case kOTHistogramChannel_Green:
            layerA = greenLayer;
            [layerA setHidden:NO];
            break;
        case kOTHistogramChannel_Blue:
            layerA = blueLayer;
            [layerA setHidden:NO];
            break;
        case kOTHistogramChannel_All:
            [self makesAllChannelHidden:NO];
            break;
        default:
            layerA = gammaLayer;
            [layerA setHidden:NO];
            break;
    }
    
}

@end
