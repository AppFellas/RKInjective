//
//  Book.h
//  RKInjective
//
//  Created by Alex on 2/14/13.
//  Copyright (c) 2013 AppFellas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Author;

@interface Book : NSManagedObject <RKInjectiveProtocol>

@property (nonatomic, retain) NSString * bookId;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) Author *author;

@end
