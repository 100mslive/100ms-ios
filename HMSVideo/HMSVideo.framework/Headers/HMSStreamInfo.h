//
//  HMSStreamInfo.h
//  HMSVideo
//
//  Created by Dmitry Fedoseyev on 17.09.2020.
//  Copyright © 2020 100ms. All rights reserved.
//

#import <Foundation/Foundation.h>
@class HMSTrack;

NS_ASSUME_NONNULL_BEGIN

@interface HMSStreamInfo : NSObject
@property (nonatomic, copy, readonly) NSString *streamId;
@property (nonatomic, copy, readonly) NSString *peerId;
@property (nonatomic, readonly) BOOL isScreen;
@end

NS_ASSUME_NONNULL_END
