
/*
 File: DrawMouseBoxView.m
 Abstract: Dims the screen and allows user to select a rectangle with a cross-hairs cursor
 Version: 2.1
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 
 */

#import "DrawMouseBoxView.h"
#import "../AppDelegate.h"

@implementation DrawMouseBoxView
{
    NSPoint _mouseDownPoint;
    NSRect _selectionRect;
    
    NSTimer* timerScanning;
    bool recordingmark_visible;
}


- (BOOL) acceptsFirstResponder
{
    return YES;
}
- (BOOL)acceptsMouseMovedEvents
{
    return YES;
}
-(id) initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if(self){
        self.recording = false;
        self.backingScaleFactor = 1.0;
        self.customSelectionMode = true;
        NSTrackingArea* trackingArea = [[NSTrackingArea alloc] initWithRect:frameRect options:(NSTrackingMouseEnteredAndExited|NSTrackingMouseMoved|NSTrackingActiveAlways|NSTrackingInVisibleRect|NSTrackingActiveInKeyWindow) owner:self userInfo:nil];
        [self addTrackingArea:trackingArea];
     }
    return self;
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
    return YES;
}

- (void) setRecordingValue:(bool) val
{
    self.recording = val;
    [self display];
}
-(void) setBackingScaleFactorValue:(float)val
{
    self.backingScaleFactor = val;
}
- (void)keyDown:(NSEvent *)theEvent
{
    if([theEvent keyCode] == 53){
         AppDelegate* app = [[NSApplication sharedApplication] delegate];
        
        if(!app.is_recording){
            for (NSWindow* w in [NSApp windows])
            {
                if ([w level] == kShadyWindowLevel)
                {
                    [w close];
                }
            }
            
            [app.frameView.btn_pause setHidden:YES];
            [app.frameView.btn_record setHidden:NO];
        }else{
            
            //  [app stopRecording];
            //  [app.frameView updateHistory];

        }
    }
}
-(void) mouseEntered:(NSEvent *)theEvent{
    if(!self.recording){
        [[NSCursor crosshairCursor] set];
    }

}
- (void)mouseDown:(NSEvent *)theEvent
{
    _mouseDownPoint = [theEvent locationInWindow];
    self.recording = false;
}
-(void) SetElapsedTime
{
    recordingmark_visible = !recordingmark_visible;
    [self display];
}
-(void) setFullScreenCapture
{
    _selectionRect = self.bounds;

    NSRect dispRect;
    dispRect.origin.x = _selectionRect.origin.x*self.backingScaleFactor;
    dispRect.origin.y = _selectionRect.origin.y*self.backingScaleFactor;
    dispRect.size.width = _selectionRect.size.width*self.backingScaleFactor;
    dispRect.size.height = _selectionRect.size.height*self.backingScaleFactor;
    
    [self.window setLevel:kRecordingShadyWindowLevel];
    [self.window setIgnoresMouseEvents:YES];
    [self.delegate drawMouseBoxView:self didSelectRect:dispRect BackingScaleFactor:self.backingScaleFactor];
    [self setRecordingValue:true];
    [self.window setAlphaValue:0.85];
    [self.window setOpaque:NO];
    [self display];
    
    
    [timerScanning invalidate];
    timerScanning = nil;
    
    timerScanning = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(SetElapsedTime) userInfo:self repeats:YES];
    
    [[NSCursor arrowCursor] set];

}
- (void)mouseUp:(NSEvent *)theEvent
{
        NSPoint mouseUpPoint = [theEvent locationInWindow];
       _selectionRect = NSMakeRect(
                                      MIN(_mouseDownPoint.x, mouseUpPoint.x),
                                      MIN(_mouseDownPoint.y, mouseUpPoint.y),
                                      MAX(_mouseDownPoint.x, mouseUpPoint.x) - MIN(_mouseDownPoint.x, mouseUpPoint.x),
                                      MAX(_mouseDownPoint.y, mouseUpPoint.y) - MIN(_mouseDownPoint.y, mouseUpPoint.y));
    if((_selectionRect.size.height > 30) && (_selectionRect.size.width > 30)){
        
        NSRect dispRect;
        dispRect.origin.x = _selectionRect.origin.x*self.backingScaleFactor;
        dispRect.origin.y = _selectionRect.origin.y*self.backingScaleFactor;
        dispRect.size.width = _selectionRect.size.width*self.backingScaleFactor;
        dispRect.size.height = _selectionRect.size.height*self.backingScaleFactor;

        [self.window setLevel:kRecordingShadyWindowLevel];
        [self.window setIgnoresMouseEvents:YES];
        [self.delegate drawMouseBoxView:self didSelectRect:dispRect BackingScaleFactor:self.backingScaleFactor];
        [self setRecordingValue:true];
        [self.window setAlphaValue:0.85];
        [self.window setOpaque:NO];
        [self display];
        
        
        [timerScanning invalidate];
        timerScanning = nil;
        
        timerScanning = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(SetElapsedTime) userInfo:self repeats:YES];
        
        [[NSCursor arrowCursor] set];
        
    }
}
-(void) viewDidMoveToWindow
{
    if(!self.recording){
        [[NSCursor crosshairCursor] set];
        [self display];
        if(!self.customSelectionMode){
            [self setFullScreenCapture];
        }
    }
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    NSPoint curPoint = [theEvent locationInWindow];
    //	NSRect previousSelectionRect = _selectionRect;
    _selectionRect = NSMakeRect(
                                MIN(_mouseDownPoint.x, curPoint.x),
                                MIN(_mouseDownPoint.y, curPoint.y),
                                MAX(_mouseDownPoint.x, curPoint.x) - MIN(_mouseDownPoint.x, curPoint.x),
                                MAX(_mouseDownPoint.y, curPoint.y) - MIN(_mouseDownPoint.y, curPoint.y));
    
    [self setNeedsDisplay:YES];
    [[NSCursor crosshairCursor] set];

}

