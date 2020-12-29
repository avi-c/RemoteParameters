//
//  RemoteParameterServer.swift
//  ParametersRemoteControl
//
//  Created by Avi Cieplinski on 9/18/18.
//  Copyright © 2018 Avi Cieplinski. All rights reserved.
//

import Foundation

public struct RemoteParameterServer: Hashable {
    public var name: String
    public var host: RemoteParameterReceiver

    public init(host: RemoteParameterReceiver, name: String? = nil) {
        self.host = host
        self.name = name ?? "\(host.peerID.displayName)"
    }
}
