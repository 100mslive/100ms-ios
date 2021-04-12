//
//  MeetingViewModel.swift
//  HMSVideo_Example
//
//  Created by Yogesh Singh on 26/02/21.
//  Copyright © 2021 100ms. All rights reserved.
//

import UIKit
import HMSKit

final class MeetingViewModel: NSObject,
                              UICollectionViewDataSource,
                              UICollectionViewDelegate,
                              UICollectionViewDelegateFlowLayout {

    private(set) var interactor: HMSKitInteractor!

    private weak var collectionView: UICollectionView?

    private let sectionInsets = UIEdgeInsets(top: 2.0, left: 4.0, bottom: 2.0, right: 4.0)

    private var peers: [HMSPeer]? {
        if let allPeers = interactor.hms?.room?.peers {
            let pinnedPeers = allPeers.filter { (peer) -> Bool in
                if let isPinned = peer.customerDescription?["isPinned"] as? Bool {
                    return isPinned
                }
                return false
            }
            let remainingPeers = Array(Set(allPeers).subtracting(Set(pinnedPeers)))
            return pinnedPeers + remainingPeers
        }
        return nil
    }

    // MARK: - Initializers

    init(_ user: String, _ room: String, _ flow: MeetingFlow, _ collectionView: UICollectionView) {

        super.init()

        interactor = HMSKitInteractor(for: user, in: room, flow) { [weak self] in
            self?.updateView()
        }

        setup(collectionView)

        observeUserActions()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setup(_ collectionView: UICollectionView) {

        collectionView.dataSource = self
        collectionView.delegate = self

        self.collectionView = collectionView
    }

    private func observeUserActions() {

        _ = NotificationCenter.default.addObserver(forName: Constants.pinTapped,
                                                   object: nil,
                                                   queue: .main) { [weak self] notification in

            self?.collectionView?.reloadData()

//            if let indexes = notification.userInfo?[Constants.indexesToBeUpdated] as? [Int] {
//
//                let indexPaths = indexes.map { IndexPath(item: $0, section: 0) }
//
//                self?.collectionView?.reloadItems(at: indexPaths)
//
//                self?.collectionView?.scrollToItem(at: IndexPath(item: 0, section: 0),
//                                                   at: .left, animated: true)
//            }
        }
    }

    // MARK: - View Modifiers

    private func updateView() {

        print(#function)

        collectionView?.reloadData()

//        switch state {
//
//        case .insert(let index):
//
//            print(#function, index)
//            collectionView?.insertItems(at: [IndexPath(item: index, section: 0)])
//
//        case .delete(let index):
//
//            print(#function, index)
//            collectionView?.deleteItems(at: [IndexPath(item: index, section: 0)])
//
//        case .refresh(let indexes):
//
//            print(#function, indexes)
//
//            let oldIndex = IndexPath(item: indexes.0, section: 0)
//            let newIndex = IndexPath(item: indexes.1, section: 0)
//
//            if let oldCell = collectionView?.cellForItem(at: oldIndex) as? VideoCollectionViewCell {
//                oldCell.isSpeaker = false
//            }
//            if let newCell = collectionView?.cellForItem(at: newIndex) as? VideoCollectionViewCell {
//                newCell.isSpeaker = true
//            }
//        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        peers?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.resuseIdentifier,
                                                            for: indexPath) as? VideoCollectionViewCell,
              let count = interactor.hms?.room?.peers.count,
              indexPath.item < count
        else {
            return UICollectionViewCell()
        }

        updateCell(at: indexPath, for: cell)

        return cell
    }

    private func updateCell(at indexPath: IndexPath, for cell: VideoCollectionViewCell) {

        if let peer = peers?[indexPath.row] {

            cell.peer = peer

            cell.videoView.setVideoTrack(peer.videoTrack)

            cell.nameLabel.text = peer.name

    //        cell.isSpeaker = model.isCurrentSpeaker

            cell.pinButton.isSelected = peer.isPinned

            if let audioEnabled = peer.audioTrack?.enabled {
                cell.muteButton.isSelected = !audioEnabled
            }

            if let videoEnabled = peer.videoTrack?.enabled {
                cell.stopVideoButton.isSelected = !videoEnabled
                cell.avatarLabel.isHidden = videoEnabled
            } else {
                cell.avatarLabel.isHidden = false
                cell.stopVideoButton.isSelected = true
            }

            cell.avatarLabel.text = Utilities.getAvatarName(from: peer.name)
        }
        else {
            print(#function, #line, "Exception!")
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let widthInsets = sectionInsets.left + sectionInsets.right
        let heightInsets = sectionInsets.top + sectionInsets.bottom

        print(#function, indexPath.item)

        if let peer = interactor.hms?.room?.peers[indexPath.item] {
            if peer.isPinned {
                let size = CGSize(width: collectionView.frame.size.width - widthInsets,
                                  height: collectionView.frame.size.height - heightInsets)

                print(#function, #line, size.width, size.height)
                return size
            }
        }

        if let count = interactor.hms?.room?.peers.count {
            if count < 5 {
                let count = CGFloat(count)
                let size = CGSize(width: collectionView.frame.size.width - widthInsets,
                                  height: (collectionView.frame.size.height / count) - 2*heightInsets)
                print(#function, #line, count, size.width, size.height)
                return size
            }
        }

        let rows = UserDefaults.standard.object(forKey: Constants.maximumRows) as? CGFloat ?? 2.0
        let size = CGSize(width: (collectionView.frame.size.width / 2) - widthInsets,
                          height: (collectionView.frame.size.height / rows) - 2*heightInsets)
        print(#function, #line, rows, size.width, size.height)
        return size
    }

    // MARK: - Action Handlers

    func cleanup() {
        interactor.hms?.leave()
        interactor.hms = nil
        interactor = nil
    }

    func switchCamera() {
        if let track = interactor.hms?.localPeer?.videoTrack as? HMSLocalVideoTrack {
            track.switchCamera()
        }
    }

    func switchAudio(isOn: Bool) {
        if let audioTrack = interactor.hms?.localPeer?.audioTrack {
            audioTrack.enabled = isOn
            print(#function, isOn, audioTrack.enabled as Any)
        }

        NotificationCenter.default.post(name: Constants.peerAudioToggled, object: nil)
    }

    func switchVideo(isOn: Bool) {
        if let videoTrack = interactor.hms?.localPeer?.videoTrack {
            videoTrack.enabled = isOn
            print(#function, isOn, videoTrack.enabled as Any)
        }

        NotificationCenter.default.post(name: Constants.peerVideoToggled, object: nil)
    }

    func muteRemoteStreams(_ isMuted: Bool) {

        if let peers = interactor.hms?.room?.peers {
            for peer in peers where peer.audioTrack?.enabled != isMuted {
                peer.audioTrack?.enabled = isMuted
            }
        }
        
        NotificationCenter.default.post(name: Constants.muteALL, object: nil)
    }
}
