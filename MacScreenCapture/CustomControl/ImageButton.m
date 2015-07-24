//
//  ImageButton.m
//  MyMacApplication
//
//  Created by albert on 3/23/15.
//  Copyright (c) 2015 elif. All rights reserved.
//

#import "ImageButton.h"
#import "Helper.h"

@implementation ImageButton

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}



-(id) initWithFrame :  (NSString*) strCommonFileName strHighLightFileName : (NSString*)strHighLightFileName
 strClickedFileName : (NSString *)strClickedFileName strBackgroundFileName : (NSString *) strBackgroundFileName
           strLabel : (NSString *) strLabel  btnSize : (CGSize)btnSize btnPos : (CGPoint) btnpos pTarget : (id) pTarget selector : (SEL) selector;
{
    
    if (CGSizeEqualToSize(btnSize, CGSizeZero))
    {
        NSImage * image = [NSImage imageNamed:strCommonFileName];
        btnSize = image.size;
    }
    
    NSRect frame = CGRectMake(btnpos.x, btnpos.y, btnSize.width, btnSize.height);
    
    self = [super initWithFrame:frame];
    if (self) {
        _commonImage = [NSImage imageNamed:strCommonFileName];
        
        _highlightImage = [NSImage imageNamed:strHighLightFileName];
        _clickedImage = [NSImage imageNamed:strClickedFileName];
        _backgroundImage = [NSImage imageNamed:strBackgroundFileName];
       
        
        
   
        _label = strLabel;
        _btnPos = btnpos;
        _btnSize = btnSize;
        _isClicked = false;
        _pTarget = pTarget;
        _pExecFunc = selector;
        _param = nil;
        
        [self setImage:_commonImage];
       [self initFont];
        
        _aligenmentMode = NSCenterTextAlignment;
      //  [self performSelector:@selector(drawLabel) withObject:nil afterDelay:0.5f];
        
    }
    
    
    return self;
}

-(id) initWithFrame :  (NSString*) strCommonFileName strHighLightFileName : (NSString*)strHighLightFileName
 strClickedFileName : (NSString *)strClickedFileName strBackgroundFileName : (NSString *) strBackgroundFileName
           strLabel : (NSString *) strLabel  btnSize : (CGSize)btnSize btnPos : (CGPoint) btnpos pTarget : (id) pTarget selector : (SEL) selector withObj : (id) obj;
{
    if (CGSizeEqualToSize(btnSize, CGSizeZero))
    {
        NSImage * image = [NSImage imageNamed:strCommonFileName];
        btnSize = image.size;
    }
    NSRect frame = CGRectMake(btnpos.x, btnpos.y, btnSize.width, btnSize.height);
    
    self = [super initWithFrame:frame];
    if (self) {
        _commonImage = [NSImage imageNamed:strCommonFileName];
        
        _highlightImage = [NSImage imageNamed:strHighLightFileName];
        _clickedImage = [NSImage imageNamed:strClickedFileName];
        _backgroundImage = [NSImage imageNamed:strBackgroundFileName];
        _label = strLabel;
        _btnPos = btnpos;
        _btnSize = btnSize;
        _isClicked = false;
        _pTarget = pTarget;
        _pExecFunc = selector;
        _param = obj;
        _aligenmentMode = NSCenterTextAlignment;
        
        [self setImage:_commonImage];
        [self initFont];
      //  [self performSelector:@selector(drawLabel) withObject:nil afterDelay:0.3f];

        
    }
    
    
    return self;
}

-(void) initFont
{
     [self setFont:[Helper  FontName] size:15];
    [self setFontColor:1.0 green:1.0f blue:1.0f alpha:1.0];
}

-(void) setFont:(NSString *)fontName size:(float)size
{
    _fontName = fontName;
    _fontSize = size;
}

