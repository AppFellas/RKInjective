//
//  RKInjectiveStubObject.m
//  RKInjective
//
//  Created by Taras Kalapun on 1/28/13.
//  Copyright (c) 2013 AppFellas. All rights reserved.
//

#import <objc/runtime.h>
#import <objc/message.h>
#import "RKInjectiveStubObject.h"
#import "NSString+Inflections.h"


@implementation RKInjectiveStubObject

+ (NSString *)modelName {
    // TODO: Fix for CoreData
    NSString *ret = NSStringFromClass([self class]);
    unichar capitalLetter = [ret characterAtIndex:0];
	NSString *letter = [[NSString stringWithCharacters:&capitalLetter length:1] lowercaseString];
	NSString *rest = [ret substringFromIndex:1];
    
	return [NSString stringWithFormat:@"%@%@", letter, rest];
}

+ (NSString *)modelNamePlural {
    return [[self modelName] pluralize];
}

+ (NSDictionary *)objectMappingDictionary {
    
    NSString *modelIdentifier = [self uniqueIdentifierName];
    if (!modelIdentifier) return nil;
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    if ([[self class] isSubclassOfClass:[NSManagedObject class]]) {
        RKManagedObjectStore *managedObjectStore = [RKManagedObjectStore defaultStore];
        if (!managedObjectStore) {
            return nil;
        }
        // TODO: Fix this
        NSString *entityName = NSStringFromClass([self class]);
        NSDictionary *entities = [managedObjectStore.managedObjectModel entitiesByName];
        if ( nil == entities || 0 == [entities count] ) {
            return nil;
        }
        NSEntityDescription *entity = [entities objectForKey:entityName];
        if ( nil == entity ) {
            return nil;
        }
        
        for (NSAttributeDescription *property in entity.properties) {
            NSString *name = [property name];
            
            if ([property isKindOfClass:[NSRelationshipDescription class]]) continue;
            
            if ([name isEqualToString:modelIdentifier]) {
                [dict setObject:name forKey:@"id"];
            } else {
                [dict setObject:name forKey:[name underscore]];
            }
        }
        return dict;
    }
    
    unsigned int count;
    objc_property_t *list = class_copyPropertyList([self class], &count);
    
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

+ (NSDictionary *)objectRequestMappingDictionary {
    NSDictionary *mappincDict = [self objectMappingDictionary];
    NSMutableDictionary *requestMapping = [NSMutableDictionary new];
    for (NSString *key in [mappincDict allKeys]) {
        requestMapping[mappincDict[key]] = key;
    }
    return requestMapping;
}

+ (RKObjectMapping *)objectMapping {
    Class cls = [self class];
    
    // CoreData
    if ([cls isSubclassOfClass:[NSManagedObject class]]) {
        RKManagedObjectStore *store = [RKManagedObjectStore defaultStore];
        //NSAssert(store, @"RKManagedObjectStore doesnt exist");
        if (!store) return nil;
        
        // TODO: Fix for CoreData
        NSString *modelName = NSStringFromClass([self class]);
        RKEntityMapping *mapping = [RKEntityMapping mappingForEntityForName:modelName inManagedObjectStore:store];
        if (!mapping.identificationAttributes && [self uniqueIdentifierName]) {
            mapping.identificationAttributes = @[[self uniqueIdentifierName]];
        }
        if (mapping.attributeMappings.count == 0 && [self objectMappingDictionary]) {
            [mapping addAttributeMappingsFromDictionary:[self objectMappingDictionary]];
        }
        return mapping;
    }
    
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:cls];
    [mapping addAttributeMappingsFromDictionary:[self objectMappingDictionary]];
    
    return mapping;
}

