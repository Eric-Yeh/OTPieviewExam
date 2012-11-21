//
//  OTLayerDrawing.m
//  OTPieViewExam
//
//  Created by Hank0272 on 12/11/19.
//  Copyright (c) 2012年 Ortery Technology, Inc. All rights reserved.
//

#import "OTLayerDrawing.h"

@implementation OTLayerDrawing

@synthesize layer1, layer2;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        [self setWantsLayer:YES];
//        layer1 = [[CALayer alloc]init];
        layer1 = [CALayer layer];
        layer1.name = @"Layer1";
        layer2 = [CALayer layer];
        layer2.name = @"Layer2";
//        [self.layer1 setDelegate:self];
//        [self.layer2 setDelegate:self];
        self.layer.frame = self.frame; //CGRectMake(0, 0, 320, 180);
        [layer2 setBackgroundColor:CGColorCreateFromNSColor([NSColor whiteColor], CGColorSpaceCreateDeviceRGB())];
        [self.layer addSublayer:layer2];
        self.layer.frame = CGRectMake(30, 60, 260, 160);
        [layer1 setBackgroundColor:CGColorCreateFromNSColor([NSColor lightGrayColor], CGColorSpaceCreateDeviceRGB())];
        [self.layer addSublayer:layer1];
        
        [layer1 setHidden:NO];
        [layer2 setHidden:NO];
        
//        [layer1 setNeedsDisplay];
//        [layer2 setNeedsDisplay];
    }
    
    return self;
}

- (void)dealloc
{
//    [layer1 release]; layer1 = nil;
//    [layer2 release]; layer2 = nil;
    [super dealloc];
}

static CGFloat randomFloat()
{
    CGFloat f = (rand() % RAND_MAX) / (float)(RAND_MAX);
    return f;
}

static CGPoint randomPointInBounds(CGRect bounds)
{
	CGFloat x = randomFloat() * bounds.size.width + bounds.origin.x;
	CGFloat y = randomFloat() * bounds.size.height + bounds.origin.y;
	return CGPointMake(x, y);
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context
{
    //要如何接 Dictionary 的資料
    //要怎麼在之後存取到 layer
    NSLog(@"drawLayer");
//    [self backgroundLayer:context];
//    [self drawBorderLayer:context];
    if ([layer.name isEqualToString:layer1.name]) {
        NSLog(@"Layer1 enter");
    } else if ([layer.name isEqualToString:layer2.name]) {
        NSLog(@"Layer2 enter");
    }
    
    if (layer == layer1) {
        [self drawBorderLayer:context];
        NSLog(@"layer1 Layer");
    } else if (layer == layer2) {
        [self backgroundLayer:context];
        NSLog(@"layer2 Layer");
    }
    
//	CGRect bounds = CGContextGetClipBoundingBox(context);
//	CGContextSetRGBFillColor(context, randomFloat(), randomFloat(), randomFloat(), 1.0);
//	CGContextFillRect(context, bounds);
//	
//	int sides = (random() % 18) + 1;
//	CGPoint p = randomPointInBounds(bounds);
//	CGContextMoveToPoint(context, p.x, p.y);
//	for(int i = 0; i < sides; ++i)
//	{
//		p = randomPointInBounds(bounds);
//		CGContextAddLineToPoint(context, p.x, p.y);
//	}
//	CGContextClosePath(context);
//	CGContextSetRGBFillColor(context, randomFloat(), randomFloat(), randomFloat(), 1.0);
//	CGContextEOFillPath(context);
}

- (void)drawBorderLayer:(CGContextRef)context
{
    //底框
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef borderColor = CGColorCreateFromNSColor([NSColor blackColor], colorSpace);
    CGContextAddRect(context, CGRectMake(1 , 1, 260, 100));
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context, borderColor); //線色
    CGContextStrokePath(context);
    CGContextClosePath(context);
//	CGContextRestoreGState(context);
}

- (void)backgroundLayer:(CGContextRef)context
{
    //背景
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef borderColor = CGColorCreateFromNSColor([NSColor whiteColor], colorSpace);
    CGContextAddRect(context, CGRectMake(0, 0, 320, 180));
    CGContextSetFillColorWithColor(context, borderColor); //內容色
    
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context, borderColor); //線色
    CGContextDrawPath(context, kCGPathFillStroke);
    CGContextClosePath(context);
    CGContextEOFillPath(context);
    
//    CGContextSetLineWidth(context, 1.0);
//    CGContextSetFillColorWithColor(context, borderColor); //內容色
//    CGContextSetStrokeColorWithColor(context, borderColor); //線色
//    CGContextAddRect(context, CGRectMake(0 , 0, 320, 180));
//
//    CGContextStrokePath(context);
//    CGContextDrawPath(context, kCGPathFillStroke);
//    CGContextClosePath(context);
//    CGContextEOFillPath(context);
//	CGContextRestoreGState(context);
    
}


- (void)changeLayerPosition:(CALayer *)layer toPosition:(NSPoint)position
{
    NSLog(@"%@", layer.name);
    layer.position = position;
//    [layer setFrame:CGRectMake(position.x, position.y, layer.frame.size.width, layer.frame.size.height)];
//    if (layer == layer1) {
//        NSLog(@"layer1 Layer");
//    } else if (layer == layer2) {
//        [layer2 setFrame:CGRectMake(position.x, position.y, layer1.frame.size.width, layer1.frame.size.height)];
//        NSLog(@"layer2 Layer");
//    }
}

- (void)changeDisplayLayer:(CALayer *)layerA
{
    //    [layer setHidden:YES];
    //    NSLog(@"%@", layer.name);
    //        [layer setHidden:NO];
//    [self.layer1 setDelegate:self];
//    [self.layer2 setDelegate:self];
    [layerA setNeedsDisplay];
    [layer1 setNeedsDisplay];
    [layer2 setNeedsDisplay];
//    [layer1 setNeedsDisplayOnBoundsChange:YES];

//    NSLog(@"%@", [self.layer sublayers]);
    
}
CGColorRef CGColorCreateFromNSColor(NSColor *color, CGColorSpaceRef colorSpace)
{
    NSColor *deviceColor = [color colorUsingColorSpaceName:NSDeviceRGBColorSpace];
    CGFloat components[4];
    [deviceColor getRed:&components[0] green:&components[1] blue:&components[2] alpha:&components[3]];
    
    return CGColorCreate (colorSpace, components);
}

@end
