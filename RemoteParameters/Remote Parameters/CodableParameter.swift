//
//  CodableParameter.swift
//  Apex
//
//  Created by Avi Cieplinski on 2/6/19.
//  Copyright © 2019 Mapbox. All rights reserved.
//

import UIKit

public struct CodableParameter: Codable {
    public var uuid: String
    public var dataType: Int
    public var category: String
    public var name: String
    public var persisted: Bool
    public var minValue: String
    public var maxValue: String
    public var stepValue: String
    public var precision: String
    public var defaultValue: String
    public var value: String

    public init(parameter: Parameter) {
        uuid = parameter.uuid
        dataType = parameter.dataType.rawValue
        category = parameter.category
        name = parameter.name
        persisted = parameter.persisted

        self.minValue = ""
        maxValue = ""
        stepValue = ""
        precision = ""
        defaultValue = ""
        value = ""

        switch parameter.dataType {
        case .bool:
            if let parameter = parameter as? BoolParameter {
                defaultValue = String(parameter.defaultValue)
                value = String(parameter.relay.value)
            }
        case .float:
            if let parameter = parameter as? FloatParameter {
                defaultValue = String(parameter.defaultValue)
                value = String(parameter.relay.value)
                minValue = String(parameter.minValue)
                maxValue = String(parameter.maxValue)
                precision = String(parameter.precision)
                stepValue = String(parameter.stepValue)
            }
        case .int:
            if let parameter = parameter as? IntParameter {
                defaultValue = String(parameter.defaultValue)
                value = String(parameter.relay.value)
                minValue = String(parameter.minValue)
                maxValue = String(parameter.maxValue)
                stepValue = String(parameter.stepValue)
            }
        case .string:
            if let parameter = parameter as? StringParameter {
                defaultValue = parameter.defaultValue
                value = parameter.relay.value
            }
        case .color:
            if let parameter = parameter as? ColorParameter {
                defaultValue = parameter.defaultValue.toHex(alpha: true)!
                value = parameter.relay.value.toHex(alpha: true)!
            }
        }
    }

    enum CodingKeys: String, CodingKey {
        case uuid
        case dataType
        case category
        case name
        case persisted
        case minValue
        case maxValue
        case stepValue
        case precision
        case defaultValue
        case value
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        uuid = try values.decode(String.self, forKey: .uuid)
        dataType = try values.decode(Int.self, forKey: .dataType)
        category = try values.decode(String.self, forKey: .category)
        name = try values.decode(String.self, forKey: .name)
        persisted = try values.decode(Bool.self, forKey: .persisted)

        minValue = ""
        maxValue = ""
        stepValue = ""
        precision = ""
        defaultValue = ""
        value = ""

        if let dataTypeEnumValue = ParameterDataType(rawValue: dataType) {
            switch dataTypeEnumValue {
            case .bool:
                defaultValue = try values.decode(String.self, forKey: .defaultValue)
                value = try values.decode(String.self, forKey: .value)
            case .float:
                defaultValue = try values.decode(String.self, forKey: .defaultValue)
                value = try values.decode(String.self, forKey: .value)
                minValue = try values.decode(String.self, forKey: .minValue)
                maxValue = try values.decode(String.self, forKey: .maxValue)
                stepValue = try values.decode(String.self, forKey: .stepValue)
                precision = try values.decode(String.self, forKey: .precision)
            case .int:
                defaultValue = try values.decode(String.self, forKey: .defaultValue)
                value = try values.decode(String.self, forKey: .value)
                minValue = try values.decode(String.self, forKey: .minValue)
                maxValue = try values.decode(String.self, forKey: .maxValue)
                stepValue = try values.decode(String.self, forKey: .stepValue)
            case .string:
                defaultValue = try values.decode(String.self, forKey: .defaultValue)
                value = try values.decode(String.self, forKey: .value)
            case .color:
                defaultValue = try values.decode(String.self, forKey: .defaultValue)
                value = try values.decode(String.self, forKey: .value)
            }
        }
    }
}
