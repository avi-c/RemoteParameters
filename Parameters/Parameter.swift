//
//  Parameter.swift
//  Parameters
//
//  Created by Avi Cieplinski on 1/29/19.
//  Copyright © 2019 Mapbox. All rights reserved.
//

import Foundation
import UIKit

public struct ParameterSet: Codable {
    public let version: String // For versioned parameters/preferences
    public let source: String // Local Prefs, Remote Prefs, Configuration Server, etc.
    public let categories: [ParameterCategory]

    public var allParameters: [Parameter] {
        var entries = [Parameter]()

        self.categories.forEach { category in
            category.entries.forEach { parameter in
                entries.append(parameter)
            }
        }

        return entries
    }

    public var hashedParameters: [String: Parameter] {
        var entries = [String: Parameter]()

        self.categories.forEach { category in
            category.entries.forEach { parameter in
                entries[parameter.uuid] = parameter
            }
        }

        return entries
    }

    enum CodingKeys: String, CodingKey {
        case version
        case source
        case categories
    }

    public init(version: String, source: String, categories: [ParameterCategory]) {
        self.version = version
        self.source = source
        self.categories = categories
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.version = try container.decode(String.self, forKey: .version)
        self.source = try container.decode(String.self, forKey: .source)
        self.categories = try container.decode([ParameterCategory].self, forKey: .categories)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(version, forKey: .version)
        try container.encode(source, forKey: .source)
        try container.encode(categories, forKey: .categories)
    }
}

public struct ParameterCategory: Codable {
    public let name: String
    public let entries: [Parameter]
    public let isDebug: Bool
    public var disclosed: Bool

    enum CodingKeys: String, CodingKey {
        case name
        case entries
        case isDebug
        case disclosed
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        let codableParameters = try container.decode([CodableParameter].self, forKey: .entries)

        self.entries = codableParameters.map({ return $0.value })
        self.isDebug = try container.decode(Bool.self, forKey: .isDebug)
        self.disclosed = try container.decode(Bool.self, forKey: .disclosed)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        let codableParameters = entries.map { CodableParameter(parameter: $0) }
        try container.encode(codableParameters, forKey: .entries)
        try container.encode(isDebug, forKey: .isDebug)
        try container.encode(disclosed, forKey: .disclosed)
    }

    public init(name: String, entries: [Parameter], isDebug: Bool = false, disclosed: Bool = false) {
        self.name = name
        self.entries = entries
        self.isDebug = isDebug
        self.disclosed = disclosed
    }
}

public enum ParameterDataType: Int, Codable {
    case bool = 0
    case int = 1
    case float = 2
    case string = 3
    case color = 4
    case segmented = 5
    case staticText = 6
    case picker = 7
}

public protocol Parameter {
    var uuid: String { get }
    var category: String { get set }
    var name: String { get set }
    var dataType: ParameterDataType { get set }
    var isNumeric: Bool { get }

    var observers: [ParameterObserver] { get }
    func add(observer: ParameterObserver)
    func remove(observer: ParameterObserver)

    func revertToDefault()
}

public protocol ParameterObserver {
    var identifier: String { get }

    func didUpdate(parameter: Parameter)
}

public class BaseParameter: NSObject {

    public var observers = [ParameterObserver]()

    public func add(observer: ParameterObserver) {
        observers.append(observer)
    }

    public func remove(observer: ParameterObserver) {
        observers.removeAll { existingObserver -> Bool in
            return existingObserver.identifier == observer.identifier
        }
    }
}

public class BoolParameter: BaseParameter, Parameter, Codable {
    public var uuid: String { return category + "-" + name }
    public var dataType: ParameterDataType = .bool
    public var persisted: Bool = true
    public var category: String = ""
    public var name: String = ""
    public var isNumeric: Bool = false
    public var value: Bool = false {
        didSet {
            self.observers.forEach { (observer) in
                observer.didUpdate(parameter: self)
            }
        }
    }
    public var defaultValue: Bool = false {
        didSet {
            revertToDefault()
        }
    }

    enum CodingKeys: String, CodingKey {
        case uuid
        case dataType
        case category
        case name
        case value
        case defaultValue
    }

    override public init() {
        super.init()
        revertToDefault()
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.dataType = .bool
        self.category = try container.decode(String.self, forKey: .category)
        self.name = try container.decode(String.self, forKey: .name)
        self.value = try container.decode(Bool.self, forKey: .value)
        self.defaultValue = try container.decode(Bool.self, forKey: .defaultValue)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(uuid, forKey: .uuid)
        try container.encode(dataType.rawValue, forKey: .dataType)
        try container.encode(category, forKey: .category)
        try container.encode(name, forKey: .name)
        try container.encode(value, forKey: .value)
        try container.encode(defaultValue, forKey: .defaultValue)
    }

