//
//  Token.m
//  HMSKitExample
//
//  Created by Yogesh Singh on 08/04/21.
//  Copyright © 2021 100ms. All rights reserved.
//

#import "Token.h"
#import <JWT/JWT.h>

@implementation Token

+ (NSString *)getTokenWith:(NSString *)roomID {
    NSDictionary *payload = @{@"access_key" : @"5fccb7dc72909272bf9995e7",
                              @"app_id" : @"5fccb7dc72909272bf9995e6",
                              @"room_id" : roomID,
                              @"peer_id" : [[NSUUID UUID] UUIDString],
                              @"iss" : @"5fccb7dc72909272bf9995e4",
                              @"exp" : @((int)[[[NSDate alloc] initWithTimeIntervalSinceNow:5000] timeIntervalSince1970]),
                              @"iat" : @((int)[[NSDate new] timeIntervalSince1970]),
                              @"nbf" : @((int)[[NSDate new] timeIntervalSince1970]),
                              @"jti": [[NSUUID UUID] UUIDString]
    };

    NSString *secret = @"w1Xl2dgCsmOF5vH2TF22otsberDoBMN48Es9EW5rnaqjnKHtybddTxuqsPw0PWo8vv_6el7N9PYqBxAxQHEXMu22OYEJXm33OZ-zgkJycVMue7eeOgXjbXcLvTF6Zm07f7-Z8k-Z_jt6fxS20nDgOtwBPulbNSG4rKidcPLoNrI=";
    id<JWTAlgorithm> algorithm = [JWTAlgorithmFactory algorithmByName:@"HS256"];

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    NSString *result = [JWTBuilder encodePayload:payload].secret(secret).algorithm(algorithm).encode;
#pragma GCC diagnostic pop

    return result;
}

@end
