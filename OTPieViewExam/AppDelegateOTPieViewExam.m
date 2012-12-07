//
//  AppDelegate.m
//  OTPieViewExam
//
//  Created by Hank0272 on 12/9/17.
//  Copyright (c) 2012年 Eric Yeh. All rights reserved.
//

#import "AppDelegateOTPieViewExam.h"

@implementation AppDelegateOTPieViewExam
/* keys used in our preset dictionaries */
NSString *kLevelKey = @"speed";
NSString *kTicksKey = @"ticks";
NSString *kTitleKey = @"title";

@synthesize presetButtonOne;
@synthesize presetButtonTwo;
@synthesize presetButtonThree;
@synthesize rulerTextField;
@synthesize presetOneValues;
@synthesize presetTwoValues;
@synthesize presetThreeValues;
@synthesize tokenField;
@synthesize speedSlider;
@synthesize popUpButton;
@synthesize movePopUpButton;
@synthesize directionMatrix;
@synthesize graphicMatrix;

@synthesize histogramDrawLayer;
@synthesize histogramDataInfo;
- (void)dealloc
{
    [super dealloc];
    if ([movingTickTimer isValid]) {
            [movingTickTimer invalidate];
            movingTickTimer = nil;
        }

}

- (void)awakeFromNib {
    
	[NSApp setDelegate: self];
    
    /* set the timings for the preset buttons */
	[presetButtonOne setPeriodicDelay:1.0 interval:60.0];
	[presetButtonTwo setPeriodicDelay:1.0 interval:60.0];
	[presetButtonThree setPeriodicDelay:1.0 interval:60.0];
	
    /* set up some default preset values */
    presetOneValues = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                       [NSNumber numberWithFloat:33.0], kLevelKey,
                       [NSNumber numberWithInt:14], kTicksKey,
                       nil];
    presetTwoValues = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                       [NSNumber numberWithFloat:56.0], kLevelKey,
                       [NSNumber numberWithInt:9], kTicksKey,
                       nil];
    presetThreeValues = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                         [NSNumber numberWithFloat:89.0], kLevelKey,
                         [NSNumber numberWithInt:14], kTicksKey,
                         nil];
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    self.tokenField.stringValue = @"A,B,C";
    [self valueSet:nil];
    [pieView setDegrees:kGrpah_Circle];
    [pieView setDrawingClockwise:YES];
    histogramDataInfo = [[OTHistogramData alloc]initWithHistogramLayerDrawing:histogramDrawLayer];
    NSImage *nImage = [[NSImage alloc]initByReferencingFile:@"/Users/Eric/Pictures/lion-256height.jpg"];
    NSBitmapImageRep *bitmapRep = [[[NSBitmapImageRep alloc] initWithData:[nImage TIFFRepresentation]]autorelease];
    [histogramDataInfo resizedCGImage:bitmapRep];
    [nImage release];
//    [histogramDrawLayer makesChannelVisible:kOTHistogramChannel_All];

}


- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
	return YES;
}

- (void)savePreset:(NSButton *)theButton toStore:(NSDictionary **)presetValues {
    
    /* set the title to acknowledge that we're setting the preset */
	NSString *savedTitle = [theButton title];
	[theButton setTitle: @"SET"];
	[*presetValues release];
	*presetValues = [[[NSDictionary alloc] initWithObjectsAndKeys:
                      [NSNumber numberWithFloat:[pieView volume]], kLevelKey,
                      [NSNumber numberWithInt:[pieView ticks]], kTicksKey,
                      savedTitle, kTitleKey,
                      nil] autorelease];
}

- (void)gotoPreset:(NSDictionary *)presetValues forButton:(NSButton *)theButton {
    
	[pieView setTotalTicks: [[presetValues objectForKey:kLevelKey] floatValue]];
	NSString *theTitle = [presetValues objectForKey:kTitleKey];
	if ( theTitle != nil ) {
        /* set the title back to normal. */
		[theButton setTitle: theTitle];
	}
}

