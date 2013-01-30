//
//  Record.m
//  RKInjective
//
//  Created by Sergii Kliuiev on 1/29/13.
//  Copyright (c) 2013 AppFellas. All rights reserved.
//

#import "Record.h"

@implementation Record
rkinjective_register(Record)

+ (NSString *)pathForRequestType:(RKIRequestType)requestType {
    switch (requestType) {
        case RKIRequestGetObjects:
            return @"api_records";
            break;
        case RKIRequestGetObject:
            return @"api_records/:itemId";
            break;
        default:
            return @"items";
            break;
    }
}
@end
