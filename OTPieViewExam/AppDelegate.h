//
//  AppDelegate.h
//  OTPieViewExam
//
//  Created by Hank0272 on 12/9/17.
//  Copyright (c) 2012年 Eric Yeh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <OTUIKit/OTPieView.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    IBOutlet OTPieView *pieView;
    NSMutableDictionary *presetOneValues, *presetTwoValues, *presetThreeValues;
	
    NSButton* presetButtonOne;
    NSButton* presetButtonTwo;
    NSButton* presetButtonThree;
    IBOutlet NSTokenField *tokenField;
    IBOutlet NSSlider *speedSlider;
    IBOutlet NSPopUpButton *popUpButton;
    IBOutlet NSPopUpButton *movePopUpButton;
    IBOutlet NSMatrix *directionMatrix;
    NSTimer *movingTickTimer;
    int newSpeed;
    int oldSpeed;
}

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, assign) IBOutlet NSButton* presetButtonOne;
@property (nonatomic, assign) IBOutlet NSButton* presetButtonTwo;
@property (nonatomic, assign) IBOutlet NSButton* presetButtonThree;
@property (nonatomic, assign) IBOutlet NSTokenField *tokenField;
@property (nonatomic, assign) IBOutlet NSSlider *speedSlider;
@property (nonatomic, assign) IBOutlet NSPopUpButton *popUpButton;
@property (nonatomic, assign) IBOutlet NSPopUpButton *movePopUpButton;
@property (nonatomic, assign) IBOutlet NSMatrix *directionMatrix;

@property (nonatomic, strong) NSMutableDictionary *presetOneValues;
@property (nonatomic, strong) NSMutableDictionary *presetTwoValues;
@property (nonatomic, strong) NSMutableDictionary *presetThreeValues;

- (IBAction)presetOne:(id)sender;
- (IBAction)presetTwo:(id)sender;
- (IBAction)presetThree:(id)sender;
- (IBAction)valueSet:(id)sender;
- (IBAction)speedSet:(id)sender;
- (IBAction)goTick:(id)sender;
- (IBAction)directionSet:(id)sender;
- (IBAction)timerTickGo:(id)sender;

@end
