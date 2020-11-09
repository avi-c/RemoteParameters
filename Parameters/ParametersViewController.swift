//
//  ParametersViewController.swift
//  Parameters
//
//  Created by Avi Cieplinski on 8/22/19.
//  Copyright © 2019 Mapbox. All rights reserved.
//

import Foundation
import UIKit

public protocol ParametersViewControllerDelegate: class {
    func willAppear(parametersViewController: ParametersViewController)
    func didAppear(parametersViewController: ParametersViewController)
    func willDisappear(parametersViewController: ParametersViewController)
    func didDisappear(parametersViewController: ParametersViewController)
}

public class ParametersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    class var backgroundColor: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.systemBackground
        } else {
            return .white
        }
    }

    class var tableViewSeparatorColor: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.separator
        } else {
            return UIColor.lightGray
        }
    }

    class var textfieldBackgroundColor: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.systemBackground
        } else {
            return UIColor.white
        }
    }

    class var textDefaultColor: UIColor {
        return UIColor.darkText
    }

    public weak var parametersViewControllerDelegate: ParametersViewControllerDelegate?

    static let pickerViewHeight = CGFloat(160)

    public var showDebugParameters = true

    public var parameters: [ParameterCategory]? {
        didSet {
            tableView.reloadData()
        }
    }

    // all the categories. Here so we can include the debug entries (if they are set to be visible)
    private var allCategories: [ParameterCategory]? {
        guard let parameters = parameters else { return nil }

        if !showDebugParameters {
            let regularParameterCategoryList: [ParameterCategory]? = parameters.filter({ (category) -> Bool in
                return category.isDebug == false
            })
            return regularParameterCategoryList
        }
        return parameters
    }

    private var selectedIndexPath: IndexPath?

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        parametersViewControllerDelegate?.willAppear(parametersViewController: self)
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        parametersViewControllerDelegate?.willDisappear(parametersViewController: self)
    }

    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        parametersViewControllerDelegate?.didDisappear(parametersViewController: self)
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        parametersViewControllerDelegate?.didAppear(parametersViewController: self)
    }

    public func numberOfSections(in tableView: UITableView) -> Int {
        return allCategories?.count ?? 0
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let allCategories = allCategories else { return 0 }
        let category = allCategories[section]
        return category.disclosed ? category.entries.count : 1
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell

        if let allCategories = allCategories {
            let category = allCategories[indexPath.section]

            if !category.disclosed {
                var cell: UITableViewCell

                cell = tableView.dequeueReusableCell(withIdentifier: "ParameterCategoryCell", for: indexPath)
                cell.backgroundColor = ParametersViewController.backgroundColor
                cell.textLabel?.text = category.name
                cell.accessoryType = .disclosureIndicator

                return cell
            } else {
                let parameter = category.entries[indexPath.row]
                if let floatPref = parameter as? FloatParameter {
                    if let floatParameterCellView = tableView.dequeueReusableCell(withIdentifier: "FloatParameterCell", for: indexPath) as? FloatParameterCellView {
                        floatParameterCellView.parameter = floatPref
                        floatParameterCellView.backgroundColor = ParametersViewController.backgroundColor
                        cell = floatParameterCellView

                        return cell
                    }
                } else if let boolPref = parameter as? BoolParameter, let boolParametersCellView = tableView.dequeueReusableCell(withIdentifier: "BoolParameterCell", for: indexPath) as? BoolParameterCellView {
                    boolParametersCellView.parameter = boolPref
                    boolParametersCellView.backgroundColor = ParametersViewController.backgroundColor
                    cell = boolParametersCellView

                    return cell
                } else if let pickerPref = parameter as? PickerParameter, let pickerParameterCellView = tableView.dequeueReusableCell(withIdentifier: "PickerParameterCell", for: indexPath) as? PickerParameterCellView {
                    pickerParameterCellView.parameter = pickerPref
                    pickerParameterCellView.pickerView.dataSource = pickerPref
                    pickerParameterCellView.pickerView.delegate = pickerPref
                    pickerParameterCellView.pickerView.selectRow(pickerPref.value, inComponent: 0, animated: false)
                    pickerParameterCellView.backgroundColor = ParametersViewController.backgroundColor
                    cell = pickerParameterCellView

                    return cell
                } else if let intPref = parameter as? IntParameter, let intParametersCellView = tableView.dequeueReusableCell(withIdentifier: "IntParameterCell", for: indexPath) as? IntParameterCellView {
                    intParametersCellView.parameter = intPref
                    intParametersCellView.backgroundColor = ParametersViewController.backgroundColor
                    cell = intParametersCellView

                    return cell
                } else if let stringPref = parameter as? StringParameter, let stringParametersCellView = tableView.dequeueReusableCell(withIdentifier: "StringParameterCell", for: indexPath) as? StringParameterCellView {
                    stringParametersCellView.parameter = stringPref
                    stringParametersCellView.backgroundColor = ParametersViewController.backgroundColor
                    cell = stringParametersCellView

                    return cell
                } else if let segmentedPref = parameter as? SegmentedParameter, let segmentedParametersCellView = tableView.dequeueReusableCell(withIdentifier: "SegmentedParameterCell", for: indexPath) as? SegmentedParameterCellView {
                    segmentedParametersCellView.parameter = segmentedPref
                    cell = segmentedParametersCellView

                    return cell
                } else if let staticTextPref = parameter as? StaticTextParameter {
                    let staticTextParameterCellView = tableView.dequeueReusableCell(withIdentifier: "StaticTextParameterCell") ?? UITableViewCell(style: .value1, reuseIdentifier: "StaticTextParameterCell")
                    staticTextParameterCellView.textLabel?.text = staticTextPref.name
                    staticTextParameterCellView.detailTextLabel?.text = staticTextPref.value
                    cell = staticTextParameterCellView

                    return cell
                } else if let staticLinkPref = parameter as? StaticLinkParameter {
                    cell = tableView.dequeueReusableCell(withIdentifier: "StaticLinkParameterCell", for: indexPath)
                    cell.textLabel?.text = staticLinkPref.name
                    cell.accessoryType = .disclosureIndicator

                    return cell
                }
            }
        }

        cell = tableView.dequeueReusableCell(withIdentifier: "ParameterCell", for: indexPath)
        cell.backgroundColor = ParametersViewController.backgroundColor
        cell.textLabel?.text = "Empty"
        return cell
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        guard let allCategories = allCategories else { return 48 }

        let category = allCategories[indexPath.section]

        if category.disclosed {
            let parameter = category.entries[indexPath.row]

            if parameter.dataType == .picker {
                return ParametersViewController.pickerViewHeight
            } else if parameter.isNumeric {
                return 120
            } else if parameter.dataType == .string {
                return 80
            } else if parameter.dataType == .segmented {
                return 100
            }
        }

        return 48
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.groupTableViewBackground

        if section == 0 {
            let bottomSeparatorView = UIView()
            bottomSeparatorView.backgroundColor = ParametersViewController.tableViewSeparatorColor
            backgroundView.addSubview(bottomSeparatorView)
            bottomSeparatorView.translatesAutoresizingMaskIntoConstraints = false
            bottomSeparatorView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor).isActive = true
            bottomSeparatorView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor).isActive = true
            bottomSeparatorView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor).isActive = true
            bottomSeparatorView.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        } else {
            let topSeparatorView = UIView()
            topSeparatorView.backgroundColor = ParametersViewController.tableViewSeparatorColor
            backgroundView.addSubview(topSeparatorView)
            topSeparatorView.translatesAutoresizingMaskIntoConstraints = false
            topSeparatorView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor).isActive = true
            topSeparatorView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor).isActive = true
            topSeparatorView.topAnchor.constraint(equalTo: backgroundView.topAnchor).isActive = true
            topSeparatorView.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        }
        return backgroundView
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard section > 0 else { return 0 }
        return 36.0
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath

        tableView.deselectRow(at: indexPath, animated: true)

        if let category = parameterCategory(for: indexPath),
           category.disclosed == true,
           let staticLinkPref = category.entries[indexPath.row] as? StaticLinkParameter,
           let url = URL(string: staticLinkPref.url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }

        // push on a VC for this parameter set
        if let category = parameterCategory(for: indexPath), category.disclosed == false {
            let parametersViewController = ParametersViewController()
            var singleCategory = category
            singleCategory.disclosed = true
            parametersViewController.title = singleCategory.name
            parametersViewController.parameters = [singleCategory]
            self.navigationController?.pushViewController(parametersViewController, animated: true)
        }
    }

    let tableView: UITableView = UITableView()
    let tableViewController: UIViewController = UIViewController()

    public override func viewDidLoad() {
        super.viewDidLoad()

        tableViewController.view.addSubview(tableView)
        self.edgesForExtendedLayout = []
        self.view.addSubview(tableViewController.view)

        self.view.backgroundColor = UIColor.groupTableViewBackground
        tableView.backgroundColor = UIColor.groupTableViewBackground

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.widthAnchor.constraint(equalTo: tableViewController.view.widthAnchor).isActive = true
        tableView.heightAnchor.constraint(equalTo: tableViewController.view.heightAnchor).isActive = true
        tableView.centerXAnchor.constraint(equalTo: tableViewController.view.centerXAnchor).isActive = true
        tableView.centerYAnchor.constraint(equalTo: tableViewController.view.centerYAnchor).isActive = true

        tableView.dataSource = self
        tableView.delegate = self
        tableView.clipsToBounds = true
        tableView.allowsSelection = true

        let tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 24))
        tableFooterView.backgroundColor = .groupTableViewBackground
        let topSeparatorView = UIView()
        topSeparatorView.backgroundColor = ParametersViewController.tableViewSeparatorColor
        tableFooterView.addSubview(topSeparatorView)
        topSeparatorView.translatesAutoresizingMaskIntoConstraints = false
        topSeparatorView.leadingAnchor.constraint(equalTo: tableFooterView.leadingAnchor).isActive = true
        topSeparatorView.trailingAnchor.constraint(equalTo: tableFooterView.trailingAnchor).isActive = true
        topSeparatorView.topAnchor.constraint(equalTo: tableFooterView.topAnchor).isActive = true
        topSeparatorView.heightAnchor.constraint(equalToConstant: 0.5).isActive = true

        tableView.tableFooterView = tableFooterView

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ParameterCell")
        tableView.register(FloatParameterCellView.self, forCellReuseIdentifier: "FloatParameterCell")
        tableView.register(BoolParameterCellView.self, forCellReuseIdentifier: "BoolParameterCell")
        tableView.register(IntParameterCellView.self, forCellReuseIdentifier: "IntParameterCell")
        tableView.register(StringParameterCellView.self, forCellReuseIdentifier: "StringParameterCell")
        tableView.register(SegmentedParameterCellView.self, forCellReuseIdentifier: "SegmentedParameterCell")
        tableView.register(PickerParameterCellView.self, forCellReuseIdentifier: "PickerParameterCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ParameterCategoryCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "StaticLinkParameterCell")

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

    private func parameterCategory(for indexPath: IndexPath) -> ParameterCategory? {
        guard let allCategories = allCategories else { return nil }

        return allCategories[indexPath.section]
    }
}

