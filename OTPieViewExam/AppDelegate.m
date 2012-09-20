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
@synthesize directionMatrix;

- (void)dealloc
{
    [super dealloc];
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
                      [NSNumber numberWithFloat:[pieView speed]], kLevelKey,
                      [NSNumber numberWithInt:[pieView ticks]], kTicksKey,
                      savedTitle, kTitleKey,
                      nil] autorelease];
}

- (void)gotoPreset:(NSDictionary *)presetValues forButton:(NSButton *)theButton {
    
	[pieView setSpeed: [[presetValues objectForKey:kLevelKey] floatValue]];
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

    self.tokenField.stringValue = @"1,2,3,4,5,6,7,8,9,10,11,12";
    [self valueSet:sender];
}

- (IBAction)valueSet:(id)sender
{
    NSMutableArray *contentArray = [NSMutableArray arrayWithArray:[self.tokenField.stringValue componentsSeparatedByString:@","]];
    [pieView changeDisplayValue:contentArray];
    self.speedSlider.numberOfTickMarks = [contentArray count] - 1;
    [popUpButton removeAllItems];
    for (int i = 0 ; i < [pieView.labelArray count]; i++) {
        [popUpButton addItemWithTitle:[NSString stringWithFormat:@"%i", i]];
    }
    [self goTick:nil];
}

- (IBAction)speedSet:(id)sender
{
    [pieView setSpeed:[sender floatValue]];
}

- (IBAction)goTick:(id)sender
{
    [pieView goTickMark:[[sender title]intValue]];
}

- (IBAction)directionSet:(id)sender
{
    if([[sender selectedCell] tag] == 1) {
        [pieView changeDisplayDirection:YES];
    } else
    {
        [pieView changeDisplayDirection:NO];
    }
}

@end
