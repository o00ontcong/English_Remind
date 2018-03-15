//
//  AddVocabularyViewController.m
//  English_Remind
//
//  Created by Cong Nguyen on 25/11/2017.
//  Copyright © 2017 MAC. All rights reserved.
//

#import "AddVocabularyViewController.h"

@interface AddVocabularyViewController (){
    AddTypeWindowController *addVC;

}
- (IBAction)addAction:(id)sender;
- (IBAction)cloaseAction:(id)sender;

@property (weak) IBOutlet NSTextField *englishTextField;
@property (weak) IBOutlet NSTextField *vietnameseTextField;

@property (weak) IBOutlet NSTextField *notifyLabel;
- (IBAction)createTypeAction:(id)sender;

@property (weak) IBOutlet NSPopUpButton *selectTypeName;

@property (weak) IBOutlet NSButton *isMultiple;

@end

@implementation AddVocabularyViewController

- (void)windowDidLoad {
    [super windowDidLoad];
    [self windowRefresh:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowRefresh:) name:@"AddVocabularyViewControllerRefresh" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(popUpSelectionChanged:)
                                                 name:NSMenuDidSendActionNotification
                                               object:[self.selectTypeName menu]];

}
- (IBAction)showWindow:(id)sender
{
    [super showWindow:sender];
    if (self.vocabulary){
        self.englishTextField.stringValue = self.vocabulary.english;
        self.vietnameseTextField.stringValue = self.vocabulary.vietnamese;
        self.selectTypeName.stringValue = self.vocabulary.type;
    }

}
- (IBAction)addAction:(id)sender {
    
    NSString *englishTextFieldString  = [self.englishTextField.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *vietnameseTextFieldString = [self.vietnameseTextField.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    
    if ([englishTextFieldString isEqualToString:@""]){
        self.notifyLabel.stringValue = @"Please enter English.";
        return;
    }
    
    if ([vietnameseTextFieldString isEqualToString:@""]){
        self.notifyLabel.stringValue = @"Please enter Vietnamese.";
        return;
    }
    
    
    NSMutableDictionary *dict = [NSMutableDictionary new];
    dict[@"english"] = englishTextFieldString;
    dict[@"vietnamese"] = vietnameseTextFieldString;
    dict[@"type"] = self.selectTypeName.title;
    dict[@"favorite"] = false;
    dict[@"audio"] = [NSString stringWithFormat:@"audio/%@",englishTextFieldString];
    dict[@"done"] = 0;
    int64_t temp;
    [SQLiteLibrary begin];
    if (self.vocabulary){
        dict[@"id"] = [NSString stringWithFormat:@"%li",(long)self.vocabulary.ID];
        temp =  [SQLiteLibrary performUpdateQueryInTable:@"Vocabulary" data:dict idColumn:@"id"];
        
    } else {
        temp =  [SQLiteLibrary performInsertQueryInTable:@"Vocabulary" data:dict];
    }
    [SQLiteLibrary commit];

    if (temp >= 0){
        if ((self.isMultiple.state == 0)){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NewVocabularyViewControllerRefresh" object:nil];
            [self close];
        } else {
            self.notifyLabel.stringValue = @"Successfull";
            self.englishTextField.stringValue = @"";
            self.vietnameseTextField.stringValue = @"";
            [self.englishTextField becomeFirstResponder];
        }
    } else {
        self.notifyLabel.stringValue = @"Something wrong";
    }
    

}

- (IBAction)cloaseAction:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NewVocabularyViewControllerRefresh" object:nil];
    [self close];
}
- (IBAction)createTypeAction:(id)sender {
    addVC = [[AddTypeWindowController alloc] initWithWindowNibName:@"AddTypeWindowController"];
    addVC.window.level = CGWindowLevelForKey(kCGMaximumWindowLevelKey);
    [addVC showWindow:self];

}
- (void)windowWillClose:(NSNotification *)notification {
    // whichever operations are needed when the
    // window is about to be closed
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}
- (void)windowRefresh:(NSNotification *)notification {
    NSMutableArray *arrayItem = [NSMutableArray new];
    __block NSString * currentValue = @"";
    [SQLiteLibrary begin];
    [SQLiteLibrary performQuery:@"SELECT * FROM Type" block:^(sqlite3_stmt *rowData) {
        [arrayItem addObject:sqlite3_column_nsstring(rowData, 1)];
        int temp = sqlite3_column_int(rowData, 2);
        if (temp == 1){
            currentValue = sqlite3_column_nsstring(rowData, 1);
        }
    }];
    [SQLiteLibrary commit];

    [self.selectTypeName removeAllItems];
    [self.selectTypeName addItemsWithTitles:arrayItem];
    [self.selectTypeName selectItemWithTitle:currentValue];
}
- (void)popUpSelectionChanged:(NSNotification *)notification {
    [SQLiteLibrary begin];
    [SQLiteLibrary performQuery:@"UPDATE Type SET favorite = '0'" block:^(sqlite3_stmt *rowData) {
    }];
    
    NSString *sql = [NSString stringWithFormat:@"UPDATE Type SET favorite = '1' WHERE id = %li",self.selectTypeName.indexOfSelectedItem + 1];
    [SQLiteLibrary performQuery:sql block:^(sqlite3_stmt *rowData) {
        
    }];
    [SQLiteLibrary commit];
}

- (IBAction)ActionEnglish:(id)sender {
    [self.vietnameseTextField becomeFirstResponder];
}


@end
