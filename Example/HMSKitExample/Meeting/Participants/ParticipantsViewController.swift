//
//  ParticipantsViewController.swift
//  HMSVideo_Example
//
//  Created by Yogesh Singh on 28/02/21.
//  Copyright © 2021 100ms. All rights reserved.
//

import UIKit
import HMSKit

final class ParticipantsViewController: UIViewController {

    @IBOutlet private weak var participantsTitle: UIButton!

    @IBOutlet private  weak var table: UITableView!

    var interactor: HMSKitInteractor?

//    var peers: [PeerState]? {
//        hms?.model.sorted(by: { $0.peer.name.lowercased() == "host" && $1.peer.name.lowercased() != "host" })
//    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        observeParticipants()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let count = interactor?.hms?.room?.peers.count ?? 0
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
        interactor?.hms?.room?.peers.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.resuseIdentifier,
                                                       for: indexPath) as? ParticipantsTableViewCell else {
            print(#function, "Error: Could not create Participants Table View Cell")
            return UITableViewCell()
        }

        if let peer = interactor?.hms?.room?.peers[indexPath.row] {

            cell.peer = peer

            cell.nameLabel.text = peer.name

            cell.roleLabel.text = peer.role.name

            cell.micButton.isSelected = !(peer.audioTrack?.enabled ?? true)

            cell.videoButton.isSelected = !(peer.videoTrack?.enabled ?? true)
        }

        return cell
    }
}
