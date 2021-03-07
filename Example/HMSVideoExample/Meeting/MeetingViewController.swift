//
//  MeetingViewController.swift
//  HMSVideo
//
//  Copyright (c) 2020 100ms. All rights reserved.
//

import UIKit
import HMSVideo
import MediaPlayer

final class MeetingViewController: UIViewController {

    // MARK: - View Properties

    internal var user: String!
    internal var roomName: String!
    internal var flow: MeetingFlow!
    
    private var viewModel: MeetingViewModel!

    @IBOutlet weak var roomNameButton: UIButton! {
        didSet {
            roomNameButton.setTitle(roomName, for: .normal)
        }
    }
    
    @IBOutlet weak var speakerButton: UIButton! 

    @IBOutlet private(set) weak var collectionView: UICollectionView!

    @IBOutlet private weak var badgeButton: BadgeButton!

    @IBOutlet weak var publishVideoButton: UIButton! {
        didSet {
            if let publishVideo = UserDefaults.standard.object(forKey: Constants.publishVideo) as? Bool {
                publishVideoButton.isSelected = !publishVideo
            } else {
                publishVideoButton.isSelected = false
            }
        }
    }

    @IBOutlet weak var publishAudioButton: UIButton! {
        didSet {
            if let publishAudio = UserDefaults.standard.object(forKey: Constants.publishAudio) as? Bool {
                publishAudioButton.isSelected = !publishAudio
            } else {
                publishAudioButton.isSelected = false
            }
        }
    }

    private var chatBadgeCount = 0

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        UIApplication.shared.isIdleTimerDisabled = true

        viewModel = MeetingViewModel(self.user, self.roomName, flow, collectionView)

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

            if let presentedVC = self?.presentedViewController {
                presentedVC.dismiss(animated: true) {
                    self?.presentAlert(message)
                }
                return
            }

            self?.presentAlert(message)
        }
    }

    func presentAlert(_ message: String) {
        let alertController = UIAlertController(title: "Error",
                                                message: message,
                                                preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "OK", style: .default))

        present(alertController, animated: true, completion: nil)
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

//        sender.isSelected = !sender.isSelected
    }

    @IBAction func muteRemoteStreamsTapped(_ sender: UIButton) {
        viewModel.muteRemoteStreams(sender.isSelected)
        sender.isSelected = !sender.isSelected
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
        viewModel.switchVideo(isOn: sender.isSelected)
        UserDefaults.standard.set(sender.isSelected, forKey: Constants.publishVideo)
        sender.isSelected = !sender.isSelected
    }

    @IBAction func micTapped(_ sender: UIButton) {
        viewModel.switchAudio(isOn: sender.isSelected)
        UserDefaults.standard.set(sender.isSelected, forKey: Constants.publishAudio)
        sender.isSelected = !sender.isSelected
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
        let alertController = UIAlertController(title: "Leave Call",
                                                message: nil,
                                                preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "YES", style: .destructive) { (_) in
            self.navigationController?.popViewController(animated: true)
        })

        alertController.addAction(UIAlertAction(title: "NO", style: .cancel))

        self.present(alertController, animated: true, completion: nil)

    }
}
