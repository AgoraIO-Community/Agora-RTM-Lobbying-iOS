//
//  ViewController+ChannelDelegate.swift
//  Agora-RTM-iOS
//
//  Created by Max Cobb on 23/11/2020.
//

import UIKit
import AgoraRtmKit
import SwiftSpinner

// MARK: Channel Delegate Methods

extension ViewController: AgoraRtmChannelDelegate, UIViewControllerTransitioningDelegate {

    func channel(_ channel: AgoraRtmChannel, memberJoined member: AgoraRtmMember) {
        print("\(member.userId) joined channel \(member.channelId)")
        if channel == self.lobbyChannel {
            // if someone joined the lobby, send a request for them
            // to join the breakout room, if no higher people in breakout
            if let bod = self.breakoutData, (bod.seniors ?? []).isEmpty {
                self.send(encodableObj: bod, to: member)
            } else {
                if self.autoBreakout {
                    // If using autoBreakout then immediately create a channel
                    // and request for new user to join
                    let channelName = UUID().uuidString
                    self.createAndJoin(channel: channelName) { channel in
                        self.breakoutChannel = channel
                        self.breakoutData = ChannelData(channelName: channelName, memberCount: 1, seniors: [])
                        self.send(encodableObj: self.breakoutData!, to: member)
                    }
                }
            }
        } else {
            // Otherwise someone has joined our breakout channel
            guard let bod = self.breakoutData else {
                print("ERROR: no breakout saved")
                return
            }
            bod.memberCount += 1
            SwiftSpinner.shared.title = "\(bod.memberCount)/\(bod.memberLimit)"
            if (bod.seniors ?? []).isEmpty, bod.memberLimit == bod.memberCount {
                self.createVideoChat(with: "test")
                self.send(encodableObj: VideoChannel(channel: "test"), to: channel)
            }
        }
    }

    func channel(_ channel: AgoraRtmChannel, memberLeft member: AgoraRtmMember) {
        print("\(member.userId) left channel \(member.channelId)")
        guard var seniors = self.breakoutData?.seniors else {
            print("ERROR: should have seniors array")
            return
        }
        self.breakoutData?.memberCount -= 1
        if seniors.remove(member.userId) != nil, seniors.isEmpty {
            print("User is now the leader of breakout channel")
        }
    }

    func channel(_ channel: AgoraRtmChannel, messageReceived message: AgoraRtmMessage, from member: AgoraRtmMember) {
        print("received channel message: \"\(message.text)\"\n from member: \(member.userId)")
        if channel == self.lobbyChannel {
            if message.type == .text, let messageData = message.text.data(using: .utf8) {
                let jsonDecoder = JSONDecoder()
                if let channelData = try? jsonDecoder.decode(
                    ChannelData.self,
                    from: messageData
                ) {
                    self.newChannelData(channelData)
                }
            }
        } else {
            let jsonDecoder = JSONDecoder()
            if let messageData = message.text.data(using: .utf8),
               let videoData = try? jsonDecoder.decode(
                VideoChannel.self,
                from: messageData
            ) {
                print("received video deets")
                self.createVideoChat(with: videoData.channel)
            }
        }
    }
}
