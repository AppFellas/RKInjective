//
//  RKInjectiveStubObject.m
//  RKInjective
//
//  Created by Taras Kalapun on 1/28/13.
//  Copyright (c) 2013 AppFellas. All rights reserved.
//

#import <objc/runtime.h>
#import "RKInjectiveStubObject.h"
#import "NSString+Inflections.h"

@implementation RKInjectiveStubObject

+ (NSString *)modelName {
    return [NSStringFromClass([self class]) lowercaseString];
}

+ (NSString *)modelNamePlural {
    return [[self modelName] pluralize];
}

+ (NSDictionary *)objectMappingDictionary {
    
    NSString *modelIdentifier = [self uniqueIdentifierName];
    
    unsigned int count;
    objc_property_t *list = class_copyPropertyList([self class], &count);
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:count];
    
    for (unsigned i = 0; i < count; i++) {
        NSString *name = [NSString stringWithUTF8String:property_getName(list[i])];
        if ([name isEqualToString:modelIdentifier]) {
            [dict setObject:name forKey:@"id"];
        } else {
            [dict setObject:name forKey:[name underscore]];
        }
    }
    
    free(list);
    
    
    return dict;
}

+ (RKObjectMapping *)objectMapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping addAttributeMappingsFromDictionary:[self objectMappingDictionary]];
    return mapping;
}

+ (NSString *)uniqueIdentifierName {
    NSString *itemIdSel = @"itemId";
    if ([self instancesRespondToSelector:NSSelectorFromString(itemIdSel)]) {
        return itemIdSel;
    }
    return [[self modelName] stringByAppendingString:@"Id"];
}

- (id)uniqueIdentifier {
    NSString *_uniqueIdentifier = [[self class] uniqueIdentifierName];
    SEL _getUniqueIdentifier = NSSelectorFromString(_uniqueIdentifier);
    if ([self respondsToSelector:_getUniqueIdentifier]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        id _uniqueIdentifier =  [self performSelector:_getUniqueIdentifier];
#pragma clang diagnostic pop
        return _uniqueIdentifier;
    }
    return nil;
}

+ (void)getObjectsOnSuccess:(RKIObjectsSuccessBlock)success failure:(RKIFailureBlock)failure {
    NSString *routeName = [self modelNamePlural];
    [[RKObjectManager sharedManager] getObjectsAtPathForRouteNamed:routeName object:nil parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        success([mappingResult array]);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        failure(error);
    }];
}

- (void)getObjectOnSuccess:(RKIObjectSuccessBlock)success failure:(RKIFailureBlock)failure {
    [[RKObjectManager sharedManager] getObject:self path:nil parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        success([mappingResult firstObject]);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        failure(error);
    }];
}


@end