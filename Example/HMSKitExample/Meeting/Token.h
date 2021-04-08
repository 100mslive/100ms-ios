//
//  Token.h
//  HMSKitExample
//
//  Created by Yogesh Singh on 08/04/21.
//  Copyright © 2021 100ms. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Token : NSObject

+ (NSString *)getTokenWith:(NSString *)roomID;

@end

NS_ASSUME_NONNULL_END
