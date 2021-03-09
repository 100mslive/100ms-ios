//
//  ParticipantsTableViewCell.swift
//  HMSVideo_Example
//
//  Created by Yogesh Singh on 07/03/21.
//  Copyright © 2021 100ms. All rights reserved.
//

import UIKit

final class ParticipantsTableViewCell: UITableViewCell {

    weak var peerState: PeerState?

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var roleLabel: UILabel!
    @IBOutlet weak var videoButton: UIButton!
    @IBOutlet weak var micButton: UIButton!

    @IBAction func micButtonTapped(_ sender: UIButton) {
        peerState?.stream.audioTracks?.first?.enabled = sender.isSelected
        sender.isSelected = !sender.isSelected
        NotificationCenter.default.post(name: Constants.peerAudioToggled, object: nil)
    }

    @IBAction func videoButtonTapped(_ sender: UIButton) {
        peerState?.stream.videoTracks?.first?.enabled = sender.isSelected
        sender.isSelected = !sender.isSelected
        NotificationCenter.default.post(name: Constants.peerVideoToggled, object: nil)
    }
}