    public func revertToDefault() {
        self.value = defaultValue
    }
}

public class FloatParameter: BaseParameter, Parameter, Codable {
    public var uuid: String { return category + "-" + name }
    public var dataType: ParameterDataType = .float
    public var persisted: Bool = true
    public var category: String = ""
    public var name: String = ""
    public var isNumeric: Bool = true
    public var minValue: Float = Float(0)
    public var maxValue: Float = Float(10)
    public var stepValue: Float = Float(0.5)
    public var precision: Float = Float(0.1)
    public var value: Float = Float(0.0) {
        didSet {
            observers.forEach { (observer) in
                observer.didUpdate(parameter: self)
            }
        }
    }

    public var defaultValue: Float = Float(0) {
        didSet {
            revertToDefault()
        }
    }

    enum CodingKeys: String, CodingKey {
        case uuid
        case dataType
        case category
        case name
        case minValue
        case maxValue
        case stepValue
        case precision
        case value
        case defaultValue
    }

    override public init() {
        super.init()
        revertToDefault()
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.dataType = .float
        self.category = try container.decode(String.self, forKey: .category)
        self.name = try container.decode(String.self, forKey: .name)
        self.minValue = try container.decode(Float.self, forKey: .minValue)
        self.maxValue = try container.decode(Float.self, forKey: .maxValue)
        self.stepValue = try container.decode(Float.self, forKey: .stepValue)
        self.precision = try container.decode(Float.self, forKey: .precision)
        self.value = try container.decode(Float.self, forKey: .value)
        self.defaultValue = try container.decode(Float.self, forKey: .defaultValue)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(uuid, forKey: .uuid)
        try container.encode(dataType.rawValue, forKey: .dataType)
        try container.encode(category, forKey: .category)
        try container.encode(name, forKey: .name)
        try container.encode(minValue, forKey: .minValue)
        try container.encode(maxValue, forKey: .maxValue)
        try container.encode(stepValue, forKey: .stepValue)
        try container.encode(precision, forKey: .precision)
        try container.encode(value, forKey: .value)
        try container.encode(defaultValue, forKey: .defaultValue)
    }

    public func revertToDefault() {
        value = defaultValue
    }
}

public class IntParameter: BaseParameter, Parameter, Codable {
    public var uuid: String { return category + "-" + name }
    public var dataType: ParameterDataType = .int
    public var persisted: Bool = true
    public var category: String = ""
    public var name: String = ""
    public var isNumeric: Bool = true
    public var minValue: Int = Int(0)
    public var maxValue: Int = Int(10)
    public var stepValue: Int = Int(1)
    public var value: Int = Int(0) {
        didSet {
            observers.forEach { (observer) in
                observer.didUpdate(parameter: self)
            }
        }
    }
    public var defaultValue: Int = Int(0) {
        didSet {
            revertToDefault()
        }
    }

    enum CodingKeys: String, CodingKey {
        case uuid
        case dataType
        case category
        case name
        case minValue
        case maxValue
        case stepValue
        case precision
        case value
        case defaultValue
    }

    override public init() {
        super.init()
        revertToDefault()
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.dataType = .int
        self.category = try container.decode(String.self, forKey: .category)
        self.name = try container.decode(String.self, forKey: .name)
        self.minValue = try container.decode(Int.self, forKey: .minValue)
        self.maxValue = try container.decode(Int.self, forKey: .maxValue)
        self.stepValue = try container.decode(Int.self, forKey: .stepValue)
        self.value = try container.decode(Int.self, forKey: .value)
        self.defaultValue = try container.decode(Int.self, forKey: .defaultValue)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(uuid, forKey: .uuid)
        try container.encode(dataType.rawValue, forKey: .dataType)
        try container.encode(category, forKey: .category)
        try container.encode(name, forKey: .name)
        try container.encode(minValue, forKey: .minValue)
        try container.encode(maxValue, forKey: .maxValue)
        try container.encode(stepValue, forKey: .stepValue)
        try container.encode(value, forKey: .value)
        try container.encode(defaultValue, forKey: .defaultValue)
    }

    public func revertToDefault() {
        value = defaultValue
    }
}

