//
//  RKInjective.h
//  RESTClient
//
//  Created by Sergii Kliuiev on 1/23/13.
//  Copyright (c) 2013 Sergii Kliuiev. All rights reserved.
//

#import <RestKit/RestKit.h>

typedef enum {
    RKIRequestGetObjects = 0,
    RKIRequestGetObject,
    RKIRequestDeleteObject,
    RKIRequestPostObject,
    RKIRequestPutObject,
    RKIRequestPatchObject
} RKIRequestType;

typedef void ( ^RKIObjectsSuccessBlock ) ( NSArray *objects );
typedef void ( ^RKIObjectSuccessBlock ) ( id object );
typedef void ( ^RKIFailureBlock ) (  NSError *error );
typedef void ( ^RKIBlock ) ( void );

@interface RKInjective : NSObject 
+(void)registerClass:(Class)cls;
@end

@protocol RKInjectiveProtocol <NSObject>
@optional
+ (NSString *)modelName;
+ (NSString *)modelNamePlural;
+ (RKObjectMapping *)objectMapping;
+ (RKObjectMapping *)requestMapping;
+ (NSDictionary *)objectMappingDictionary;
+ (NSDictionary *)objectRequestMappingDictionary;
+ (NSArray *)objectRelationsMappings;
+ (NSString *)uniqueIdentifierName;
+ (NSString *)pathForRequestType:(RKIRequestType)requestType;
+ (NSString *)defaultPathForRequestType:(RKIRequestType)requestType;
- (id)uniqueIdentifier;
+ (void)getObjectsOnSuccess:(RKIObjectsSuccessBlock)success failure:(RKIFailureBlock)failure;
- (void)getObjectOnSuccess:(RKIObjectSuccessBlock)success failure:(RKIFailureBlock)failure;
- (void)postObjectOnSuccess:(RKIObjectSuccessBlock)success failure:(RKIFailureBlock)failure;
- (void)deleteObjectOnSuccess:(RKIBlock)success failure:(RKIFailureBlock)failure;
- (void)putObjectOnSuccess:(RKIObjectSuccessBlock)success failure:(RKIFailureBlock)failure;
- (void)patchObjectOnSuccess:(RKIObjectSuccessBlock)success failure:(RKIFailureBlock)failure;
@end

#define rkinjective_register(cls) \
    + (void)initialize	\
    { \
        if(self == [cls class]) { \
            [RKInjective registerClass:[cls class]];\
        } \
    }