//
//  TOEIC700ViewController.m
//  English_Remind
//
//  Created by Cong Nguyen on 20/03/2018.
//  Copyright © 2018 MAC. All rights reserved.
//

#import "TOEIC700ViewController.h"

@interface TOEIC700ViewController ()<NSTableViewDelegate,NSTableViewDataSource,NSTextFieldDelegate>{
    NSUserDefaults *userDefaults;
    NSMutableArray *selectedArray, *originVocabularys, *counterVocabulary;
    NSInteger selectedIndex;
    ShowWindowController *showVC;
    
}
@end

@implementation TOEIC700ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.viewDatePicker setDateValue:[NSDate date]];
    self.viewDatePicker.delegate = self;
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
    if ([userDefaults objectForKey:@"ENGLISH_REMIND_IS_SOUND"] == nil){
        [userDefaults setInteger:0 forKey:@"ENGLISH_REMIND_IS_SOUND"];
    }
    // NMDatePicker appearance properties
    self.viewDatePicker.backgroundColor = [NSColor whiteColor];
    self.viewDatePicker.font = [NSFont systemFontOfSize:13.0];
    self.viewDatePicker.titleFont = [NSFont boldSystemFontOfSize:14.0];
    self.viewDatePicker.textColor = [NSColor blackColor];
    self.viewDatePicker.todayTextColor = [NSColor purpleColor];
    self.viewDatePicker.selectedTextColor = [NSColor whiteColor];
    self.viewDatePicker.todayBackgroundColor = [NSColor purpleColor];
    self.viewDatePicker.todayBorderColor = [NSColor redColor];
    self.viewDatePicker.highlightedBackgroundColor = [NSColor lightGrayColor];
    self.viewDatePicker.highlightedBorderColor = [NSColor darkGrayColor];
    self.viewDatePicker.selectedBackgroundColor = [NSColor orangeColor];
    self.viewDatePicker.selectedBorderColor = [NSColor blueColor];
    
    selectedArray = [[NSMutableArray alloc] init];
    originVocabularys = [[NSMutableArray alloc] init];
    counterVocabulary = [[NSMutableArray alloc] init];
    [self loadDataFromSQLite];
    [self windowRefresh:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowRefresh:) name:@"TOEIC700ViewController" object:nil];
    
}
+ (NSString *)shortDateForDate:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [NSLocale currentLocale];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    
    return [dateFormatter stringFromDate:date];
}
-(void)nmDatePicker:(NMDatePicker *)datePicker newSize:(NSSize)newSize{
    
}
-(void)nmDatePicker:(NMDatePicker *)datePicker selectedDate:(NSDate *)selectedDate{
    
}
- (void)windowRefresh:(NSNotification *)notification {
    self.textFieldTime.stringValue =[NSString stringWithFormat:@"%li" ,(long)[userDefaults integerForKey:@"ENGLISH_REMIND_TIME"]];
    self.textFieldCounter.stringValue = [NSString stringWithFormat:@"%li" ,(long)[userDefaults integerForKey:@"ENGLISH_REMIND_COUNTER"] ];
    self.labelPoint.stringValue = [NSString stringWithFormat:@"%li" ,(long)[userDefaults integerForKey:@"ENGLISH_REMIND_POINT"]];
    [self.btnSoundOutlet setState:[userDefaults integerForKey:@"ENGLISH_REMIND_IS_SOUND"]];

}
- (void)loadDataFromSQLite {
    
    [originVocabularys removeAllObjects];
    [SQLiteLibrary setDatabaseFileInDocuments:@"700TOEIC" ofType:@"sqlite"];
    [SQLiteLibrary begin];
    [SQLiteLibrary performQuery:@"SELECT * FROM ZVOCABWORD" block:^(sqlite3_stmt *rowData) {
        VocabularyModel * vocabularyModel = [[VocabularyModel alloc] init];
        vocabularyModel.ID = sqlite3_column_int(rowData, 0);
        vocabularyModel.english = sqlite3_column_nsstring(rowData, 6);
        vocabularyModel.vietnamese = sqlite3_column_nsstring(rowData, 5);
        vocabularyModel.isFavorite = sqlite3_column_int(rowData, 2);
        [originVocabularys addObject:vocabularyModel];
        
    }];
    [SQLiteLibrary commit];
    [selectedArray removeAllObjects];
    for (int i = 0; i < originVocabularys.count; i ++) {
        VocabularyModel * vocabularyModel = originVocabularys[i];
        if (vocabularyModel.isFavorite == NO){
            [selectedArray addObject:vocabularyModel];
        }
        if ([selectedArray count] >= 5){
            break;
        }
    }
    [self.todayTableView reloadData];
}
#pragma mark TableView Delegate DataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return originVocabularys.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    NSString *identifierStr = tableColumn.identifier;
    NSTableCellView *cell = [tableView makeViewWithIdentifier:identifierStr owner:self];
    
    VocabularyModel *item = originVocabularys[row];
    
    if ([identifierStr isEqualToString: @"english"]){
        [cell textField].stringValue = [NSString stringWithFormat:@"%@",item.english];
    } else if ([identifierStr isEqualToString: @"vietnamese"]){
        [cell textField].stringValue = [NSString stringWithFormat:@"%@",item.vietnamese];
    } else if ([identifierStr isEqualToString: @"done"]){
        FavoriteTableCellView *cell = [tableView makeViewWithIdentifier:identifierStr owner:self];
        [cell.btnFavorite setTag: row];
        [cell.btnFavorite setAction:@selector(abtnDoneRow:)];
        [cell.btnFavorite setState: item.isFavorite];
        cell.wantsLayer = YES;  // make the cell layer-backed
        cell.layer.backgroundColor = nil;
        if ([self isExistInsideSelectedByID:item.ID]){
            cell.layer.backgroundColor = [[NSColor greenColor] CGColor]; // or whatever color you like
        }
        
        return cell;
    }
    cell.wantsLayer = YES;  // make the cell layer-backed
    cell.layer.backgroundColor = nil;
    if ([self isExistInsideSelectedByID:item.ID]){
        cell.layer.backgroundColor = [[NSColor greenColor] CGColor]; // or whatever color you like
    }
    
    
    return cell;
}

