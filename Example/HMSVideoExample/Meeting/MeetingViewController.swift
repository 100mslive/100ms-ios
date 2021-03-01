//
//  MeetingViewController.swift
//  HMSVideo
//
//  Copyright (c) 2020 100ms. All rights reserved.
//

import UIKit
import MediaPlayer

final class MeetingViewController: UIViewController {

    // MARK: - View Properties

    var user: String!
    var roomName: String!
    var flow: MeetingFlow!

    private var viewModel: MeetingViewModel!

    @IBOutlet weak var roomNameButton: UIButton! {
        didSet {
            roomNameButton.setTitle(roomName, for: .normal)
        }
    }

    @IBOutlet weak var collectionView: UICollectionView!

    @IBOutlet weak var badgeButton: BadgeButton!
    
    var chatBadgeCount = 0
    

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        UIApplication.shared.isIdleTimerDisabled = true

        switch flow {
        case .join:
            viewModel = MeetingViewModel(Constants.endpoint, Constants.token,
                                         self.user, self.roomName, collectionView)
        case .start:
            viewModel = MeetingViewModel(Constants.endpoint, Constants.serverToken,
                                         self.user, self.roomName, collectionView)
        case .none:
            fatalError()
        }

        handleError()
        observeBroadcast()
    }

    override func viewWillDisappear(_ animated: Bool) {
        if isMovingFromParent {
            UIApplication.shared.isIdleTimerDisabled = false
            viewModel.cleanup()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Action Handlers

    func handleError() {
        _ = NotificationCenter.default.addObserver(forName: Constants.hmsError,
                                                   object: nil,
                                                   queue: .main) { [weak self] notification in

            let message = notification.userInfo?["error"] as? String ?? "Client Error!"

            print("Error: ", message)

            let alertController = UIAlertController(title: "Error",
                                                    message: message,
                                                    preferredStyle: .alert)

            alertController.addAction(UIAlertAction(title: "OK", style: .default))

            self?.present(alertController, animated: true, completion: nil)
        }
    }

    func observeBroadcast() {
        _ = NotificationCenter.default.addObserver(forName: Constants.broadcastReceived,
                                                   object: nil,
                                                   queue: .main) { [weak self] _ in
            if let strongSelf = self {
                strongSelf.chatBadgeCount += 1
                strongSelf.badgeButton.badge = "\(strongSelf.chatBadgeCount)"
            }
        }
    }

    @IBAction func roomNameTapped(_ sender: UIButton) {
        guard let viewController = UIStoryboard(name: Constants.participants, bundle: nil)
                .instantiateInitialViewController() as? ParticipantsViewController else {
            return
        }

        viewController.hms = viewModel.hms

        present(viewController, animated: true)
    }

    @IBAction func switchLayoutTapped(_ sender: UIButton) {

        sender.isSelected = !sender.isSelected

        switch viewModel.layout {
        case .grid:
            viewModel.layout = .portrait
        case .portrait:
            viewModel.layout = .grid
        }
    }

    @IBAction func volumeTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        let volumeView = MPVolumeView()
        if let view = volumeView.subviews.first as? UISlider {
            view.value = sender.isSelected ? 0.0 : 1.0
        }
    }

    @IBAction func switchCameraTapped(_ sender: UIButton) {
        viewModel.switchCamera()
    }

    @IBAction func editSettingsTapped(_ sender: UIButton) {

        guard let viewController = UIStoryboard(name: Constants.settings, bundle: nil)
                .instantiateInitialViewController() as? SettingsViewController
        else {
            return
        }

        present(viewController, animated: true)
    }

    @IBAction func videoTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        viewModel.switchVideo(isOn: sender.isSelected)
    }

    @IBAction func micTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        viewModel.switchAudio(isOn: sender.isSelected)
    }

    @IBAction func chatTapped(_ sender: UIButton) {
        guard let viewController = UIStoryboard(name: Constants.chat, bundle: nil)
                .instantiateInitialViewController() as? ChatViewController else {
            return
        }

        viewController.hms = viewModel.hms
        
        chatBadgeCount = 0
        
        badgeButton.badge = nil

        present(viewController, animated: true)
    }

    @IBAction func disconnectTapped(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Exit Call",
                                                message: nil,
                                                preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "YES", style: .destructive) { (_) in
            self.navigationController?.popViewController(animated: true)
        })

        alertController.addAction(UIAlertAction(title: "NO", style: .cancel))

        self.present(alertController, animated: true, completion: nil)

    }
}
