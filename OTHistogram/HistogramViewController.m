//
//  HistogramViewController.m
//  OTPieViewExam
//
//  Created by Hank0272 on 12/12/4.
//  Copyright (c) 2012年 Ortery Technology, Inc. All rights reserved.
//

#import "HistogramViewController.h"

@interface HistogramViewController ()

@end

@implementation HistogramViewController
@synthesize hWindow;
@synthesize histogramChannelButton;
@synthesize histogramLayer = _histogramLayer;
@synthesize histogramDataInfo;
@synthesize tmpImage;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
        [self.hWindow setReleasedWhenClosed:NO];
        histogramDataInfo = [[HistogramData alloc]initWithHistogramLayerDrawing:histogramLayer];
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void)dealloc
{
    [histogramDataInfo release];
    [super dealloc];
}
#pragma Private Method
- (void)reLoadImage:(NSImage *)image
{
    self.tmpImage = [image autorelease];
    [self _refreshHistogramData];
}

- (IBAction)changeHistogramChannel:(id)sender {
    int modeButtonIndex = (int)[[self.histogramChannelButton selectedItem] tag];
    switch (modeButtonIndex) {
        case 1: //Red
            [histogramLayer makesChannelVisible:kOTHistogramChannel_Red];
            break;
            
        case 2: //Green
            [histogramLayer makesChannelVisible:kOTHistogramChannel_Green];
            break;
            
        case 3: //Blue
            [histogramLayer makesChannelVisible:kOTHistogramChannel_Blue];
            break;
            
        case 4://All
            [histogramLayer makesChannelVisible:kOTHistogramChannel_All];
            break;
            
        default: //RGB
            [histogramLayer makesChannelVisible:kOTHistogramChannel_Gamma];
            break;
    }
}

- (IBAction)okButton:(id)sender {
    [self.hWindow close];
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
