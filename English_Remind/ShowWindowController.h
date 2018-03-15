//
//  ShowWindowController.h
//  English_Remind
//
//  Created by Cong Nguyen on 25/11/2017.
//  Copyright © 2017 MAC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "VocabularyModel.h"
@interface ShowWindowController : NSWindowController
@property (strong, nonatomic)VocabularyModel *vocabulary;
@property (weak) IBOutlet NSTextField *textVietnamese;
@property (weak) IBOutlet NSTextField *textEnglish;
@property (weak) IBOutlet NSTextField *textfieldInput;
@property (copy, nonatomic) void (^callBackBlock)(BOOL result, VocabularyModel *vocabulary);
- (IBAction)closeAction:(id)sender;


- (IBAction)textfieldInputAction:(id)sender;

@end