-(void) setFont:(NSFont *)font
{
    _fontName = font.fontName;
    _fontSize = font.pointSize;
}
-(void) setFontColor : (float)red green : (float)green blue : (float)blue alpha : (float) alpha
{
    _fontColor.colorRed = red;
    _fontColor.colorGreen = green;
    _fontColor.colorBlue = blue;
    _fontColor.colorAlpha = alpha;
    
}
-(void) convertImage:(BOOL)state
{
    if (state)
        [self setImage:_clickedImage];
    else
        [self setImage:_commonImage];
    [self setNeedsDisplay];
}
- (void)drawRect:(NSRect)dirtyRect
{
//    //Get current context
//    CGContextRef myContext = [[NSGraphicsContext currentContext] graphicsPort];
//    
//    
//    //Draw background image
//    [_backgroundImage drawAtPoint:CGPointZero fromRect:CGRectMake(0, 0, _backgroundImage.size.width, _backgroundImage.size.height) operation:NSCompositeSourceOver fraction:1];
//    
//    //Draw common or clicked button imgae
//    
//    if (!_isClicked)
//    {
//        int width = _commonImage.size.width;
//        
//        [_commonImage drawAtPoint:CGPointZero fromRect:CGRectMake(0, 0,_commonImage.size.width, _commonImage.size.height) operation:NSCompositeSourceOver fraction:1];
//    }
//    else
//        [_clickedImage drawAtPoint:CGPointZero fromRect:CGRectMake(0, 0,_clickedImage.size.width, _clickedImage.size.height) operation:NSCompositeSourceOver fraction:1];
    
    [super drawRect:dirtyRect];
    //Draw label
    
    [self drawLabel];
    
    
}
-(void) drawLabel
{
    if ([_label compare:@""] == NSOrderedSame || _label == nil) return;
    CGSize viewSize = self.bounds.size;

    CGContextRef myContext = [[NSGraphicsContext currentContext] graphicsPort];
    //CGContextSetBlendMode(myContext, kCGBlendModeNormal);
    
    //set font about context
    
    // cgcontextsetfont
    CGContextSetFont(myContext, CGFontCreateWithFontName((__bridge CFStringRef)_fontName));
    
    float xScale, yScale;
    xScale = 1;//viewSize.width / _btnSize.width;
    yScale = 1;//viewSize.height / _btnSize.height;
    
    if (_isClicked) {
        xScale *= 0.9f;
        yScale *= 0.9f;
    }
    CGContextSetTextMatrix(myContext, CGAffineTransformMakeScale(xScale, yScale));

    // NSFont * font1 = [NSFont fontWithName:@"Helvetica" size:5];
    
    
     //CGContextSetFont(myContext, (__bridge CGFontRef)(font1));
    CGContextSetFontSize(myContext, _fontSize);
    

     
    CGContextSetRGBStrokeColor(myContext, _fontColor.colorRed, _fontColor.colorGreen, _fontColor.colorBlue, _fontColor.colorAlpha);
    CGContextSetRGBFillColor(myContext, _fontColor.colorRed, _fontColor.colorGreen, _fontColor.colorBlue, _fontColor.colorAlpha);
    
    CGContextSetTextDrawingMode(myContext, kCGTextFill);
   
    
    //Calculate size of text
    NSFont * font = [NSFont fontWithName:_fontName size:_fontSize];
    NSDictionary *attrsDictionary =
    [NSDictionary dictionaryWithObject:font
                                forKey:NSFontAttributeName];
    
  
    CGSize textSize = [_label sizeWithAttributes:attrsDictionary];
    textSize.width *= xScale;
    textSize.height *= yScale;
    
    if (_aligenmentMode == NSCenterTextAlignment)
        CGContextSetTextPosition (myContext, viewSize.width / 2 - textSize.width / 2, viewSize.height / 2 - textSize.height / 4);
    else if (_aligenmentMode == NSRightTextAlignment)
        CGContextSetTextPosition (myContext, viewSize.width - textSize.width-8, viewSize.height / 2 - textSize.height / 4+2);
    else if (_aligenmentMode == NSLeftTextAlignment)
        CGContextSetTextPosition(myContext, 0, viewSize.height / 2 - textSize.height / 4);


 
}
-(void) setText:(NSString *)text
{
    _label = text;
    [self setNeedsDisplay:YES];
    
}

-(void) mouseDown:(NSEvent *)theEvent
{
    if (theEvent.type == NSLeftMouseDown)
    {
        _isClicked = true;
        [self convertImage:true];
        [self setNeedsDisplay:true];
        
        while (YES)
        {
            //
            // Lock focus and take all the dragged and mouse up events until we
            // receive a mouse up.
            //
            NSEvent *newEvent = [self.window
                                 nextEventMatchingMask:(NSLeftMouseUpMask)];
            
            if ([newEvent type] == NSLeftMouseUp)
            {
                _isClicked = false;
                [self convertImage:false];
                [self setNeedsDisplay:true];
                CGPoint newPos = [newEvent locationInWindow];
                CGPoint nPos = [self.superview convertPoint:newPos fromView:[self.window contentView]];
                NSView* target = [self hitTest:nPos];
                if (target == self)
                    [self execFunction];
                break;
            }
        }
    }
    
}

-(void) mouseUp:(NSEvent *)theEvent
{
    if (theEvent.type == NSLeftMouseUp)
    {
    }
    
}

-(void) execFunction
{
    if (_pTarget != nil && _pExecFunc != nil){
        IMP imp = [_pTarget methodForSelector:_pExecFunc];
        void (*func)(id, SEL, id) = (void *)imp;
        func(_pTarget, _pExecFunc, _param);
    }
}

-(void) setClickState:(Boolean)clicked
{
    _isClicked = clicked;
    [self convertImage:_isClicked];
    [self setNeedsDisplay:YES];
}

-(void) setAlignment:(NSTextAlignment)mode
{
    _aligenmentMode = mode;
    [self setNeedsDisplay:YES];
}
@end
