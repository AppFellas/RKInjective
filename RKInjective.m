//
//  RKInjective.m
//  RESTClient
//
//  Created by Sergii Kliuiev on 1/23/13.
//  Copyright (c) 2013 Sergii Kliuiev. All rights reserved.
//

#import <objc/runtime.h>
#import "RKInjective.h"
#import "NSString+Inflections.h"

@interface RKInjectiveStubObject : NSObject 
@end

@implementation RKInjectiveStubObject

+ (NSString *)modelName {
    return [NSStringFromClass([self class]) lowercaseString];
}

+ (NSString *)modelNamePlural {
    return [[self modelName] pluralize];
}

+ (NSDictionary *)objectMappingDictionary {
    
    NSString *modelIdentifier = [[self modelName] stringByAppendingString:@"Id"];
    
    unsigned int count;
    objc_property_t *list = class_copyPropertyList([self class], &count);
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:count];
    
    for (unsigned i = 0; i < count; i++) {
        NSString *name = [NSString stringWithUTF8String:property_getName(list[i])];
        if ([name isEqualToString:@"itemId"] || [name isEqualToString:modelIdentifier]) {
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

+ (void)getObjectsOnSuccess:(RKIObjectsSuccessBlock)success failure:(RKIFailureBlock)failure {
    NSString *routeName = [self modelNamePlural];
    [[RKObjectManager sharedManager] getObjectsAtPathForRouteNamed:routeName object:nil parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        success([mappingResult array]);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        failure(error);
    }];
}


@end

@implementation RKInjective

+ (void)setupRoutesForClass:(Class)cls {
    RKRouter *router = [[RKObjectManager sharedManager] router];
    RKRoute *named = [RKRoute routeWithName:[[NSStringFromClass(cls) stringByAppendingString:@"s"] lowercaseString]
                                pathPattern:[[@"/api/" stringByAppendingString:[NSStringFromClass(cls) stringByAppendingString:@"s"]] lowercaseString]
                                     method:RKRequestMethodGET];
    [router.routeSet addRoute:named];
}

+ (void)setupMappingForClass:(Class)cls {
    RKObjectMapping *mapping = [cls objectMapping];
    NSIndexSet *codes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    RKResponseDescriptor *descriptor = nil;
    descriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping
                                                         pathPattern:@"/api/artists"
                                                             keyPath:nil
                                                         statusCodes:codes];
    [[RKObjectManager sharedManager] addResponseDescriptorsFromArray:@[descriptor]];
}

+ (void)registerClass:(Class)cls {
    
    if (nil == [RKObjectManager sharedManager]) {
        assert(@"RKObject manager doesnt exist");
    }
    
    Class stubObjClass = [RKInjectiveStubObject class];
    Protocol *protocol = @protocol(RKInjectiveProtocol);
    
    if ( class_conformsToProtocol(cls, protocol) ) {
        
        unsigned int count;
        struct objc_method_description *methods = protocol_copyMethodDescriptionList(protocol, NO, NO, &count);
        for (unsigned i = 0; i < count; i++)
        {
            SEL selector = methods[i].name;
            if (![cls respondsToSelector:selector]) {
                //addDefaultImplementation
                Method method = class_getClassMethod(stubObjClass, selector);
                char *signature = methods[i].types;
                IMP implementation = method_getImplementation(method);
                class_addMethod(object_getClass(cls), selector, implementation, signature);
            }
        }
        free(methods);
        
        return;
        if (nil == [RKObjectManager sharedManager]) {
            assert(@"RKObject manager doesnt exist");
        }
        
        [RKInjective setupMappingForClass:cls];
        [RKInjective setupRoutesForClass:cls];

    }
}

@end
