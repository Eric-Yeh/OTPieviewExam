//
//  CorePlotView.m
//  OTPieViewExam
//
//  Created by Hank0272 on 12/11/2.
//  Copyright (c) 2012年 Ortery Technology, Inc. All rights reserved.
//

#import "CorePlotView.h"

@implementation CorePlotView

@synthesize boundingFrame;
@synthesize histogrameDictionary;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc {
    self.boundingFrame = nil;
	[super dealloc];
}

- (void)setDictionaryToDraw:(NSDictionary *)dictionary withMaxValue:(int)maxValue
{
    self.histogrameDictionary = dictionary;
    maxVolume = maxValue;
//    NSLog(@"%@, maxValue: %d", self.histogrameDictionary, maxVolume);
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
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
//    [borderFrame closePath];

//    borderFrame app
    //畫每個值的量
    if (!histogrameDictionary) {
        return;
    }
    NSBezierPath *volumeFrame = [[[NSBezierPath alloc] init] autorelease];
    float volume;
    for (int i = 0; i < 256; i++) {
        NSString *tmpColorStringValue = [self.histogrameDictionary objectForKey:[NSString stringWithFormat:@"%d", i]];
        int colorValue = [tmpColorStringValue intValue];
        volume = ((float)colorValue / maxVolume) * 100;
        NSLog(@"volume: %f", volume);
        [volumeFrame moveToPoint:NSMakePoint(30 + i, 30)];
        [volumeFrame lineToPoint:NSMakePoint(30 + i , 30 + volume)];
        [volumeFrame setLineWidth:0.5];
        [[NSColor darkGrayColor] set];
        
    }

    [volumeFrame stroke];
    [volumeFrame closePath];
    self.boundingFrame = boundingFrame;
    
}

@end
