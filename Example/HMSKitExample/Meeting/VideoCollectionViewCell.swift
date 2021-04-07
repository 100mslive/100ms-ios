//
//  VideoCollectionViewCell.swift
//  HMSVideo_Example
//
//  Created by Yogesh Singh on 03/03/21.
//  Copyright © 2021 100ms. All rights reserved.
//

import UIKit
import HMSVideo
import QuartzCore

final class VideoCollectionViewCell: UICollectionViewCell {

    weak var model: PeerState?

    @IBOutlet weak var stackView: UIStackView! {
        didSet {
            Utilities.applyBorder(on: stackView)
            stackView.backgroundColor = stackView.backgroundColor?.withAlphaComponent(0.5)
        }
    }

    @IBOutlet weak var nameLabel: UILabel!

    @IBOutlet weak var pinButton: UIButton!

    @IBOutlet weak var muteButton: UIButton!

    @IBOutlet weak var videoView: HMSVideoView!

    @IBOutlet weak var stopVideoButton: UIButton!

    @IBOutlet weak var avatarLabel: UILabel! {
        didSet {
            avatarLabel.layer.cornerRadius = 54
        }
    }

    var isSpeaker = false {
        didSet {
            if isSpeaker {
                Utilities.applySpeakerBorder(on: videoView)
            } else {
                Utilities.applyBorder(on: videoView)
            }
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        _ = NotificationCenter.default.addObserver(forName: Constants.muteALL,
                                               object: nil,
                                               queue: .main) { [weak self] _ in
            if let audioEnabled = self?.model?.stream.audioTracks?.first?.enabled {
                self?.muteButton.isSelected = !audioEnabled
            }
        }

        _ = NotificationCenter.default.addObserver(forName: Constants.peerAudioToggled,
                                                   object: nil,
                                                   queue: .main) { [weak self] _ in
            if let audioEnabled = self?.model?.stream.audioTracks?.first?.enabled {
                self?.muteButton.isSelected = !audioEnabled
            }
        }

        _ = NotificationCenter.default.addObserver(forName: Constants.peerVideoToggled,
                                                   object: nil,
                                                   queue: .main) { [weak self] _ in
            if let videoEnabled = self?.model?.stream.videoTracks?.first?.enabled {
                self?.stopVideoButton.isSelected = !videoEnabled
                self?.avatarLabel.isHidden = videoEnabled
            }
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @IBAction func pinTapped(_ sender: UIButton) {
        print(#function, sender.isSelected, model?.peer.name as Any)
        sender.isSelected = !sender.isSelected
        model?.isPinned = sender.isSelected
        NotificationCenter.default.post(name: Constants.pinTapped,
                                        object: nil,
                                        userInfo: [Constants.peerID: model?.peer.peerId as Any])
    }

    @IBAction func muteTapped(_ sender: UIButton) {
        print(#function, sender.isSelected, model?.peer.name as Any)
        model?.stream.audioTracks?.first?.enabled = sender.isSelected
        sender.isSelected = !sender.isSelected
    }

    @IBAction func stopVideoTapped(_ sender: UIButton) {
        print(#function, sender.isSelected, model?.peer.name as Any, model?.stream.videoTracks?.count as Any)
        model?.stream.videoTracks?.first?.enabled = sender.isSelected
        avatarLabel.isHidden = sender.isSelected
        sender.isSelected = !sender.isSelected
    }
}
