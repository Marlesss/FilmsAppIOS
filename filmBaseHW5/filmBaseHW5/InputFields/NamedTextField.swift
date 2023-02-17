import UIKit

// TODO: fix paint error
@IBDesignable
class NamedTextField: UIControl, Field {
    typealias DataType = String
    
    private lazy var label: UILabel = {
        label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var space: UIView = {
        space = UIView()
        space.translatesAutoresizingMaskIntoConstraints = false
        return space
    }()
    internal lazy var textField: MyTextField = {
        textField = MyTextField(frame: .zero)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    public var validator: Validator?
    
    @IBInspectable public var labelText: String? {
        get { label.text }
        set { label.text = newValue }
    }
    @IBInspectable public var labelTextColor: UIColor? {
        didSet { label.textColor = labelTextColor }
    }
    @IBInspectable public var padding: CGFloat {
        get { textField.padding }
        set { textField.padding = newValue }
    }
    @IBInspectable public var cornerRadius: CGFloat {
        get { textField.layer.cornerRadius }
        set { textField.layer.cornerRadius = newValue }
    }
    @IBInspectable public var borderWidth: CGFloat {
        get { textField.layer.borderWidth }
        set { textField.layer.borderWidth = newValue }
    }
    @IBInspectable public var borderColor: UIColor? {
        didSet { textField.layer.borderColor = borderColor?.cgColor }
    }
    @IBInspectable public var textBackgroundColor: UIColor? {
        didSet { textField.backgroundColor = textBackgroundColor }
    }
    
    @IBInspectable public var placeholderString: String? {
        get { textField.placeholder }
        set { textField.placeholder = newValue }
    }
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        postInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        postInit()
    }
    
    private func postInit() {
        setDefaults()
        
        for subview in [label, space, textField] {
            addSubview(subview)
        }
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: space.topAnchor),
            space.leadingAnchor.constraint(equalTo: leadingAnchor),
            space.trailingAnchor.constraint(equalTo: trailingAnchor),
            space.bottomAnchor.constraint(equalTo: textField.topAnchor),
            space.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.05),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor),
            textField.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.75)
        ])
        
        addTarget(self, action: #selector(validateData), for: .editingChanged)
    }
    
    private func setDefaults() {
        labelTextColor = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1)
        padding = 16
        cornerRadius = 8
        borderWidth = 1
        borderColor = UIColor.black
        textBackgroundColor = UIColor(white: 0.9, alpha: 0.2)
    }
    
    @objc
    public func validateData() {
        paint(stateIsNormal: dataIsValid())
    }
    
    func clean() {
        textField.text = ""
        paint(stateIsNormal: true)
    }
    
    func getData() -> DataType {
        textField.text ?? ""
    }
    
    func dataIsValid() -> Bool {
        guard let validator = validator else { return true }
        return validator.validate(text: getData())
    }
    
    
    private func paint(stateIsNormal: Bool) {
        if (stateIsNormal) {
            label.textColor = labelTextColor
            textField.layer.borderColor = borderColor?.cgColor
        } else {
            label.textColor = .red
            textField.layer.borderColor = UIColor.red.cgColor
        }
    }
    
    override func addTarget(_ target: Any?, action: Selector, for controlEvents: UIControl.Event) {
        super.addTarget(target, action: action, for: controlEvents)
        textField.addTarget(target, action: action, for: controlEvents)
    }
}
