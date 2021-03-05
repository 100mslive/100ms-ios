//
//  VideoModel.swift
//  HMSVideo_Example
//
//  Created by Yogesh Singh on 04/03/21.
//  Copyright © 2021 100ms. All rights reserved.
//

import Foundation
import HMSVideo

class PeerState {

    let peer: HMSPeer

    let stream: HMSStream

    let videoTrack: HMSVideoTrack

    var isCurrentSpeaker = false

    var isPinned = false

    var indexPath: IndexPath?

    init(_ peer: HMSPeer, _ stream: HMSStream, _ videoTrack: HMSVideoTrack) {
        self.peer = peer
        self.stream = stream
        self.videoTrack = videoTrack
    }
}
