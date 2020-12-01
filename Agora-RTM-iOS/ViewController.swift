//
//  ViewController.swift
//  Agora-RTM-iOS
//
//  Created by Max Cobb on 17/11/2020.
//

import Foundation
import UIKit
import MultipeerConnectivity
import AgoraRtmKit
import SwiftSpinner

class ViewController: UIViewController {

    static var agoraAppId: String = <#Agora App ID#>

    var agoraRTM: AgoraRtmKit!
    var lobbyChannel: AgoraRtmChannel?
    var breakoutChannel: AgoraRtmChannel?
    var lobbyChannelName = "lobby"
    let tableView = UITableView()

    var breakoutChannelName: String? {
        self.breakoutData?.channelName
    }
    var breakoutData: ChannelData?
    var breakoutSize = 2

    var channelsList: [String: ChannelData] = [:] {
        didSet {
            if oldValue.keys.sorted() != channelsList.keys.sorted() {
                self.tableView.reloadData()
            }
        }
    }

    lazy var username: String = {
        if let nameFiltered = self.filterNameRTM(str: UIDevice.current.name) {
            return nameFiltered
        }
        // device name is not usable, using random hash
        return String(UUID().uuidString.prefix(8))
    }()

    override func loadView() {
        super.loadView()
        self.title = "begin"
        setupTableView()
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupRTM()
    }

    func setupRTM() {
        self.agoraRTM = AgoraRtmKit(
            appId: ViewController.agoraAppId,
            delegate: self
        )
        print("logging in as \(self.username)")
        self.agoraRTM.login(
            byToken: nil, user: self.username,
            completion: self.rtmLoginCallback
        )
    }

    func rtmLoginCallback(_ err: AgoraRtmLoginErrorCode) {
        if err != .ok {
            print("login failed: \(err)")
        } else {
            print("login success")
            self.createAndJoin(channel: self.lobbyChannelName) { channel in
                self.lobbyChannel = channel
            }
        }
    }

    /// Attempt to strip out any unsuitable characters for use with Agora RTM
    /// - Parameter str: Original string to be stripped if needed
    /// - Returns: Original string if no change is needed, modified version if an easy modification can be made.
    ///            Nil if no straightforward change can be made to the input string.
    func filterNameRTM(str: String) -> String? {
        // removes accents from characters
        var nameFiltered = str.folding(options: .diacriticInsensitive, locale: .current)
        // Fetches CharacterSet of [a-zA-Z0-9]
        var charset = CharacterSet.baseAlphanumerics
        // The below characters are referenced in Agora documentation https://bit.ly/39gjZpC
        charset.insert(charactersIn: "!#$%&()+-:;<=.>?[]^_ {}|~,")

        nameFiltered = String(nameFiltered.unicodeScalars.filter { charset.contains($0) })
        return nameFiltered
    }

    func newChannelData(_ channelData: ChannelData) {
        self.channelsList[channelData.channelName] = channelData
    }
}
