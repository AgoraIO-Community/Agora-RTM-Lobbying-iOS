//
//  AgoraRTM+ErrorExtensions.swift
//  Agora-RTM-iOS
//
//  Created by Max Cobb on 18/11/2020.
//

import AgoraRtmKit

extension AgoraRtmLeaveChannelErrorCode {
    var describe: String {
        switch self {
        case .ok:
            return "ok"
        case .failure:
            return "failure"
        case .rejected:
            return "rejected"
        case .notInChannel:
            return "notInChannel"
        case .notInitialized:
            return "notInitialized"
        case .notLoggedIn:
            return "notLoggedIn"
        @unknown default:
            return "unknown value"
        }
    }
}

extension AgoraRtmJoinChannelErrorCode {
    /// Method added to make debugging easier to understand
    /// - Returns: string value telling you what type of error you have
    var describe: String {
        switch self {
        case .channelErrorOk:
            return "channelErrorOk"
        case .channelErrorFailure:
            return "channelErrorFailure"
        case .channelErrorRejected:
            return "channelErrorRejected"
        case .channelErrorInvalidArgument:
            return "channelErrorInvalidArgument"
        case .channelErrorTimeout:
            return "channelErrorTimeout"
        case .channelErrorExceedLimit:
            return "channelErrorExceedLimit"
        case .channelErrorAlreadyJoined:
            return "channelErrorAlreadyJoined"
        case .channelErrorTooOften:
            return "channelErrorTooOften"
        case .sameChannelErrorTooOften:
            return "sameChannelErrorTooOften"
        case .channelErrorNotInitialized:
            return "channelErrorNotInitialized"
        case .channelErrorNotLoggedIn:
            return "channelErrorNotLoggedIn"
        @unknown default:
            return "unknown reason"
        }
    }
}

extension AgoraRtmConnectionChangeReason {
    var describe: String {
        switch self {
        case .login:
            return "login"
        case .loginSuccess:
            return "loginSuccess"
        case .loginFailure:
            return "loginFailure"
        case .loginTimeout:
            return "loginTimeout"
        case .interrupted:
            return "interrupted"
        case .logout:
            return "logout"
        case .bannedByServer:
            return "bannedByServer"
        case .remoteLogin:
            return "remoteLogin"
        @unknown default:
            return "unknown"
        }
    }
}

extension AgoraRtmConnectionState {
    var describe: String {
        switch self {
        case .disconnected:
            return "disconnected"
        case .connecting:
            return "connecting"
        case .connected:
            return "connected"
        case .reconnecting:
            return "reconnecting"
        case .aborted:
            return "aborted"
        @unknown default:
            return "unknown"
        }
    }
}
