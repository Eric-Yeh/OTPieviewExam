//
//  AppDelegate.m
//  LayerGraphicsDrawing
//
//  Created by Hank0272 on 12/11/19.
//  Copyright (c) 2012年 Ortery Technology, Inc. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate
@synthesize originImage, targetImage;

- (void)dealloc
{
    [otLayer release];
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    NSImage *nImage = [[NSImage alloc]initByReferencingFile:@"/Users/Eric/Pictures/Image/eagle.jpg"];
    self.originImage.image = nImage;
    [nImage release];
    otLayer = [[OTLayerDrawing alloc]init];
}

- (IBAction)opendlgImage:(id)sender
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
            self.originImage.image = [[[NSImage alloc] initWithContentsOfFile:strPath] autorelease];
        }
    }
}

- (IBAction)layerActor:(id)sender
{
    [otLayer changeDisplayLayer:otLayer.layer2];
//    NSLog(@"%@",otLayer.layer2.name);
    //[otLayer changeLayerPosition:otLayer.layer1 toPosition:NSMakePoint(50, 50)];
}

@end