+ (NSArray *)objectRelationsMappings {
    RKManagedObjectStore *managedObjectStore = [RKManagedObjectStore defaultStore];
    if (!managedObjectStore) return nil;
    NSString *entityName = NSStringFromClass([self class]);
    NSEntityDescription *entity = [[managedObjectStore.managedObjectModel entitiesByName] objectForKey:entityName];
    NSDictionary *relationsDict = entity.relationshipsByName;
    
    NSMutableArray *mappings = [NSMutableArray new];
    
    for (NSString *key in [relationsDict allKeys]) {
        NSRelationshipDescription *relationDescription = relationsDict[key];
        NSString *destination = relationDescription.destinationEntity.name;
        Class dstClass = NSClassFromString(destination);
        if (![dstClass conformsToProtocol:@protocol(RKInjectiveProtocol)]) continue;
        RKObjectMapping *relMapping = [dstClass objectMapping];
        RKRelationshipMapping *relationMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:[key underscore]
                                                                                             toKeyPath:key
                                                                                           withMapping:relMapping];
        [mappings addObject:relationMapping];
    }
    
    return mappings;
}

+ (RKObjectMapping *)requestMapping {
    RKObjectMapping *mapping = [RKObjectMapping requestMapping];
    [mapping addAttributeMappingsFromDictionary:[self objectRequestMappingDictionary]];
    return mapping;
}

+ (NSString *)pathForRequestType:(RKIRequestType)requestType {
    return nil;
}

+ (NSString *)defaultPathForRequestType:(RKIRequestType)requestType {
    NSString *path = nil;
    switch (requestType) {
        case RKIRequestPatchObject:
        case RKIRequestPutObject:
        case RKIRequestDeleteObject:
        case RKIRequestGetObject: {
            path = [[self modelNamePlural] stringByAppendingFormat:@"/:%@", [self uniqueIdentifierName]];
            break;
        }
        case RKIRequestPostObject:
        default: {
            path = [self modelNamePlural];
            break;
        }
    }
    return path;
}

+ (NSString *)uniqueIdentifierName {
    NSString *testProperty1 = @"itemId";
    NSString *testProperty2 = [[self modelName] stringByAppendingString:@"Id"];

    if ([[self class] isSubclassOfClass:[NSManagedObject class]]) {
        RKManagedObjectStore *managedObjectStore = [RKManagedObjectStore defaultStore];
        if (!managedObjectStore) return nil;
        // TODO: Fix this
        NSString *entityName = NSStringFromClass([self class]);
        NSEntityDescription *entity = [[managedObjectStore.managedObjectModel entitiesByName] objectForKey:entityName];
        
        for (NSAttributeDescription *property in entity.properties) {
            NSString *pName = [property name];
            if ([pName isEqualToString:testProperty1] || [pName isEqualToString:testProperty2]) {
                return pName;
            }
        }
    }
    
    if ([self instancesRespondToSelector:NSSelectorFromString(testProperty1)]) {
        return testProperty1;
    }
    if ([self instancesRespondToSelector:NSSelectorFromString(testProperty2)]) {
        return testProperty2;
    }
    return nil;
}

- (id)uniqueIdentifier {
    NSString *_uniqueIdentifier = [[self class] uniqueIdentifierName];
    SEL _getUniqueIdentifier = NSSelectorFromString(_uniqueIdentifier);
    if ([self respondsToSelector:_getUniqueIdentifier]) {
        id _uniqueIdentifier = objc_msgSend(self, _getUniqueIdentifier);
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

- (void)deleteObjectOnSuccess:(RKIBlock)success failure:(RKIFailureBlock)failure {
    [[RKObjectManager sharedManager] deleteObject:self path:nil parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        success();
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        failure(error);
    }];
}

- (void)postObjectOnSuccess:(RKIObjectSuccessBlock)success failure:(RKIFailureBlock)failure {
    [[RKObjectManager sharedManager] postObject:self path:nil parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        success([mappingResult firstObject]);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        failure(error);
    }];
}

- (void)putObjectOnSuccess:(RKIObjectSuccessBlock)success failure:(RKIFailureBlock)failure {
    [[RKObjectManager sharedManager] putObject:self path:nil parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        success([mappingResult firstObject]);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        failure(error);
    }];
}

- (void)patchObjectOnSuccess:(RKIObjectSuccessBlock)success failure:(RKIFailureBlock)failure {
    [[RKObjectManager sharedManager] patchObject:self path:nil parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult){
        success([mappingResult firstObject]);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        failure(error);
    }];
}

@end