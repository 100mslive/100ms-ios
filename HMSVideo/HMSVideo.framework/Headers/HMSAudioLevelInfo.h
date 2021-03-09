//
//  HMSAudioLevelInfo.h
//  HMSVideo
//
//  Created by Dmitry Fedoseyev on 16.02.2021.
//  Copyright © 2021 100ms. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HMSAudioLevelInfo : NSObject
@property (nonatomic) float audioLevel;
@property (nonatomic, copy) NSString *streamId;
@end

NS_ASSUME_NONNULL_END
