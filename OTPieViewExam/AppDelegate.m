//
//  AppDelegate.m
//  OTPieViewExam
//
//  Created by Hank0272 on 12/9/17.
//  Copyright (c) 2012年 Eric Yeh. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate
/* keys used in our preset dictionaries */
NSString *kLevelKey = @"speed";
NSString *kTicksKey = @"ticks";
NSString *kTitleKey = @"title";

@synthesize presetButtonOne;
@synthesize presetButtonTwo;
@synthesize presetButtonThree;
@synthesize presetOneValues;
@synthesize presetTwoValues;
@synthesize presetThreeValues;
@synthesize tokenField;
@synthesize speedSlider;
@synthesize popUpButton;
@synthesize movePopUpButton;
@synthesize directionMatrix;
@synthesize graphicMatrix;

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
//    [NSAnimationContext beginGrouping];
//    [[NSAnimationContext currentContext] setDuration:3.0f];
//    [[pieView animator] setFrameOrigin:NSMakePoint([pieView frame].origin.x, 10.0)];
//    [NSAnimationContext endGrouping];
}

- (IBAction)presetThree:(id)sender {
    self.tokenField.stringValue = @"1,2,3,4,5,6,7,8,9,10,11,12";
    [self valueSet:sender];
}

- (IBAction)valueSet:(id)sender
{
    NSMutableArray *contentArray = [NSMutableArray arrayWithArray:[self.tokenField.stringValue componentsSeparatedByString:@","]];
    [pieView setTickMarkers:contentArray];


//    if (pieView.otPieViewGraph == kGrpah_Circle) {
//        self.speedSlider.numberOfTickMarks = [contentArray count] - 1;
//    } else {
//        self.speedSlider.numberOfTickMarks = [contentArray count];
//    }
    self.speedSlider.numberOfTickMarks = [contentArray count];
    
    [popUpButton removeAllItems];
    [movePopUpButton removeAllItems];
    for (int i = 0 ; i < [pieView.tickMarkers count]; i++) {
        [popUpButton addItemWithTitle:[NSString stringWithFormat:@"%i", i]];
        [movePopUpButton addItemWithTitle:[NSString stringWithFormat:@"%i", i]];
    }
    [self goTick:nil];
}

- (IBAction)speedSet:(id)sender
{
    [pieView setTotalTicks:[sender floatValue]];
}

- (IBAction)goTick:(id)sender
{
    if ([movingTickTimer isValid]) {
        [movingTickTimer invalidate];
        movingTickTimer = nil;
    }
    [pieView setCurrentTick:[[sender title]intValue] animated:NO];
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
    } else {
        [pieView setDegrees:kGrpah_Semicircle];
    }
}

- (IBAction)timerTickGo:(id)sender
{
//    [NSAnimationContext beginGrouping];
//    [[NSAnimationContext currentContext] setDuration:3.0f];
//    int moveButtonIndex = [[self.movePopUpButton title] intValue];
//    NSLog(@"newSpeed: %i, oldSpeed: %i", newSpeed, oldSpeed);
//    [[pieView animator] setTickMark:moveButtonIndex];
//    [NSAnimationContext endGrouping];
    
    
    int moveButtonIndex = [[self.movePopUpButton title] intValue];    
//    NSLog(@"newSpeed: %i, oldSpeed: %i", newSpeed, oldSpeed);
    [pieView setCurrentTick:moveButtonIndex animated:YES];
    float value = 360 * (float)moveButtonIndex / (self.speedSlider.numberOfTickMarks - 1);
    self.speedSlider.floatValue = value;
//    newSpeed = pieView.speed;
//    int moveButtonIndex = [[self.movePopUpButton title] intValue];
//    if (pieView.clockwise) {
//        oldSpeed = ((float)moveButtonIndex / ([pieView.labelArray count] - 1)) * 100;
//    } else {
//        if (moveButtonIndex == 0) {
//            oldSpeed = 0;
//        } else {
//            oldSpeed = ((float)([pieView.labelArray count] - moveButtonIndex) / ([pieView.labelArray count] - 1)) * 100;            
//        }
//    }

    
//    if ([movingTickTimer isValid]) {
//        [movingTickTimer invalidate];
//        movingTickTimer = nil;
//    }
//    movingTickTimer = [NSTimer scheduledTimerWithTimeInterval:0.005 target:self selector:@selector(updateTimer) userInfo:nil repeats:YES];

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
//            [popUpButton setTitle:[self.movePopUpButton title]];
        }
    }
}

@end
