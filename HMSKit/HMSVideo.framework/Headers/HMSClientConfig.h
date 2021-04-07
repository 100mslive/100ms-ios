//
//  HMSClientConfig.h
//  HMSVideo
//
//  Created by Dmitry Fedoseyev on 20.09.2020.
//  Copyright © 2020 100ms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HMSCommonDefs.h"

NS_ASSUME_NONNULL_BEGIN

@interface HMSClientConfig : NSObject
@property (nonatomic, copy, nullable) NSString *endpoint;
@property (nonatomic, assign) HMSAnalyticsEventLevel analyticsLevel;
@property (nonatomic, assign) BOOL shouldSkipPIIEvents;
@end

NS_ASSUME_NONNULL_END
