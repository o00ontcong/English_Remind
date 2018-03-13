//
//  NewVocabularyViewController.m
//  English_Remind
//
//  Created by MAC on 20/11/2016.
//  Copyright © 2016 MAC. All rights reserved.
//

#import "NewVocabularyViewController.h"
#import "AddVocabularyViewController.h"
#import "ShowWindowController.h"
#import "VocabularyModel.h"

@interface NewVocabularyViewController ()<NSTableViewDelegate,NSTableViewDataSource>{
    ShowWindowController *showVC;
    AddVocabularyViewController *addVC;
}

@property (weak) IBOutlet NSTableView *listTable;
@property (weak) IBOutlet NSTableView *currentTable;

@property (weak) IBOutlet NSTextField *labelPoint;
@property (weak) IBOutlet NSTextField *textFieldTime;


- (IBAction)abtnAdd:(id)sender;
- (IBAction)abtnRemove:(id)sender;
- (IBAction)abtnAuto:(id)sender;
- (IBAction)abtnClear:(id)sender;

- (IBAction)abtnInsert:(id)sender;
- (IBAction)abtnDelete:(id)sender;
- (IBAction)abtnUpdate:(id)sender;

- (IBAction)abtnQuit:(id)sender;
- (IBAction)abtnPlayNow:(id)sender;

- (IBAction)abtnPoint:(id)sender;

@end

@implementation NewVocabularyViewController

NSMutableArray *vocabularys;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [self loadDataFromSQLite];
    showVC = [[ShowWindowController alloc] initWithWindowNibName:@"ShowWindowController"];
    
    
}

- (void)loadDataFromSQLite {
    
    [SQLiteLibrary setDatabaseFileInDocuments:@"NewVocabulary.sqlite"];
    
    //    [SQLiteLibrary setupDatabaseAndForceReset:NO];
    vocabularys = [[NSMutableArray alloc] init];
    [SQLiteLibrary begin];
    [SQLiteLibrary performQuery:@"SELECT * FROM Vocabulary" block:^(sqlite3_stmt *rowData) {
        VocabularyModel * vocabularyModel = [[VocabularyModel alloc] init];
        vocabularyModel.ID = sqlite3_column_int(rowData, 0);
        vocabularyModel.english = sqlite3_column_nsstring(rowData, 1);
        vocabularyModel.vietnamese = sqlite3_column_nsstring(rowData, 2);
        vocabularyModel.type = sqlite3_column_nsstring(rowData, 3);
        vocabularyModel.isFavorite = sqlite3_column_int(rowData, 4);

        
        [vocabularys addObject:vocabularyModel];
        
    }];
    [SQLiteLibrary commit];
    
    
    [self.listTable  reloadData];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return vocabularys.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    NSString *identifierStr = tableColumn.identifier;
    NSTableCellView *cell = [tableView makeViewWithIdentifier:identifierStr owner:self];
    VocabularyModel * vocabularyModel = (VocabularyModel*)vocabularys[row] ;
    
    if ([identifierStr isEqualToString: @"id"]){
        [cell textField].stringValue = [NSString stringWithFormat:@"%ld",(long)vocabularyModel.ID];
    } else if ([identifierStr isEqualToString: @"english"]){
        [cell textField].stringValue = [NSString stringWithFormat:@"%@",vocabularyModel.english];
    } else if ([identifierStr isEqualToString: @"vietnamese"]){
        [cell textField].stringValue = [NSString stringWithFormat:@"%@",vocabularyModel.vietnamese];
    } else if ([identifierStr isEqualToString: @"type"]){
        [cell textField].stringValue = [NSString stringWithFormat:@"%@",vocabularyModel.type];
    } else if ([identifierStr isEqualToString: @"favorite"]){
        [cell textField].stringValue = [NSString stringWithFormat:@"%hhd",vocabularyModel.isFavorite];
    }
    else if ([identifierStr isEqualToString: @"select"]){
    }
    else if ([identifierStr isEqualToString: @"delete"]){
    }
    return cell;
}



- (IBAction)abtnAdd:(id)sender {
}

- (IBAction)abtnRemove:(id)sender {
}

- (IBAction)abtnAuto:(id)sender {
}

- (IBAction)abtnClear:(id)sender {
}

- (IBAction)abtnInsert:(id)sender {
    addVC = [[AddVocabularyViewController alloc] initWithWindowNibName:@"AddVocabularyViewController"];
    addVC.window.level = CGWindowLevelForKey(kCGMaximumWindowLevelKey);
    [addVC showWindow:self];
    
}

- (IBAction)abtnDelete:(id)sender {
}

- (IBAction)abtnUpdate:(id)sender {
}

- (IBAction)abtnQuit:(id)sender {
    [NSApp terminate:nil];
}

- (IBAction)abtnPlayNow:(id)sender {
    showVC.window.level = CGWindowLevelForKey(kCGMaximumWindowLevelKey);
    [showVC showWindow:self];
    
}

- (IBAction)abtnPoint:(id)sender {
    NSLog(@"Point:");
}
@end
