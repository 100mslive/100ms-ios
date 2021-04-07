//
//  HMSNetworkQualityInfo.h
//  HMSVideo
//
//  Created by Dmitry Fedoseyev on 16.02.2021.
//  Copyright © 2021 100ms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HMSCommonDefs.h"

NS_ASSUME_NONNULL_BEGIN

@interface HMSNetworkQualityInfo : NSObject
@property (nonatomic, copy) NSString *peerId;
@property (nonatomic) NSUInteger incomingAvailableBitrate;
@property (nonatomic) NSUInteger outgoingAvailableBitrate;
@end

NS_ASSUME_NONNULL_END
