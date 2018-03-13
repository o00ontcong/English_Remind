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

@property (weak) IBOutlet NSTextField *labelPoint;
@property (weak) IBOutlet NSTextField *textFieldTime;


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
    [self windowRefresh:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowRefresh:) name:@"AddVocabularyViewControllerRefresh" object:nil];
    
}
- (void)windowRefresh:(NSNotification *)notification {
    [self loadDataFromSQLite];

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
#pragma mark TableView Delegate DataSource
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
        SelectTableCellView *cell = [tableView makeViewWithIdentifier:identifierStr owner:self];
        [cell.btnSelect setTag: row];
        [cell.btnSelect setAction:@selector(abtnSelectRow:)];
        return cell;
    }
    else if ([identifierStr isEqualToString: @"delete"]){
        DeleteTableCellView *cell = [tableView makeViewWithIdentifier:identifierStr owner:self];
        [cell.btnDelete setTag: row];
        [cell.btnDelete setAction:@selector(abtnDeleteRow:)];
        return cell;
    }
    return cell;
}
#pragma mark Action Button
- (IBAction)abtnDeleteRow:(id)sender {
    NSButton *delete = sender;
    NSLog(@"🔴%li",(long)delete.tag);
    VocabularyModel * vocabularyModel = (VocabularyModel*)vocabularys[delete.tag];
    NSString * sql = [NSString stringWithFormat:@"DELETE FROM Vocabulary WHERE id = %li",(long)vocabularyModel.ID];

    [SQLiteLibrary begin];
    [SQLiteLibrary performQuery: sql block:^(sqlite3_stmt *rowData) {
       
    }];
    [SQLiteLibrary commit];
    dispatch_async(dispatch_get_main_queue(), ^{
        [vocabularys removeObjectAtIndex:delete.tag];
        [self.listTable reloadData];
    });
}
- (IBAction)abtnSelectRow:(id)sender {
    NSButton *select = sender;
    
    NSLog(@"🔴%li and status :%ld",(long)select.tag, (long)select.state);
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
    showVC = [[ShowWindowController alloc] initWithWindowNibName:@"ShowWindowController"];
    showVC.window.level = CGWindowLevelForKey(kCGMaximumWindowLevelKey);
    [showVC showWindow:self];
    
}

- (IBAction)abtnPoint:(id)sender {
    NSLog(@"Point:");
}
@end
