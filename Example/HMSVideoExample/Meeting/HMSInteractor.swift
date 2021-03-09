//
//  HMSInteractor.swift
//  HMSVideo_Example
//
//  Created by Yogesh Singh on 26/02/21.
//  Copyright © 2021 100ms. All rights reserved.
//

import Foundation
import HMSVideo

final class HMSInteractor {

    // MARK: - Instance Properties

    private(set) var model = [PeerState]()

    private let updateView: (VideoCellState) -> Void

    private var client: HMSClient!

    private var room: HMSRoom! {
        didSet {
            let pasteboard = UIPasteboard.general
            pasteboard.string = room.roomId
            UserDefaults.standard.set(room.roomId, forKey: Constants.roomIDKey)
        }
    }

    private(set) var localPeer: HMSPeer!

    private(set) var localStream: HMSStream?

    private var speakerVideoTrack: HMSVideoTrack? {
        didSet {
            if let oldValue = oldValue, let speakerVideoTrack = speakerVideoTrack {

                if let oldIndex = model.firstIndex(where: { $0.videoTrack.trackId == oldValue.trackId }),
                   let newIndex = model.firstIndex(where: { $0.videoTrack.trackId == speakerVideoTrack.trackId }) {
                    if oldIndex != newIndex {
                        model[oldIndex].isCurrentSpeaker = false
                        model[newIndex].isCurrentSpeaker = true
                        updateView(.refresh(indexes: (oldIndex, newIndex)))
                    }
                }
            }
        }
    }

    internal var broadcasts = [[AnyHashable: Any]]()

    private var cameraSource = "Front Facing" {
        didSet {
            if cameraSource != oldValue {
                localStream?.videoCapturer?.switchCamera()
            }
        }
    }

    // MARK: - Setup Stream

