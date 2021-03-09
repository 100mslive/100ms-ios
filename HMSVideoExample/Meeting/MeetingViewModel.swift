//
//  MeetingViewModel.swift
//  HMSVideo_Example
//
//  Created by Yogesh Singh on 26/02/21.
//  Copyright © 2021 100ms. All rights reserved.
//

import UIKit

final class MeetingViewModel: NSObject,
                              UICollectionViewDataSource,
                              UICollectionViewDelegate,
                              UICollectionViewDelegateFlowLayout {

    private(set) var hms: HMSInteractor!

    weak var collectionView: UICollectionView?

    private let sectionInsets = UIEdgeInsets(top: 2.0, left: 4.0, bottom: 2.0, right: 4.0)

    // MARK: - Initializers

    init(_ user: String, _ room: String, _ flow: MeetingFlow, _ collectionView: UICollectionView) {

        super.init()

        hms = HMSInteractor(for: user, in: room, flow) { [weak self] state in
            self?.updateView(for: state)
        }

        setup(collectionView)

        observeUserActions()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func setup(_ collectionView: UICollectionView) {

        collectionView.dataSource = self
        collectionView.delegate = self

        self.collectionView = collectionView
    }

    func observeUserActions() {

        _ = NotificationCenter.default.addObserver(forName: Constants.updatePinnedView,
                                                   object: nil,
                                                   queue: .main) { [weak self] notification in

            if let indexes = notification.userInfo?[Constants.indexesToBeUpdated] as? [Int] {

                let indexPaths = indexes.map { IndexPath(item: $0, section: 0) }

                self?.collectionView?.reloadItems(at: indexPaths)

                self?.collectionView?.scrollToItem(at: IndexPath(item: 0, section: 0),
                                                   at: .left, animated: true)
            }
        }
    }

    // MARK: - View Modifiers

    func updateView(for state: VideoCellState) {

        print(#function, state)

        switch state {

        case .insert(let index):

            print(#function, index)
            collectionView?.insertItems(at: [IndexPath(item: index, section: 0)])

        case .delete(let index):

            print(#function, index)
            collectionView?.deleteItems(at: [IndexPath(item: index, section: 0)])

        case .refresh(let indexes):

            print(#function, indexes)

            let oldIndex = IndexPath(item: indexes.0, section: 0)
            let newIndex = IndexPath(item: indexes.1, section: 0)

            if let oldCell = collectionView?.cellForItem(at: oldIndex) as? VideoCollectionViewCell {
                oldCell.isSpeaker = false
            }
            if let newCell = collectionView?.cellForItem(at: newIndex) as? VideoCollectionViewCell {
                newCell.isSpeaker = true
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        hms.model.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.resuseIdentifier,
                                                            for: indexPath) as? VideoCollectionViewCell,
               indexPath.item < hms.model.count
        else {
            return UICollectionViewCell()
        }

        updateCell(at: indexPath, for: cell)

        return cell
    }

    func updateCell(at indexPath: IndexPath, for cell: VideoCollectionViewCell) {

        let model = hms.model[indexPath.row]

        cell.model = model

        cell.videoView.setVideoTrack(model.videoTrack)

        cell.nameLabel.text = model.peer.name

        cell.isSpeaker = model.isCurrentSpeaker

        cell.pinButton.isSelected = model.isPinned

        if let audioEnabled = model.stream.audioTracks?.first?.enabled {
            cell.muteButton.isSelected = !audioEnabled
        }

        if let videoEnabled = model.stream.videoTracks?.first?.enabled {
            cell.stopVideoButton.isSelected = !videoEnabled
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let widthInsets = sectionInsets.left + sectionInsets.right
        let heightInsets = sectionInsets.top + sectionInsets.bottom

        print(#function, indexPath.item)

        let model = hms.model[indexPath.item]

        if model.isPinned {
            return CGSize(width: collectionView.frame.size.width - widthInsets,
                          height: collectionView.frame.size.height - heightInsets)
        }

        if hms.model.count < 4 {
            let count = CGFloat(hms.model.count)
            return CGSize(width: collectionView.frame.size.width - widthInsets,
                          height: (collectionView.frame.size.height / count) - heightInsets)
        } else {
            let rows = UserDefaults.standard.object(forKey: Constants.maximumRows) as? CGFloat ?? 2.0
            return CGSize(width: (collectionView.frame.size.width / 2) - widthInsets,
                          height: (collectionView.frame.size.height / rows) - heightInsets)
        }
    }

    // MARK: - Action Handlers

    func cleanup() {
        hms.cleanup()
    }

    func switchCamera() {
        hms.localStream?.videoCapturer?.switchCamera()
    }

    func switchAudio(isOn: Bool) {
        if let audioTrack = hms.localStream?.audioTracks?.first {
            audioTrack.enabled = isOn
        }

        NotificationCenter.default.post(name: Constants.peerAudioToggled, object: nil)
        print(#function, isOn, hms.localStream?.audioTracks?.first?.enabled as Any)
    }

    func switchVideo(isOn: Bool) {
        if let videoTrack = hms.localStream?.videoTracks?.first {
            videoTrack.enabled = isOn
        }

        NotificationCenter.default.post(name: Constants.peerVideoToggled, object: nil)
        print(#function, isOn, hms.localStream?.videoTracks?.first?.enabled as Any)
    }

    func muteRemoteStreams(_ isMuted: Bool) {
        var indexes = [IndexPath]()
        for (index, model) in hms.model.enumerated() where model.stream.audioTracks?.first?.enabled != isMuted {
            indexes.append(IndexPath(item: index, section: 0))
        }
        hms.model.forEach { $0.stream.audioTracks?.first?.enabled = isMuted }

        NotificationCenter.default.post(name: Constants.muteALL, object: nil)
    }
}
