//
//  HMSInteractor.swift
//  HMSVideo_Example
//
//  Created by Yogesh Singh on 26/02/21.
//  Copyright © 2021 100ms. All rights reserved.
//

import Foundation
import HMSKit

final class HMSKitInteractor: HMSUpdateProtocol {

    internal var hms: HMS?

    // MARK: - Instance Properties

    private let updateView: () -> Void

    internal var messages = [HMSMessage]()


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

        hms?.join(config: config, delegate: self)
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

    func on(track: HMSTrack, update: HMSTrackUpdate, for peer: HMSPeer) {
        updateView()
    }

    func on(error: HMSError) {
        updateView()
    }

    func on(message: HMSMessage) {

        messages.append(message)

        NotificationCenter.default.post(name: Constants.messageReceived, object: nil)
    }
}
