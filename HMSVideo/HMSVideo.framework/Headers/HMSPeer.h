//
//  HMSPeer.h
//  HMSVideosdk
//
//  Created by Dmitry Fedoseyev on 10.09.2020.
//  Copyright © 2020 100ms. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HMSPeer : NSObject
@property (nonatomic, copy, readonly) NSString * peerId;
@property (nonatomic, copy, readonly) NSString * _Nullable customerUserId;
@property (nonatomic, copy, readonly) NSString * name;
@property (nonatomic, copy, readonly) NSString * _Nullable role;
@property (nonatomic, copy, readonly) NSString * _Nullable authToken;
@property (nonatomic, copy, readonly) NSString * _Nullable customerDescription;

- (instancetype)initWithName:(NSString *)name authToken:(NSString *)authToken;

- (instancetype)initWithName:(NSString *)name authToken:(NSString *)authToken customerDescription:(NSString *_Nullable)customerDescription;

@end

NS_ASSUME_NONNULL_END
