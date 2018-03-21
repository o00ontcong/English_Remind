//
//  AvailableVocabularyViewController.m
//  English_Remind
//
//  Created by Cong Nguyen on 16/03/2018.
//  Copyright © 2018 MAC. All rights reserved.
//

#import "AvailableVocabularyViewController.h"
#import "Utility.h"
#import "FavoriteTableCellView.h"
#import "ShowWindowController.h"

@interface AvailableVocabularyViewController ()<NSTableViewDelegate,NSTableViewDataSource,NSTextFieldDelegate>{
    NSUserDefaults *userDefaults;
    NSMutableArray *vocabularys, *selectedArray, *originVocabularys, *counterVocabulary, *selectedArrayType;
    NSInteger selectedIndex;
    ShowWindowController *showVC;

}

@end

@implementation AvailableVocabularyViewController

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
    
    vocabularys = [[NSMutableArray alloc] init];
    selectedArray = [[NSMutableArray alloc] init];
    originVocabularys = [[NSMutableArray alloc] init];
    counterVocabulary = [[NSMutableArray alloc] init];
    selectedArrayType = [[NSMutableArray alloc] init];
    [self loadDataFromSQLite];
    [self windowRefresh:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowRefresh:) name:@"AvailableVocabularyViewController" object:nil];

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
    [self loadSelectArrayWithIndex:selectedIndex];
    self.textFieldTime.stringValue =[NSString stringWithFormat:@"%li" ,(long)[userDefaults integerForKey:@"ENGLISH_REMIND_TIME"]];
    self.textFieldCounter.stringValue = [NSString stringWithFormat:@"%li" ,(long)[userDefaults integerForKey:@"ENGLISH_REMIND_COUNTER"] ];
    self.labelPoint.stringValue = [NSString stringWithFormat:@"%li" ,(long)[userDefaults integerForKey:@"ENGLISH_REMIND_POINT"]];
    [self.btnSoundOutlet setState:[userDefaults integerForKey:@"ENGLISH_REMIND_IS_SOUND"]];

}
- (void)loadDataFromSQLite {
    
    [originVocabularys removeAllObjects];
    [SQLiteLibrary setDatabaseFileInDocuments:@"AutoEV" ofType:@"sqlite"];
    [SQLiteLibrary begin];
    [SQLiteLibrary performQuery:@"SELECT * FROM phrases" block:^(sqlite3_stmt *rowData) {
        VocabularyModel * vocabularyModel = [[VocabularyModel alloc] init];
        vocabularyModel.ID = sqlite3_column_int(rowData, 0);
        vocabularyModel.english = sqlite3_column_nsstring(rowData, 1);
        vocabularyModel.english = [self decodeDatabyBase64:vocabularyModel.english];
        vocabularyModel.vietnamese = sqlite3_column_nsstring(rowData, 2);
        vocabularyModel.vietnamese = [self decodeDatabyBase64:vocabularyModel.vietnamese];

        vocabularyModel.type = sqlite3_column_nsstring(rowData, 6);
        vocabularyModel.isFavorite = sqlite3_column_int(rowData, 4);
        [originVocabularys addObject:vocabularyModel];
        
    }];
    [SQLiteLibrary commit];
    [self filterOriginVocabulary:originVocabularys];
    [self.listTableView reloadData];
}
#pragma mark TableView Delegate DataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    if (tableView == self.listTableView){
        return selectedArrayType.count;
    } else {
        return vocabularys.count;
    }
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    NSString *identifierStr = tableColumn.identifier;
    NSTableCellView *cell = [tableView makeViewWithIdentifier:identifierStr owner:self];
    if (tableView == self.listTableView){
    TypeVocabulary * typeVocabulary = (TypeVocabulary*)selectedArrayType[row] ;
    
        if ([identifierStr isEqualToString: @"number"]){
            [cell textField].stringValue = [NSString stringWithFormat:@"%ld",(long)typeVocabulary.number];
        } else if ([identifierStr isEqualToString: @"type"]){
            [cell textField].stringValue = [NSString stringWithFormat:@"%@",typeVocabulary.type];
        } else if ([identifierStr isEqualToString: @"totalDone"]){
            [cell textField].stringValue = [NSString stringWithFormat:@"%ld",typeVocabulary.TotalFavorite];
        }
    } else {
        VocabularyModel *item = vocabularys[row];
        
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
    }

    return cell;
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row{
    if (tableView == self.listTableView){
    selectedIndex = row;
    [self loadSelectArrayWithIndex:row];
    }
    return YES;
}
-(void)loadSelectArrayWithIndex:(NSInteger)row{
    TypeVocabulary *item = selectedArrayType[row];
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM phrases WHERE tag == '%@'",item.type];
    [vocabularys removeAllObjects];
    [selectedArray removeAllObjects];
    [SQLiteLibrary setDatabaseFileInDocuments:@"AutoEV" ofType:@"sqlite"];

    [SQLiteLibrary begin];
    [SQLiteLibrary performQuery: sql block:^(sqlite3_stmt *rowData) {
        VocabularyModel * vocabularyModel = [[VocabularyModel alloc] init];
        vocabularyModel.ID = sqlite3_column_int(rowData, 0);
        vocabularyModel.english = sqlite3_column_nsstring(rowData, 1);
        vocabularyModel.english = [self decodeDatabyBase64:vocabularyModel.english];
        vocabularyModel.vietnamese = sqlite3_column_nsstring(rowData, 2);
        vocabularyModel.vietnamese = [self decodeDatabyBase64:vocabularyModel.vietnamese];
        vocabularyModel.type = sqlite3_column_nsstring(rowData, 6);
        vocabularyModel.isFavorite = sqlite3_column_int(rowData, 4);
        [vocabularys addObject:vocabularyModel];
        
    }];
    [SQLiteLibrary commit];
    
    for (int i = 0; i < vocabularys.count; i ++) {
        VocabularyModel * vocabularyModel = vocabularys[i];
        if (vocabularyModel.isFavorite == NO){
            [selectedArray addObject:vocabularyModel];
        }
        if ([selectedArray count] >= 5){
            break;
        }
    }
    [self.todayTableView reloadData];
}
-(void)autoChoiceVocabulary{
    
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
    [self.listTableView setEnabled:isEnable];
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
                    NSString *sql = [NSString stringWithFormat:@"UPDATE phrases SET favorite = '%d' WHERE idphrases = %li",1, vocabulary.ID];
                    [SQLiteLibrary begin];
                    [SQLiteLibrary performQuery: sql block:^(sqlite3_stmt *rowData) {
                    }];
                    [SQLiteLibrary commit];
                    [self loadSelectArrayWithIndex:selectedIndex];
                    [self.todayTableView reloadData];
                    if ([selectedArray count] <=0){
                        [weakSelf showAlertWithMessage:@"Successfully" andInformative:@"Finish! Well done." andBlock:nil];
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
-(void)filterOriginVocabulary:(NSArray *) array{
    
    for (VocabularyModel *item in array) {
        BOOL exist = NO;
        for (TypeVocabulary *itemType in selectedArrayType) {
            if ([item.type isEqualToString:itemType.type]){
                exist = YES;
                
                itemType.number += 1;
                if (item.isFavorite == TRUE){
                    itemType.TotalFavorite += 1;
                }
                break;
            }
        }
        if (exist == NO) {
            TypeVocabulary *newItem = [[TypeVocabulary alloc] init];
            newItem.type = item.type;
            newItem.number = 0;
            newItem.TotalFavorite = 0;
            [selectedArrayType addObject:newItem];
        }
    }
    
    [selectedArrayType sortUsingDescriptors:
     @[
       [NSSortDescriptor sortDescriptorWithKey:@"type" ascending:YES]
       ]];
}
- (IBAction)abtnDoneRow:(id)sender {
    NSButton *select = sender;
    VocabularyModel * vocabularyModel = (VocabularyModel*)vocabularys[select.tag] ;
    
    NSString *sql = [NSString stringWithFormat:@"UPDATE phrases SET favorite = '%ld' WHERE idphrases = %li",(long)select.state, vocabularyModel.ID];
    [SQLiteLibrary begin];
    [SQLiteLibrary performQuery: sql block:^(sqlite3_stmt *rowData) {
    }];
    [SQLiteLibrary commit];
    [self loadSelectArrayWithIndex:selectedIndex];
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
