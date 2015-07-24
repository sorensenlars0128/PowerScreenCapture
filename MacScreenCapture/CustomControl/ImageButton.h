//
//  ImageButton.h
//  MyMacApplication
//
//  Created by albert on 3/23/15.
//  Copyright (c) 2015 elif. All rights reserved.
//

#import <Cocoa/Cocoa.h>

struct COLOR
{
    float colorRed, colorGreen, colorBlue, colorAlpha;
};
@interface ImageButton : NSImageView
{
    NSImage * _commonImage;
    NSImage * _highlightImage;
    NSImage * _clickedImage;
    NSImage * _backgroundImage;
    NSString * _label;
    CGSize _btnSize;
    CGPoint _btnPos;
    
    id _pTarget;
    SEL _pExecFunc;
    id _param;
    
    bool _isClicked;
    
    NSString * _fontName;
    float _fontSize;
    struct COLOR _fontColor;
    NSTextAlignment _aligenmentMode;
    
}

-(id) initWithFrame :  (NSString*) strCommonFileName strHighLightFileName : (NSString*)strHighLightFileName
 strClickedFileName : (NSString *)strClickedFileName strBackgroundFileName : (NSString *) strBackgroundFileName
           strLabel : (NSString *) strLabel  btnSize : (CGSize)btnSize btnPos : (CGPoint) btnpos pTarget : (id) pTarget selector : (SEL) selector withObj : (id) obj;

-(id) initWithFrame :  (NSString*) strCommonFileName strHighLightFileName : (NSString*)strHighLightFileName
 strClickedFileName : (NSString *)strClickedFileName strBackgroundFileName : (NSString *) strBackgroundFileName
           strLabel : (NSString *) strLabel  btnSize : (CGSize)btnSize btnPos : (CGPoint) btnpos pTarget : (id) pTarget selector : (SEL) selector;


-(void) setClickState:(Boolean)clicked;
-(void) setText : (NSString *) text;

-(void) setFont:(NSString *) fontName size : (float)size;
-(void) setFont:(NSFont *)font;
-(void) setFontColor : (float)red green : (float)green blue : (float)blue alpha : (float) alpha;
-(void) setAlignment:(NSTextAlignment)mode;
@end
