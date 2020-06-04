//
//  Parameter.swift
//  Apex
//
//  Created by Avi Cieplinski on 1/29/19.
//  Copyright © 2019 Mapbox. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

public enum ParameterDataType: Int, Decodable {
    case bool = 0
    case int = 1
    case float = 2
    case string = 3
    case color = 4
}

public protocol Parameter {
    var uuid: String { get }
    var category: String { get set }
    var name: String { get set }
    var dataType: ParameterDataType { get set }
    var dictionaryRepresentation: [String: Any?] { get set }
    var persisted: Bool { get set }

    var isNumeric: Bool { get }
    func revertToDefault()
}

public class BoolParameter: NSObject, Parameter {
    public var dictionaryRepresentation: [String: Any?] {
        get {
            var parameterDictionary: [String: Any?] = [:]
            parameterDictionary["uuid"] = uuid
            parameterDictionary["category"] = category
            parameterDictionary["name"] = name
            parameterDictionary["dataType"] = dataType.rawValue
            parameterDictionary["value"] = relay.value
            parameterDictionary["defaultValue"] = defaultValue
            return parameterDictionary
        }

        set {
            self.category = newValue["category"] as? String ?? ""
            self.name = newValue["name"] as? String ?? ""
            self.defaultValue = newValue["defaultValue"] as? Bool ?? false
            let value = newValue["value"] as? Bool ?? false
            relay.accept(value)
        }
    }

    public var uuid: String { return category + "-" + name }
    public var dataType: ParameterDataType = .bool
    public var category: String = ""
    public var name: String = ""
    public var defaultValue: Bool = false
    public var relay: BehaviorRelay<Bool> = BehaviorRelay<Bool>(value: false)
    public var persisted: Bool = true

    public override init() {
        super.init()
        revertToDefault()
    }

    public var isNumeric: Bool = false

    public func revertToDefault() {
        relay.accept(defaultValue)
    }
}

public class FloatParameter: NSObject, Parameter {
    public var uuid: String { return category + "-" + name }
    public var dataType: ParameterDataType = .float
    public var category: String = ""
    public var name: String = ""
    public var relay: BehaviorRelay<Float> = BehaviorRelay<Float>(value: 0)
    public var persisted: Bool = true
    public var minValue: Float = Float(0)
    public var maxValue: Float = Float(10)
    public var stepValue: Float = Float(0.5)
    public var precision: Float = Float(0.1)
    public var defaultValue: Float = Float(0)

    public override init() {
        super.init()
        revertToDefault()
    }

    public var dictionaryRepresentation: [String: Any?] {
        get {
            var parameterDictionary: [String: Any?] = [:]
            parameterDictionary["uuid"] = uuid
            parameterDictionary["category"] = category
            parameterDictionary["name"] = name
            parameterDictionary["dataType"] = dataType.rawValue
            parameterDictionary["value"] = relay.value
            parameterDictionary["minValue"] = minValue
            parameterDictionary["maxValue"] = maxValue
            parameterDictionary["stepValue"] = stepValue
            parameterDictionary["defaultValue"] = defaultValue
            parameterDictionary["precision"] = precision
            return parameterDictionary
        }

        set {
            self.category = newValue["category"] as? String ?? ""
            self.name = newValue["name"] as? String ?? ""

            self.minValue = newValue["minValue"] as? Float ?? 0
            self.maxValue = newValue["maxValue"] as? Float ?? 1
            self.stepValue = newValue["stepValue"] as? Float ?? 1
            let value = newValue["value"] as? Float ?? 0.0
            self.defaultValue = newValue["defaultValue"] as? Float ?? value
            self.precision = newValue["precision"] as? Float ?? precision

            relay.accept(value)
        }
    }

    public var isNumeric: Bool = true

    public func revertToDefault() {
        relay.accept(defaultValue)
    }
}

public class IntParameter: NSObject, Parameter {
    public var uuid: String { return category + "-" + name }
    public var dataType: ParameterDataType = .int
    public var category: String = ""
    public var name: String = ""
    public var relay: BehaviorRelay<Int> = BehaviorRelay<Int>(value: 0)
    public var persisted: Bool = true
    public var minValue: Int = Int(0)
    public var maxValue: Int = Int(10)
    public var stepValue: Int = Int(1)
    public var defaultValue: Int = Int(0)

