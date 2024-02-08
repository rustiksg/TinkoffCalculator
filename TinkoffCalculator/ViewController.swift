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
        
        switch buttonText {
        case "." where label.text?.contains(".") == true:
            return
        case "," where label.text == "0":
            label.text = "0,"
        case "," where label.text?.contains(",") == true:
            return
        default:
            if label.text == "0" || label.text == "Ошибка" {
                label.text = buttonText
            } else {
                let count = label.text?.filter { $0 != " " }.count ?? 0
                if count < 9 {
                    label.text?.append(buttonText)
                }
            }
        }
    }

    
    @IBAction func operationButtonPressed(_ sender: UIButton) {
            guard
                let buttonText = sender.currentTitle,
                let buttonOperation = Operation(rawValue: buttonText)
            else { return }
            if case .operation(_) = calculationHistory.last {
                return
            }
            
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
               if result > 1_000_000_000 {
                   // Форматирование числа в формате научной нотации
                   label.text = String(format: "%.2e", result)
               } else {
                   label.text = numberFormatter.string(from: NSNumber(value: result))
               }
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