- (IBAction)quitAction:(id)sender {
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
-(void)isEnableButton:(BOOL)isEnable{
    [self.todayTableView setEnabled:isEnable];
}
-(void)autoPlayNow{
    if ([self.textFieldTime.stringValue intValue] == 0 || [self.textFieldCounter.stringValue intValue] == 0){
        [self showAlertWithMessage:@"Warning" andInformative:@"Please Enter TIME and COUNTER by Number" andBlock:nil];
        return;
    }
    [userDefaults setInteger:[self.textFieldTime.stringValue integerValue] forKey:@"ENGLISH_REMIND_TIME"];
    [userDefaults setInteger:[self.textFieldCounter.stringValue integerValue] forKey:@"ENGLISH_REMIND_COUNTER"];
    
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
            [self.todayTableView reloadData];
            
        }
    } else {
        showVC.vocabulary = selectedArray[arc4random() % n];
        __weak typeof(self) weakSelf = self;
        showVC.callBackBlock = ^(BOOL result,VocabularyModel *vocabulary){
            if (result){
                [counterVocabulary addObject:vocabulary];
                NSCountedSet *set = [[NSCountedSet alloc] initWithArray:counterVocabulary];
                NSUInteger count = [set countForObject:vocabulary];
                if (count >= [self.textFieldCounter.stringValue intValue]){
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
                    [SQLiteLibrary setDatabaseFileInDocuments:@"700TOEIC" ofType:@"sqlite"];
                    NSString *sql = [NSString stringWithFormat:@"UPDATE ZVOCABWORD SET Z_OPT = '1' WHERE Z_PK = %li", vocabulary.ID];
                    [SQLiteLibrary begin];
                    [SQLiteLibrary performQuery: sql block:^(sqlite3_stmt *rowData) {
                    }];
                    [SQLiteLibrary commit];
                    for (VocabularyModel *item in originVocabularys) {
                        if (vocabulary.ID == item.ID){
                            item.isFavorite = 1;
                            break;
                        }
                    }
                    if ([selectedArray count] <=0){
                        [weakSelf showAlertWithMessage:@"Successfully" andInformative:@"Finish! Well done." andBlock:^(NSInteger result) {
                            for (int i = 0; i < originVocabularys.count; i ++) {
                                VocabularyModel * vocabularyModel = originVocabularys[i];
                                if (vocabularyModel.isFavorite == NO){
                                    [selectedArray addObject:vocabularyModel];
                                }
                                if ([selectedArray count] >= 5){
                                    break;
                                }
                            }
                            [self.todayTableView reloadData];
                        }];
                        weakSelf.btnPlayNow.image = [NSImage imageNamed:@"Play_Now"];
                        if ([weakSelf.timerForLoopStatus isValid]){
                            [weakSelf.timerForLoopStatus invalidate];
                        }
                        weakSelf.timerForLoopStatus = nil;
                    }
                    [weakSelf.todayTableView reloadData];
                    return ;
                }
            }
        };
        [showVC showWindow:self];
    }
}
-(BOOL)isExistInsideSelectedByID:(NSInteger) ID {
    for (VocabularyModel *item  in selectedArray) {
        if(item.ID == ID){
            return YES;
        }
    }
    return NO;
    
}
-(NSString *)decodeDatabyBase64:(NSString *)decodeString{
    NSString *newDecodeString = [decodeString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:newDecodeString options:0];
    NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
    return decodedString;
}

- (IBAction)abtnDoneRow:(id)sender {
    NSButton *select = sender;
    VocabularyModel * vocabularyModel = (VocabularyModel*)originVocabularys[select.tag] ;
    [SQLiteLibrary setDatabaseFileInDocuments:@"700TOEIC" ofType:@"sqlite"];

    NSString *sql = [NSString stringWithFormat:@"UPDATE ZVOCABWORD SET Z_OPT = '%ld' WHERE Z_PK = %li",(long)select.state, vocabularyModel.ID];
    [SQLiteLibrary begin];
    [SQLiteLibrary performQuery: sql block:^(sqlite3_stmt *rowData) {
    }];
    [SQLiteLibrary commit];
    vocabularyModel.isFavorite = select.state;
    [selectedArray removeAllObjects];
    for (int i = 0; i < originVocabularys.count; i ++) {
        VocabularyModel * vocabularyModel = originVocabularys[i];
        if (vocabularyModel.isFavorite == NO){
            [selectedArray addObject:vocabularyModel];
        }
        if ([selectedArray count] >= 5){
            break;
        }
    }
    [self.todayTableView reloadData];
    
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
- (IBAction)btnSound:(id)sender {
    NSButton *button = sender;
    [userDefaults setInteger:(long)button.state forKey:@"ENGLISH_REMIND_IS_SOUND"];
    [self.btnSoundOutlet setState:[userDefaults integerForKey:@"ENGLISH_REMIND_IS_SOUND"]];
    
}
@end