class ParameterCellView: UITableViewCell, UITextFieldDelegate {
    let horizontalInset = CGFloat(12)
    let verticalInset = CGFloat(8)
    let horizontalSpacing = CGFloat(12)
    let verticalSpacing = CGFloat(10)

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
    let segmentedControl: UISegmentedControl = UISegmentedControl()
    let pickerView: UIPickerView = UIPickerView()

    init(style: UITableViewCell.CellStyle, reuseIdentifier: String?, parameter: Parameter) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.parameter = parameter
        self.backgroundColor = .groupTableViewBackground
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
        contentView.addSubview(segmentedControl)
        contentView.addSubview(pickerView)

        label.font = UIFont.systemFont(ofSize: 17)
        textfield.font = UIFont.systemFont(ofSize: 14)
        textfield.delegate = self
        textfield.returnKeyType = .done
        textfield.backgroundColor = ParametersViewController.textfieldBackgroundColor
        textfield.textColor = ParametersViewController.textDefaultColor
        textfield.isUserInteractionEnabled = true
        textfield.borderStyle = .roundedRect
        textfield.clearButtonMode = .whileEditing

        pickerView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        pickerView.layer.borderWidth = 0.5
        pickerView.layer.cornerRadius = 6
        pickerView.backgroundColor = ParametersViewController.textfieldBackgroundColor

