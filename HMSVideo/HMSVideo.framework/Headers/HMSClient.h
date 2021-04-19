//
//  HMSClient.h
//  HMSVideosdk
//
//  Created by Dmitry Fedoseyev on 10.09.2020.
//  Copyright © 2020 100ms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HMSPeer.h"
#import "HMSRoom.h"
#import "HMSStream.h"
#import "HMSMediaStreamConstraints.h"
#import "HMSCommonDefs.h"
#import "HMSStreamInfo.h"
#import "HMSClientConfig.h"
#import "HMSAudioLevelInfo.h"
#import "HMSNetworkQualityInfo.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^HMSStreamResultHandler)(HMSStream * _Nullable stream, NSError * _Nullable error);

@interface HMSClient : NSObject

@property(nonatomic, copy, nullable) void (^onPeerJoin)(HMSRoom *, HMSPeer *);
@property(nonatomic, copy, nullable) void (^onPeerLeave)(HMSRoom *, HMSPeer *);
@property(nonatomic, copy, nullable) void (^onStreamAdd)(HMSRoom *, HMSPeer *, HMSStreamInfo *);
@property(nonatomic, copy, nullable) void (^onStreamRemove)(HMSRoom *, HMSPeer *, HMSStreamInfo *);
@property(nonatomic, copy, nullable) void (^onBroadcast)(HMSRoom *, HMSPeer *, NSDictionary *);
@property(nonatomic, copy, nullable) void (^onDisconnect)(NSError *_Nullable);
@property(nonatomic, copy, nullable) void (^onConnect)(void);
@property(nonatomic, copy, nullable) void (^onAudioLevelInfo)(NSArray<HMSAudioLevelInfo *> *);
@property(nonatomic, copy, nullable) void (^onNetworkLevelInfo)(NSArray<HMSNetworkQualityInfo *> *);

@property(nonatomic, readonly) HMSVideoConnectionState connectionState;


@property(nonatomic, assign) HMSLogLevel logLevel;
@property(nonatomic, assign) HMSLogLevel rtcLogLevel;
@property(nonatomic, strong, nullable) NSObject<HMSLogger> *logger;

- (instancetype)initWithPeer:(HMSPeer *)peer;
- (instancetype)initWithPeer:(HMSPeer *)peer config:(HMSClientConfig *_Nullable)config;

- (void)connect;
- (void)disconnect;

- (void)join:(HMSRoom *)room completion:(__nullable HMSOperationStatusHandler)completionHandler;
- (void)leave:(HMSRoom *)room completion:(__nullable HMSOperationStatusHandler)completionHandler;

- (HMSStream *_Nullable)getLocalStream:(HMSMediaStreamConstraints *)constraints error:(NSError **)error;
- (BOOL)applyConstraints:(HMSMediaStreamConstraints *)constraints toLocalStream:(HMSStream *)stream error:(NSError **)error NS_SWIFT_NAME(applyConstraints(_:to:));

- (void)publish:(HMSStream *)stream room:(HMSRoom *)room completion:(__nullable HMSStreamResultHandler)completionHandler;
- (void)unpublish:(HMSStream *)stream room:(HMSRoom *)room completion:(__nullable HMSOperationStatusHandler)completionHandler;

- (void)subscribe:(HMSStreamInfo *)stream room:(HMSRoom *)room completion:(__nullable HMSStreamResultHandler)completionHandler;
- (void)subscribe:(HMSStreamInfo *)stream room:(HMSRoom *)room bitrate:(NSInteger)bitrate completion:(__nullable HMSStreamResultHandler)completionHandler;
- (void)unsubscribe:(HMSStream *)stream room:(HMSRoom *)room completion:(__nullable HMSOperationStatusHandler)completionHandler;

- (void)broadcast:(NSDictionary *)message room:(HMSRoom *)room completion:(__nullable HMSOperationStatusHandler)completionHandler;

- (void)startAudioLevelMonitor:(NSTimeInterval)interval;
- (void)stopAudioLevelMonitor;

- (void)rtcStatsForTrack:(HMSVideoTrack *)track completion:(void (^)(NSString *))completionHandler;

@end

NS_ASSUME_NONNULL_END