public class PickerItem: NSObject, Codable {
    public let displayName: String // String to display in the picker UI, e.g. name of a server
    public let value: String? // An optional value corresponding to the name, e.g. IP Address of the named server

    enum CodingKeys: String, CodingKey {
        case displayName
        case value
    }

    public init(displayName: String, value: String?) {
        self.displayName = displayName
        self.value = value
        super.init()
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.displayName = try container.decode(String.self, forKey: .displayName)
        self.value = try container.decodeIfPresent(String.self, forKey: .value)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(displayName, forKey: .displayName)
        try container.encodeIfPresent(value, forKey: .value)
    }
}

public class PickerParameter: BaseParameter, Parameter, Codable {
    public var uuid: String { return category + "-" + name }
    public var dataType: ParameterDataType = .picker
    public var persisted: Bool = true
    public var category: String = ""
    public var name: String = ""
    public var isNumeric: Bool = false
    public var pickerItems: [PickerItem]?   // List of items
    public var minValue: Int = Int(0)
    public var maxValue: Int = Int(10)
    public var stepValue: Int = Int(1)
    public var value: Int = Int(0) {
        didSet {
            observers.forEach { (observer) in
                observer.didUpdate(parameter: self)
            }
        }
    }

    public var defaultValue: Int = Int(0) {
        didSet {
            revertToDefault()
        }
    }

    enum CodingKeys: String, CodingKey {
        case uuid
        case dataType
        case category
        case name
        case pickerItems
        case pickerValues
        case minValue
        case maxValue
        case stepValue
        case value
        case defaultValue
    }

    override public init() {
        super.init()
        revertToDefault()
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.dataType = .picker
        self.category = try container.decode(String.self, forKey: .category)
        self.name = try container.decode(String.self, forKey: .name)
        self.pickerItems = try container.decodeIfPresent([PickerItem].self, forKey: .pickerItems)
        self.minValue = try container.decode(Int.self, forKey: .minValue)
        self.maxValue = try container.decode(Int.self, forKey: .maxValue)
        self.stepValue = try container.decode(Int.self, forKey: .stepValue)
        self.value = try container.decode(Int.self, forKey: .value)
        self.defaultValue = try container.decode(Int.self, forKey: .defaultValue)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(uuid, forKey: .uuid)
        try container.encode(dataType.rawValue, forKey: .dataType)
        try container.encode(category, forKey: .category)
        try container.encode(name, forKey: .name)
        try container.encode(pickerItems, forKey: .pickerItems)
        try container.encode(minValue, forKey: .minValue)
        try container.encode(maxValue, forKey: .maxValue)
        try container.encode(stepValue, forKey: .stepValue)
        try container.encode(value, forKey: .value)
        try container.encode(defaultValue, forKey: .defaultValue)
    }

    public func revertToDefault() {
        value = defaultValue
    }
}

extension PickerParameter: UIPickerViewDataSource {

    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerItems?.count ?? 0
    }
}

extension PickerParameter: UIPickerViewDelegate {

    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let pickerItems = pickerItems, component == 0, row < pickerItems.count else { return nil }
        return pickerItems[row].displayName
    }

    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        value = row
    }

    public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = view as? UILabel ?? UILabel()

        label.text = self.pickerView(pickerView, titleForRow: row, forComponent: component)
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        label.textAlignment = .center

        return label
    }

    public func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 36.0
    }
}

public class StringParameter: BaseParameter, Parameter, Codable {
    public var uuid: String { return category + "-" + name }
    public var dataType: ParameterDataType = .string
    public var persisted: Bool = true
    public var category: String = ""
    public var name: String = ""
    public var isNumeric: Bool = false
    public var value: String = "" {
        didSet {
            observers.forEach { (observer) in
                observer.didUpdate(parameter: self)
            }
        }
    }

    enum CodingKeys: String, CodingKey {
        case uuid
        case dataType
        case category
        case name
        case value
        case defaultValue
    }

    override public init() {
        super.init()
        revertToDefault()
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.dataType = .string
        self.category = try container.decode(String.self, forKey: .category)
        self.name = try container.decode(String.self, forKey: .name)
        self.value = try container.decode(String.self, forKey: .value)
        self.defaultValue = try container.decode(String.self, forKey: .defaultValue)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(uuid, forKey: .uuid)
        try container.encode(dataType.rawValue, forKey: .dataType)
        try container.encode(category, forKey: .category)
        try container.encode(name, forKey: .name)
        try container.encode(value, forKey: .value)
        try container.encode(defaultValue, forKey: .defaultValue)
    }