-(void) mouseMoved:(NSEvent *)theEvent
{
    if(!self.recording){
        [[NSCursor crosshairCursor] set];
    }
}

- (void)drawRect:(NSRect)dirtyRect
{
    if(self.customSelectionMode){
        if(!self.recording){
            [[NSCursor crosshairCursor] set];
            [self drawLabel];
        }

    //	NSFrameRect(_selectionRect);
        if((_selectionRect.size.height <= 30) || (_selectionRect.size.width <= 30)){
            return;
        }
    
    
        if(self.recording)
        {
            [[NSColor clearColor] setFill];
            NSRectFill(dirtyRect);
        
            if(recordingmark_visible){
                [[NSColor redColor] setStroke];
            }else{
                [[NSColor clearColor] setStroke];
            }
            [[NSCursor arrowCursor] set];
            
        }else{
            [[NSColor colorWithCalibratedWhite:0.0 alpha:0.5] setFill];
            NSRectFill(dirtyRect);
        
            [[NSColor whiteColor] setFill];
            NSRectFill(_selectionRect);
        
            [[NSGraphicsContext currentContext] setShouldAntialias: NO];
            [[NSColor yellowColor] setStroke];
        
            /*
             [[NSColor blueColor] setStroke];
             NSBezierPath *line = [NSBezierPath bezierPathWithRect:NSIntegralRect(_cropRect)];
             line.lineWidth = 1;
             [line stroke];
             */
       
        }
    }else{
        [[NSColor clearColor] setFill];
        NSRectFill(dirtyRect);
        _selectionRect = self.bounds;
    }
    NSBezierPath *line = [NSBezierPath bezierPath];
    line.lineWidth = 3;
    
    NSPoint pt1 = {_selectionRect.origin.x-2, _selectionRect.origin.y+20};
    NSPoint pt2 = {_selectionRect.origin.x-2, _selectionRect.origin.y-2};
    NSPoint pt3 = {_selectionRect.origin.x + 20, _selectionRect.origin.y-2};
    
    [line moveToPoint:pt1];
    [line lineToPoint:pt2];
    [line lineToPoint:pt3];
    
    NSPoint pt4 = {_selectionRect.origin.x + _selectionRect.size.width + 2, _selectionRect.origin.y+20};
    NSPoint pt5 = {_selectionRect.origin.x + _selectionRect.size.width + 2, _selectionRect.origin.y - 2};
    NSPoint pt6 = {_selectionRect.origin.x + _selectionRect.size.width - 20, _selectionRect.origin.y -2 };
    
    [line moveToPoint:pt4];
    [line lineToPoint:pt5];
    [line lineToPoint:pt6];
    
    NSPoint pt7 = {_selectionRect.origin.x + _selectionRect.size.width + 2, _selectionRect.origin.y + _selectionRect.size.height - 20};
    NSPoint pt8 = {_selectionRect.origin.x + _selectionRect.size.width + 2, _selectionRect.origin.y + _selectionRect.size.height + 2};
    NSPoint pt9 = {_selectionRect.origin.x + _selectionRect.size.width - 20, _selectionRect.origin.y + _selectionRect.size.height + 2};
    
    [line moveToPoint:pt7];
    [line lineToPoint:pt8];
    [line lineToPoint:pt9];
    
    NSPoint pt10 = {_selectionRect.origin.x - 2 , _selectionRect.origin.y + _selectionRect.size.height - 20};
    NSPoint pt11 = {_selectionRect.origin.x - 2, _selectionRect.origin.y + _selectionRect.size.height + 2};
    NSPoint pt12 = {_selectionRect.origin.x+20, _selectionRect.origin.y + _selectionRect.size.height + 2};
    
    [line moveToPoint:pt10];
    [line lineToPoint:pt11];
    [line lineToPoint:pt12];
    
    [line stroke];
    
}
- (void)drawLabel {
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.alignment = NSCenterTextAlignment;
    
    NSAttributedString *labelToDraw = [[NSAttributedString alloc] initWithString:@"Please drag to select capture area or press 'Esc' key to cancel."
                                                                      attributes:@{NSFontAttributeName: [NSFont systemFontOfSize:30],
                                                                                   NSForegroundColorAttributeName : [NSColor whiteColor],
                                                                                   NSParagraphStyleAttributeName : paragraph}];
    NSRect centeredRect;
    centeredRect.size = labelToDraw.size;
    centeredRect.origin.x = (self.bounds.size.width - centeredRect.size.width) / 2.0;
    centeredRect.origin.y = self.bounds.size.height - centeredRect.size.height*3;
    [labelToDraw drawInRect:centeredRect];
}

@end

@implementation BorderlessWindow
-(BOOL) canBecomeKeyWindow{
    return YES;
}

-(BOOL) canBecomeMainWindow{
    return YES;
}

@end
