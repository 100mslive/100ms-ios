//
//  HMSTrackSettings.h
//  HMSKit
//
//  Created by Dmitry Fedoseyev on 30.03.2021.
//  Copyright © 2021 100ms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HMSCommonDefs.h"
NS_ASSUME_NONNULL_BEGIN

@interface HMSVideoTrackSettings : NSObject <NSCopying>
@property (nonatomic, assign, readonly) HMSVideoCodec codec;
@property (nonatomic, assign, readonly) HMSVideoResolution resolution;
@property (nonatomic, assign, readonly) NSInteger maxBitrate;
@property (nonatomic, assign, readonly) NSInteger maxFrameRate;
@property (nonatomic, assign, readonly) HMSCameraFacing cameraFacing;


- (instancetype)initWithCodec:(HMSVideoCodec)codec resolution:(HMSVideoResolution)resolution maxBitrate:(NSInteger)maxBitrate maxFrameRate:(NSInteger)maxFrameRate cameraFacing:(HMSCameraFacing)cameraFacing;
- (instancetype)init;

@end

@interface HMSAudioTrackSettings : NSObject <NSCopying>
@property (nonatomic, assign, readonly) NSInteger maxBitrate;

- (instancetype)initWithMaxBitrate:(NSInteger)maxBitrate;
- (instancetype)init;

@end

@interface HMSTrackSettings : NSObject <NSCopying>
@property (nonatomic, strong, readonly, nullable) HMSVideoTrackSettings *video;
@property (nonatomic, strong, readonly, nullable) HMSAudioTrackSettings *audio;

- (instancetype)initWithVideoSettings:(HMSVideoTrackSettings *_Nullable)videoSettings audioSettings:(HMSAudioTrackSettings *)audioSettings;
- (instancetype)init;


@end

NS_ASSUME_NONNULL_END
