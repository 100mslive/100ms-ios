//
//  HMSMediaStreamConstraints.h
//  HMSVideo
//
//  Created by Dmitry Fedoseyev on 12.09.2020.
//  Copyright © 2020 100ms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HMSCommonDefs.h"

NS_ASSUME_NONNULL_BEGIN

@interface HMSMediaStreamConstraints : NSObject <NSCopying>
@property (nonatomic, assign) HMSVideoCodec codec;
@property (nonatomic, assign) HMSVideoResolution resolution;
@property (nonatomic, assign) NSInteger bitrate;
@property (nonatomic, assign) NSInteger frameRate;
@property (nonatomic, assign) NSInteger audioBitrate;
@property (nonatomic, assign) BOOL shouldPublishAudio;
@property (nonatomic, assign) BOOL shouldPublishVideo;
@end

NS_ASSUME_NONNULL_END
