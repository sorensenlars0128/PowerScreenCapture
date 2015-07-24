//
//  RoundWindowFrameView.h
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

#import <Cocoa/Cocoa.h>
#import "../CustomControl/CustomAdvancedSwitch.h"
#import "../CustomControl/ImageButton.h"

#define WINDOW_FRAME_PADDING 28

@interface QDictRow : NSObject
@property (strong, nonatomic) NSString *path;

@end

@interface RoundWindowFrameView : NSView <NSTableViewDataSource, NSTableViewDelegate>
{
    NSString *savePath;
    bool startAtLoginValue;
    NSInteger qualityLevel;
    NSString *formatText;
    NSMutableArray *mData;
    NSMutableArray * removeArray;
    NSMutableArray * historyArray;
    NSString * filePath_saved;
}

    @property (strong) IBOutlet NSView *prefView;
    @property (strong) IBOutlet NSView *prefSetting;
    @property (strong) IBOutlet NSView *prefInfo;
    @property (strong) IBOutlet NSTextField *folderPath;

    @property (strong, nonatomic) ImageButton *btn_record;
    @property (strong, nonatomic) ImageButton *btn_pause;
    @property (strong, nonatomic) ImageButton *btn_setting;
    @property (strong, nonatomic) ImageButton *btn_info;
    @property (strong, nonatomic) ImageButton *btn_arrow;
    @property (strong, nonatomic) ImageButton *btn_power;
    @property (strong, nonatomic) ImageButton *arrowButtonRight;
    @property (strong, nonatomic) ImageButton *settingFolderButton;

    @property (strong, nonatomic) ImageButton *statusLoginButton;

    @property (strong, nonatomic) NSImageView * recordTitle;
    @property (strong, nonatomic) NSImageView * prefTitle;

    @property (strong) IBOutlet NSMatrix * formatButton;
    @property (strong) IBOutlet NSSlider *qualitySlider;
    @property (strong) IBOutlet NSTableView *tableView;

    - (IBAction)OnQualityChanged:(id)sender;
    - (IBAction)OnFormatChanged:(id)sender;

    - (void) loadSavedData;
    - (void) setSavedData;
    - (void) updateHistory;

    - (void)setSavePath:(NSString*)path;
    - (NSString*)getSavePath;
    -(void) setQualityLevel:(NSInteger)val;
    -(NSInteger) getQualityLevel;
    -(void) setFormatText:(NSString*) val;
    -(NSString*) getFormatText;
    -(void) setStartAtLoginValue:(bool)val;
    -(bool) getStartAtLoginValue;
    -(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView;
    - (NSView *)tableView:(NSTableView *)tableView
       viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row;
    -(void) setHistoryData:(NSArray*)itemList;


@end

