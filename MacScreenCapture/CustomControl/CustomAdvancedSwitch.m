//
//  CustomAdvancedSwitch.m
//  MacScreenCapture
//
//  Created by lms on 4/23/15.
//  Copyright (c) 2015 elif. All rights reserved.
//

#import "CustomAdvancedSwitch.h"
#import "Util.h"

#define BT_SWITCH_ICO2              @"bt_switch.png"
#define BT_SWITCH_MASK              @"mask_switch.png"
#define TURN_ON_BLUE_ICON           @"switchOffButton.png"

@implementation CustomAdvancedSwitch
{
    id _pTarget;
    SEL _pExecFunc;
}

-(void) setTarget:(id)pTarget withExecFunc:(SEL)pExecFunc
{
    _pTarget = pTarget;
    _pExecFunc = pExecFunc;
}

- (id)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self) {
        // Initialization code here.
        _switchImageView = [[NSImageView alloc] initWithFrame:NSMakeRect(2, 2, 119, 40)];
        [_switchImageView setImage:[NSImage imageNamed:TURN_ON_BLUE_ICON]];
        [_switchImageView setImageScaling:NSImageScaleAxesIndependently];
        [self addSubview:_switchImageView];
        
        _markedImageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, 123, 44)];
        [_markedImageView setImage:[NSImage imageNamed:BT_SWITCH_MASK]];
        [_markedImageView setImageScaling:NSImageScaleAxesIndependently];
        [self addSubview:_markedImageView];
        
        _buttonImageView = [[NSImageView alloc] initWithFrame:NSMakeRect(5, 6, 56, 32)];
        [_buttonImageView setImage:[NSImage imageNamed:BT_SWITCH_ICO2]];
        [_buttonImageView setImageScaling:NSImageScaleAxesIndependently];
        [self addSubview:_buttonImageView];
        
        
        _flag=YES;
        
    }
    
    return self;
}

- (void)mouseDown:(NSEvent *)theEvent{
        NSEvent *newEvent = [self.window
                             nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask)];
        
        if ([newEvent type] == NSLeftMouseUp)
        {
            
            [_switchImageView setImage:[NSImage imageNamed:@"switchOnButton.png"]];
            bool _n_flag;
            _n_flag = YES;
          
            [self setNeedsDisplay:YES];
            
            if (_n_flag != _flag)
            {
                _flag = _n_flag;
                if (_pTarget != nil && _pExecFunc != nil)   {
                    ((void (*)(id, SEL))[_pTarget methodForSelector:_pExecFunc])(_pTarget, _pExecFunc);
                }
            }
            
        } else if ([newEvent type] == NSLeftMouseDragged)
        {
            [_switchImageView setImage:[NSImage imageNamed:@"switchOffButton.png"]];
            [self setNeedsDisplay:YES];
        }
}

- (void)setStatus:(Boolean)mFlag{
    _flag=mFlag;
    
    NSSize sizeofbt = [_buttonImageView frame].size;
    NSSize sizeofme = [self frame].size;
    
    NSPoint location;
    
    location.y = 6;
    
    if(!_flag) {
        location.x = 5;
    } else {
        location.x=sizeofme.width - sizeofbt.width - 5;
    }
     
    [_buttonImageView setFrameOrigin:location];
}

- (bool)getStatus
{
    return _flag;
}

@end
