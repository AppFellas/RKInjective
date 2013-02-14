//
//  Author.h
//  RKInjective
//
//  Created by Alex on 2/14/13.
//  Copyright (c) 2013 AppFellas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Book;

@interface Author : NSManagedObject <RKInjectiveProtocol>

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * authorId;
@property (nonatomic, retain) NSSet *books;
@end

@interface Author (CoreDataGeneratedAccessors)

- (void)addBooksObject:(Book *)value;
- (void)removeBooksObject:(Book *)value;
- (void)addBooks:(NSSet *)values;
- (void)removeBooks:(NSSet *)values;

@end
