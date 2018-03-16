//
//  AddTypeWindowController.m
//  English_Remind
//
//  Created by Cong Nguyen on 06/03/2018.
//  Copyright © 2018 MAC. All rights reserved.
//

#import "AddTypeWindowController.h"

@interface AddTypeWindowController ()
- (IBAction)addAction:(id)sender;
- (IBAction)closeAction:(id)sender;
@property (weak) IBOutlet NSTextField *textFieldInput;
@property (weak) IBOutlet NSTextField *labelWaring;

@end

@implementation AddTypeWindowController

- (void)windowDidLoad {
    [super windowDidLoad];

    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}
- (IBAction)showWindow:(id)sender
{
    [super showWindow:sender];
    
}
- (IBAction)addAction:(id)sender {
    NSString *textFieldInputString  = [self.textFieldInput.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if ([textFieldInputString isEqualToString:@""]){
        [self.labelWaring setHidden:NO];
        self.labelWaring.stringValue = @"Please enter Type Name.";
        return;
    } else {
        self.labelWaring.stringValue = @"";
    }
    
//    [SQLiteLibrary setDatabaseFileInDocuments:@"NewVocabulary.sqlite"];
    [SQLiteLibrary begin];
    
    NSMutableDictionary *dict = [NSMutableDictionary new];
    dict[@"TypeName"] = textFieldInputString;
    dict[@"Favorite"] = 0;
    int64_t temp =  [SQLiteLibrary performInsertQueryInTable:@"Type" data:dict];
    if (temp >= 0){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AddVocabularyViewControllerRefresh" object:nil];
        [self close];
    } else {
        self.labelWaring.stringValue = @"Enter other Value.";
    }
    [SQLiteLibrary commit];
}

- (IBAction)closeAction:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AddVocabularyViewControllerRefresh" object:nil];
    [self close];

}
- (IBAction)actionTypeInput:(id)sender {
}
@end
