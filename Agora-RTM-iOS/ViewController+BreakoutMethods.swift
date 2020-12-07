//
//  ViewController+BreakoutMethods.swift
//  Agora-RTM-iOS
//
//  Created by Max Cobb on 25/11/2020.
//

import UIKit

import AgoraRtmKit
import SwiftSpinner

extension ViewController {

    func createAndJoin(channel channelName: String, callback: @escaping (AgoraRtmChannel?) -> Void) {
        var channel = self.agoraRTM.createChannel(withId: channelName, delegate: self)
        channel?.join { joinErr in
            switch joinErr {
            case .channelErrorOk, .channelErrorAlreadyJoined:
                print("joined channel \"\(channelName)\"")
            default:
                print("join failed: \(joinErr.describe)")
                channel = nil
            }
            callback(channel)
        }
    }

    func makeNewChannel() {
        // add a new channel
        let alert = UIAlertController(title: "New Channel", message: "Enter Channel Name", preferredStyle: .alert)
        let okAction = UIAlertAction(
            title: "OK", style: .default,
            handler: { (action) in
                self.popupHandler(action: action, text: alert.textFields?.first?.text)
            }
        )
        okAction.isEnabled = false
        alert.addTextField { (tfield) in
            tfield.placeholder = "Channel Name"
            tfield.autocorrectionType = .no
            tfield.delegate = self
            tfield.addTarget(self, action: #selector(self.textFieldValueChanged), for: UIControl.Event.editingChanged)
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            self.popupHandler(action: action)
        }))
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }

    func joinedBreakout(name: String, channel: AgoraRtmChannel) {
        self.breakoutChannel = channel
        self.breakoutData = ChannelData(channelName: name)
        self.channelsList[name] = self.breakoutData
        self.checkBreakoutChannelSize(justJoined: true)
    }

    func checkBreakoutChannelSize(justJoined: Bool = false) {
        self.breakoutChannel?.getMembersWithCompletion { (members, getErr) in
            guard let members = members, !members.isEmpty else {
                print("coult not get members:  \(getErr)")
                return
            }
            if justJoined {
                self.breakoutData?.seniors = Set(members.map { $0.userId }.filter{ $0 != self.username })
            }
            if let bod = self.breakoutData {
                SwiftSpinner.shared.title = "\(members.count)/\(bod.membersMinimum)"
            }
            self.breakoutData?.memberCount = members.count
            if let bod = self.breakoutData, (bod.seniors ?? []).isEmpty {
                self.send(encodableObj: bod, to: self.lobbyChannel!)
            }
        }
    }

    func joinChannelSpinner(channelName: String) {
        let sSpinner = SwiftSpinner.show("Joining channel \(channelName)")
        sSpinner.addTapHandler({
            SwiftSpinner.hide()

            self.leaveBreakout()
        }, subtitle: "Tap to cancel")
    }
    func leaveBreakout() {
        guard let currBreakout = self.breakoutChannel else {
            return
        }
        currBreakout.leave { leaveErr in
            if leaveErr != .ok {
                print("ERROR problem leaving channel")
            }
            print("leaving breakout: \(self.breakoutData?.channelName ?? "unknown")")
            self.breakoutChannel = nil
            self.breakoutVideo = nil
            self.breakoutData = nil
            self.tableView.reloadData()
        }
    }

}
