//
//  ViewController+TableView.swift
//  Agora-RTM-iOS
//
//  Created by Max Cobb on 25/11/2020.
//

import UIKit

// MARK: TableView

extension ViewController: UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    var data: [ChannelData] {
        Array(self.channelsList.values) + [ChannelData(channelName: "Add New Channel…")]
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }

    func setupTableView() {
        view.addSubview(tableView)
        self.view.sendSubviewToBack(tableView)
        tableView.frame = self.view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let chName = data[indexPath.row].channelName
        cell.textLabel?.text = chName
        if indexPath.row == self.data.count - 1 {
            // for adding a new channel
            cell.textLabel?.font = .italicSystemFont(ofSize: UIFont.systemFontSize)
        } else {
            cell.textLabel?.font = .systemFont(ofSize: UIFont.systemFontSize, weight: UIFont.Weight.heavy)
        }
        return cell
    }

    func popupHandler(action: UIAlertAction, text: String? = nil) {
        print("text: \(text ?? "")")
        switch action.style{
        case .default:
            guard let text = text, !text.isEmpty else {
                return
            }
            self.joinChannelSpinner(channelName: text)
            self.createAndJoin(channel: text) { channel in
                guard let channel = channel else {
                    return
                }
                self.joinedBreakout(name: text, channel: channel)
                self.tableView.reloadData()
            }
        case .cancel:
            print("cancel")
        case .destructive:
            print("destructive")
        @unknown default:
            fatalError("bad case \(action.style)")
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""

        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)

        if updatedText != "" && updatedText.trimmingCharacters(in: .whitespaces).isEmpty {
            return false
        }
        return self.filterNameRTM(str: updatedText) == updatedText
    }

    @objc func textFieldValueChanged(selector textField: UITextField) {
        guard let alertVC = (self.presentedViewController as? UIAlertController) else {
            return
        }
        alertVC.actions[1].isEnabled = !(textField.text ?? "").isEmpty
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer { tableView.deselectRow(at: indexPath, animated: true) }
        if indexPath.row == self.data.count - 1 {
            makeNewChannel()
            return
        }
        let chName = data[indexPath.row].channelName

        self.joinChannelSpinner(channelName: chName)
        self.createAndJoin(channel: chName) { (channelJoined) in
            guard let boc = channelJoined else {
                return
            }
            print("setting accessoryView to checkmark")
//            cell.accessoryType = .checkmark
            self.joinedBreakout(name: chName, channel: boc)
        }
    }
}

