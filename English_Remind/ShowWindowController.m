//
//  ShowWindowController.m
//  English_Remind
//
//  Created by Cong Nguyen on 25/11/2017.
//  Copyright © 2017 MAC. All rights reserved.
//

#import "ShowWindowController.h"

@interface ShowWindowController (){
    BOOL result;
}

@end

@implementation ShowWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    
}
-(void)showWindow:(id)sender{
    [super showWindow:sender];
    self.textVietnamese.stringValue = self.vocabulary.vietnamese;
    result = YES;
}
- (IBAction)closeAction:(id)sender {
    [self close];
}

- (IBAction)textfieldInputAction:(id)sender {
    NSCharacterSet * alphaNumSet = [NSCharacterSet characterSetWithCharactersInString:@"!@#$%^&*?.,'~-=_+()[]/<>:;"];

    NSString *stringValue = self.textfieldInput.stringValue.lowercaseString;
    stringValue = [stringValue stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    stringValue = [stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    stringValue = [stringValue stringByTrimmingCharactersInSet:alphaNumSet];
    
    NSString *vocabulary = self.vocabulary.english.lowercaseString;
    vocabulary = [vocabulary stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    vocabulary = [vocabulary stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    vocabulary = [vocabulary stringByTrimmingCharactersInSet:alphaNumSet];
    
    if ([stringValue isEqualToString:vocabulary]){
        self.callBackBlock(result,self.vocabulary);
        [self close];
        return;
    } else {
        result = YES;
        self.textEnglish.stringValue = self.vocabulary.english;
    }
}

@end
