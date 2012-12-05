//
//  AppDelegate.m
//  HistogramWindow_ShowTest
//
//  Created by Hank0272 on 12/12/4.
//  Copyright (c) 2012年 Ortery Technology, Inc. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate
@synthesize window;
@synthesize sourceImageView;
@synthesize hvController;

- (void)dealloc
{
    [hvController release];
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    hvController = [[HistogramViewController alloc] initWithWindowNibName:@"HistogramViewController"];
    [self.window addChildWindow:hvController.window ordered:NSWindowBelow];
    [self _initLoadImage:@"/Users/Eric/Pictures/lion-256height.jpg"];
}

- (IBAction)openExistImage:(id)sender
{
    
}
- (IBAction)showHistogramWindow:(id)sender
{
    [hvController reLoadImage:self.sourceImageView.image];
    [[hvController hWindow]makeMainWindow];
}

- (void)_initLoadImage:(NSString *)fileName
{
    NSImage *nImage = [[NSImage alloc]initByReferencingFile:fileName];
    self.sourceImageView.image = nImage;
    [nImage release];
}
@end
