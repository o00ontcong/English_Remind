//
//  AvailableVocabularyViewController.h
//  English_Remind
//
//  Created by Cong Nguyen on 16/03/2018.
//  Copyright © 2018 MAC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "English_Remind-Swift.h"
#import "TypeVocabulary.h"
@interface AvailableVocabularyViewController : NSViewController <NMDatePickerDelegate>

@property (weak) IBOutlet NSTableView *listTableView;
@property (weak) IBOutlet NSTableView *todayTableView;
@property (weak) IBOutlet NMDatePicker *viewDatePicker;

- (IBAction)quitAction:(id)sender;
@property (weak) IBOutlet NSButton *btnPlayNow;
- (IBAction)abtnPlayNow:(id)sender;
- (IBAction)btnSound:(id)sender;
@property (weak) IBOutlet NSButton *btnSoundOutlet;

@property (weak) IBOutlet NSTextField *textFieldTime;
@property (nonatomic, strong) NSTimer *timerForLoopStatus;
@property (weak) IBOutlet NSTextField *textFieldCounter;
@property (weak) IBOutlet NSTextField *labelPoint;

@end
