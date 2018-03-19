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
    NSInteger selectedIndex;
    BOOL isFirstRun;
    NSUserDefaults *userDefaults;
}

@property (weak) IBOutlet NSTableView *listTable;
@property (weak) IBOutlet NSTextField *labelPoint;
@property (weak) IBOutlet NSTextField *textFieldTime;
@property (weak) IBOutlet NSButton *btnAuto;
@property (nonatomic, strong) NSTimer *timerForLoopStatus;
@property (weak) IBOutlet NSButton *btnPlayNow;
@property (weak) IBOutlet NSTextField *textfieldInputCounter;


- (IBAction)abtnAuto:(id)sender;
- (IBAction)abtnClear:(id)sender;

- (IBAction)abtnInsert:(id)sender;
- (IBAction)abtnUpdate:(id)sender;

- (IBAction)abtnQuit:(id)sender;
- (IBAction)abtnPlayNow:(id)sender;


@end

@implementation NewVocabularyViewController

NSMutableArray *vocabularys, *selectedArray, *originVocabularys, *counterVocabulary;

- (void)viewDidLoad {
    [super viewDidLoad];
    userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:@"ENGLISH_REMIND_TIME"] == nil){
        [userDefaults setInteger:0 forKey:@"ENGLISH_REMIND_TIME"];
    }
    if ([userDefaults objectForKey:@"ENGLISH_REMIND_COUNTER"] == nil){
        [userDefaults setInteger:0 forKey:@"ENGLISH_REMIND_COUNTER"];
    }
    if ([userDefaults objectForKey:@"ENGLISH_REMIND_POINT"] == nil){
        [userDefaults setInteger:0 forKey:@"ENGLISH_REMIND_POINT"];
    }
    [self.searchBar setDelegate:self];
    selectedArray = [[NSMutableArray alloc] init];
    originVocabularys = [[NSMutableArray alloc] init];
    vocabularys = [[NSMutableArray alloc] init];
    counterVocabulary = [[NSMutableArray alloc] init];
    [self windowRefresh:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowRefresh:) name:@"NewVocabularyViewControllerRefresh" object:nil];
    selectedIndex = -1;

}
- (void)windowRefresh:(NSNotification *)notification {
    [self loadDataFromSQLite];

    self.textFieldTime.stringValue =[NSString stringWithFormat:@"%li" ,(long)[userDefaults integerForKey:@"ENGLISH_REMIND_TIME"]];
    self.textfieldInputCounter.stringValue = [NSString stringWithFormat:@"%li" ,(long)[userDefaults integerForKey:@"ENGLISH_REMIND_COUNTER"] ];
    self.labelPoint.stringValue = [NSString stringWithFormat:@"%li" ,(long)[userDefaults integerForKey:@"ENGLISH_REMIND_POINT"]];
}
- (void)loadDataFromSQLite {
    
    [SQLiteLibrary setDatabaseFileInDocuments:@"NewVocabulary" ofType:@"sqlite"];
//    [SQLiteLibrary setupDatabaseAndForceReset:YES];
    [vocabularys removeAllObjects];
    [originVocabularys removeAllObjects];
    [SQLiteLibrary begin];
    [SQLiteLibrary performQuery:@"SELECT * FROM Vocabulary" block:^(sqlite3_stmt *rowData) {
        VocabularyModel * vocabularyModel = [[VocabularyModel alloc] init];
        vocabularyModel.ID = sqlite3_column_int(rowData, 0);
        vocabularyModel.english = sqlite3_column_nsstring(rowData, 1);
        vocabularyModel.vietnamese = sqlite3_column_nsstring(rowData, 2);
        vocabularyModel.type = sqlite3_column_nsstring(rowData, 3);
        vocabularyModel.isFavorite = sqlite3_column_int(rowData, 4);
        [originVocabularys addObject:vocabularyModel];
        
    }];
    [SQLiteLibrary commit];
    
    vocabularys = [originVocabularys mutableCopy];
    [self.listTable  reloadData];
}
#pragma mark TableView Delegate DataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    if (vocabularys.count > 0){
        if (!isFirstRun){
            [self abtnAuto:self.btnAuto];
            isFirstRun = YES;
        }
    }
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

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row{
    selectedIndex = row;
    return YES;
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
    for (VocabularyModel *vocabulary in vocabularys) {
        BOOL isExist = NO;
        for (VocabularyModel *voca in selectedArray){
            if (vocabulary.ID == voca.ID){
                isExist = YES;
                break;
            }
        }
        if (!isExist){
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



- (IBAction)abtnUpdate:(id)sender {
    if (selectedIndex >= 0){
        addVC = [[AddVocabularyViewController alloc] initWithWindowNibName:@"AddVocabularyViewController"];
        addVC.window.level = CGWindowLevelForKey(kCGMaximumWindowLevelKey);
        addVC.vocabulary = vocabularys[selectedIndex];
        [addVC showWindow:self];
    }else {
        [self showAlertWithMessage:@"Warning" andInformative:@"Please choice 1 Item." andBlock:nil];
    }
}

- (IBAction)abtnQuit:(id)sender {
    [NSApp terminate:nil];
}

- (IBAction)abtnPlayNow:(id)sender {
    if ([selectedArray count] > 0){
        if (self.timerForLoopStatus){
            [self isEnableButton:YES];
            self.btnPlayNow.image = [NSImage imageNamed:@"Play_Now"];
            if ([self.timerForLoopStatus isValid]){
                [self.timerForLoopStatus invalidate];
            }
            self.timerForLoopStatus = nil;
        } else {
            [self isEnableButton:NO];
            self.btnPlayNow.image = [NSImage imageNamed:@"Stop"];
            [self autoPlayNow];
            self.timerForLoopStatus = [NSTimer scheduledTimerWithTimeInterval:self.textFieldTime.stringValue.intValue repeats:YES block:^(NSTimer * _Nonnull timer) {
                if (![showVC.window isVisible]) {
                    [self autoPlayNow];
                }
            }];
        }
        
        
    } else {
        [self showAlertWithMessage:@"Warning" andInformative:@"Please choice vocabulary" andBlock:nil];
        
    }
}

#pragma mark Methods privacy
-(void)isEnableButton:(BOOL)isEnable{
    self.btnAuto.enabled = isEnable;
    self.btnClear.enabled = isEnable;
    self.btnInsert.enabled = isEnable;
    self.btnUpdate.enabled = isEnable;
}
-(void)autoPlayNow{
    if ([self.textFieldTime.stringValue intValue] == 0 || [self.textfieldInputCounter.stringValue intValue] == 0){
        [self showAlertWithMessage:@"Warning" andInformative:@"Please Enter TIME and COUNTER by Number" andBlock:nil];
        return;
    }
    [userDefaults setInteger:[self.textFieldTime.stringValue integerValue] forKey:@"ENGLISH_REMIND_TIME"];
    [userDefaults setInteger:[self.textfieldInputCounter.stringValue integerValue] forKey:@"ENGLISH_REMIND_COUNTER"];

    showVC = [[ShowWindowController alloc] initWithWindowNibName:@"ShowWindowController"];
    showVC.window.level = CGWindowLevelForKey(kCGMaximumWindowLevelKey);
    
    NSUInteger n = [selectedArray count];
    if (n <= 0){
        if (!self.timerForLoopStatus){
            [self showAlertWithMessage:@"Warning" andInformative:@"Please choice vocabulary" andBlock:nil];
        } else {
            self.btnPlayNow.image = [NSImage imageNamed:@"Play_Now"];
            if ([self.timerForLoopStatus isValid]){
                [self.timerForLoopStatus invalidate];
            }
            self.timerForLoopStatus = nil;
            [self showAlertWithMessage:@"Warning" andInformative:@"Done" andBlock:nil];
            [self.listTable reloadData];
            
        }
    } else {
        showVC.vocabulary = selectedArray[arc4random() % n];
        __weak typeof(self) weakSelf = self;
        showVC.callBackBlock = ^(BOOL result,VocabularyModel *vocabulary){
            if (result){
                [counterVocabulary addObject:vocabulary];
                NSCountedSet *set = [[NSCountedSet alloc] initWithArray:counterVocabulary];
                NSUInteger count = [set countForObject:vocabulary];
                if (count >= [self.textfieldInputCounter.stringValue intValue]){
                    //remove item from list array
                    for (NSInteger i = selectedArray.count - 1; i >= 0; i--) {
                        VocabularyModel *tempVoca = selectedArray[i];
                        if (tempVoca.ID == vocabulary.ID){
                            [selectedArray removeObjectAtIndex:i];
                            break;
                        }
                    }
                    NSUserDefaults *myUserDefaults = [NSUserDefaults standardUserDefaults];
                    
                    NSInteger pointCounter = [myUserDefaults integerForKey:@"ENGLISH_REMIND_POINT"];
                    [myUserDefaults setInteger:pointCounter + 1 forKey:@"ENGLISH_REMIND_POINT"];
                    weakSelf.labelPoint.stringValue = [NSString stringWithFormat:@"%li",pointCounter + 1];
                    //update local
                    NSMutableDictionary *dict = [NSMutableDictionary new];
                    dict[@"english"] = vocabulary.english;
                    dict[@"vietnamese"] = vocabulary.vietnamese;
                    dict[@"type"] = vocabulary.type;
                    dict[@"favorite"] = vocabulary.isFavorite?@"1":@"0";
                    dict[@"audio"] = vocabulary.audio;
                    dict[@"done"] = [NSString stringWithFormat:@"%i",1];
                    dict[@"id"] = [NSString stringWithFormat:@"%li",(long)vocabulary.ID];
                    
                    [SQLiteLibrary begin];
                    [SQLiteLibrary performUpdateQueryInTable:@"Vocabulary" data:dict idColumn:@"id"];
                    [SQLiteLibrary commit];
                    if ([selectedArray count] <=0){
                        [weakSelf showAlertWithMessage:@"Successfully" andInformative:@"Finish! Well done." andBlock:nil];
                        weakSelf.btnPlayNow.image = [NSImage imageNamed:@"Play_Now"];
                        if ([weakSelf.timerForLoopStatus isValid]){
                            [weakSelf.timerForLoopStatus invalidate];
                        }
                        weakSelf.timerForLoopStatus = nil;
                    }
                    [weakSelf.listTable reloadData];
                    return ;
                }
            }
        };
        [showVC showWindow:self];
    }
}
- (void)controlTextDidChange:(NSNotification *)notification {
    NSTextField *textField = [notification object];
    if (![[textField stringValue] isEqualToString:@""]){
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.english contains[c] %@",[textField stringValue]];
        vocabularys = [NSMutableArray arrayWithArray:[originVocabularys filteredArrayUsingPredicate:predicate]];
    } else {
        vocabularys = [originVocabularys mutableCopy];
    }
    [self.listTable reloadData];
}

-(void)showAlertWithMessage:(NSString *)message andInformative:(NSString *)informative andBlock:(void (^ __nullable)(NSInteger result))block {
    NSAlert *alert = [NSAlert new];
    alert.messageText = message;
    alert.informativeText = informative;
    [alert addButtonWithTitle:@"OK"];
    [alert beginSheetModalForWindow:[self.view window] completionHandler:^(NSInteger result) {
        if (block != nil){
            block(result);
        }
    }];
}
@end
