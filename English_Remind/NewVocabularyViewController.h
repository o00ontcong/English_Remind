//
//  NewVocabularyViewController.h
//  English_Remind
//
//  Created by MAC on 20/11/2016.
//  Copyright © 2016 MAC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Utility.h"
#import "SQLiteLibrary.h"
#import "DeleteTableCellView.h"
#import "SelectTableCellView.h"
#import "FavoriteTableCellView.h"
@interface NewVocabularyViewController : NSViewController
@property (weak) IBOutlet NSTextField *searchBar;
@property (weak) IBOutlet NSButton *btnInsert;
@property (weak) IBOutlet NSButton *btnUpdate;
@property (weak) IBOutlet NSButton *btnClear;

@end
