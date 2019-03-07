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

// TODO
// 1. Remote Parameters

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
    public var defaultValue: Bool = false {
        didSet {
            revertToDefault()
        }
    }
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
    public var defaultValue: Float = Float(0) {
        didSet {
            revertToDefault()
        }
    }

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
    public var defaultValue: Int = Int(0) {
        didSet {
            revertToDefault()
        }
    }

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
    public var defaultValue: String = "" {
        didSet {
            revertToDefault()
        }
    }
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
    public var defaultValue: UIColor = UIColor.white {
        didSet {
            revertToDefault()
        }
    }
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

public class ParametersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    public weak var parametersViewControllerDelegate: ParametersViewControllerDelegate?
    var sortedGroups: [[String: [Parameter]]]?
    var parametersGroups: [String: [Parameter]]?
    public var parameters: [Parameter] = [Parameter]() {
        didSet {
            parametersGroups = [String: [Parameter]]()
            parameters.forEach { (parameter) in
                if var entries = parametersGroups?[parameter.category] {
                    entries.append(parameter)
                    parametersGroups?[parameter.category] = entries
                } else {
                    parametersGroups?[parameter.category] = [parameter]
                }
            }

            // get the sorted keys
            let sortedKeys = parametersGroups?.keys.sorted()
            var newValues: [[String: [Parameter]]] = [[String: [Parameter]]]()

            sortedKeys?.forEach({ (key) in
                let values = parametersGroups?[key]

                // sort the values by name
                let sortedValues = values?.sorted(by: { (p0, p1) -> Bool in
                    p0.name > p1.name
                })

                var newCategory: [String: [Parameter]] = [String: [Parameter]]()
                newCategory[key] = sortedValues
                newValues.append(newCategory)
            })
            sortedGroups = newValues
            tableView.reloadData()
        }
    }

    var selectedIndexPath: IndexPath?

    public func numberOfSections(in tableView: UITableView) -> Int {
        return sortedGroups?.count ?? 0
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sortedGroups = sortedGroups else { return 0 }
        return (sortedGroups[section].values.first?.count)!
    }

    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sortedGroups = sortedGroups else { return nil }
        return sortedGroups[section].keys.first
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell: UITableViewCell

        let parameter = self.parameter(for: indexPath)

        if let floatPref = parameter as? FloatParameter {
            if let floatParameterCellView = tableView.dequeueReusableCell(withIdentifier: "FloatParameterCell", for: indexPath) as? FloatParameterCellView {
                floatParameterCellView.parameter = floatPref
                cell = floatParameterCellView

                return cell
            }
        } else if let boolPref = parameter as? BoolParameter, let boolParametersCellView = tableView.dequeueReusableCell(withIdentifier: "BoolParameterCell", for: indexPath) as? BoolParameterCellView {
            boolParametersCellView.parameter = boolPref
            cell = boolParametersCellView

            return cell
        } else if let intPref = parameter as? IntParameter, let intParametersCellView = tableView.dequeueReusableCell(withIdentifier: "IntParameterCell", for: indexPath) as? IntParameterCellView {
            intParametersCellView.parameter = intPref
            cell = intParametersCellView

            return cell
        } else if let stringPref = parameter as? StringParameter, let stringParametersCellView = tableView.dequeueReusableCell(withIdentifier: "StringParameterCell", for: indexPath) as? StringParameterCellView {
            stringParametersCellView.parameter = stringPref
            cell = stringParametersCellView

            return cell
        } else if let colorPref = parameter as? ColorParameter, let colorParametersCellView = tableView.dequeueReusableCell(withIdentifier: "ColorParameterCell", for: indexPath) as? ColorParameterCellView {
            colorParametersCellView.parameter = colorPref
            cell = colorParametersCellView

            return cell
        }

        cell = tableView.dequeueReusableCell(withIdentifier: "ParameterCell", for: indexPath)
        cell.textLabel?.text = "Empty"
        return cell
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let parameter = self.parameter(for: indexPath) {
            if parameter.isNumeric {
                return 112
            } else if parameter.dataType == .string || parameter.dataType == .color {
                return 80
            }
        }

        return 44
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
    }

    let tableView: UITableView = UITableView()

    override public func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(tableView)

        self.view.backgroundColor = UIColor.lightGray

        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .done, target: self, action: #selector(self.doneWasTapped))

        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: "Revert", style: .plain, target: self, action: #selector(self.revertWasTapped))

        self.navigationItem.title = "Parameters"

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        tableView.heightAnchor.constraint(equalTo: self.view.heightAnchor).isActive = true
        tableView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        tableView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true

        tableView.dataSource = self
        tableView.delegate = self
        tableView.layer.cornerRadius = 10
        tableView.clipsToBounds = true

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ParameterCell")
        tableView.register(FloatParameterCellView.self, forCellReuseIdentifier: "FloatParameterCell")
        tableView.register(BoolParameterCellView.self, forCellReuseIdentifier: "BoolParameterCell")
        tableView.register(IntParameterCellView.self, forCellReuseIdentifier: "IntParameterCell")
        tableView.register(StringParameterCellView.self, forCellReuseIdentifier: "StringParameterCell")
        tableView.register(ColorParameterCellView.self, forCellReuseIdentifier: "ColorParameterCell")

        startObservingKeyboardEvents()
    }

    private func startObservingKeyboardEvents() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    private func stopObservingKeyboardEvents() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
            tableView.contentInset = contentInset
            tableView.scrollIndicatorInsets = contentInset

            if let selectedIndexPath = selectedIndexPath {
                tableView.scrollToRow(at: selectedIndexPath, at: .bottom, animated: true)
            }
        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        let animationDuration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.floatValue
        UIView.animate(withDuration: TimeInterval(animationDuration ?? 0.1), delay: 0, options: .beginFromCurrentState, animations: { [weak self] in
            let contentInset = UIEdgeInsets.zero
            if let self = self {
                self.tableView.contentInset = contentInset
                self.tableView
                    .scrollIndicatorInsets = contentInset
            }
            }, completion: nil)
    }

    @objc private func doneWasTapped() {
        if let presentingViewController = self.presentingViewController {
            stopObservingKeyboardEvents()
            presentingViewController.dismiss(animated: true) {
                if let delegate = self.parametersViewControllerDelegate {
                    delegate.viewControllerWasDismissed(self)
                }
            }
        }
    }

    @objc private func revertWasTapped() {
        parameters.forEach { (parameter) in
            parameter.revertToDefault()
        }
        self.tableView.reloadData()
    }

    private func parameter(for indexPath: IndexPath) -> Parameter? {
        guard let sortedGroups = sortedGroups else { return nil }

        let valuesArray = Array(sortedGroups[indexPath.section].values)
        if let parametersArray = valuesArray.first {
            return parametersArray[indexPath.row]
        }
        return nil
    }
}

