//
//  VocabularyModel.h
//  English_Remind
//
//  Created by Cong Nguyen on 28/11/2017.
//  Copyright © 2017 MAC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VocabularyModel : NSObject
@property (nonatomic, assign) NSInteger ID;
@property (nonatomic, strong) NSString *english;
@property (nonatomic, strong) NSString *vietnamese;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, assign) BOOL isFavorite;
@property (nonatomic, strong) NSString *audio;
@property (nonatomic, assign) BOOL isDone;

@end