- (IBAction)presetOne:(id)sender {
    self.tokenField.stringValue = @"A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z";
    [self valueSet:sender];
}

- (IBAction)presetTwo:(id)sender {
    self.tokenField.stringValue = @"一,二,三,四,五,六,七,八,九";
    [self valueSet:sender];
}

- (IBAction)presetThree:(id)sender {
//    self.tokenField.stringValue = @"1,2,3,4,5,6,7,8,9,10,11,12";
//    [self valueSet:sender];
//    [histogramDrawLayer makesChannelVisible:kOTHistogramChannel_All];
    
}

- (IBAction)valueSet:(id)sender
{
    NSMutableArray *contentArray = [NSMutableArray arrayWithArray:[self.tokenField.stringValue componentsSeparatedByString:@","]];
    [pieView initializeLabels:contentArray];
    self.rulerTextField.stringValue = [NSString stringWithFormat:@"%ld", [pieView.tickMarkers count]];

    [self rulerSet:nil];
}

- (IBAction)rulerSet:(id)sender
{
    self.speedSlider.numberOfTickMarks = [self.rulerTextField.stringValue integerValue];
    [pieView setTotalTicks:self.speedSlider.numberOfTickMarks];
    [popUpButton removeAllItems];
    [movePopUpButton removeAllItems];
    for (int i = 0 ; i < [self.rulerTextField.stringValue integerValue]; i++) {
        [popUpButton addItemWithTitle:[NSString stringWithFormat:@"%i", i]];
        [movePopUpButton addItemWithTitle:[NSString stringWithFormat:@"%i", i]];
    }
    [self goTick:nil];
}

- (IBAction)speedSet:(id)sender
{
    [pieView setCurrentTick:[sender floatValue]];
}

- (IBAction)goTick:(id)sender
{
    if ([movingTickTimer isValid]) {
        [movingTickTimer invalidate];
        movingTickTimer = nil;
    }
    [pieView setCurrentTickMark:[[sender title]intValue] animated:NO];
    int moveButtonIndex = [[self.popUpButton title] intValue];
    float value = 360 * (float)moveButtonIndex / (self.speedSlider.numberOfTickMarks - 1);
    self.speedSlider.floatValue = value;
}

- (IBAction)directionSet:(id)sender
{

    if([[sender selectedCell] tag] == 1) {
        [pieView setDrawingClockwise:YES];
    } else {
        [pieView setDrawingClockwise:NO];
    }
}

- (IBAction)graphSet:(id)sender
{
    if([[sender selectedCell] tag] == 1) {
        [pieView setDegrees:kGrpah_Circle];
        [self.originMatrix setEnabled:YES];
    } else {
        [pieView setDegrees:kGrpah_Semicircle];
        [self.originMatrix setEnabled:NO];
    }
}

- (IBAction)originSet:(id)sender
{
    if([[sender selectedCell] tag] == 1) {
        [pieView setOriginAt:kOrigin_6Clock];
    } else {
        [pieView setOriginAt:kOrigin_12Clock];
    }
}

- (IBAction)timerTickGo:(id)sender
{    
    int moveButtonIndex = [[self.movePopUpButton title] intValue];    
//    NSLog(@"newSpeed: %i, oldSpeed: %i", newSpeed, oldSpeed);
    [pieView setCurrentTickMark:moveButtonIndex animated:YES];
    float value = 360 * (float)moveButtonIndex / (self.speedSlider.numberOfTickMarks - 1);
    self.speedSlider.floatValue = value;

}

- (void)updateTimer
{
    newSpeed = pieView.volume;
    if (newSpeed > oldSpeed) {
        --newSpeed;
        [pieView setTotalTicks:newSpeed];
        
    } else if (newSpeed < oldSpeed) {
        ++newSpeed;
        [pieView setTotalTicks:newSpeed];
    } else {
        if ([movingTickTimer isValid]) {
            [movingTickTimer invalidate];
            movingTickTimer = nil;
        }
    }
}

@end
