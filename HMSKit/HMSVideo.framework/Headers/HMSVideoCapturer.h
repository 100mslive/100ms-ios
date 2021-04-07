//
//  HMSVideoCapturer.h
//  HMSVideo
//
//  Created by Dmitry Fedoseyev on 16.09.2020.
//  Copyright © 2020 100ms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HMSCommonDefs.h"

NS_ASSUME_NONNULL_BEGIN

@interface HMSVideoCapturer : NSObject
- (void)startCapture;
- (void)stopCapture;
- (void)switchCamera;

@end

NS_ASSUME_NONNULL_END
