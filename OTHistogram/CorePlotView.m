//
//  CorePlotView.m
//  OTPieViewExam
//
//  Created by Hank0272 on 12/11/2.
//  Copyright (c) 2012年 Ortery Technology, Inc. All rights reserved.
//

#import "CorePlotView.h"
@interface CorePlotView()
@property (nonatomic, copy) NSBezierPath *boundingFrame;
//@property (nonatomic, readwrite, copy) NSDictionary *histogrameDictionary;
@property (nonatomic, assign) NSMutableDictionary *histogrameDictionary;
@property (assign) kOTHistogram_Color otHistogramColor;
@end

@implementation CorePlotView

@synthesize boundingFrame;
@synthesize histogrameDictionary;
@synthesize otHistogramColor;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
//         self.histogrameDictionary = [[NSDictionary alloc] init];
        self.histogrameDictionary = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (void)dealloc {
//    [self.histogrameDictionary release], self.histogrameDictionary = nil;
//    self.boundingFrame = nil;
	[super dealloc];
}

- (void)setDictionaryToDraw:(NSDictionary *)dictionary withMaxValue:(int)maxValue withHistogramColor:(kOTHistogram_Color)histogramColor
{

    self.histogrameDictionary = [dictionary mutableCopy];
    maxVolume = maxValue;
    self.otHistogramColor = histogramColor;
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
    
    if (!self.histogrameDictionary) {
        return;
    }
    //畫背景用
    NSBezierPath *backgroundFrame = [[[NSBezierPath alloc] init] autorelease];
    [backgroundFrame appendBezierPathWithRect:NSMakeRect(0, 0, 320, 160)];
    [[NSColor whiteColor] set];
    [backgroundFrame fill];
    [backgroundFrame stroke];
    [backgroundFrame closePath];
    
    float borderXOffset = 0.0, borderYOffset = 10.0; //座標偏移，移動圖形用
    float borderXRedeem = 0.0, borderYRedeem = 4.0; //座標補償，主要是變高變長用
    //畫外框
    NSBezierPath *borderFrame = [[[NSBezierPath alloc] init] autorelease];
    [borderFrame appendBezierPathWithRect:NSMakeRect(30 + borderXOffset , 30 + borderYOffset, 260, 100 + borderYRedeem)];
    [[NSColor blackColor] set];
//    [borderFrame moveToPoint:NSMakePoint(30 + borderXOffset, 30 + borderYOffset)];
//    [borderFrame lineToPoint:NSMakePoint(290 + borderXOffset + borderXRedeem, 30 + borderYOffset)];
//    [borderFrame setLineWidth: 0.5];
//    [[NSColor blackColor] set];
//    [borderFrame stroke];
//    
//    [borderFrame moveToPoint:NSMakePoint(290 + borderXOffset + borderXRedeem, 30 + borderYOffset)];
//    [borderFrame lineToPoint:NSMakePoint(290 + borderXOffset + borderXRedeem, 130 + borderYOffset + borderYRedeem)];
//    [borderFrame setLineWidth: 0.5];
//    [[NSColor blackColor] set];
//    [borderFrame stroke];
//    
//    [borderFrame moveToPoint:NSMakePoint(30 + borderXOffset, 30 + borderYOffset)];
//    [borderFrame lineToPoint:NSMakePoint(30 + borderXOffset, 130 + borderYOffset + borderYRedeem)];
//    [borderFrame setLineWidth: 0.5];
//    [[NSColor blackColor] set];
//    [borderFrame stroke];
//    
//    [borderFrame moveToPoint:NSMakePoint(30 + borderXOffset, 130 + borderYOffset + borderYRedeem)];
//    [borderFrame lineToPoint:NSMakePoint(290 + borderXOffset + borderXRedeem, 130 + borderYOffset + borderYRedeem)];
//    [borderFrame setLineWidth: 0.5];
//    [[NSColor blackColor] set];
    [borderFrame stroke];
    [borderFrame closePath];

    //畫每個值的量

    NSBezierPath *volumeFrame = [[[NSBezierPath alloc] init] autorelease];
    float volume;
    NSColor *histogramColor;
    switch (self.otHistogramColor) {
        case kOTHistogramColor_Red:
            histogramColor = [NSColor redColor];
            break;

        case kOTHistogramColor_Green:
            histogramColor = [NSColor greenColor];
            break;
            
        case kOTHistogramColor_Blue:
            histogramColor = [NSColor blueColor];
            break;
        default:
            histogramColor = [NSColor grayColor];
            break;
    }
    float xOffset = 2.0, yOffset = 1.5; //長條的位移量
    for (int i = 0; i < 256; i++) {
        NSString *tmpColorStringValue = [self.histogrameDictionary objectForKey:[NSString stringWithFormat:@"%d", i]];
        int colorValue = [tmpColorStringValue intValue];
        volume = ((float)colorValue / maxVolume) * 100;
//        NSLog(@"volume: %f", volume);
        [volumeFrame moveToPoint:NSMakePoint(30 + i + xOffset + borderXOffset, 30 + yOffset + borderYOffset)];
        [volumeFrame lineToPoint:NSMakePoint(30 + i + xOffset + borderXOffset, 30 + volume + yOffset + borderYOffset)];
        [volumeFrame setLineWidth:0.25];
        [histogramColor set];
        [volumeFrame stroke];
        
    }
    [volumeFrame stroke];
    [volumeFrame closePath];
    
    NSBezierPath *borderOfLightShadow = [[[NSBezierPath alloc] init] autorelease];
    [borderOfLightShadow appendBezierPathWithRect:NSMakeRect(30, 10, 260, 20)];
    [[NSColor blackColor] set];
    [borderOfLightShadow stroke];
    [borderOfLightShadow closePath];

    NSGradient *gradient = [[[NSGradient alloc] initWithStartingColor:[NSColor blackColor] endingColor:[NSColor whiteColor]] autorelease];
    [gradient drawInRect:NSMakeRect(31, 11, 258, 18) angle:0];
    
//    NSBezierPath *lineOfLightShadow = [[[NSBezierPath alloc] init] autorelease];
//    for (int i = 0 ; i < 101; i++)
//    {
//        [lineOfLightShadow moveToPoint:NSMakePoint(32 + i + 2, 11)];
//        [lineOfLightShadow lineToPoint:NSMakePoint(32 + i + 2, 29)];
//        [lineOfLightShadow setLineWidth: 2];
//        double floatColor = ((float)i / 100);
//        NSColor *lineColor = [NSColor colorWithCalibratedRed:floatColor green:floatColor blue:floatColor alpha:1.0f];
//        
////        [lineColor set];
////        [[lineColor blendedColorWithFraction:1.0*floatColor ofColor:[NSColor whiteColor]] set];
//        [[NSColor blackColor] set];
//        [lineOfLightShadow stroke];
//    }

//    [lineOfLightShadow stroke];
//    [lineOfLightShadow closePath];
    
    self.boundingFrame = boundingFrame;
    
}

@end
