//
//  RoundWindowFrameView.m
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

#import "RoundWindowFrameView.h"
#import "LNGIFConverter.h"
#import <AVFoundation/AVFoundation.h>
#import "../AppDelegate.h"
#import <ServiceManagement/ServiceManagement.h>
#import "LaunchAtLoginController.h"
#import "../LoginController/StartAtLoginController.h"
#import "DatabaseModel.h"
#import "NSAlert+Popover.h"
#import "AppDelegate.h"
#import "GrantAccess.h"
#import "NSURL+FileAccess.h"
#import "Helper.h"

@implementation QDictRow
@synthesize path;

- (id)initWithCoder:(NSCoder *)decoder  {
    if (self = [super init]) {
        self.path = [decoder decodeObjectForKey:@"path"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder  {
    
    [encoder encodeObject:self.path forKey:@"path"];
}


@end

@implementation RoundWindowFrameView

@synthesize btn_record, btn_pause, btn_setting, btn_info, btn_arrow, recordTitle, btn_power, prefTitle,arrowButtonRight, settingFolderButton, statusLoginButton;

-(id)initWithFrame:(NSRect)rect
{
    self = [super initWithFrame:rect];
    if(self)
    {
    }
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder: aDecoder];
    if(self)
    {
        [self performSelector:@selector(drawSelf) withObject:nil afterDelay:0.5f];
        

    }
    return self;
}

- (void)removeAction:(NSButton *)sender {
    
    NSInteger row_Ind = sender.tag;
    QDictRow* data = [mData objectAtIndex:row_Ind];
    NSAlert*alert=[NSAlert alertWithMessageText:[NSString stringWithFormat:@"Do you want to move the file “%@” to the Trash, or only remove the reference to it?",data.path]defaultButton:@"Remove on List" alternateButton:@"Cancel" otherButton:@"Delete on disk" informativeTextWithFormat:@""];
    
    [alert setAlertStyle:NSInformationalAlertStyle];
    [alert runAsPopoverForView:self withCompletionBlock:^(NSInteger result) {
        if(result == NSAlertFirstButtonReturn)  {
            [mData removeObjectAtIndex:row_Ind];
            [removeArray addObject:data.path];
            DatabaseModel * saveModel = [[DatabaseModel alloc] initWithKeyword:@"removePath"];
            [saveModel saveData:removeArray];
            [self updateHistory];
        }
        else if (result == NSAlertSecondButtonReturn)   {
            NSLog(@"secondButton");
            [mData removeObjectAtIndex:row_Ind];
            [self removeFile:historyArray[row_Ind]];
            [self updateHistory];
        }
    }];
}

- (void)removeFile:(NSString *)path  {
    NSFileManager * fm = [[NSFileManager alloc] init];
    NSDirectoryEnumerator *en = [fm enumeratorAtPath:path];
    NSError * error = nil;
    
    BOOL res;
    
    NSString * file;
    while (file = [en nextObject]) {
        res = [fm removeItemAtPath:[path stringByAppendingPathComponent:file] error:&error];
        
        if (!res && error) {
            NSLog(@"error: %@", error);
        }
    }
    
    [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
    
    if (error.code != NSFileNoSuchFileError) {
        NSLog(@"%@", error);
    }
}

- (void)playAction:(NSButton *)sender   {
    NSInteger row_Ind = sender.tag;
    NSInteger col_Ind = [self.tableView clickedColumn];
    
    if((row_Ind < 0) || (row_Ind >= 5)){
        return;
    }
    NSTableCellView *cell = [self.tableView viewAtColumn:col_Ind row:row_Ind makeIfNecessary:NO];
    
    NSLog(@"Text : %@",[[cell textField] stringValue]);
    
    NSString *directoryPath = [[savePath stringByAppendingString:@"/"] stringByAppendingString:[[cell textField] stringValue]];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[directoryPath stringByAppendingString:@".mp4"]]) {
        [[NSWorkspace sharedWorkspace] openFile:[directoryPath stringByAppendingString:@".mp4"]];
    }else if([[NSFileManager defaultManager] fileExistsAtPath:[directoryPath stringByAppendingString:@".gif"]]){
        [[NSWorkspace sharedWorkspace] openFile:[directoryPath stringByAppendingString:@".gif"]];
    }
    
    AppDelegate * delegate = [[NSApplication sharedApplication] delegate];
    [delegate.window orderOut:nil];
    [delegate setVisible:false];
}

-(void) awakeFromNib
{
    [self.tableView setDoubleAction:@selector(DoubleClickOnTableRow)];
}
-(void) DoubleClickOnTableRow{
    NSInteger row_Ind = [self.tableView clickedRow];
    NSInteger col_Ind = [self.tableView clickedColumn];
    
    if((row_Ind < 0) || (row_Ind >= 5)){
        return;
    }
    NSTableCellView *cell = [self.tableView viewAtColumn:col_Ind row:row_Ind makeIfNecessary:NO];
    
    NSLog(@"Text : %@",[[cell textField] stringValue]);
    
    [[NSWorkspace sharedWorkspace] openURL:[NSURL fileURLWithPath:savePath]];
}
-(void)drawSelf
{
    btn_info= [[ImageButton alloc] initWithFrame:@"icon info_normal.png" strHighLightFileName:@"icon info_highlight.png"
                              strClickedFileName:@"icon info_selected.png" strBackgroundFileName:nil strLabel:nil btnSize:NSMakeSize(33, 33) btnPos:NSMakePoint(35, 20) pTarget:self selector:@selector(OnClickInfo)];
    [self addSubview:btn_info];
    
    btn_record= [[ImageButton alloc] initWithFrame:@"icon record_normal.png" strHighLightFileName:@"icon record_highlight.png"
                                strClickedFileName:@"icon record_selected.png" strBackgroundFileName:nil strLabel:nil btnSize:NSMakeSize(40, 40) btnPos:NSMakePoint(35, 392) pTarget:self selector:@selector(OnClickRecord)];
    [self addSubview:btn_record];
    
    btn_power = [[ImageButton alloc] initWithFrame:@"powerButton.png" strHighLightFileName:@"powerButtonHighlight.png" strClickedFileName:@"powerButtonHighlight.png" strBackgroundFileName:nil strLabel:nil btnSize:NSMakeSize(33, 33) btnPos:NSMakePoint(332, 395) pTarget:self selector:@selector(OnclickPower)];
    
    [self addSubview:btn_power];
    
    recordTitle = [[NSImageView alloc] initWithFrame:NSRectFromCGRect(CGRectMake(85, 399, 130, 25))];
    [recordTitle setImage:[NSImage imageNamed:@"recordTitle.png"]];
    [self addSubview:recordTitle];
    
    prefTitle = [[NSImageView alloc] initWithFrame:NSRectFromCGRect(CGRectMake(100, 15, 200, 40))];
    [prefTitle setImage:[NSImage imageNamed:@"capturetitle.png"]];
    [self addSubview:prefTitle];
    
    btn_pause= [[ImageButton alloc] initWithFrame:@"icon_pause.png" strHighLightFileName:@"icon_pause_highlight.png"                                    strClickedFileName:@"icon_pause_selected.png" strBackgroundFileName:nil strLabel:nil btnSize:NSMakeSize(40, 48) btnPos:NSMakePoint(35, 392) pTarget:self selector:@selector(OnClickPause)];
    [self addSubview:btn_pause];
    [btn_pause setHidden:YES];
    
    settingFolderButton = [[ImageButton alloc] initWithFrame:@"fileBrowserButton.png" strHighLightFileName:@"fileBrowserButton.png" strClickedFileName:@"fileBrowserButton.png" strBackgroundFileName:nil strLabel:nil btnSize:NSMakeSize(35, 35) btnPos:NSMakePoint(324, 190) pTarget:self selector:@selector(selectFolder:)];
    
    statusLoginButton = [[ImageButton alloc] initWithFrame:@"switchOffButton.png" strHighLightFileName:@"switchOffButton.png" strClickedFileName:@"switchOffButton.png" strBackgroundFileName:nil strLabel:nil btnSize:NSMakeSize(100, 40) btnPos:NSMakePoint(270, 250) pTarget:self selector:@selector(selectStatusLogin:)];
    
    [self addSubview:statusLoginButton];
    [statusLoginButton setHidden:YES];
    
    [self addSubview:settingFolderButton];
    [settingFolderButton setHidden:YES];
    
    btn_setting= [[ImageButton alloc] initWithFrame:@"settingsButton.png" strHighLightFileName:@"settingsButton.png"
                                 strClickedFileName:@"settingsButton.png" strBackgroundFileName:nil strLabel:nil btnSize:NSMakeSize(33, 33) btnPos:NSMakePoint(330, 20) pTarget:self selector:@selector(OnClickSettings)];
    [self addSubview:btn_setting];
    
    btn_arrow= [[ImageButton alloc] initWithFrame:@"icon_back.png" strHighLightFileName:@"icon_back_highlight.png"
                               strClickedFileName:@"icon_back_selected.png" strBackgroundFileName:nil strLabel:nil btnSize:NSMakeSize(32, 32) btnPos:NSMakePoint(37, 20) pTarget:self selector:@selector(OnClickBack)];
    [self addSubview:btn_arrow];
    [btn_arrow setHidden:YES];
    
    arrowButtonRight = [[ImageButton alloc] initWithFrame:@"rightbackButton.png" strHighLightFileName:@"rightbackButton.png" strClickedFileName:@"rightbackButton.png" strBackgroundFileName:nil strLabel:nil btnSize:NSMakeSize(32, 32) btnPos:NSMakePoint(330, 20) pTarget:self selector:@selector(OnClickBack)];
    [self addSubview:arrowButtonRight];
    [arrowButtonRight setHidden:YES];
    
    [self setSavedData];
    
}
- (void) loadSavedData
{
    removeArray = [[NSMutableArray alloc] init];
    DatabaseModel * loadModel = [[DatabaseModel alloc] initWithKeyword:@"removePath"];
    removeArray = [loadModel loadData];
    
    if (!removeArray) {
        removeArray = [[NSMutableArray alloc] init];
    }
    
    savePath = [[NSUserDefaults standardUserDefaults] stringForKey:@"SavePath"];
    if( savePath == nil )
        savePath = [[Helper realHomeDirectory] stringByAppendingPathComponent:@"Movies"];
    
    if(!(formatText = [[NSUserDefaults standardUserDefaults] stringForKey:@"FormatText"]) || [formatText length] == 0){
        [self setFormatText:@"MPEG 4"];
    }
    
    if(!(qualityLevel = [[NSUserDefaults standardUserDefaults] integerForKey:@"QualityLevel"])){
        [self setQualityLevel:3];
    }
    
    if(!(startAtLoginValue = [[NSUserDefaults standardUserDefaults] boolForKey:@"StartatLogin"])){
        [self setStartAtLoginValue:false];
    }
    
    [self updateHistory];
}
-(void)setSavePath:(NSString *)path
{
    savePath = path;
}
-(NSString*)getSavePath
{
    return savePath;
}
-(void) setQualityLevel:(NSInteger)val
{
    qualityLevel = val;
}
-(NSInteger) getQualityLevel
{
    return  qualityLevel;
}
-(void) setFormatText:(NSString*) val
{
    formatText = val;
}
-(NSString*) getFormatText
{
    return formatText;
}
-(void) setStartAtLoginValue:(bool)val
{
    startAtLoginValue = val;
}
-(bool) getStartAtLoginValue
{
    return  startAtLoginValue;
}

- (void) setSavedData
{
    [self.folderPath setStringValue:savePath];
    if ([formatText isEqualToString:@"GIF"]) {
        [self.formatButton selectCellAtRow:0 column:1];
    }
    else    {
        [self.formatButton selectCellAtRow:0 column:0];
    }
    
    if(startAtLoginValue)
    {
        [statusLoginButton setImage:[NSImage imageNamed:@"switchOnButton.png"]];
        [statusLoginButton setHidden:YES];
    }
    else    {
        [statusLoginButton setImage:[NSImage imageNamed:@"switchOffButton.png"]];
        [statusLoginButton setHidden:YES];
    }
    [self.qualitySlider setIntegerValue:qualityLevel];
    [self display];
}
- (void) updateHistory
{
    NSArray* history = [NSArray arrayWithArray:[self getSortedFilesFromFolder:savePath]];
    [self setHistoryData:history];
}
- (void)viewDidMoveToWindow{
    return;
}
- (NSRect)resizeRect
{
    const CGFloat resizeBoxSize = 16.0;
    const CGFloat contentViewPadding = 5.5;
    
    NSRect contentViewRect = [[self window] contentRectForFrameRect:[[self window] frame]];
    NSRect resizeRect = NSMakeRect(
                                   NSMaxX(contentViewRect) + contentViewPadding,
                                   NSMinY(contentViewRect) - resizeBoxSize - contentViewPadding,
                                   resizeBoxSize,
                                   resizeBoxSize);
    
    return resizeRect;
}

- (void)drawRect:(NSRect)rect
{
    [[NSColor clearColor] set];
    NSRectFill(rect);
    
    NSImage  * backImg = [NSImage imageNamed:@"menupopout_normal.png"];
    [backImg drawAtPoint:CGPointZero fromRect:CGRectMake(0, 0, backImg.size.width, backImg.size.height) operation:NSCompositeSourceOver fraction:1];
    
}

-(void)OnClickInfo
{
    prefTitle.frame = NSRectFromCGRect(CGRectMake(115, 20, 170, 30));
    [prefTitle setImage:[NSImage imageNamed:@"aboutTitle.png"]];
    [btn_arrow setHidden:NO];
    [btn_info setHidden:YES];
    [btn_setting setHidden:YES];
    [btn_pause setHidden:YES];
    [arrowButtonRight setHidden:YES];
    [settingFolderButton setHidden:YES];
    [statusLoginButton setHidden:YES];
    
    [self.prefInfo setHidden:NO];
    [self.prefSetting setHidden:YES];
    [self.prefView setHidden:YES];
  
    
}

- (void)OnclickPower
{
    [[NSApplication sharedApplication] terminate:self];
}

-(void)OnClickRecord
{
    AppDelegate* app = [[NSApplication sharedApplication] delegate];
    [app setDisplayAndCropRect];
    
    [btn_pause setHidden:NO];
    [btn_record setHidden:YES];
    
    [app OnClickHide:nil];
}
-(void)OnClickPause
{
    AppDelegate* app = [[NSApplication sharedApplication] delegate];
    [app stopRecording];
    
    [btn_pause setHidden:YES];
    [btn_record setHidden:NO];
    
    [[NSCursor arrowCursor] set];
    [self updateHistory];
}
-(void)OnClickSettings
{
    prefTitle.frame = NSRectFromCGRect(CGRectMake(115, 20, 170, 30));
    [prefTitle setImage:[NSImage imageNamed: @"preferenceTitle.png"]];
    [btn_arrow setHidden:YES];
    [arrowButtonRight setHidden:NO];
    [settingFolderButton setHidden:NO];
    [statusLoginButton setHidden:NO];
    
    [btn_info setHidden:YES];
    [btn_setting setHidden:YES];
    [btn_pause setHidden:YES];
    
    [_prefSetting setHidden:NO];
    [_prefView setHidden:YES];
    
}
-(void)OnClickBack
{
    prefTitle.frame = NSRectFromCGRect(CGRectMake(100, 15, 200, 40));
    [_prefInfo setHidden:YES];
    [_prefSetting setHidden:YES];
    [prefTitle setImage:[NSImage imageNamed:@"capturetitle.png"]];
    [btn_arrow setHidden:YES];
    [arrowButtonRight setHidden:YES];
    [settingFolderButton setHidden:YES];
    [statusLoginButton setHidden:YES];
    [_prefView setHidden:NO];
    [btn_info setHidden:NO];
    
    AppDelegate* app = [[NSApplication sharedApplication] delegate];
    if (![app is_recording]) {
        [btn_record setHidden:NO];
        [btn_pause setHidden:YES];
    }else{
        [btn_record setHidden:YES];
        [btn_pause setHidden:NO];
    }
    [self updateHistory];
    [btn_setting setHidden:NO];
    [_prefView display];
    
}
- (void)selectFolder:(id)sender {
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    [openDlg setDirectoryURL:[NSURL fileURLWithPath:savePath]];
    [openDlg setPrompt: @"Select"];
    [openDlg setCanChooseFiles: NO];
    [openDlg setCanChooseDirectories:YES];
    [openDlg setCanCreateDirectories:YES];
    [openDlg setAllowsMultipleSelection:NO];
    
    if ( [openDlg runModal] == NSOKButton )
    {
        /****KMS*****/
        NSString * oldPath = [[NSUserDefaults standardUserDefaults] stringForKey:@"SavePath"];
        if( oldPath != nil )
        {
            [[GrantAccess sharedInstance] stopAccessingToPath:oldPath];
            [[NSURL fileURLWithPath:oldPath] removeBookmarkData];
        }
        
        NSURL * selectedURL = [openDlg URL];
        [selectedURL setBookmarkData];
        [self setSavePath:[selectedURL path]];
        [self.folderPath setStringValue:savePath];
        
        [[NSUserDefaults standardUserDefaults] setObject:savePath forKey:@"SavePath"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        /*
        [self setSavePath:[[openDlg URL] path]];
        [_folderPath setStringValue:savePath];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setValue:savePath forKey:@"SavePath"];
        */
        
        [self updateHistory];
    }
    
}

- (IBAction)OnQualityChanged:(id)sender
{
    //    NSSlider *qualitySlider = (NSSlider*)sender;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [self setQualityLevel:[_qualitySlider intValue]];
    [defaults setInteger:qualityLevel forKey:@"QualityLevel"];
}

- (IBAction)OnFormatChanged:(id)sender
{
    //    NSPopUpButton *formatButton = (NSPopUpButton* )sender;
    NSString * formatString;
    if([self.formatButton selectedColumn] == 0) {
        formatString = @"MPEG 4";
    }
    else    {
        formatString = @"GIF";
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [self setFormatText:formatString];
    [defaults setObject:formatText forKey:@"FormatText"];
}

-(void)selectStatusLogin:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (startAtLoginValue) {
        startAtLoginValue = FALSE;
        [self.statusLoginButton setImage:[NSImage imageNamed:@"switchOffButton.png"]];
    }
    else    {
        startAtLoginValue = TRUE;
        [self.statusLoginButton setImage:[NSImage imageNamed:@"switchOnButton.png"]];
    }
    
    [defaults setBool:startAtLoginValue forKey:@"StartatLogin"];
    
    LaunchAtLoginController *launchController = [[LaunchAtLoginController alloc] init];
    
    if (startAtLoginValue) {
        [launchController setLaunchAtLogin:YES];
    } else {
        [launchController setLaunchAtLogin:NO];
    }
    
}

-(NSArray*) getSortedFilesFromFolder:(NSString*)folderPath
{
    
    filePath_saved = folderPath;
    NSError*error = nil;
    NSArray* filesArray = [NSArray arrayWithArray:[[NSFileManager defaultManager] contentsOfDirectoryAtPath:filePath_saved error:&error]];
    
    if( error != nil )
        NSLog(@"%@", error);
    
    NSPredicate* predicate =[NSPredicate predicateWithFormat:@"self ENDSWITH '.mp4' or self ENDSWITH '.gif'"];
    NSArray *tempArray = [NSArray arrayWithArray:[filesArray filteredArrayUsingPredicate:predicate]];
    
    NSMutableArray* filesAndProperties=[NSMutableArray arrayWithCapacity:[tempArray count]];
    for(NSString*file in tempArray){
        BOOL isRemoved = NO;
        if(![file isEqualToString:@".DS_Store"]){
            NSString *filePath = [folderPath stringByAppendingPathComponent:file];
            NSDictionary* properties = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&error];
            
            NSString* path = [file substringToIndex:[file length]-4];
            
            if ([removeArray count] > 0) {
                for (int j = 0; j < [removeArray count]; j++) {
                    if ([path isEqualToString:[removeArray objectAtIndex:j]]) {
                        isRemoved = YES;
                        break;
                    }
                }
            }
            if (!isRemoved) {
                NSDate* modDate=[properties objectForKey:NSFileModificationDate];
                [filesAndProperties addObject:[NSDictionary dictionaryWithObjectsAndKeys:file, @"path", modDate, @"lastModDate", nil]];
            }
        }
    }
    
    NSArray* sortedFiles=[filesAndProperties sortedArrayUsingComparator:^(id path1,id path2){
        NSComparisonResult comp = [[path1 objectForKey:@"lastModDate"] compare:[path2 objectForKey:@"lastModDate"]];
        if(comp == NSOrderedDescending){
            comp = NSOrderedAscending;
        }else if(comp == NSOrderedAscending){
            comp = NSOrderedDescending;
        }
        comp = NSOrderedDescending;
        return comp;
    }];
    
    NSInteger count= 5;
    if(count > [sortedFiles count]){
        count = [sortedFiles count];
    }
    
    return [sortedFiles subarrayWithRange:NSMakeRange(0, count)];
}

#pragma mark TableView delegate

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return mData.count;
    
}

