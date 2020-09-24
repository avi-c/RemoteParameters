//
//  CodableParameter.swift
//  Apex
//
//  Created by Avi Cieplinski on 2/6/19.
//  Copyright © 2019 Mapbox. All rights reserved.
//

import UIKit

public class CodableParameter: Codable {

    private enum CodingKeys: String, CodingKey {
        case dataType
        case value
    }

    public var dataType: Int {
        return value.dataType.rawValue
    }
    
    public let value: Parameter

    init(parameter: Parameter) {
        self.value = parameter
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let decodedDataType = try container.decode(Int.self, forKey: .dataType)

        switch ParameterDataType(rawValue: decodedDataType) {
        case .bool:
            value = try container.decode(BoolParameter.self, forKey: .value)
        case .int:
            value = try container.decode(IntParameter.self, forKey: .value)
        case .float:
            value = try container.decode(FloatParameter.self, forKey: .value)
        case .string:
            value = try container.decode(StringParameter.self, forKey: .value)
        case .color:
            value = try container.decode(ColorParameter.self, forKey: .value)
        case .segmented:
            value = try container.decode(SegmentedParameter.self, forKey: .value)
        case .staticText:
            value = try container.decode(StaticTextParameter.self, forKey: .value)
        case .picker:
            value = try container.decode(PickerParameter.self, forKey: .value)
        case .staticLink:
            value = try container.decode(StaticLinkParameter.self, forKey: .value)
        case .none:
            value = BoolParameter()
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(dataType, forKey: .dataType)
        switch value.dataType {
        case .bool:
            try container.encode(value as! BoolParameter, forKey: .value)
        case .int:
            try container.encode(value as! IntParameter, forKey: .value)
        case .float:
            try container.encode(value as! FloatParameter, forKey: .value)
        case .string:
            try container.encode(value as! StringParameter, forKey: .value)
        case .color:
            try container.encode(value as! ColorParameter, forKey: .value)
        case .segmented:
            try container.encode(value as! SegmentedParameter, forKey: .value)
        case .staticText:
            try container.encode(value as! StaticTextParameter, forKey: .value)
        case .picker:
            try container.encode(value as! PickerParameter, forKey: .value)
        case .staticLink:
            try container.encode(value as! StaticLinkParameter, forKey: .value)
        }
    }
}