public protocol ParametersViewControllerDelegate : class {
    func viewControllerWasDismissed(_ viewController: ParametersViewController)
}

class ParameterCellView: UITableViewCell, UITextFieldDelegate {
    let horizontalInset = CGFloat(12)
    let verticalInset = CGFloat(8)
    let horizontalSpacing = CGFloat(12)
    let verticalSpacing = CGFloat(8)

    var parameter: Parameter? {
        didSet {
            rebuildControls()
            self.setNeedsLayout()
        }
    }
    let label: UILabel = UILabel()
    let textfield: UITextField = UITextField()
    let switchControl: UISwitch = UISwitch()
    let slider: UISlider = UISlider()
    let stepper: UIStepper = UIStepper()
    let revertButton: UIButton = UIButton()

    init(style: UITableViewCell.CellStyle, reuseIdentifier: String?, parameter: Parameter) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.parameter = parameter
        commonInit()
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    func commonInit() {
        contentView.addSubview(label)
        contentView.addSubview(textfield)
        contentView.addSubview(switchControl)
        contentView.addSubview(slider)
        contentView.addSubview(stepper)
        contentView.addSubview(revertButton)

        label.font = UIFont.systemFont(ofSize: 16)
        textfield.font = UIFont.systemFont(ofSize: 14)
        textfield.delegate = self
        textfield.returnKeyType = .done
        textfield.backgroundColor = .white
        textfield.textColor = .black
        textfield.isUserInteractionEnabled = true
        textfield.borderStyle = .roundedRect

        revertButton.setAttributedTitle(NSAttributedString(string: "Revert", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.black]), for: .normal)
        revertButton.sizeToFit()
        addDoneButtonOnKeyboard()
    }

    open override func prepareForReuse() {
        super.prepareForReuse()
        reset()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        var labelFrame = label.frame

        if let parameter = self.parameter {
            label.text = parameter.name
            label.sizeToFit()
            labelFrame = label.frame

            labelFrame.origin.x = horizontalInset
            labelFrame.origin.y = verticalInset

            switch parameter.dataType {
            case .bool:
                if let parameter = parameter as? BoolParameter {
                    textfield.text = "\(parameter.relay.value)"
                }
                labelFrame.size.height = contentView.bounds.size.height
                labelFrame.origin.y = 0
            case .float:
                if let parameter = parameter as? FloatParameter {
                    textfield.text = "\(parameter.relay.value)"
                }
            case .int:
                if let parameter = parameter as? IntParameter {
                    textfield.text = "\(parameter.relay.value)"
                    slider.maximumValue = Float(parameter.maxValue)
                    slider.minimumValue = Float(parameter.minValue)
                }
            case .string:
                if let parameter = parameter as? StringParameter {
                    textfield.text = parameter.relay.value
                }
            case .color:
                if let parameter = parameter as? ColorParameter {
                    textfield.text = parameter.relay.value.toHex(alpha: true)
                }
            }

            label.frame = labelFrame
        }

        var revertButtonFrame = revertButton.frame
        revertButtonFrame.origin.x = contentView.bounds.width - horizontalInset - revertButtonFrame.size.width
        revertButtonFrame.origin.y = verticalInset + labelFrame.size.height + verticalSpacing - 2
        revertButton.frame = revertButtonFrame

        var textfieldFrame = textfield.frame
        textfieldFrame.origin.x = horizontalInset
        textfieldFrame.origin.y = verticalInset + labelFrame.size.height + verticalSpacing
        textfieldFrame.size.height = 32
        textfieldFrame.size.width = contentView.bounds.width - 2 * horizontalInset - revertButton.bounds.size.width - horizontalSpacing
        textfield.frame = textfieldFrame

        var stepperFrame = stepper.frame
        stepperFrame.origin.x = contentView.bounds.width - horizontalInset - stepperFrame.size.width
        stepperFrame.origin.y = textfieldFrame.origin.y + textfieldFrame.size.height + verticalSpacing
        stepper.frame = stepperFrame

        var sliderFrame = slider.frame
        sliderFrame.origin.x = horizontalInset
        sliderFrame.origin.y = textfieldFrame.origin.y + textfieldFrame.size.height + verticalSpacing
        sliderFrame.size.width = contentView.bounds.width - 2 * horizontalInset - stepperFrame.size.width - horizontalSpacing
        slider.frame = sliderFrame

        var switchFrame = switchControl.frame
        switchFrame.origin.x = contentView.bounds.width - horizontalInset - switchFrame.size.width
        switchFrame.origin.y = verticalInset
        switchControl.frame = switchFrame
    }

    func rebuildControls() {
        switchControl.removeTarget(self, action: #selector(self.switchValueChanged(_:)), for: .valueChanged)
        slider.removeTarget(self, action: #selector(self.sliderValueChanged(_:)), for: .valueChanged)
        stepper.removeTarget(self, action: #selector(self.stepperValueChanged(_:)), for: .valueChanged)
        revertButton.removeTarget(self, action: #selector(self.revertButtonTapped(_:)), for: .touchUpInside)

        guard let parameter = parameter else { return }

        switchControl.isHidden = true
        slider.isHidden = true
        stepper.isHidden = true
        revertButton.isHidden = true

        if parameter.isNumeric {
            switchControl.isHidden = true
            slider.isHidden = false
            stepper.isHidden = false
            textfield.isHidden = false
            revertButton.isHidden = false

            if let parameter = parameter as? FloatParameter {
                slider.maximumValue = parameter.maxValue
                slider.minimumValue = parameter.minValue
                slider.value = parameter.relay.value

                stepper.minimumValue = Double(parameter.minValue)
                stepper.maximumValue = Double(parameter.maxValue)
                stepper.stepValue = Double(parameter.stepValue)
                stepper.value = Double(parameter.relay.value)
            } else if let parameter = parameter as? IntParameter {
                slider.maximumValue = Float(parameter.maxValue)
                slider.minimumValue = Float(parameter.minValue)
                slider.value = Float(parameter.relay.value)

                stepper.minimumValue = Double(parameter.minValue)
                stepper.maximumValue = Double(parameter.maxValue)
                stepper.stepValue = Double(parameter.stepValue)
                stepper.value = Double(parameter.relay.value)
            }
            slider.addTarget(self, action: #selector(self.sliderValueChanged(_:)), for: .valueChanged)
            stepper.addTarget(self, action: #selector(self.stepperValueChanged(_:)), for: .valueChanged)
            textfield.keyboardType = .numbersAndPunctuation
        } else {
            if let parameter = parameter as? BoolParameter {
                switchControl.isHidden = false
                slider.isHidden = true
                stepper.isHidden = true
                textfield.isHidden = true

                switchControl.isOn = parameter.relay.value
                switchControl.addTarget(self, action: #selector(self.switchValueChanged(_:)), for: .valueChanged)
                textfield.keyboardType = .numbersAndPunctuation
            } else if let parameter = parameter as? StringParameter {
                textfield.keyboardType = .default
                switchControl.isHidden = true
                slider.isHidden = true
                stepper.isHidden = true
                revertButton.isHidden = false
                textfield.isHidden = false
                textfield.text = parameter.relay.value
            } else if let parameter = parameter as? ColorParameter {
                switchControl.isHidden = true
                slider.isHidden = true
                stepper.isHidden = true
                textfield.isHidden = false
                revertButton.isHidden = false
                
                textfield.text = parameter.relay.value.toHex(alpha: true)

                textfield.keyboardType = .default
            }
        }
        revertButton.addTarget(self, action: #selector(self.revertButtonTapped(_:)), for: .touchUpInside)
    }

    private func reset() {
        parameter = nil
        label.text = nil
    }

    // MARK: Events
    @objc private func switchValueChanged(_ sender: UISwitch) {
        if let parameter = parameter as? BoolParameter {
            parameter.relay.accept(sender.isOn)
        }
    }

    @objc private func sliderValueChanged(_ sender: UISlider) {
        if let parameter = parameter as? FloatParameter {
            let roundingPrecision = 1.0 / parameter.precision
            let floatValue = Float(sender.value)
            let roundedFloat = round(roundingPrecision*floatValue)/roundingPrecision
            parameter.relay.accept(roundedFloat)
            stepper.value = Double(roundedFloat)
            textfield.text = "\(roundedFloat)"
        } else if let parameter = parameter as? IntParameter {
            let roundedValue = Int(slider.value)
            parameter.relay.accept(roundedValue)
            stepper.value = Double(roundedValue)
            textfield.text = "\(roundedValue)"
        }
    }

    @objc private func stepperValueChanged(_ sender: UIStepper) {
        if let parameter = parameter as? FloatParameter {
            let roundingPrecision = 1.0 / parameter.precision
            let floatValue = Float(sender.value)
            let roundedFloat = round(roundingPrecision*floatValue)/roundingPrecision
            parameter.relay.accept(roundedFloat)
            slider.value = roundedFloat
            textfield.text = "\(roundedFloat)"
        } else if let parameter = parameter as? IntParameter {
            let roundedValue = Int(sender.value)
            let roundedFloat = Float(roundedValue)
            parameter.relay.accept(roundedValue)
            slider.value = roundedFloat
            textfield.text = "\(roundedValue)"
        }
    }

    @objc private func revertButtonTapped(_ sender: UIStepper) {
        parameter?.revertToDefault()

        if let parameter = parameter as? FloatParameter {
            slider.value = parameter.defaultValue
            textfield.text = "\(parameter.defaultValue)"
            stepper.value = Double(parameter.defaultValue)
        } else if let parameter = parameter as? IntParameter {
            slider.value = Float(parameter.defaultValue)
            textfield.text = "\(parameter.defaultValue)"
            stepper.value = Double(parameter.defaultValue)
        } else if let parameter = parameter as? StringParameter {
            textfield.text = parameter.relay.value
        } else if let parameter = parameter as? ColorParameter {
            textfield.text = parameter.relay.value.toHex(alpha: true)
        }
    }

    private func commitTextFieldValue() {
        if let parameter = parameter as? FloatParameter {
            if let floatValue = Float(textfield.text!) {
                let roundingPrecision = 1.0 / parameter.precision
                let roundedFloat = round(roundingPrecision*floatValue)/roundingPrecision
                parameter.relay.accept(roundedFloat)
                slider.value = floatValue
                textfield.text = "\(parameter.relay.value)"
                stepper.value = Double(floatValue)
            }
        } else if let parameter = parameter as? IntParameter {
            if let intValue = Int(textfield.text!) {
                parameter.relay.accept(intValue)
                slider.value = Float(intValue)
                textfield.text = "\(parameter.relay.value)"
                stepper.value = Double(intValue)
            }
        } else if let parameter = parameter as? StringParameter, let text = textfield.text {
            parameter.relay.accept(text)
            textfield.text = parameter.relay.value
        } else if let parameter = parameter as? ColorParameter, let text = textfield.text {
            let color = UIColor.init(hexString: text)
            parameter.relay.accept(color)
        }
    }

    func addDoneButtonOnKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height))
        doneToolbar.barStyle = UIBarStyle.default

        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.doneButtonAction))

        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)

        doneToolbar.items = items
        doneToolbar.sizeToFit()

        textfield.inputAccessoryView = doneToolbar
    }

    @objc private func doneButtonAction() {
        textfield.resignFirstResponder()
    }

    // MARK: UITextFieldDelegate Methods

    func textFieldDidBeginEditing(_ textField: UITextField) {
//        print("textFieldDidBeginEditing: \(String(describing: textField.text))")
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        textfield.resignFirstResponder()
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        commitTextFieldValue()
        return true
    }
}

class BoolParameterCellView: ParameterCellView {
}

class FloatParameterCellView: ParameterCellView {
}

class IntParameterCellView: ParameterCellView {
}

class StringParameterCellView: ParameterCellView {
}

class ColorParameterCellView: ParameterCellView {
}
