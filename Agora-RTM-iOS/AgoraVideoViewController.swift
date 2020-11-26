//
//  AgoraVideoViewController.swift
//  Agora-RTM-iOS
//
//  Created by Max Cobb on 24/11/2020.
//

import UIKit

import SwiftSpinner
import Agora_UIKit

extension ViewController: UIAdaptivePresentationControllerDelegate {

    func createVideoChat(with name: String) {
        SwiftSpinner.hide()
        let videoVC = AgoraVideoViewController(appId: ViewController.agoraAppId, channel: name)
        videoVC.transitioningDelegate = self
        videoVC.onDoneBlock = {
            self.leaveBreakout()
            videoVC.agoraVideoView?.exit()
        }
        videoVC.presentationController?.delegate = self
        self.present(videoVC, animated: true)
    }

    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        guard let videoViewer = (presentationController.presentedViewController as? AgoraVideoViewController) else {
            return
        }
        videoViewer.onDoneBlock?()
    }
}

class AgoraVideoViewController: UIViewController {
    var channel: String
    var appId: String
    var token: String?
    var onDoneBlock: (() -> Void)?
    var agoraVideoView: AgoraVideoViewer?
    init(appId: String, channel: String, token: String? = nil) {
        self.channel = channel
        self.appId = appId
        self.token = token
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let agoraView = AgoraVideoViewer(connectionData: AgoraConnectionData(appId: appId, appToken: token), viewController: self, style: .grid)
        agoraView.fills(view: self.view)

        agoraView.joinChannel(channel: channel)
        self.agoraVideoView = agoraView
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        self.onDoneBlock?()
        super.dismiss(animated: flag, completion: completion)
    }
}
