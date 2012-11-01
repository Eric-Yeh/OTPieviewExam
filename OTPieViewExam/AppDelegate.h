//
//  AppDelegate.h
//  OTPieViewExam
//
//  Created by Hank0272 on 12/9/17.
//  Copyright (c) 2012年 Eric Yeh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <OTUIKit/OTPieView.h>
#import <OTFoundation/OTFoundation.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    IBOutlet OTPieView *pieView;
    NSMutableDictionary *presetOneValues, *presetTwoValues, *presetThreeValues;
    NSButton *presetButtonOne;
    NSButton *presetButtonTwo;
    NSButton *presetButtonThree;
    IBOutlet NSTextField *rulerTextField;
    IBOutlet NSTokenField *tokenField;
    IBOutlet NSSlider *speedSlider;
    IBOutlet NSPopUpButton *popUpButton;
    IBOutlet NSPopUpButton *movePopUpButton;
    IBOutlet NSMatrix *directionMatrix;
    IBOutlet NSMatrix *graphicMatrix;
    NSTimer *movingTickTimer;
    int newSpeed;
    int oldSpeed;
    
    IBOutlet NSImageView *oriImage;
    IBOutlet NSImageView *dstImage;
    IBOutlet NSImageView *tmpImage;
}

@property (assign) IBOutlet NSWindow *window;

@property (nonatomic, assign) IBOutlet NSButton *presetButtonOne;
@property (nonatomic, assign) IBOutlet NSButton *presetButtonTwo;
@property (nonatomic, assign) IBOutlet NSButton *presetButtonThree;
@property (nonatomic, assign) IBOutlet NSTextField *rulerTextField;
@property (nonatomic, assign) IBOutlet NSTokenField *tokenField;
@property (nonatomic, assign) IBOutlet NSSlider *speedSlider;
@property (nonatomic, assign) IBOutlet NSPopUpButton *popUpButton;
@property (nonatomic, assign) IBOutlet NSPopUpButton *movePopUpButton;
@property (nonatomic, assign) IBOutlet NSMatrix *directionMatrix;
@property (nonatomic, assign) IBOutlet NSMatrix *graphicMatrix;
@property (retain) IBOutlet NSImageView *oriImage;
@property (retain) IBOutlet NSImageView *dstImage;
@property (retain) IBOutlet NSImageView *tmpImage;


@property (nonatomic, strong) NSMutableDictionary *presetOneValues;
@property (nonatomic, strong) NSMutableDictionary *presetTwoValues;
@property (nonatomic, strong) NSMutableDictionary *presetThreeValues;

- (IBAction)presetOne:(id)sender;
- (IBAction)presetTwo:(id)sender;
- (IBAction)presetThree:(id)sender;
- (IBAction)rulerSet:(id)sender;
- (IBAction)valueSet:(id)sender;
- (IBAction)speedSet:(id)sender;
- (IBAction)goTick:(id)sender;
- (IBAction)directionSet:(id)sender;
- (IBAction)graphSet:(id)sender;
- (IBAction)timerTickGo:(id)sender;

- (IBAction)saveImageTo:(id)sender;
- (IBAction)openImageFrom:(id)sender;
@end