    public override init() {
        super.init()
        revertToDefault()
    }

    public var dictionaryRepresentation: [String: Any?] {
        get {
            var parameterDictionary: [String: Any?] = [:]
            parameterDictionary["uuid"] = uuid
            parameterDictionary["category"] = category
            parameterDictionary["name"] = name
            parameterDictionary["dataType"] = dataType.rawValue
            parameterDictionary["value"] = relay.value
            parameterDictionary["minValue"] = minValue
            parameterDictionary["maxValue"] = maxValue
            parameterDictionary["stepValue"] = stepValue
            parameterDictionary["defaultValue"] = defaultValue
            return parameterDictionary
        }

        set {
            self.category = newValue["category"] as? String ?? ""
            self.name = newValue["name"] as? String ?? ""
            self.minValue = newValue["minValue"] as? Int ?? 0
            self.maxValue = newValue["maxValue"] as? Int ?? 1
            self.stepValue = newValue["stepValue"] as? Int ?? 1
            let value = newValue["value"] as? Int ?? 0
            self.defaultValue = newValue["defaultValue"] as? Int ?? value
            relay.accept(value)
        }
    }

    public var isNumeric: Bool = true

    public func revertToDefault() {
        relay.accept(defaultValue)
    }
}

public class StringParameter: NSObject, Parameter {
    public var dictionaryRepresentation: [String: Any?] {
        get {
            var parameterDictionary: [String: Any?] = [:]
            parameterDictionary["uuid"] = uuid
            parameterDictionary["category"] = category
            parameterDictionary["name"] = name
            parameterDictionary["dataType"] = dataType.rawValue
            parameterDictionary["value"] = relay.value
            parameterDictionary["defaultValue"] = defaultValue
            return parameterDictionary
        }

        set {
            self.category = newValue["category"] as? String ?? ""
            self.name = newValue["name"] as? String ?? ""
            self.defaultValue = newValue["defaultValue"] as? String ?? ""
            let value = newValue["value"] as? String ?? ""
            relay.accept(value)
        }
    }

    public var uuid: String { return category + "-" + name }
    public var dataType: ParameterDataType = .string
    public var category: String = ""
    public var name: String = ""
    public var defaultValue: String = ""
    public var relay: BehaviorRelay<String> = BehaviorRelay<String>(value: "")
    public var persisted: Bool = true

    public override init() {
        super.init()
        revertToDefault()
    }

    public var isNumeric: Bool = false

    public func revertToDefault() {
        relay.accept(defaultValue)
    }
}

public class ColorParameter: NSObject, Parameter {
    public var dictionaryRepresentation: [String: Any?] {
        get {
            var parameterDictionary: [String: Any?] = [:]
            parameterDictionary["uuid"] = uuid
            parameterDictionary["category"] = category
            parameterDictionary["name"] = name
            parameterDictionary["dataType"] = dataType.rawValue
            parameterDictionary["value"] = relay.value.toHex(alpha: true)
            parameterDictionary["defaultValue"] = defaultValue.toHex(alpha: true)
            return parameterDictionary
        }

        set {
            self.category = newValue["category"] as? String ?? ""
            self.name = newValue["name"] as? String ?? ""
            self.defaultValue = UIColor.white
            if let defaultStringValue = newValue["defaultValue"] as? String {
                self.defaultValue = UIColor.init(hexString: defaultStringValue)
            }

            var value = UIColor.white
            if let stringValue = newValue["value"] as? String {
                value = UIColor.init(hexString: stringValue)
            }
            relay.accept(value)
        }
    }

    public var uuid: String { return category + "-" + name }
    public var dataType: ParameterDataType = .color
    public var category: String = ""
    public var name: String = ""
    public var defaultValue: UIColor = UIColor.white
    public var relay: BehaviorRelay<UIColor> = BehaviorRelay<UIColor>(value: UIColor.white)
    public var persisted: Bool = true

    public override init() {
        super.init()
        revertToDefault()
    }

    public var isNumeric: Bool = false

    public func revertToDefault() {
        relay.accept(defaultValue)
    }
}
