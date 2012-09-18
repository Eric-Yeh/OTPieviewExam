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
    IBOutlet SpeedometerView *meterView;
    NSMutableDictionary *presetOneValues, *presetTwoValues, *presetThreeValues;
	
    NSButton* presetButtonOne;
    NSButton* presetButtonTwo;
    NSButton* presetButtonThree;
    IBOutlet NSTokenField *setTokenField;
}

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, assign) IBOutlet NSButton* presetButtonOne;
@property (nonatomic, assign) IBOutlet NSButton* presetButtonTwo;
@property (nonatomic, assign) IBOutlet NSButton* presetButtonThree;
@property (nonatomic, assign) IBOutlet NSTokenField *setTokenField;

@property (nonatomic, strong) NSMutableDictionary *presetOneValues;
@property (nonatomic, strong) NSMutableDictionary *presetTwoValues;
@property (nonatomic, strong) NSMutableDictionary *presetThreeValues;

- (IBAction)presetOne:(id)sender;
- (IBAction)presetTwo:(id)sender;
- (IBAction)presetThree:(id)sender;
- (IBAction)valueSet:(id)sender;
- (IBAction)speedSet:(id)sender;
@end
