//
//  ViewController+SendRTM.swift
//  Agora-RTM-iOS
//
//  Created by Max Cobb on 25/11/2020.
//

import AgoraRtmKit

class ChannelData: Codable {
    var channelName: String = ""
    var memberCount: Int = 0
    var memberLimit: Int = 2
    var seniors: Set<String>?
    init(channelName: String, memberCount: Int = 0, seniors: Set<String>? = nil) {
        self.channelName = channelName
        self.memberCount = memberCount
        self.seniors = seniors
    }
}

struct VideoChannel: Codable {
    var channel: String
}

extension ViewController {
    func send(message: String, to peers: [String]) {
        for peer in peers {
            self.agoraRTM.send(AgoraRtmMessage(text: message), toPeer: peer)
        }
    }

    func encodeObject<T>(_ object: T) -> String? where T : Encodable {
        let jsonEncoder = JSONEncoder()
        let jsonData = try! jsonEncoder.encode(object)
        return String(data: jsonData, encoding: String.Encoding.utf8)
    }
    func send<T>(encodableObj obj: T, to member: AgoraRtmMember) where T : Encodable {
        if let bodJson = encodeObject(obj) {
            self.send(message: bodJson, to: [member.userId])
        }
    }
    func send<T>(encodableObj obj: T, to channel: AgoraRtmChannel) where T : Encodable {
        if let bodJson = encodeObject(obj) {
            channel.send(AgoraRtmMessage(text: bodJson))
        }
    }
}
