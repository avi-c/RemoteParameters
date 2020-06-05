//
//  RemoteParameters.swift
//  Porsche
//
//  Created by Avi Cieplinski on 9/18/18.
//  Copyright © 2018 Avi Cieplinski. All rights reserved.
//

import Foundation
import Parameters
import MultipeerConnectivity

struct RemoteParameterAttribute {
    static let name = "RemoteParameterAttributeName"
}

public class RemoteParameters: NSObject, RemoteParameterSessionDelegate {

    var remoteParameterSession: RemoteParameterSession?
    var remoteParameterAdvertiser: RemoteParameterAdvertiser?

    public weak var dataSource: RemoteParametersDataSource?

    public init(serviceName: String, appDisplayName: String) {
        let myDevice = UIDevice.current.name
        let peerID = MCPeerID(displayName: "\(appDisplayName) on \(myDevice)")
        let myself = RemoteParameterReceiver(peerID: peerID)
        remoteParameterSession = RemoteParameterSession(myself: myself)
        remoteParameterAdvertiser = RemoteParameterAdvertiser(myself: myself, serviceType: serviceName, displayName: appDisplayName, session: remoteParameterSession!.session)
        super.init()
        remoteParameterSession?.delegate = self
        remoteParameterAdvertiser?.start()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func session(_ session: RemoteParameterSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        if state == .connected {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                if let parameterCategories = self.dataSource?.remoteParameterList(self) {
                    if let session = self.remoteParameterSession?.session, let encodedData = try? JSONEncoder().encode(parameterCategories) {
                        print("\(encodedData.count)")
                        do {
                            try session.send(encodedData, toPeers: session.connectedPeers, with: .unreliable)
                        } catch let error {
                            NSLog("%@", "Error for sending: \(error)")
                        }
                    }
                }
            }
        }
    }

    public func session(_ session: RemoteParameterSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print("session with peer: \(peerID) didReceiveData")

        // reconstitute the parameters
        do {
            let decodedParameters = try JSONDecoder().decode([ParameterCategory].self, from: data)
            DispatchQueue.main.async {
                self.dataSource?.remoteParametersDidUpdate(self, parameters: decodedParameters)
            }
        } catch {
            print("deserialization error: \(error)")
        }
    }
}

public protocol RemoteParametersDataSource: class {
    func remoteParameterList(_ remoteParameters: RemoteParameters) -> [ParameterCategory]
    func remoteParametersDidUpdate(_ remoteParameters: RemoteParameters, parameters: [ParameterCategory])
}
