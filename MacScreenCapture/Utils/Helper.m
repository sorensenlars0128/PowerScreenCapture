//
//  Helper.m
//  BitMedicAntiVirus
//
//  Created by hook on 3/23/15.
//  Copyright (c) 2015 elif. All rights reserved.
//

#import "Helper.h"
#import <pwd.h>

@implementation Helper
+(NSImageView*) imageViewWithName:(NSString*)name Point:(CGPoint) pos
{
    NSRect rect;
    NSImageView* ret;
    ret = [[NSImageView alloc] init];
    NSImage* img =[NSImage imageNamed:name];
    rect.origin = pos;
    rect.size = img.size;
    ret = [[NSImageView alloc] initWithFrame:rect];
    [ret setImage:img];
    [ret setImageScaling:NSImageScaleAxesIndependently];
    return ret;
}

+(NSFont*) generateFontWithSize:(int)size
{
    NSFont* ret = [NSFont fontWithName:[Helper FontName] size:size];
    return ret;
}
+(NSFont*) generateFontWithSize
{
    NSFont* ret = [NSFont fontWithName:[Helper FontName] size:10];
    return ret;
}
+(NSString*) FontName
{
    return @"Helvetica-Light";
}
+(CGSize) getRectByString:(NSString *)str font:(NSFont *)font
{
    
    NSDictionary *attrsDictionary =
    [NSDictionary dictionaryWithObject:font
                                forKey:NSFontAttributeName];
    
    CGSize size = [str sizeWithAttributes:attrsDictionary];
    return size;
}

+ (NSString *)realHomeDirectory
{
    struct passwd * pw;
    if( (pw = getpwuid( getuid() )) == NULL )
        return nil;
    return [NSString stringWithUTF8String:pw->pw_dir];
}

@end