        revertButton.setAttributedTitle(NSAttributedString(string: "Revert", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: ParametersViewController.textDefaultColor]), for: .normal)
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
                    textfield.text = "\(parameter.value)"
                }
                labelFrame.size.height = contentView.bounds.size.height
                labelFrame.origin.y = 0
            case .float:
                if let parameter = parameter as? FloatParameter {
                    textfield.text = "\(parameter.value)"
                }
            case .int:
                if let parameter = parameter as? IntParameter {
                    textfield.text = "\(parameter.value)"
                    slider.maximumValue = Float(parameter.maxValue)
                    slider.minimumValue = Float(parameter.minValue)
                }
            case .string:
                if let parameter = parameter as? StringParameter {
                    textfield.text = parameter.value
                }
            case .segmented:
                if let parameter = parameter as? SegmentedParameter {
                    segmentedControl.selectedSegmentIndex = parameter.value
                }
            default:
                textfield.text = ""
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

        var segmentedControlFrame = segmentedControl.frame
        segmentedControlFrame.origin.x = horizontalInset
        segmentedControlFrame.origin.y = label.frame.origin.y + label.frame.height + verticalSpacing
        segmentedControlFrame.size.width = contentView.bounds.width - 2 * horizontalInset
        segmentedControlFrame.size.height = 46
        segmentedControl.frame = segmentedControlFrame

        var pickerViewControlFrame = pickerView.frame
        pickerViewControlFrame.origin.x = horizontalInset
        pickerViewControlFrame.origin.y = verticalInset + labelFrame.size.height + verticalSpacing
        pickerViewControlFrame.size.width = contentView.bounds.width - 2 * horizontalInset - revertButton.bounds.size.width - horizontalSpacing
        pickerViewControlFrame.size.height = ParametersViewController.pickerViewHeight - (verticalInset + labelFrame.size.height + verticalSpacing + verticalInset + verticalSpacing)
        pickerView.frame = pickerViewControlFrame
    }

    func rebuildControls() {
        switchControl.removeTarget(self, action: #selector(self.switchValueChanged(_:)), for: .valueChanged)
        slider.removeTarget(self, action: #selector(self.sliderValueChanged(_:)), for: .valueChanged)
        stepper.removeTarget(self, action: #selector(self.stepperValueChanged(_:)), for: .valueChanged)
        revertButton.removeTarget(self, action: #selector(self.revertButtonTapped(_:)), for: .touchUpInside)
        segmentedControl.removeTarget(self, action: #selector(self.segmentedControlChanged(_:)), for: .valueChanged)

        guard let parameter = parameter else { return }

        switchControl.isHidden = true
        slider.isHidden = true
        stepper.isHidden = true
        revertButton.isHidden = true
        segmentedControl.isHidden = true
        pickerView.isHidden = true

        if parameter.isNumeric {
            switchControl.isHidden = true
            slider.isHidden = false
            stepper.isHidden = false
            textfield.isHidden = false
            revertButton.isHidden = false

            if let parameter = parameter as? FloatParameter {
                slider.maximumValue = parameter.maxValue
                slider.minimumValue = parameter.minValue
                slider.value = parameter.value

                stepper.minimumValue = Double(parameter.minValue)
                stepper.maximumValue = Double(parameter.maxValue)
                stepper.stepValue = Double(parameter.stepValue)
                stepper.value = Double(parameter.value)
            } else if let parameter = parameter as? IntParameter {
                slider.maximumValue = Float(parameter.maxValue)
                slider.minimumValue = Float(parameter.minValue)
                slider.value = Float(parameter.value)

                stepper.minimumValue = Double(parameter.minValue)
                stepper.maximumValue = Double(parameter.maxValue)
                stepper.stepValue = Double(parameter.stepValue)
                stepper.value = Double(parameter.value)
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

                switchControl.isOn = parameter.value
                switchControl.addTarget(self, action: #selector(self.switchValueChanged(_:)), for: .valueChanged)
                textfield.keyboardType = .numbersAndPunctuation
            } else if let parameter = parameter as? StringParameter {
                textfield.keyboardType = .default
                switchControl.isHidden = true
                slider.isHidden = true
                stepper.isHidden = true
                revertButton.isHidden = false
                textfield.isHidden = false
                textfield.text = parameter.value
            } else if let parameter = parameter as? SegmentedParameter {
                switchControl.isHidden = true
                slider.isHidden = true
                stepper.isHidden = true
                textfield.isHidden = true
                segmentedControl.isHidden = false
                segmentedControl.removeAllSegments()
                segmentedControl.addTarget(self, action: #selector(self.segmentedControlChanged(_:)), for: .valueChanged)
                parameter.titles.forEach { (title) in
                    segmentedControl.insertSegment(withTitle: title, at: segmentedControl.numberOfSegments, animated: false)
                }
            } else if parameter is PickerParameter {
                textfield.keyboardType = .default
                switchControl.isHidden = true
                slider.isHidden = true
                stepper.isHidden = true
                revertButton.isHidden = false
                textfield.isHidden = true
                textfield.text = ""
                pickerView.isHidden = false
            }
        }
        revertButton.addTarget(self, action: #selector(self.revertButtonTapped(_:)), for: .touchUpInside)
    }

    private func reset() {
        parameter = nil
        label.text = nil
        backgroundColor = backgroundColor
    }

    // MARK: Events
    @objc private func switchValueChanged(_ sender: UISwitch) {
        if let parameter = parameter as? BoolParameter {
            parameter.value = sender.isOn
        }
    }

    @objc private func sliderValueChanged(_ sender: UISlider) {
        if let parameter = parameter as? FloatParameter {
            let roundingPrecision = 1.0 / parameter.precision
            let floatValue = Float(sender.value)
            let roundedFloat = round(roundingPrecision*floatValue)/roundingPrecision
            parameter.value = roundedFloat
            stepper.value = Double(roundedFloat)
            textfield.text = "\(roundedFloat)"
        } else if let parameter = parameter as? IntParameter {
            let roundedValue = Int(slider.value)
            parameter.value = roundedValue
            stepper.value = Double(roundedValue)
            textfield.text = "\(roundedValue)"
        }
    }

    @objc private func stepperValueChanged(_ sender: UIStepper) {
        if let parameter = parameter as? FloatParameter {
            let roundingPrecision = 1.0 / parameter.precision
            let floatValue = Float(sender.value)
            let roundedFloat = round(roundingPrecision*floatValue)/roundingPrecision
            parameter.value = roundedFloat
            slider.value = roundedFloat
            textfield.text = "\(roundedFloat)"
        } else if let parameter = parameter as? IntParameter {
            let roundedValue = Int(sender.value)
            let roundedFloat = Float(roundedValue)
            parameter.value = roundedValue
            slider.value = roundedFloat
            textfield.text = "\(roundedValue)"
        }
    }

    @objc private func segmentedControlChanged(_ sender: UISegmentedControl) {
        if let parameter = parameter as? SegmentedParameter {
            parameter.value = segmentedControl.selectedSegmentIndex
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
            textfield.text = parameter.value
        } else if let parameter = parameter as? PickerParameter {
            pickerView.selectRow(parameter.defaultValue, inComponent: 0, animated: true)
        }
    }

    private func commitTextFieldValue() {
        if let parameter = parameter as? FloatParameter {
            if let floatValue = Float(textfield.text!) {
                let roundingPrecision = 1.0 / parameter.precision
                let roundedFloat = round(roundingPrecision*floatValue)/roundingPrecision
                parameter.value = roundedFloat
                slider.value = floatValue
                textfield.text = "\(parameter.value)"
                stepper.value = Double(floatValue)
            }
        } else if let parameter = parameter as? IntParameter {
            if let intValue = Int(textfield.text!) {
                parameter.value = intValue
                slider.value = Float(intValue)
                textfield.text = "\(parameter.value)"
                stepper.value = Double(intValue)
            }
        } else if let parameter = parameter as? StringParameter, let text = textfield.text {
            parameter.value = text
            textfield.text = parameter.value
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
        commitTextFieldValue()
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textfield.resignFirstResponder()
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
    override func commonInit() {
        super.commonInit()
        label.font = UIFont.systemFont(ofSize: 15)
    }
}

class SegmentedParameterCellView: ParameterCellView {
    override func commonInit() {
        super.commonInit()
        label.font = UIFont.systemFont(ofSize: 15)
    }
}

class StaticTextParameterCellView: UITableViewCell {

    let horizontalInset = CGFloat(12)
    let verticalInset = CGFloat(8)
    let horizontalSpacing = CGFloat(12)
    let verticalSpacing = CGFloat(10)
    var parameter: StaticTextParameter?

}

class PickerParameterCellView: ParameterCellView {
}
