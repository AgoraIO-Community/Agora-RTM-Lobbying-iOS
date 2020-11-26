//
//  ViewController+AgoraRtmDelegate.swift
//  Agora-RTM-iOS
//
//  Created by Max Cobb on 25/11/2020.
//

import AgoraRtmKit

// MARK: RTM Delegate Methods

extension ViewController: AgoraRtmDelegate {
    func rtmKit(_ kit: AgoraRtmKit, messageReceived message: AgoraRtmMessage, fromPeer peerId: String) {
        print("received message: \"\(message.text)\"\nfrom peer: \(peerId)")
        if message.type == .text, let messageData = message.text.data(using: .utf8) {
            let jsonDecoder = JSONDecoder()
            if let channelData = try? jsonDecoder.decode(
                ChannelData.self,
                from: messageData
            ) {
                self.newChannelData(channelData)
            }
        }
    }

    func rtmKit(_ kit: AgoraRtmKit, peersOnlineStatusChanged onlineStatus: [AgoraRtmPeerOnlineStatus]) {
        print("peer statusssss \(onlineStatus.count)\n\(onlineStatus)")
    }
    func rtmKit(_ kit: AgoraRtmKit, connectionStateChanged state: AgoraRtmConnectionState, reason: AgoraRtmConnectionChangeReason) {
        print("connection changed to connected \(state.describe), because \(reason.describe)")
    }
}

