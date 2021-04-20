//
//  ParticipantsViewController.swift
//  HMSVideo_Example
//
//  Created by Yogesh Singh on 28/02/21.
//  Copyright © 2021 100ms. All rights reserved.
//

import UIKit
import HMSVideo

final class ParticipantsViewController: UIViewController {

    @IBOutlet private weak var participantsTitle: UIButton!

    @IBOutlet private  weak var table: UITableView!

    var hms: HMSInteractor?

    var peers: [PeerState]? {
        hms?.model.sorted(by: { $0.peer.name.lowercased() == "host" && $1.peer.name.lowercased() != "host" })
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        observeParticipants()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let count = hms?.model.count ?? 0
        let title = "Participants " + (count > 0 ? "(\(count))" : "")
        participantsTitle.setTitle(title, for: .normal)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Action Handlers

    private func observeParticipants() {
        _ = NotificationCenter.default.addObserver(forName: Constants.peersUpdated,
                                                   object: nil,
                                                   queue: .main) { [weak self] _ in
            self?.table.reloadData()
        }
    }

    @IBAction private func closeTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

extension ParticipantsViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        peers?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.resuseIdentifier,
                                                       for: indexPath) as? ParticipantsTableViewCell else {
            print(#function, "Error: Could not create Participants Table View Cell")
            return UITableViewCell()
        }

        if let peerState = peers?[indexPath.row] {

            cell.peerState = peerState

            cell.nameLabel.text = peerState.peer.name

            cell.roleLabel.text = peerState.peer.role?.capitalized ?? "Guest"

            cell.micButton.isSelected = !(peerState.stream.audioTracks?.first?.enabled ?? true)

            cell.videoButton.isSelected = !(peerState.stream.videoTracks?.first?.enabled ?? true)
        }

        return cell
    }
}
