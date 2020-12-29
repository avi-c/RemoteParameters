//
//  RemoteParameterReceiver.swift
//  Portfolio
//
//  Created by Avi Cieplinski on 9/18/18.
//  Copyright © 2018 Avi Cieplinski. All rights reserved.
//

import MultipeerConnectivity
import simd
import UIKit

public class RemoteParameterReceiver: Hashable {

    public static func == (lhs: RemoteParameterReceiver, rhs: RemoteParameterReceiver) -> Bool {
        return lhs.peerID == rhs.peerID
    }

    public func hash(into hasher: inout Hasher) {
        peerID.hash(into: &hasher)
    }

    public let peerID: MCPeerID

    public init(peerID: MCPeerID) {
        self.peerID = peerID
    }

    public init(username: String) {
        self.peerID = MCPeerID(displayName: username)
    }
}
