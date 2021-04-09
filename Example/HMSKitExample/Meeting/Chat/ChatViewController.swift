//
//  ChatViewController.swift
//  HMSVideo_Example
//
//  Created by Yogesh Singh on 28/02/21.
//  Copyright © 2021 100ms. All rights reserved.
//

import UIKit

final class ChatViewController: UIViewController {

    private var interactor: HMSKitInteractor?

    @IBOutlet private weak var table: UITableView!
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var sendButton: UIButton!

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        table.tableFooterView = UIView()
        table.estimatedRowHeight = 64
        table.rowHeight = UITableView.automaticDimension
        table.tableFooterView = stackView

        observeBroadcast()
        handleKeyboard()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textField.becomeFirstResponder()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }


    // MARK: - View Modifiers

    private func handleKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillShow(notification: NSNotification) {

        guard let userInfo = notification.userInfo,
              var keyboardFrame = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
        else { return }

        keyboardFrame = view.convert(keyboardFrame, from: nil)

        var contentInset = table.contentInset
        contentInset.bottom = keyboardFrame.size.height + 30
        table.contentInset = contentInset
    }

    @objc private func keyboardWillHide(notification: NSNotification) {

        let contentInset = UIEdgeInsets.zero
        table.contentInset = contentInset
    }


    // MARK: - Action Handlers

    private func observeBroadcast() {
        _ = NotificationCenter.default.addObserver(forName: Constants.broadcastReceived,
                                                   object: nil,
                                                   queue: .main) { [weak self] _ in

            self?.table.reloadData()
//            let index = IndexPath(row: (self?.interactor?.hms?.broadcasts.count ?? 1) - 1, section: 0)
//            self?.table.insertRows(at: [index], with: .automatic)
//            self?.table.scrollToRow(at: index, at: .top, animated: true)
        }
    }

    @IBAction private func closeTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }

    @IBAction private func sendTapped(_ sender: UIButton) {

//        if let message = textField.text, !message.isEmpty, let interactor = interactor {
//
//            sender.isEnabled = false
//
//            let broadcast = [ Constants.chatSenderName: interactor.hms?.localPeer.name,
//                              Constants.chatMessage: message ]
//
//            hms.send(broadcast) { [weak self] in
//
//                sender.isEnabled = true
//                self?.textField.text = nil
//                hms.broadcasts.append(broadcast)
//                let index = IndexPath(row: hms.broadcasts.count - 1, section: 0)
//                self?.table.insertRows(at: [index], with: .automatic)
//                self?.table.scrollToRow(at: index, at: .top, animated: true)
//            }
//        }
    }
}

extension ChatViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        hms?.broadcasts.count ?? 0
        0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard //let chat = hms?.broadcasts[indexPath.row],
//              let sender = chat[Constants.chatSenderName] as? String,
//              let message = chat[Constants.chatMessage] as? String,
              let cell = tableView.dequeueReusableCell(withIdentifier: Constants.resuseIdentifier,
                                                       for: indexPath) as? ChatTableViewCell
        else {
            return UITableViewCell()
        }

//        if sender.lowercased() == hms?.localPeer.name.lowercased() {
//            cell.nameLabel.textAlignment = .right
//            cell.messageLabel.textAlignment = .right
//        } else {
            cell.nameLabel.textAlignment = .left
            cell.messageLabel.textAlignment = .left
//        }

//        cell.nameLabel.text = sender
//        cell.messageLabel.text = message

        return cell
    }
}

extension ChatViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendTapped(sendButton)
        return true
    }
}
