//
//  Helper.h
//  BitMedicAntiVirus
//
//  Created by hook on 3/23/15.
//  Copyright (c) 2015 elif. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Helper : NSObject
+(NSImageView*) imageViewWithName:(NSString*) name Point:(CGPoint) pos;
+(NSFont*) generateFontWithSize:(int)size;
+(NSFont*) generateFontWithSize;
+(NSString*) FontName;
+(CGSize) getRectByString : (NSString *)str font : (NSFont*)font;

+ (NSString *)realHomeDirectory;

@end