    init(for user: String, in room: String, _ flow: MeetingFlow, _ callback: @escaping (VideoCellState) -> Void) {

        self.updateView = callback

        RoomService.setup(for: flow, user, room) { [weak self] token, room in

            guard let token = token, let room = room, let strongSelf = self else {
                print("Error: ", #function)
                return
            }
            strongSelf.connect(user, with: token, in: room)
        }

        initializeObservers()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func connect(_ user: String, with token: String, in roomID: String) {

        localPeer = HMSPeer(name: user, authToken: token)

        let config = HMSClientConfig()
        config.endpoint = Constants.endpoint

        client = HMSClient(peer: localPeer, config: config)
        client.logLevel = .verbose

        room = HMSRoom(roomId: roomID)

        setupCallbacks()

        setAudioDelay()

        client.connect()
    }

    private func setAudioDelay() {
        let audioPollDelay = UserDefaults.standard.object(forKey: Constants.audioPollDelay) as? Double ?? 3.0
        client.startAudioLevelMonitor(audioPollDelay)
    }

    // MARK: - Stream Handlers

    private func setupCallbacks() {
        client.onPeerJoin = { room, peer in
            print("onPeerJoin: ", room.roomId, peer.name)
            NotificationCenter.default.post(name: Constants.peersUpdated, object: nil)
        }

        client.onPeerLeave = { room, peer in
            print("onPeerLeave: ", room.roomId, peer.name)
            NotificationCenter.default.post(name: Constants.peersUpdated, object: nil)
        }

        client.onStreamAdd = { [weak self] room, peer, info in
            print("onStreamAdd: ", room.roomId, peer.name, info.streamId)
            self?.subscribe(to: room, peer, with: info)
        }

        client.onStreamRemove = { [weak self] room, peer, info in

            print("onStreamRemove: ", room.roomId, peer.name, info.streamId)

            if let model = self?.model {

                var indexes = [Int]()

                for (index, item) in model.enumerated() where item.videoTrack.streamId == info.streamId {
                    self?.model.remove(at: index)
                    indexes.append(index)
                }

                indexes.forEach { self?.updateView(.delete(index: $0)) }
            }
        }

        client.onBroadcast = { [weak self] room, peer, data in
            print("onBroadcast: ", room.roomId, peer.peerId, data)
            self?.broadcasts.append(data)
            NotificationCenter.default.post(name: Constants.broadcastReceived, object: nil)
        }

        client.onConnect = { [weak self] in
            self?.client.join((self?.room)!) { isSuccess, error in
                print("client.join: ", isSuccess, error ?? "No Error")
                self?.publish()
            }
        }

        client.onDisconnect = { error in

            let message = error?.localizedDescription ?? "Client disconnected!"

            NotificationCenter.default.post(name: Constants.hmsError,
                                            object: nil,
                                            userInfo: ["error": message])
        }

        client.onAudioLevelInfo = { [weak self] levels in
            self?.updateAudio(with: levels)
        }
    }

    private func subscribe(to room: HMSRoom, _ peer: HMSPeer, with info: HMSStreamInfo) {

        client.subscribe(info, room: room) { [weak self] (stream, error) in

            guard let stream = stream,
                  let videoTrack = stream.videoTracks?.first
            else {
                print(error?.localizedDescription ?? "Client Subscribe Error")
                return
            }

            let item = PeerState(peer, stream, videoTrack)
            self?.model.append(item)
            self?.updateView(.insert(index: (self?.model.count ?? 1) - 1))
        }
    }

    private func publish() {

        let userDefaults = UserDefaults.standard

        let constraints = HMSMediaStreamConstraints()
        constraints.shouldPublishAudio = userDefaults.object(forKey: Constants.publishAudio) as? Bool ?? true
        constraints.shouldPublishVideo = userDefaults.object(forKey: Constants.publishVideo) as? Bool ?? true
        constraints.bitrate = userDefaults.object(forKey: Constants.videoBitRate) as? Int ?? 256
        constraints.audioBitrate = userDefaults.object(forKey: Constants.audioBitRate) as? Int ?? 0
        constraints.frameRate = userDefaults.object(forKey: Constants.videoFrameRate) as? Int ?? 25
        constraints.resolution = resolution
        constraints.codec = codec

        guard let localStream = try? client.getLocalStream(constraints) else {
            return
        }

        let audioPollDelay = userDefaults.object(forKey: Constants.audioPollDelay) as? Double ?? 0.5
        client.startAudioLevelMonitor(audioPollDelay)

        client.publish(localStream, room: room) { stream, error in
            guard let stream = stream else {
                print(error?.localizedDescription ?? "Local Stream publish failed")
                return
            }

            self.setupLocal(stream)
        }
    }

    private func setupLocal(_ stream: HMSStream) {
        localStream = stream

        if let source = UserDefaults.standard.string(forKey: Constants.defaultVideoSource) {
            cameraSource = source
        }

        localStream?.videoCapturer?.startCapture()

        if let track = stream.videoTracks?.first, let localPeer = localPeer {

            let item = PeerState(localPeer, stream, track)
            model.append(item)

            let lastIndex = model.count > 0 ? model.count : 1
            updateView(.insert(index: lastIndex - 1))
        }
    }

    private func updateAudio(with levels: [HMSAudioLevelInfo]) {

        guard let topLevel = levels.first,
            let peerState = model.first(where: { $0.stream.streamId == topLevel.streamId })
        else {
            print(#function, "Error: Could not find Stream!")
            return
        }

        if speakerVideoTrack?.trackId != peerState.videoTrack.trackId {
            speakerVideoTrack = peerState.videoTrack
        }

        print("Speaker: ", peerState.peer.name)
    }

    // MARK: - Action Handlers

    func send(_ broadcast: [AnyHashable: Any], completion: @escaping () -> Void) {

        client.broadcast(broadcast, room: room) { _, error in

            if let error = error {
                print(error.localizedDescription)
            }
            completion()
        }
    }

    private func initializeObservers() {
        observeSettingsUpdated()
        observePinnedState()
    }

    private func observeSettingsUpdated() {
        _ = NotificationCenter.default.addObserver(forName: Constants.settingsUpdated,
                                                   object: nil,
                                                   queue: .main) { [weak self] _ in

            let userDefaults = UserDefaults.standard

            let constraints = HMSMediaStreamConstraints()

            constraints.bitrate = userDefaults.object(forKey: Constants.videoBitRate) as? Int ?? 256
            constraints.audioBitrate = userDefaults.object(forKey: Constants.audioBitRate) as? Int ?? 0
            constraints.frameRate = userDefaults.object(forKey: Constants.videoFrameRate) as? Int ?? 25
            constraints.resolution = self?.resolution ?? .QHD

            do {
                if let strongSelf = self, let stream = self?.localStream {
                    try strongSelf.client.applyConstraints(constraints, to: stream)
                }
            } catch {
                NotificationCenter.default.post(name: Constants.hmsError, object: nil, userInfo: ["Error": error])
            }

            if let source = UserDefaults.standard.string(forKey: Constants.defaultVideoSource) {
                self?.cameraSource = source
            }

            let publishVideo = UserDefaults.standard.object(forKey: Constants.publishVideo) as? Bool ?? true
            self?.localStream?.videoTracks?.first?.enabled = publishVideo

            let publishAudio = UserDefaults.standard.object(forKey: Constants.publishAudio) as? Bool ?? true
            self?.localStream?.audioTracks?.first?.enabled = publishAudio

            self?.setAudioDelay()
        }
    }

    private func observePinnedState() {
        _ = NotificationCenter.default.addObserver(forName: Constants.pinTapped,
                                                   object: nil,
                                                   queue: .main) { [weak self] notification in

            if let peerID = notification.userInfo?[Constants.peerID] as? String {

                if let pinnedPeerIndex = self?.model.firstIndex(where: { $0.peer.peerId == peerID }) {
                    let indexesToBeUpdated = Array(0...pinnedPeerIndex).map { Int($0) }

                    self?.model.sort { $0.isPinned && !$1.isPinned }

                    NotificationCenter.default.post(name: Constants.updatePinnedView,
                                                    object: nil,
                                                    userInfo: [ Constants.indexesToBeUpdated: indexesToBeUpdated ])
                }
            }
        }
    }

    func cleanup() {
        guard let client = client else {
            return
        }

        localStream?.videoCapturer?.stopCapture()

        client.leave(room)

        client.disconnect()
    }
}

// MARK: - Helpers

extension HMSInteractor {

    private var codec: HMSVideoCodec {
        let codecString = UserDefaults.standard.string(forKey: Constants.videoCodec) ?? "VP8"

        switch codecString {
        case "H264":
            return .H264
        case "VP9":
            return .VP9
        default:
            return .VP8
        }
    }

    private var resolution: HMSVideoResolution {
        let resolutionString = UserDefaults.standard.string(forKey: Constants.videoResolution) ?? "QHD"

        switch resolutionString {
        case "QVGA":
            return .QVGA
        case "VGA":
            return .VGA
        case "HD":
            return .HD
        case "Full HD":
            return .fullHD
        default:
            return .QHD
        }
    }
}
