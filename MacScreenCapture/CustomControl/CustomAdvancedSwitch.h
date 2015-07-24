//
//  CustomAdvancedSwitch.h
//  BitMedicAntiVirus
//
//  Created by lms on 3/23/15.
//  Copyright (c) 2015 elif. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CustomAdvancedSwitch : NSView

@property NSImageView *switchImageView;
@property NSImageView *buttonImageView;
@property NSImageView *markedImageView;


@property Boolean flag;
@property NSPoint orgPt;
@property NSPoint orgLocation;
@property NSPoint orgLocation1;
@property NSPoint orgLocation2;
@property Boolean orgflag;
@property Boolean animateFlag;

-(void) setTarget:(id)pTarget withExecFunc:(SEL)pExecFunc;

- (void)setStatus:(Boolean)mFlag;
- (bool)getStatus;

@end
