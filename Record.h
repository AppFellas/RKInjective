//
//  Record.h
//  RKInjective
//
//  Created by Sergii Kliuiev on 1/29/13.
//  Copyright (c) 2013 AppFellas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Record : NSObject <RKInjectiveProtocol>
@property (nonatomic, strong) NSString *itemId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *title;
@end
