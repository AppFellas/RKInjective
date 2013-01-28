//
//  Article.h
//  RKInjective
//
//  Created by Taras Kalapun on 1/28/13.
//  Copyright (c) 2013 AppFellas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Article : NSObject <RKInjectiveProtocol>

@property (nonatomic, strong) NSString *articleId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *title;

@end
