//
//  LoginViewController.swift
//  HMSVideo
//
//  Copyright (c) 2020 100ms. All rights reserved.
//

import UIKit
import AVKit

final class LoginViewController: UIViewController {

    // MARK: - View Properties

    @IBOutlet private weak var containerStackView: UIStackView! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:)))
            containerStackView.addGestureRecognizer(tap)
        }
    }

    @IBOutlet private weak var joinMeetingIDField: UITextField! {
        didSet {
            Utilities.drawCorner(on: joinMeetingIDField)
        }
    }

    @IBOutlet private weak var joinMeetingStackView: UIStackView! {
        didSet {
            Utilities.drawCorner(on: joinMeetingStackView)
            let blurEffect = UIBlurEffect(style: .regular)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = joinMeetingStackView.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            joinMeetingStackView.addSubview(blurEffectView)
            joinMeetingStackView.sendSubviewToBack(blurEffectView)
        }
    }

    @IBOutlet private weak var startMeetingStackView: UIStackView! {
        didSet {
            Utilities.drawCorner(on: startMeetingStackView)
            let blurEffect = UIBlurEffect(style: .regular)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = startMeetingStackView.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            startMeetingStackView.addSubview(blurEffectView)
            startMeetingStackView.sendSubviewToBack(blurEffectView)
        }
    }

    @IBOutlet private weak var joinMeetingButton: UIButton! {
        didSet {
            Utilities.drawCorner(on: joinMeetingButton)
        }
    }

    @IBOutlet private weak var startMeetingButton: UIButton! {
        didSet {
            Utilities.drawCorner(on: startMeetingButton)
        }
    }

    @IBOutlet private weak var publishVideoButton: UIButton! {
        didSet {
            UserDefaults.standard.set(true, forKey: Constants.publishVideo)
        }
    }

    @IBOutlet private weak var publishAudioButton: UIButton! {
        didSet {
            UserDefaults.standard.set(true, forKey: Constants.publishAudio)
        }
    }

    @IBOutlet private weak var cameraPreview: UIView!

    private var session: AVCaptureSession?
    private var input: AVCaptureDeviceInput?
    private var output: AVCapturePhotoOutput?
    private var previewLayer: AVCaptureVideoPreviewLayer?

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupCameraPreview()

        observeNotifications()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        joinMeetingIDField.text = UserDefaults.standard.string(forKey: Constants.roomIDKey) ?? Constants.defaultRoomID
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateCameraView()
    }

    override func willTransition(to newCollection: UITraitCollection,
                                 with coordinator: UIViewControllerTransitionCoordinator) {

        super.willTransition(to: newCollection, with: coordinator)

        coordinator.animate { _ in
            self.updateCameraView()
            self.joinMeetingIDField.resignFirstResponder()
        }
    }

    // MARK: - View Modifiers

    private func setupCameraPreview() {

        session = AVCaptureSession()
        output = AVCapturePhotoOutput()
        if let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
            do {
                input = try AVCaptureDeviceInput(device: camera)
            } catch let error as NSError {
                print(error)
                input = nil
            }

            guard let input = input, let output = output, let session = session else { return }

            if session.canAddInput(input) {
                session.addInput(input)

                if session.canAddOutput(output) {
                    session.addOutput(output)
                }

                let settings = AVCapturePhotoSettings()
                let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!

                let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
                                     kCVPixelBufferWidthKey as String: view.frame.size.width,
                                     kCVPixelBufferHeightKey as String: view.frame.size.height] as [String: Any]
                settings.previewPhotoFormat = previewFormat

                output.capturePhoto(with: settings, delegate: self)
            }
        }
    }

    private func updateCameraView() {
        let orientation = UIApplication.shared.statusBarOrientation
        let videoOrientation = AVCaptureVideoOrientation(rawValue: orientation.rawValue) ?? .portrait
        previewLayer?.connection?.videoOrientation = videoOrientation
        previewLayer?.frame = cameraPreview.bounds
    }

    // MARK: - Action Handlers

    func observeNotifications() {
        _ = NotificationCenter.default.addObserver(forName: Constants.deeplinkTapped,
                                                   object: nil,
                                                   queue: .main) { notification in
            guard let info = notification.userInfo,
                  let roomID = info[Constants.roomIDKey] as? String,
                  let endpoint = info[Constants.hostKey] as? String else {
                print(#function, "Error: Could not find correct Deep link URL")
                return
            }

            self.joinMeetingIDField.text = roomID

            let socketEndpoint = "wss://\(endpoint)/ws"
            UserDefaults.standard.set(socketEndpoint, forKey: Constants.socketEndpointKey)

            self.showInputAlert(flow: .join)
        }
    }

    @objc private func dismissKeyboard(_ sender: Any) {
        joinMeetingIDField.resignFirstResponder()
    }

    @IBAction private func cameraTapped(_ sender: UIButton) {

        UserDefaults.standard.set(sender.isSelected, forKey: Constants.publishVideo)
        sender.isSelected = !sender.isSelected

        if let session = session {
            if sender.isSelected {
                if session.isRunning {
                    session.stopRunning()
                    previewLayer?.removeFromSuperlayer()
                }
            } else {
                if !session.isRunning {
                    session.startRunning()
                    cameraPreview.layer.addSublayer(previewLayer ?? CALayer())
                }
            }
        }
    }

    @IBAction private func micTapped(_ sender: UIButton) {
        AVAudioSession.sharedInstance().requestRecordPermission { _ in }
        UserDefaults.standard.set(sender.isSelected, forKey: Constants.publishAudio)
        sender.isSelected = !sender.isSelected
    }

    @IBAction private func startMeetingTapped(_ sender: UIButton) {
        showInputAlert(flow: sender.tag == 0 ? .join : .start)
    }

    private func showInputAlert(flow: MeetingFlow) {

        let title: String
        var message: String?
        let action: String

        if flow == .join {
            title = "Join a Meeting"
            message = "Enter your Name"
            action = "Join"
        } else {
            title = "Start a Meeting"
            action = "Start"
        }

        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)

        alertController.addTextField { textField in
            textField.placeholder = "Enter your Name"
            textField.clearButtonMode = .always
            textField.text = UserDefaults.standard.string(forKey: Constants.defaultName) ?? "iOS User"
        }

        if flow == .start {
            alertController.addTextField { textField in
                textField.placeholder = "Enter Room Name"
                textField.clearButtonMode = .always
                textField.text = "My Meeting"
            }
        }

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alertController.addAction(UIAlertAction(title: action, style: .default) { [weak self] _ in

            self?.handleActions(for: alertController, in: flow)
        })

        present(alertController, animated: true, completion: nil)
    }

    private func handleActions(for alertController: UIAlertController, in flow: MeetingFlow) {
        var room: String

        if flow == .join {
            if !joinMeetingIDField.text!.isEmpty {
                room = joinMeetingIDField.text!
            } else {
                showErrorAlert(with: "Enter Meeting ID!")
                return
            }
        } else {
            if !(alertController.textFields?[1].text!.isEmpty)! {
                room = (alertController.textFields?[1].text!)!
            } else {
                showErrorAlert(with: "Enter Meeting Name!")
                return
            }
        }

        guard let name = alertController.textFields?[0].text, !name.isEmpty,
              let viewController = UIStoryboard(name: Constants.meeting, bundle: nil)
                .instantiateInitialViewController() as? MeetingViewController
        else {
            dismiss(animated: true)
            let message = flow == .join ? "Could not join meeting" : "Could not start meeting"
            showErrorAlert(with: message)
            return
        }

        viewController.user = name
        viewController.flow = flow
        viewController.roomName = room

        save(name, room)

        navigationController?.pushViewController(viewController, animated: true)
    }

    private func showErrorAlert(with message: String) {
        let alertController = UIAlertController(title: "Alert",
                                                message: message,
                                                preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "OK", style: .default))

        present(alertController, animated: true, completion: nil)
    }

    private func save(_ name: String, _ room: String, _ meeting: String? = nil) {
        let userDefaults = UserDefaults.standard

        userDefaults.set(name, forKey: Constants.defaultName)
        userDefaults.set(room, forKey: Constants.roomName)

        if let meeting = meeting {
            userDefaults.set(meeting, forKey: "meeting")
        }
    }

    @IBAction private func settingsTapped(_ sender: UIButton) {
        guard let viewController = UIStoryboard(name: Constants.settings, bundle: nil)
                .instantiateInitialViewController() as? SettingsViewController
        else {
            return
        }

        present(viewController, animated: true)
    }
}

@available(iOS 11.0, *)
extension LoginViewController: AVCapturePhotoCaptureDelegate {

    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {

        if let session = session {
            previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer?.videoGravity = .resizeAspectFill
            updateCameraView()
            cameraPreview.layer.addSublayer(previewLayer!)
            session.startRunning()
        }
    }
}
