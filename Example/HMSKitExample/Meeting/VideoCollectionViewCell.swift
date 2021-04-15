//
//  VideoCollectionViewCell.swift
//  HMSVideo_Example
//
//  Created by Yogesh Singh on 03/03/21.
//  Copyright © 2021 100ms. All rights reserved.
//

import UIKit
import HMSKit
import QuartzCore

final class VideoCollectionViewCell: UICollectionViewCell {

    weak var peer: HMSPeer?

    var isDominant = false {
        didSet {
            if isDominant {
                Utilities.applyDominantSpeakerBorder(on: self)
            } else {
                Utilities.applyBorder(on: self)
            }
        }
    }

    var isSpeaking = false {
        didSet {
            if isSpeaking {
                Utilities.applySpeakingBorder(on: self)
            } else {
                Utilities.applyBorder(on: self)
            }
        }
    }

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
            avatarLabel.layer.cornerRadius = 32
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        Utilities.applyBorder(on: self)

//        _ = NotificationCenter.default.addObserver(forName: Constants.muteALL,
//                                               object: nil,
//                                               queue: .main) { [weak self] _ in
//            if let audioEnabled = self?.model?.stream.audioTracks?.first?.enabled {
//                self?.muteButton.isSelected = !audioEnabled
//            }
//        }
//
//        _ = NotificationCenter.default.addObserver(forName: Constants.peerAudioToggled,
//                                                   object: nil,
//                                                   queue: .main) { [weak self] _ in
//            if let audioEnabled = self?.model?.stream.audioTracks?.first?.enabled {
//                self?.muteButton.isSelected = !audioEnabled
//            }
//        }
//
//        _ = NotificationCenter.default.addObserver(forName: Constants.peerVideoToggled,
//                                                   object: nil,
//                                                   queue: .main) { [weak self] _ in
//            if let videoEnabled = self?.model?.stream.videoTracks?.first?.enabled {
//                self?.stopVideoButton.isSelected = !videoEnabled
//                self?.avatarLabel.isHidden = videoEnabled
//            }
//        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @IBAction func pinTapped(_ sender: UIButton) {
//        print(#function, sender.isSelected, peer?.name as Any)
        sender.isSelected = !sender.isSelected
        peer?.isPinned = sender.isSelected
        NotificationCenter.default.post(name: Constants.pinTapped,
                                        object: nil)
    }

    @IBAction func muteTapped(_ sender: UIButton) {
//        print(#function, sender.isSelected, peer?.name as Any)
//        peer?.audioTrack?.enabled = sender.isSelected
        sender.isSelected = !sender.isSelected
    }

    @IBAction func stopVideoTapped(_ sender: UIButton) {
//        print(#function, sender.isSelected, peer?.name as Any)
//        peer?.videoTrack?.enabled = sender.isSelected
        avatarLabel.isHidden = sender.isSelected
        sender.isSelected = !sender.isSelected
    }
}
