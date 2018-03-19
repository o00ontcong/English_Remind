//
//  AvailableVocabularyViewController.m
//  English_Remind
//
//  Created by Cong Nguyen on 16/03/2018.
//  Copyright © 2018 MAC. All rights reserved.
//

#import "AvailableVocabularyViewController.h"
#import "Utility.h"

@interface AvailableVocabularyViewController ()<NSTableViewDelegate,NSTableViewDataSource,NSTextFieldDelegate>{
    NSUserDefaults *userDefaults;
    NSMutableArray *vocabularys, *selectedArray, *originVocabularys, *counterVocabulary;
    NSInteger selectedIndex;

}

@end

@implementation AvailableVocabularyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.viewDatePicker setDateValue:[NSDate date]];
    self.viewDatePicker.delegate = self;
    
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
    [self loadDataFromSQLite];

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
    [self loadDataFromSQLite];
    
    self.textFieldTime.stringValue =[NSString stringWithFormat:@"%li" ,(long)[userDefaults integerForKey:@"ENGLISH_REMIND_TIME"]];
    self.textFieldCounter.stringValue = [NSString stringWithFormat:@"%li" ,(long)[userDefaults integerForKey:@"ENGLISH_REMIND_COUNTER"] ];
    self.labelPoint.stringValue = [NSString stringWithFormat:@"%li" ,(long)[userDefaults integerForKey:@"ENGLISH_REMIND_POINT"]];
}
- (void)loadDataFromSQLite {
    
    [vocabularys removeAllObjects];
    [originVocabularys removeAllObjects];
    [SQLiteLibrary setDatabaseFileInDocuments:@"AutoEV" ofType:@"sqlite"];
//    [SQLiteLibrary setupDatabaseAndForceReset:YES];
    [SQLiteLibrary begin];
    [SQLiteLibrary performQuery:@"SELECT * FROM phrases" block:^(sqlite3_stmt *rowData) {
        VocabularyModel * vocabularyModel = [[VocabularyModel alloc] init];
        vocabularyModel.ID = sqlite3_column_int(rowData, 0);
        vocabularyModel.english = sqlite3_column_nsstring(rowData, 1);
        vocabularyModel.vietnamese = sqlite3_column_nsstring(rowData, 2);
        vocabularyModel.type = sqlite3_column_nsstring(rowData, 6);
        vocabularyModel.isFavorite = sqlite3_column_int(rowData, 4);
        [originVocabularys addObject:vocabularyModel];
        
    }];
    [SQLiteLibrary commit];
    
    vocabularys = [originVocabularys mutableCopy];
    [self.listTableView reloadData];
}
#pragma mark TableView Delegate DataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    if (tableView == self.listTableView){
        return originVocabularys.count;
    } else {
        return vocabularys.count;
    }
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
    }
    return cell;
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row{
    selectedIndex = row;
    return YES;
}

- (IBAction)quitAction:(id)sender {
    [NSApp terminate:nil];

}
- (IBAction)abtnPlayNow:(id)sender {
}

- (IBAction)abtnAuto:(id)sender {
//    [self loadDataFromSQLite];
//
//    [selectedArray removeAllObjects];
//    for (VocabularyModel *vocabulary in vocabularys) {
//        if (vocabulary.isFavorite == TRUE){
//            [selectedArray addObject:vocabulary];
//        }
//        if ([selectedArray count] >= 10){
//            [self.listTable reloadData];
//            return;
//        }
//    }
//    for (VocabularyModel *vocabulary in vocabularys) {
//        BOOL isExist = NO;
//        for (VocabularyModel *voca in selectedArray){
//            if (vocabulary.ID == voca.ID){
//                isExist = YES;
//                break;
//            }
//        }
//        if (!isExist){
//            [selectedArray addObject:vocabulary];
//        }
//        if ([selectedArray count] >= 10){
//            [self.listTable reloadData];
//            return;
//        }
//    }
//
//    [self.listTable reloadData];
    
}
- (IBAction)abtnClear:(id)sender {
//    [selectedArray removeAllObjects];
//    [self.listTable reloadData];
    
}

@end
