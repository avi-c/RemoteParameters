//
//  RemoteParameterAdvertiser.swift
//  Porsche
//
//  Created by Avi Cieplinski on 10/1/18.
//  Copyright © 2018 Mapbox. All rights reserved.
//

import MultipeerConnectivity
import os.signpost
import UIKit

class RemoteParameterAdvertiser: NSObject {

    private var serviceAdvertiser: MCNearbyServiceAdvertiser?
    let myself: RemoteParameterReceiver
    let session: MCSession
    let serviceType: String
    let displayName: String

    init(myself: RemoteParameterReceiver, serviceType: String, displayName: String, session: MCSession) {
        self.myself = myself
        self.session = session
        self.serviceType = serviceType
        self.displayName = displayName
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func start() {
        self.startAdvertising()
    }

    func startAdvertising() {
        guard serviceAdvertiser == nil else { return } // already advertising

        let discoveryInfo: [String: String] = ["Remote Parameters Server": displayName]
        let advertiser = MCNearbyServiceAdvertiser(peer: myself.peerID,
                                                   discoveryInfo: discoveryInfo,
                                                   serviceType: self.serviceType)
        advertiser.delegate = self
        advertiser.startAdvertisingPeer()
        serviceAdvertiser = advertiser
    }

    func stopAdvertising() {
        if #available(iOS 12.0, *) {
            os_log(.info, "stop advertising")
        } else {
            print("stop advertising")
        }
        serviceAdvertiser?.stopAdvertisingPeer()
        serviceAdvertiser = nil
    }
}

extension RemoteParameterAdvertiser: MCNearbyServiceAdvertiserDelegate {
    // MARK: MCNearbyServiceAdvertiserDelegate
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser,
                    didReceiveInvitationFromPeer peerID: MCPeerID,
                    withContext context: Data?,
                    invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        if #available(iOS 12.0, *) {
            os_log(.info, "got request from %@, accepting!", peerID)
        } else {
            print("got request from \(peerID), accepting!")
        }
        invitationHandler(true, self.session)
    }
}
