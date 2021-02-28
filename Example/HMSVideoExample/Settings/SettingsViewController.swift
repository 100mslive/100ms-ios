//
//  SettingsViewController.swift
//  HMSVideo_Example
//
//  Created by Yogesh Singh on 27/02/21.
//  Copyright © 2021 100ms. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    // MARK: - View Properties

    let defaultVideoSource = ["Front Facing", "Rear Facing"]
    let videoCodecs = ["H264", "VP8", "VP9"]
    let videoResolution = ["QVGA", "VGA", "QHD", "HD", "Full HD"]
    let videoBitRate = ["Lowest (100 kbps)", "Low (256 kbps)", "Medium (512 kbps)", "High (1 mbps)", "LAN (4 mbps)"]

    @IBOutlet weak var videoSourcePicker: UIPickerView!

    @IBOutlet weak var videoCodecPicker: UIPickerView!

    @IBOutlet weak var videoResolutionPicker: UIPickerView!

    @IBOutlet weak var videoBitRatePicker: UIPickerView!

    @IBOutlet weak var defaultNameField: UITextField! {
        didSet {
            if let name = UserDefaults.standard.string(forKey: Constants.defaultName) {
                defaultNameField.text = name
            }
        }
    }

    @IBOutlet weak var publishVideoSwitch: UISwitch! {
        didSet {
            if let isOn = UserDefaults.standard.object(forKey: Constants.publishVideo) as? Bool {
                publishVideoSwitch.setOn(isOn, animated: false)
            }
        }
    }

    @IBOutlet weak var publishAudioSwitch: UISwitch! {
        didSet {
            if let isOn = UserDefaults.standard.object(forKey: Constants.publishAudio) as? Bool {
                publishAudioSwitch.setOn(isOn, animated: false)
            }
        }
    }

    @IBOutlet weak var maximumRowsField: UITextField! {
        didSet {
            if let rows = UserDefaults.standard.string(forKey: Constants.maximumaRows) {
                maximumRowsField.text = rows
            }
        }
    }

    @IBOutlet weak var audioPollDelayField: UITextField! {
        didSet {
            if let delay = UserDefaults.standard.string(forKey: Constants.audioPollDelay) {
                audioPollDelayField.text = delay
            }
        }
    }

    @IBOutlet weak var silenceThresholdField: UITextField! {
        didSet {
            if let threshold = UserDefaults.standard.string(forKey: Constants.silenceThreshold) {
                silenceThresholdField.text = threshold
            }
        }
    }

    @IBOutlet weak var mirrorMyVideoSwitch: UISwitch! {
        didSet {
            if let isOn = UserDefaults.standard.object(forKey: Constants.mirrorMyVideo) as? Bool {
                mirrorMyVideoSwitch.setOn(isOn, animated: false)
            }
        }
    }

    @IBOutlet weak var showVideoPreviewSwitch: UISwitch! {
        didSet {
            if let isOn = UserDefaults.standard.object(forKey: Constants.showVideoPreview) as? Bool {
                showVideoPreviewSwitch.setOn(isOn, animated: false)
            }
        }
    }

    @IBOutlet weak var videoFrameRateField: UITextField! {
        didSet {
            if let rate = UserDefaults.standard.string(forKey: Constants.videoFrameRate) {
                videoFrameRateField.text = rate
            }
        }
    }

    @IBOutlet weak var environmentField: UITextField! {
        didSet {
            if let environment = UserDefaults.standard.string(forKey: Constants.environment) {
                environmentField.text = environment
            }
        }
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupPickers()
    }

    // MARK: - View Modifiers

    func setupPickers() {

        let userDefaults = UserDefaults.standard

        let source = userDefaults.string(forKey: Constants.defaultVideoSource) ?? "Front Facing"
        let sourceIndex = defaultVideoSource.firstIndex(of: source) ?? 0
        videoSourcePicker.selectRow(sourceIndex, inComponent: 0, animated: false)

        let codec = userDefaults.string(forKey: Constants.videoCodec) ?? "VP8"
        let codecIndex = videoCodecs.firstIndex(of: codec) ?? 1
        videoCodecPicker.selectRow(codecIndex, inComponent: 0, animated: false)

        let resolution = userDefaults.string(forKey: Constants.videoResolution) ?? "QHD"
        let resolutionIndex = videoResolution.firstIndex(of: resolution) ?? 2
        videoResolutionPicker.selectRow(resolutionIndex, inComponent: 0, animated: false)

        let bitrate = userDefaults.string(forKey: Constants.videoBitRate) ?? "Medium (512 kbps)"
        let bitrateIndex = videoBitRate.firstIndex(of: bitrate) ?? 2
        videoBitRatePicker.selectRow(bitrateIndex, inComponent: 0, animated: false)
    }

    // MARK: - Action Handlers

    @IBAction func closeTapped(_ sender: UIButton) {
        save()
        self.dismiss(animated: true)
    }

    func save() {
        let userDefaults = UserDefaults.standard

        userDefaults.set(!defaultNameField.text!.isEmpty ? defaultNameField.text : "iOS User",
                         forKey: Constants.defaultName)
        userDefaults.set(publishVideoSwitch.isOn, forKey: Constants.publishVideo)
        userDefaults.set(publishAudioSwitch.isOn, forKey: Constants.publishAudio)
        userDefaults.set(!maximumRowsField.text!.isEmpty ? maximumRowsField.text : "2",
                         forKey: Constants.maximumaRows)
        userDefaults.set(!audioPollDelayField.text!.isEmpty ? audioPollDelayField.text : "2",
                         forKey: Constants.audioPollDelay)
        userDefaults.set(!silenceThresholdField.text!.isEmpty ? silenceThresholdField.text : "0.01",
                         forKey: Constants.silenceThreshold)
        userDefaults.set(mirrorMyVideoSwitch.isOn, forKey: Constants.mirrorMyVideo)
        userDefaults.set(showVideoPreviewSwitch.isOn, forKey: Constants.showVideoPreview)
        userDefaults.set(!videoFrameRateField.text!.isEmpty ? videoFrameRateField.text : "25",
                         forKey: Constants.videoFrameRate)
        userDefaults.set(!environmentField.text!.isEmpty ? environmentField.text : "prod-in",
                         forKey: Constants.environment)

        let source = defaultVideoSource[videoSourcePicker.selectedRow(inComponent: 0)]
        userDefaults.set(source, forKey: Constants.defaultVideoSource)

        let codec = videoCodecs[videoCodecPicker.selectedRow(inComponent: 0)]
        userDefaults.set(codec, forKey: Constants.videoCodec)

        let resolution = videoResolution[videoResolutionPicker.selectedRow(inComponent: 0)]
        userDefaults.set(resolution, forKey: Constants.videoResolution)

        let bitrate = videoBitRate[videoBitRatePicker.selectedRow(inComponent: 0)]
        userDefaults.set(bitrate, forKey: Constants.videoBitRate)
    }
}

// MARK: - Picker View

extension SettingsViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case 0:
            return defaultVideoSource.count
        case 1:
            return videoCodecs.count
        case 2:
            return videoResolution.count
        case 3:
            return videoBitRate.count
        default:
            return 0
        }
    }
}

extension SettingsViewController: UIPickerViewDelegate {

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {

        switch pickerView.tag {
        case 0:
            return defaultVideoSource[row]
        case 1:
            return videoCodecs[row]
        case 2:
            return videoResolution[row]
        case 3:
            return videoBitRate[row]
        default:
            return nil
        }
    }
}