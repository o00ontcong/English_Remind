//
//  MainTabViewController.m
//  English_Remind
//
//  Created by Cong Nguyen on 16/03/2018.
//  Copyright © 2018 MAC. All rights reserved.
//

#import "MainTabViewController.h"
#import "NewVocabularyViewController.h"
#import "AvailableVocabularyViewController.h"
@interface MainTabViewController ()

@end

@implementation MainTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSUserDefaults *userDefaults;
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
}

-(void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem{
    NSUInteger index = [tabView indexOfTabViewItem:[tabView selectedTabViewItem]];
    if (index == 0){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NewVocabularyViewControllerRefresh" object:nil];

    } else if (index == 1){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AvailableVocabularyViewController" object:nil];

    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TOEIC700ViewController" object:nil];

    }


}
-(void)tabView:(NSTabView *)tabView willSelectTabViewItem:(NSTabViewItem *)tabViewItem{

}
@end
