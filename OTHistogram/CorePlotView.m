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
@property (nonatomic, readwrite, copy) NSDictionary *histogrameDictionary;
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
        self.histogrameDictionary = [[NSDictionary alloc] init];
    }
    
    return self;
}

- (void)dealloc {
    [self.histogrameDictionary release], self.histogrameDictionary = nil;
    self.boundingFrame = nil;
	[super dealloc];
}

- (void)setDictionaryToDraw:(NSDictionary *)dictionary withMaxValue:(int)maxValue withHistogramColor:(kOTHistogram_Color)histogramColor
{

    self.histogrameDictionary = dictionary;
    maxVolume = maxValue;
    self.otHistogramColor = histogramColor;
    NSLog(@"%@, maxValue: %d", self.histogrameDictionary, maxVolume);
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
    
    if (!self.histogrameDictionary) {
        return;
    }
    
    //畫外框
    NSBezierPath *borderFrame = [[[NSBezierPath alloc] init] autorelease];
    //borderFrame appendBezierPathWithRect:NSMakeRect(30, 30, 290, 33);
    [borderFrame moveToPoint:NSMakePoint(30, 30)];
    [borderFrame lineToPoint:NSMakePoint(290, 30)];
    [borderFrame setLineWidth: 1];
    [[NSColor blackColor] set];
    [borderFrame moveToPoint:NSMakePoint(30, 30)];
    [borderFrame lineToPoint:NSMakePoint(30, 130)];
    [borderFrame setLineWidth: 1];
    [[NSColor blackColor] set];
    [borderFrame stroke];
    [borderFrame closePath];

//    borderFrame app
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
            histogramColor = [NSColor darkGrayColor];
            break;
    }
    for (int i = 0; i < 256; i++) {
        NSString *tmpColorStringValue = [self.histogrameDictionary objectForKey:[NSString stringWithFormat:@"%d", i]];
        int colorValue = [tmpColorStringValue intValue];
        volume = ((float)colorValue / maxVolume) * 100;
//        NSLog(@"volume: %f", volume);
        [volumeFrame moveToPoint:NSMakePoint(30 + i, 30)];
        [volumeFrame lineToPoint:NSMakePoint(30 + i , 30 + volume)];
        [volumeFrame setLineWidth:0.25];
        [histogramColor set];
        
    }

    [volumeFrame stroke];
    [volumeFrame closePath];
    self.boundingFrame = boundingFrame;
    
}

@end
