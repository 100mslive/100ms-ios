//
//  HMSStream.h
//  HMSVideosdk
//
//  Created by Dmitry Fedoseyev on 10.09.2020.
//  Copyright © 2020 100ms. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class HMSTrack;
@class HMSVideoView;
@class HMSVideoTrack;
@class HMSAudioTrack;
@class HMSVideoCapturer;

@interface HMSStream : NSObject
@property (nonatomic, copy, readonly) NSString *streamId;
@property (nonatomic, readonly, nullable) NSArray<HMSVideoTrack *> *videoTracks;
@property (nonatomic, readonly, nullable) NSArray<HMSAudioTrack *> *audioTracks;
@property (nonatomic, readonly, nullable) HMSVideoCapturer *videoCapturer;
@end

NS_ASSUME_NONNULL_END
