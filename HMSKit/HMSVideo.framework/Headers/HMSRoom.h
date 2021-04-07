//
//  HMSRoom.h
//  HMSVideosdk
//
//  Created by Dmitry Fedoseyev on 10.09.2020.
//  Copyright © 2020 100ms. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HMSRoom : NSObject
@property (nonatomic, copy, readonly) NSString *roomId;

- (instancetype)initWithRoomId:(NSString *)roomId;

@end

NS_ASSUME_NONNULL_END
