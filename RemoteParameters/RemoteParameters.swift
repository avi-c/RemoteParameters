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
                if let parameters = self.dataSource?.remoteParameterList(self) {
                    var codableParameters = [CodableParameter]()
                    parameters.forEach({ parameter in
                        let codableParam = CodableParameter(parameter: parameter)
                        codableParameters.append(codableParam)
                    })

                    if let session = self.remoteParameterSession?.session, let encodedData = try? JSONEncoder().encode(codableParameters) {
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
            let codedParameters = try JSONDecoder().decode(Array<CodableParameter>.self, from: data)
            var parameters: [String: Parameter] = [String: Parameter]()
            for codedParameter in codedParameters {
                var parameter: Parameter?

                if let parameterDataType = ParameterDataType(rawValue: codedParameter.dataType) {
                    switch parameterDataType {
                    case .bool:
                        let boolParameter = BoolParameter()
                        boolParameter.category = codedParameter.category
                        boolParameter.name = codedParameter.name
                        boolParameter.persisted = codedParameter.persisted
                        boolParameter.defaultValue = Bool(codedParameter.defaultValue)!
                        boolParameter.relay.accept(Bool(codedParameter.value)!)
                        parameter = boolParameter
                    case .float:
                        let floatParameter = FloatParameter()
                        floatParameter.category = codedParameter.category
                        floatParameter.name = codedParameter.name
                        floatParameter.persisted = codedParameter.persisted
                        floatParameter.defaultValue = Float(codedParameter.defaultValue)!
                        floatParameter.minValue = Float(codedParameter.minValue)!
                        floatParameter.maxValue = Float(codedParameter.maxValue)!
                        floatParameter.stepValue = Float(codedParameter.stepValue)!
                        floatParameter.precision = Float(codedParameter.precision)!
                        floatParameter.relay.accept(Float(codedParameter.value)!)
                        parameter = floatParameter
                    case .int:
                        let intParameter = IntParameter()
                        intParameter.category = codedParameter.category
                        intParameter.name = codedParameter.name
                        intParameter.persisted = codedParameter.persisted
                        intParameter.defaultValue = Int(codedParameter.defaultValue)!
                        intParameter.minValue = Int(codedParameter.minValue)!
                        intParameter.maxValue = Int(codedParameter.maxValue)!
                        intParameter.stepValue = Int(codedParameter.stepValue)!
                        intParameter.relay.accept(Int(codedParameter.value)!)
                        parameter = intParameter
                    case .string:
                        let stringParameter = StringParameter()
                        stringParameter.category = codedParameter.category
                        stringParameter.name = codedParameter.name
                        stringParameter.persisted = codedParameter.persisted
                        stringParameter.defaultValue = codedParameter.defaultValue
                        stringParameter.relay.accept(codedParameter.value)
                        parameter = stringParameter
                    case .color:
                        let colorParameter = ColorParameter()
                        colorParameter.category = codedParameter.category
                        colorParameter.name = codedParameter.name
                        colorParameter.persisted = codedParameter.persisted
                        colorParameter.defaultValue = UIColor.init(hexString: codedParameter.defaultValue)
                        let decodedColor = UIColor.init(hexString: codedParameter.value)
                        colorParameter.relay.accept(decodedColor)
                        parameter = colorParameter
                    }

                    if let parameter = parameter {
                        parameters[parameter.uuid] = parameter
                    }
                }
            }
            DispatchQueue.main.async {
                self.dataSource?.remoteParametersDidUpdate(self, parameters: parameters)
            }
        } catch {
            print("deserialization error: \(error)")
        }
    }
}

public protocol RemoteParametersDataSource: class {
    func remoteParameterList(_ remoteParameters: RemoteParameters) -> [Parameter]
    func remoteParametersDidUpdate(_ remoteParameters: RemoteParameters, parameters: [String : Parameter])
}
