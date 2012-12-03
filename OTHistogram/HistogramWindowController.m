//
//  HistogramWindowController.m
//  OTPieViewExam
//
//  Created by Eric Yeh on 12/12/3.
//  Copyright (c) 2012年 Ortery Technology, Inc. All rights reserved.
//

#import "HistogramWindowController.h"

@implementation HistogramWindowController
@synthesize hWindow;
@synthesize histogramChannelPopUpButton;
@synthesize histogramDrawLayer;
@synthesize histogramDataInfo;
@synthesize tmpImage;
@synthesize testButton;

- (id)init
{
    self = [super initWithWindowNibName:@"HistogramWindow"];
    if (self) {
        [self.hWindow setReleasedWhenClosed:NO];
        histogramDataInfo = [[HistogramData alloc]initWithHistogramLayerDrawing:histogramDrawLayer];
//        [self.window setIsVisible:YES];
//        [self.window setTitle:@"Ortery Histogram Window"];
//        [self.window makeKeyAndOrderFront:self];
    }
    return self;
}
//- (id)initWithWindow:(NSWindow *)window
//{
//    self = [super initWithWindow:window];
////    self = [super initWithWindowNibName:@"HistogramWindow"];
//    if (self) {
//        // Initialization code here.
//    }
//    return self;
//}

- (void)dealloc
{
    [histogramDataInfo release];
    [super dealloc];
}

//- (void)windowDidLoad
//{
//    [super windowDidLoad];
//    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
//
//}

- (IBAction)changeHistogram:(id)sender
{
    int modeButtonIndex = (int)[[self.histogramChannelPopUpButton selectedItem] tag];
    switch (modeButtonIndex) {
        case 1: //Red
            [histogramDrawLayer makesChannelVisible:kOTHistogramChannel_Red];
            break;
            
        case 2: //Green
            [histogramDrawLayer makesChannelVisible:kOTHistogramChannel_Green];
            break;
            
        case 3: //Blue
            [histogramDrawLayer makesChannelVisible:kOTHistogramChannel_Blue];
            break;
            
        case 4://All
            [histogramDrawLayer makesChannelVisible:kOTHistogramChannel_All];
            break;
            
        default: //RGB
            [histogramDrawLayer makesChannelVisible:kOTHistogramChannel_Gamma];
            break;
    }
}

- (IBAction)closePanel:(id)sender
{
    [self.hWindow close];
}

- (IBAction)applyPanel:(id)sender
{
    [self.hWindow close];
}
#pragma Private Method
- (void)reLoadImage:(NSImage *)image
{
    self.tmpImage = [image autorelease];
    [self _refreshHistogramData];
}

- (IBAction)testButton:(id)sender {
}

- (void)_refreshHistogramData
{
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSBitmapImageRep *bitmapRep = [[[NSBitmapImageRep alloc] initWithData:[self.tmpImage TIFFRepresentation]]autorelease];
//        [histogramDataInfo setHistogramData:bitmapRep withLayer:histogramDrawLayer];
        [histogramDataInfo resizedCGImage:bitmapRep toSize:CGRectMake(0, 0, 320, 240)];
    });
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sliderValueNotification) name:@"sliderChange" object:nil];
}

/*
 for Slider bar Using, but need set [histogramDrawLayer setNeedSliderAdjustment:YES];
 - (void)_initialSliderValue
 {
 [histogramDrawLayer _initialSlider];
 [self.histogramChannelPopUpButton selectItemAtIndex:0];
 [self changeHistogram:nil];
 [self.histogramWindow setIsVisible:YES];
 }
 
 init:[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sliderValueNotification) name:@"sliderChange" object:nil];
 
 dealloc:[[NSNotificationCenter defaultCenter] removeObserver:self name:@"sliderChange" object:nil];
 [super dealloc];
 
 - (void)sliderValueNotification
 {
 int modeButtonIndex = (int)[[histogramChannelPopUpButton selectedItem] tag];
 kOTHistogram_Channel channel;
 switch (modeButtonIndex) {
 case 1:
 channel = kOTHistogramChannel_Red;
 break;
 case 2:
 channel = kOTHistogramChannel_Green;
 break;
 case 3:
 channel = kOTHistogramChannel_Blue;
 break;
 default:
 channel = kOTHistogramChannel_Gamma;
 break;
 }
 NSBitmapImageRep *bitmapRep = [[[NSBitmapImageRep alloc] initWithData:[self.tmpImage TIFFRepresentation]]autorelease];
 self.dstImage.image = [[[NSImage alloc] initWithData:[[histogramDataInfo adjustHistogramValueForImage:bitmapRep withHistogramChannel:channel withValue:histogramDrawLayer.sliderValue] TIFFRepresentation]]autorelease];
 }
*/

@end