    public var defaultValue: String = "" {
        didSet {
            revertToDefault()
        }
    }

    public func revertToDefault() {
        value = defaultValue
    }
}

public class ColorParameter: BaseParameter, Parameter, Codable {
    public var uuid: String { return category + "-" + name }
    public var dataType: ParameterDataType = .color
    public var persisted: Bool = true
    public var category: String = ""
    public var name: String = ""
    public var isNumeric: Bool = false
    public var value: UIColor = UIColor.white {
        didSet {
            observers.forEach { (observer) in
                observer.didUpdate(parameter: self)
            }
        }
    }
    public var defaultValue: UIColor = UIColor.white {
        didSet {
            revertToDefault()
        }
    }

    enum CodingKeys: String, CodingKey {
        case uuid
        case dataType
        case category
        case name
        case value
        case defaultValue
    }

    override public init() {
        super.init()
        revertToDefault()
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.dataType = .color
        self.category = try container.decode(String.self, forKey: .category)
        self.name = try container.decode(String.self, forKey: .name)
        let stringValue = try container.decode(String.self, forKey: .value)
        self.value = UIColor(hexString: stringValue)

        let stringDefaultValue = try container.decode(String.self, forKey: .defaultValue)
        self.defaultValue = UIColor(hexString: stringDefaultValue)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(uuid, forKey: .uuid)
        try container.encode(dataType.rawValue, forKey: .dataType)
        try container.encode(category, forKey: .category)
        try container.encode(name, forKey: .name)
        if let stringValue = value.toHex {
            try container.encode(stringValue, forKey: .value)
        }

        if let stringValue = defaultValue.toHex {
            try container.encode(stringValue, forKey: .defaultValue)
        }
    }

    public func revertToDefault() {
        value = defaultValue
    }
}

public class SegmentedParameter: BaseParameter, Parameter, Codable {
    public var uuid: String { return category + "-" + name }
    public var dataType: ParameterDataType = .segmented
    public var persisted: Bool = true
    public var category: String = ""
    public var name: String = ""
    public var isNumeric: Bool = false
    public var titles: [String]!
    public var value: Int = 0 {
       didSet {
            observers.forEach { (observer) in
                observer.didUpdate(parameter: self)
            }
        }
    }
    public var defaultValue: Int = 0 {
        didSet {
            revertToDefault()
        }
    }

    enum CodingKeys: String, CodingKey {
        case uuid
        case dataType
        case category
        case name
        case titles
        case value
        case defaultValue
    }

    override public init() {
        super.init()
        revertToDefault()
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.dataType = .segmented
        self.category = try container.decode(String.self, forKey: .category)
        self.name = try container.decode(String.self, forKey: .name)
        self.value = try container.decode(Int.self, forKey: .value)
        self.defaultValue = try container.decode(Int.self, forKey: .defaultValue)
        self.titles = try container.decode([String].self, forKey: .titles)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(uuid, forKey: .uuid)
        try container.encode(dataType.rawValue, forKey: .dataType)
        try container.encode(category, forKey: .category)
        try container.encode(name, forKey: .name)
        try container.encode(value, forKey: .value)
        try container.encode(defaultValue, forKey: .defaultValue)
        try container.encode(titles, forKey: .titles)
    }


    init(titles: [String]) {
        self.titles = titles
        super.init()
        revertToDefault()
    }

    public func revertToDefault() {
        value = defaultValue
    }
}

public class StaticTextParameter: BaseParameter, Parameter, Codable {

    public var uuid: String { return category + "-" + name }
    public var dataType: ParameterDataType = .staticText
    public var persisted: Bool = true
    public var category: String = ""
    public var name: String = ""
    public var isNumeric: Bool = false
    public var value: String = "" {
        didSet {
            observers.forEach { (observer) in
                observer.didUpdate(parameter: self)
            }
        }
    }

    enum CodingKeys: String, CodingKey {
        case uuid
        case dataType
        case category
        case name
        case value
    }

    override public init() {
        super.init()
        revertToDefault()
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.dataType = .staticText
        self.category = try container.decode(String.self, forKey: .category)
        self.name = try container.decode(String.self, forKey: .name)
        self.value = try container.decode(String.self, forKey: .value)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(uuid, forKey: .uuid)
        try container.encode(dataType.rawValue, forKey: .dataType)
        try container.encode(category, forKey: .category)
        try container.encode(name, forKey: .name)
        try container.encode(value, forKey: .value)
    }

    public func revertToDefault() {
    }
}