-(void)setHistoryData:(NSArray *)itemList
{
    historyArray = [[NSMutableArray alloc] init];
    mData = [[NSMutableArray alloc] init];
    NSInteger count= 5;
    if(count > [itemList count]){
        count = [itemList count];
    }
    
    for (int i = 0; i < count; i ++) {
        QDictRow* data = [[QDictRow alloc] init];
        NSDictionary *historyDict = [itemList objectAtIndex:i];
        NSString *fileName = [historyDict objectForKey: @"path"];
        NSString* path = [fileName substringToIndex:[fileName length]-4];
        data.path = path;
        
        [mData addObject:data];
        [historyArray addObject:[NSString stringWithFormat:@"%@/%@", filePath_saved, fileName]];
    }
    
    [self setNeedsDisplay:YES];
    
    [self.tableView reloadData];
}

- (NSView *)tableView:(NSTableView *)tableView
   viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row {
    QDictRow* data = [mData objectAtIndex:row];
    NSTableCellView *cell;
    NSString* str = [tableColumn identifier];
    
    if ([str compare:@"FileName"] == NSOrderedSame)
    {
        cell = [tableView makeViewWithIdentifier:@"FileNameCell" owner:tableView];
        [[cell textField] setStringValue:[data path]];
        NSButton * playButton = [cell viewWithTag:100];
        NSButton * removeButton = [cell viewWithTag:102];
        
        playButton.tag = row;
        removeButton.tag = row;
        
        [playButton setAction:@selector(playAction:)];
        [removeButton setAction:@selector(removeAction:)];
    }
    return cell;
}

- (NSIndexSet*)tableView:(NSTableView *)tableView selectionIndexesForProposedSelection:(NSIndexSet *)proposedSelectionIndexes   {
    return 0;
}

@end