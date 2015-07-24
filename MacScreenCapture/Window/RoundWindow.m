//
//  RoundWindow.m
//  RoundWindow
//
//  Created by Matt Gallagher on 12/12/08.
//  Copyright 2008 Matt Gallagher. All rights reserved.
//
//  Permission is given to use this source code file without charge in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import "RoundWindow.h"
#import "RoundWindowFrameView.h"

@implementation RoundWindow

//
// initWithContentRect:styleMask:backing:defer:screen:
//
// Init method for the object.
//
- (id)initWithContentRect:(NSRect)contentRect
	styleMask:(NSUInteger)windowStyle
	backing:(NSBackingStoreType)bufferingType
	defer:(BOOL)deferCreation
{
	self = [super
		initWithContentRect:contentRect
		styleMask:NSBorderlessWindowMask
		backing:bufferingType
		defer:deferCreation];
	if (self)
	{
		[self setOpaque:NO];
		[self setBackgroundColor:[NSColor clearColor]];
		
		[[NSNotificationCenter defaultCenter]
			addObserver:self
			selector:@selector(mainWindowChanged:)
			name:NSWindowDidBecomeMainNotification
			object:self];
		
		[[NSNotificationCenter defaultCenter]
			addObserver:self
			selector:@selector(mainWindowChanged:)
			name:NSWindowDidResignMainNotification
			object:self];
	}
	return self;
}

//
// dealloc
//
// Releases instance memory.
//
- (void)dealloc
{
	[[NSNotificationCenter defaultCenter]
		removeObserver:self];
	
}


//
// setContentSize:
//
// Convert from childContentView to frameView for size.
//
- (void)setContentSize:(NSSize)newSize
{
	NSSize sizeDelta = newSize;
	NSSize childBoundsSize = [childContentView bounds].size;
	sizeDelta.width -= childBoundsSize.width;
	sizeDelta.height -= childBoundsSize.height;
	
	RoundWindowFrameView *frameView = [super contentView];
	NSSize newFrameSize = [frameView bounds].size;
	newFrameSize.width += sizeDelta.width;
	newFrameSize.height += sizeDelta.height;
	
	[super setContentSize:newFrameSize];
}

//
// mainWindowChanged:
//
// Redraw the close button when the main window status changes.
//
- (void)mainWindowChanged:(NSNotification *)aNotification
{
	[closeButton setNeedsDisplay];
    [minimizeButton setNeedsDisplay];
}

//
// setContentView:
//
// Keep our frame view as the content view and make the specified "aView"
// the child of that.
//
- (void)setContentView:(NSView *)aView
{
	if ([childContentView isEqualTo:aView])
	{
		return;
	}
	
	NSRect bounds = [self frame];
	bounds.origin = NSZeroPoint;

	RoundWindowFrameView *frameView = [super contentView];
	if (!frameView)
	{
		frameView = [[RoundWindowFrameView alloc] initWithFrame:bounds] ;
		[super setContentView:frameView];

	}
	
	if (childContentView)
	{
		[childContentView removeFromSuperview];
	}
	childContentView = aView;
	[childContentView setFrame:[self contentRectForFrameRect:bounds]];
	[childContentView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
	[frameView addSubview:childContentView];
}

//
// contentView
//
// Returns the child of our frame view instead of our frame view.
//
- (NSView *)contentView
{
	return childContentView;
}

//
// canBecomeKeyWindow
//
// Overrides the default to allow a borderless window to be the key window.
//
- (BOOL)canBecomeKeyWindow
{
	return YES;
}

//
// canBecomeMainWindow
//
// Overrides the default to allow a borderless window to be the main window.
//
- (BOOL)canBecomeMainWindow
{
	return YES;
}

//
// contentRectForFrameRect:
//
// Returns the rect for the content rect, taking the frame.
//

- (NSRect)contentRectForFrameRect:(NSRect)windowFrame
{
	windowFrame.origin = NSZeroPoint;
	return NSInsetRect(windowFrame, 0, 0);
}

//
// frameRectForContentRect:styleMask:
//
// Ensure that the window is make the appropriate amount bigger than the content.
//
+ (NSRect)frameRectForContentRect:(NSRect)windowContentRect styleMask:(NSUInteger)windowStyle
{
	return NSInsetRect(windowContentRect, -0, -0);
}

@end
