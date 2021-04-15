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

        RoomService.setup(for: flow, user, room) { [weak self] token, aRoom in
            guard let token = token else {
                print(#function, "error fetching token")
                return
            }
            self?.setup(for: user, in: aRoom ?? room, token: token)
        }
    }
    
    func setup(for user: String, in room: String, token: String) {

        hms = HMS.build(block: { (hms) in
            hms.logLevel = .verbose
            hms.analyticsLevel = .verbose
        })

        let config = HMSConfig(userName: user,
                               userID: UUID().uuidString,
                               roomID: room,
                               authToken: token)

        hms?.join(config: config, delegate: self)
    }

    
    // MARK: - HMS Update Callbacks

    func on(join room: HMSRoom) {
        print(#function)
        updateView()
    }

    func on(room: HMSRoom, update: HMSRoomUpdate) {
        print(#function, "update:", update.description)
        updateView()
    }

    func on(peer: HMSPeer, update: HMSPeerUpdate) {
        print(#function, "peer:", peer.name, "update:", update.description)
        updateView()
    }

    func on(track: HMSTrack, update: HMSTrackUpdate, for peer: HMSPeer) {
        print(#function, "peer:", peer.name, "track:", track.kind.rawValue, "update:", update.description)
        updateView()
    }

    func on(error: HMSError) {
        print(#function, error.localizedDescription)
        updateView()
    }

    func on(message: HMSMessage) {

        print(#function, message)
        messages.append(message)

        NotificationCenter.default.post(name: Constants.messageReceived, object: nil)
    }
}
