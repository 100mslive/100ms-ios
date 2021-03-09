//
//  HMSVideoTrack.h
//  HMSVideo
//
//  Created by Dmitry Fedoseyev on 15.09.2020.
//  Copyright © 2020 100ms. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HMSVideoTrack : NSObject
@property (nonatomic, copy, readonly) NSString *streamId;
@property (nonatomic, readonly) NSString *trackId;
@property (nonatomic, assign) BOOL enabled;
@end

NS_ASSUME_NONNULL_END
