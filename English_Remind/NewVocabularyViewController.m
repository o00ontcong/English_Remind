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

@interface NewVocabularyViewController ()<NSTableViewDelegate,NSTableViewDataSource,NSTextFieldDelegate>{
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

NSMutableArray *vocabularys, *selectedArray, *originVocalarys;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [self.searchBar setDelegate:self]; // or whatever object you want

    selectedArray = [[NSMutableArray alloc] init];
    originVocalarys = [[NSMutableArray alloc] init];
    vocabularys = [[NSMutableArray alloc] init];
    [self windowRefresh:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowRefresh:) name:@"NewVocabularyViewControllerRefresh" object:nil];
    
    
}
- (void)windowRefresh:(NSNotification *)notification {
    [self loadDataFromSQLite];

}
- (void)loadDataFromSQLite {
    
    [SQLiteLibrary setDatabaseFileInDocuments:@"NewVocabulary.sqlite"];
    [vocabularys removeAllObjects];
    [originVocalarys removeAllObjects];
    [SQLiteLibrary begin];
    [SQLiteLibrary performQuery:@"SELECT * FROM Vocabulary" block:^(sqlite3_stmt *rowData) {
        VocabularyModel * vocabularyModel = [[VocabularyModel alloc] init];
        vocabularyModel.ID = sqlite3_column_int(rowData, 0);
        vocabularyModel.english = sqlite3_column_nsstring(rowData, 1);
        vocabularyModel.vietnamese = sqlite3_column_nsstring(rowData, 2);
        vocabularyModel.type = sqlite3_column_nsstring(rowData, 3);
        vocabularyModel.isFavorite = sqlite3_column_int(rowData, 4);
        [originVocalarys addObject:vocabularyModel];
        
    }];
    [SQLiteLibrary commit];
    
    vocabularys = [originVocalarys mutableCopy];
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
        FavoriteTableCellView *cell = [tableView makeViewWithIdentifier:identifierStr owner:self];
        [cell.btnFavorite setTag: row];
        [cell.btnFavorite setAction:@selector(abtnFavoriteRow:)];
        [cell.btnFavorite setState: vocabularyModel.isFavorite];
        return cell;

    }
    else if ([identifierStr isEqualToString: @"select"]){
        SelectTableCellView *cell = [tableView makeViewWithIdentifier:identifierStr owner:self];
        [cell.btnSelect setTag: row];
        [cell.btnSelect setAction:@selector(abtnSelectRow:)];
        for (VocabularyModel *item in selectedArray) {
            if (item.ID == vocabularyModel.ID){
                [cell.btnSelect setState: 1];
                return cell;
            }
            
        }
        [cell.btnSelect setState: 0];
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
- (IBAction)abtnFavoriteRow:(id)sender {
    NSButton *select = sender;
    VocabularyModel * vocabularyModel = (VocabularyModel*)vocabularys[select.tag] ;

    NSString *sql = [NSString stringWithFormat:@"UPDATE Vocabulary SET favorite = '%ld' WHERE id = %li",(long)select.state, vocabularyModel.ID];
    [SQLiteLibrary begin];
    [SQLiteLibrary performQuery: sql block:^(sqlite3_stmt *rowData) {
    }];
    [SQLiteLibrary commit];
}
- (IBAction)abtnSelectRow:(id)sender {
    NSButton *select = sender;
    if ([select state] == 1){
        if ([selectedArray count] >= 10){
            [select setState:0];
            NSAlert *alert = [NSAlert new];
            alert.messageText = @"Warning";
            alert.informativeText = @"Maximum 10 at time";
            [alert addButtonWithTitle:@"Ok"];
            
            [alert beginSheetModalForWindow:[self.view window] completionHandler:^(NSInteger result) {
                NSLog(@"Success");
            }];
            return;
        } else {
            VocabularyModel *vocabulary = [vocabularys objectAtIndex:select.tag];
            [selectedArray addObject:vocabulary];
        }
    } else {
        VocabularyModel *vocabulary = [vocabularys objectAtIndex:select.tag];
        for (long i = selectedArray.count - 1; i >= 0; i--) {
            VocabularyModel *item = selectedArray[i];
            if (vocabulary.ID == item.ID){
                [selectedArray removeObjectAtIndex:i];
                break;
            }
        }

    }
   
}
- (IBAction)abtnAdd:(id)sender {
    
}

- (IBAction)abtnRemove:(id)sender {
}

- (IBAction)abtnAuto:(id)sender {
    [self loadDataFromSQLite];

    [selectedArray removeAllObjects];
    for (VocabularyModel *vocabulary in vocabularys) {
        if (vocabulary.isFavorite == TRUE){
            [selectedArray addObject:vocabulary];
        }
        if ([selectedArray count] >= 10){
            [self.listTable reloadData];
            return;
        }
    }
    [self.listTable reloadData];

}

- (IBAction)abtnClear:(id)sender {
    [selectedArray removeAllObjects];
    [self.listTable reloadData];
    
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
#pragma mark Methods privacy
-(void)autoSelectionAction:(NSNotification *)notification{
    
}
- (void)controlTextDidChange:(NSNotification *)notification {
    NSTextField *textField = [notification object];
    if (![[textField stringValue] isEqualToString:@""]){
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.english contains[c] %@",[textField stringValue]];
    vocabularys = [NSMutableArray arrayWithArray:[originVocalarys filteredArrayUsingPredicate:predicate]];
    } else {
        vocabularys = [originVocalarys mutableCopy];
    }
    [self.listTable reloadData];
}


@end
