//
//  AppDelegate.m
//  OTHistogram
//
//  Created by Eric Yeh on 12/11/2.
//  Copyright (c) 2012年 Ortery Technologies, Inc. All rights reserved.
//

#import "AppDelegate.h"
#define BEST_BYTE_ALIGNMENT 16
#define COMPUTE_BEST_BYTES_PER_ROW(bpr)		( ( (bpr) + (BEST_BYTE_ALIGNMENT-1) ) & ~(BEST_BYTE_ALIGNMENT-1) )



#pragma MainCode
@implementation AppDelegate
//NSImageView
@synthesize window;
@synthesize histogramPanel;
@synthesize oriImage, dstImage;
@synthesize modePopUpButton;
@synthesize histogramDrawLayer;
@synthesize histogramDataInfo;
@synthesize tmpImage;

- (void)dealloc
{
    [histogramDataInfo release];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"sliderChange" object:nil];
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    [self.histogramPanel setReleasedWhenClosed:NO];
    [self.histogramPanel close];
    [self.histogramPanel setHidesOnDeactivate:NO];
    [self.histogramPanel setTitle:@"Ortery Histogram Panel"];
    histogramDataInfo = [[HistogramData alloc]init];
    [self _initLoadImage:@"/Users/Eric/Pictures/lion-256height.jpg"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sliderValueNotification) name:@"sliderChange" object:nil];
}

- (void)sliderValueNotification
{
    int modeButtonIndex = (int)[[self.modePopUpButton selectedItem] tag];
    //[[self.layerMatrix selectedCell]tag]
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

- (IBAction)initializeDstImage:(id)sender
{
    self.dstImage.image = self.oriImage.image;
    self.tmpImage = self.dstImage.image;
}

- (IBAction)openImageFrom:(id)sender
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseFiles:YES];
    [openPanel setCanChooseDirectories:YES];
    NSString *initPath = @"/Users/Eric/Pictures/PNGTest/";
    [openPanel setDirectoryURL:[NSURL fileURLWithPath:initPath]];
    [openPanel setAllowsMultipleSelection:NO];
    [openPanel setAllowedFileTypes:[NSArray arrayWithObject:@"jpg"]];
    if ([openPanel runModal] == NSOKButton)
    {
        for (NSURL *fileURL in [openPanel URLs])
        {
            NSString *strPath = [fileURL path];
            [self _initLoadImage:strPath];
//            [self drawImageToTmpImageview];
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
//                NSBitmapImageRep *bmprep = [[self.oriImage.image representations] objectAtIndex:0];
//                NSData *jpegData = [bmprep representationUsingType: NSPNGFileType properties: nil];
////                self.dstImage.image = [[[NSImage alloc]initWithData:jpegData]autorelease];
//                [jpegData writeToFile:@"/Users/Eric/Pictures/PNGTest/999.png" atomically:NO];
//
//            });
        }
    }
}

- (IBAction)readHistogramData:(id)sender
{
//    NSLog(@"needReload: %i", needReloadDataInfo);
    if (needReloadDataInfo) {
        [self _refreshHistogramData];
        needReloadDataInfo = NO;
    }
//    NSLog(@"needReload: %i", needReloadDataInfo);
    [self _initialSliderValue];
}

- (IBAction)resizeNSImage:(id)sender
{
    needReloadDataInfo = YES;
    [histogramDataInfo setImageForHistogram:self.dstImage.image toSize:NSMakeSize(320, 240) withLayer:histogramDrawLayer];
    [self _initialSliderValue];
}

- (IBAction)resizeCGImage:(id)sender
{
/*
    needReloadDataInfo = YES;
    NSBitmapImageRep *bitmapRep = [[[NSBitmapImageRep alloc] initWithData:[self.dstImage.image TIFFRepresentation]]autorelease];
    [histogramDataInfo resizedImage:bitmapRep toSize:CGRectMake(0, 0, 320, 240) withLayer:histogramDrawLayer];
    [self _initialSliderValue];
*/
    NSBitmapImageRep *bitmapRep = [[[NSBitmapImageRep alloc] initWithData:[self.dstImage.image TIFFRepresentation]]autorelease];
    [histogramDataInfo imageDump:bitmapRep];
    
}

- (IBAction)changeHistogram:(id)sender
{
    int modeButtonIndex = (int)[[self.modePopUpButton selectedItem] tag];
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

        default: //RGB
            [histogramDrawLayer makesChannelVisible:kOTHistogramChannel_Gamma];
            break;
    }
}

- (IBAction)closePanel:(id)sender
{
    self.dstImage.image = self.tmpImage;
    [self.histogramPanel close];
}

- (IBAction)applyPanel:(id)sender
{
    [self.histogramPanel close];
    self.tmpImage = self.dstImage.image;
}
#pragma Private Method

- (void)_initLoadImage:(NSString *)fileName
{
    NSImage *nImage = [[NSImage alloc]initByReferencingFile:fileName];
    self.oriImage.image = nImage;
    [nImage release];
    [self initializeDstImage:nil];
    [self _refreshHistogramData];
}

- (void)_refreshHistogramData
{
    dispatch_async( dispatch_get_current_queue(), ^(void){
        NSBitmapImageRep *bitmapRep = [[[NSBitmapImageRep alloc] initWithData:[self.oriImage.image TIFFRepresentation]]autorelease];
        
        [histogramDataInfo setHistogramData:bitmapRep withLayer:histogramDrawLayer];
    });
}

- (void)_initialSliderValue
{
    [histogramDrawLayer _initialSlider];
    [self.histogramPanel setIsVisible:YES];
}
@end

