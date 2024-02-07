import UIKit

enum CalculationError: Error {
    case dividedByZero
}

enum Operation {
    case add
    case subtract
    case multiply
    case divide
    
    func calculate(_ number1: Double, _ number2: Double) throws -> Double {
        switch self {
        case .add:
            return number1 + number2
        case .subtract:
            return number1 - number2
        case .multiply:
            return number1 * number2
        case .divide:
            if number2 == 0 {
                throw CalculationError.dividedByZero
            }
            return number1 / number2
        }
    }
    
    var rawValue: String {
        switch self {
        case .add:
            return "+"
        case .subtract:
            return "-"
        case .multiply:
            return "*"
        case .divide:
            return "/"
        }
    }
    
    init?(rawValue: String) {
        switch rawValue {
        case "+":
            self = .add
        case "-":
            self = .subtract
        case "*", "x", "X":
            self = .multiply
        case "/":
            self = .divide
        default:
            return nil
        }
    }
}

enum CalculationHistoryItem {
    case number(Double)
    case operation(Operation)
}

class ViewController: UIViewController {
    @IBOutlet weak var label: UILabel!
    @IBAction func buttonPressed(_ sender: UIButton) {
        guard let buttonText = sender.currentTitle else { return }
        if buttonText == "." && label.text?.contains(".") == true {
            return
        }
        if label.text == "0" {
            label.text = buttonText
        } else {
            label.text?.append(buttonText)
        }
    }
    
    @IBAction func operationButtonPressed(_ sender: UIButton) {
        guard
            let buttonText = sender.currentTitle,
            let buttonOperation = Operation(rawValue: buttonText)
        else { return }
        
        guard
            let labelText = label.text,
            let labelNumber = numberFormatter.number(from: labelText)?.doubleValue
        else { return }
        
        calculationHistory.append(.number(labelNumber))
        calculationHistory.append(.operation(buttonOperation))
        resetLabelText()
    }
    
    @IBAction func clearButtonPressed() {
        calculationHistory.removeAll()
        resetLabelText()
    }
    
    @IBAction func calculateButtonPressed(_ sender: UIButton) {
        guard
            let labelText = label.text,
            let labelNumber = numberFormatter.number(from: labelText)?.doubleValue
        else { return }
        calculationHistory.append(.number(labelNumber))
        do {
            let result = try calculate()
            
            label.text = numberFormatter.string(from: NSNumber(value: result))
        }
        catch CalculationError.dividedByZero {
            label.text = "Ошибка: деление на ноль"
        }
        catch {
            label.text = "Ошибка"
        }
        calculationHistory.removeAll()
    }
    
    var calculationHistory: [CalculationHistoryItem] = []
    lazy var numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.usesGroupingSeparator = false
        numberFormatter.locale = Locale(identifier: "ru_RU")
        numberFormatter.numberStyle = .decimal
        return numberFormatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resetLabelText()
    }
    
    func calculate() throws -> Double {
        guard case .number(let firstNumber) = calculationHistory.first else { return 0 }
        var currentResult = firstNumber
        for index in stride(from: 1, to: calculationHistory.count, by: 2) {
            guard
                case .operation(let operation) = calculationHistory[index],
                case .number(let number) = calculationHistory[index + 1]
            else { break }
            currentResult = try operation.calculate(currentResult, number)
        }
        return currentResult
    }
    func resetLabelText() {
        label.text = "0"
    }
}
