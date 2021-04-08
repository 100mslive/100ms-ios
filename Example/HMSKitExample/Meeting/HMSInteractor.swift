//
//  HMSInteractor.swift
//  HMSVideo_Example
//
//  Created by Yogesh Singh on 26/02/21.
//  Copyright © 2021 100ms. All rights reserved.
//

import Foundation
import HMSKit

final class HMSInteractor: HMSUpdateProtocol {

    internal var hms: HMS

    // MARK: - Instance Properties

    private let updateView: () -> Void


    // MARK: - Setup Stream

    init(for user: String, in room: String, _ flow: MeetingFlow, _ callback: @escaping () -> Void) {

        self.updateView = callback

        let token = Token.getWith(room)

        hms = HMS.build(block: { (hms) in
            hms.logLevel = .verbose
            hms.analyticsLevel = .verbose
        })

        let config = HMSConfig(userName: user,
                               userID: UUID().uuidString,
                               roomID: room,
                               authToken: token,
                               endPoint: "wss://webrtcv3.100ms.live:8443/ws")

        hms.join(config: config, delegate: self)
    }

    
    // MARK: - HMS Update Callbacks

    func on(join room: HMSRoom) {
        updateView()
    }

    func on(room: HMSRoom, update: HMSRoomUpdate) {
        updateView()
    }

    func on(peer: HMSPeer, update: HMSPeerUpdate) {
        updateView()
    }

    func on(error: HMSError) {
        updateView()
    }

    func on(message: HMSMessage) {
        
    }
}
