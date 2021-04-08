//
//  HMSTrack.h
//  HMSKit
//
//  Created by Dmitry Fedoseyev on 23.03.2021.
//  Copyright © 2021 100ms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HMSCommonDefs.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString *const kHMSTrackStateDidChangeNotification;

@interface HMSTrack : NSObject
@property (nonatomic, readonly) NSString *trackId;
@property (nonatomic, readonly) HMSTrackKind kind;
@property (nonatomic, assign) BOOL enabled;

@end

NS_ASSUME_NONNULL_END
