//
//  RemoteParameterSession.swift
//  Portfolio
//
//  Created by Avi Cieplinski on 9/18/18.
//  Copyright © 2018 Avi Cieplinski. All rights reserved.
//

import MultipeerConnectivity
import UIKit
import os.signpost

public class RemoteParameterSession: NSObject, MCSessionDelegate {

    let myself: RemoteParameterReceiver
    public let session: MCSession
    public weak var delegate: RemoteParameterSessionDelegate?

    public init(myself: RemoteParameterReceiver) {
        self.myself = myself
        self.session = MCSession(peer: myself.peerID, securityIdentity: nil, encryptionPreference: .optional)

        super.init()
        self.session.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func receive(data: Data, from peerID: MCPeerID) {

    }

    // MARK: MCSessionDelegate
    public func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        self.delegate?.session(self, peer: peerID, didChange: state)
    }

    public func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        self.delegate?.session(self, didReceive: data, fromPeer: peerID)
    }

    public func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        print("session with peer: \(peerID) didReceiveStream: \(streamName)")
    }

    public func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        print("session with peer: \(peerID) didStartReceivingResource: \(resourceName)")
    }

    public func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        print("session with peer: \(peerID) didFinishReceivingResourceWithName: \(resourceName)")
    }
}

public protocol RemoteParameterSessionDelegate: class {
    func session(_ session: RemoteParameterSession, peer peerID: MCPeerID, didChange state: MCSessionState)
    func session(_ session: RemoteParameterSession, didReceive data: Data, fromPeer peerID: MCPeerID)
}
