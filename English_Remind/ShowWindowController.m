//
//  ShowWindowController.m
//  English_Remind
//
//  Created by Cong Nguyen on 25/11/2017.
//  Copyright © 2017 MAC. All rights reserved.
//

#import "ShowWindowController.h"

@interface ShowWindowController ()<NSSpeechSynthesizerDelegate>{
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
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults integerForKey:@"ENGLISH_REMIND_IS_SOUND"] == 0){
        return;
    }

    self.speechSynthesizer = [[NSSpeechSynthesizer alloc] init];
    self.speechSynthesizer.delegate = self;
    [self.speechSynthesizer startSpeakingString:self.vocabulary.english];

}
- (IBAction)closeAction:(id)sender {
    [self close];
}

- (IBAction)textfieldInputAction:(id)sender {
    [self.speechSynthesizer startSpeakingString:self.vocabulary.english];

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
