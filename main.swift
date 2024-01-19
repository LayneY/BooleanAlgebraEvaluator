import Foundation

enum Token {
    case variable(String)
    case operatorToken(String)
    case openParenthesis
    case closeParenthesis
}

class BooleanEvaluator {
    private var tokens: [Token] = []
    private var currentIndex: Int = 2
    
    init(equation: String) {
        self.tokens = tokenize(equation)
    }

    private func tokenize(_ equation: String) -> [Token] {
        var tokens: [Token] = []
        var currentIndex = equation.startIndex
        
        while currentIndex < equation.endIndex {
            let currentChar = equation[currentIndex].lowercased()
            
            switch currentChar {
            case "a"..."z":
                // Recognize variables
                var variable = ""
                while currentIndex < equation.endIndex, case "a"..."z" = equation[currentIndex] {
                    variable.append(equation[currentIndex])
                    currentIndex = equation.index(after: currentIndex)
                }
                tokens.append(.variable(variable))
                
            case "&", "|", "!", "and", "or", "not", "equal", "notequal":
                // Recognize operators
                tokens.append(.operatorToken(String(currentChar)))
                currentIndex = equation.index(after: currentIndex)
                
            case "(":
                // Recognize opening parenthesis
                tokens.append(.openParenthesis)
                currentIndex = equation.index(after: currentIndex)
                
            case ")":
                // Recognize closing parenthesis
                tokens.append(.closeParenthesis)
                currentIndex = equation.index(after: currentIndex)
                
            case " ":
                // Skip whitespace
                currentIndex = equation.index(after: currentIndex)
                
            default:
                // Ignore unrecognized characters
                currentIndex = equation.index(after: currentIndex)
            }
        }
        
        return tokens
    }

    func evaluate(values: [Bool]) -> Int {
        while currentIndex < tokens.count {
            if case .variable = tokens[currentIndex - 2] {
                if case .variable = tokens[currentIndex] {
                    switch tokens[currentIndex-1] {
                    case .operatorToken("&"):
                        if values[0] && values[1] {
                            return 1
                        }else{
                            return 0
                        }
                    case .operatorToken("|"):
                        if values[0] || values[1] {
                            return 1
                        }else{
                            return 0
                        }
                    case .operatorToken("0"):
                        if (values[0] == true && values[1] == false) || (values[0] == false && values[1] == true) {
                            return 1
                        }else{
                            return 0
                        }
                    case .operatorToken("="):
                        if values[0] == values[1] {
                            return 1
                        }else{
                            return 0
                        }
                    default:
                        return 0
                    }
                }
            }
        }
        return 0
    }

    func createTruthTable() {
        var variables: [String] = []
        for token in tokens {
            switch token {
            case .variable(let value):
                variables.append(value)
            default:
                print()
            }
        }

        print(variables.joined(separator: "\t") + "\tOutput")

        let combinationsCount = Int(pow(2.0, Double(variables.count)))
        var combinations = [[Bool]]()

        for i in 0..<combinationsCount {
            let binaryString = String(i, radix: 2)
            let binaryArray = binaryString.padding(toLength: variables.count, withPad: "0", startingAt: 0).compactMap { $0 == "1" }
            combinations.append(binaryArray)
        }

        for combination in combinations {
            let evaluationResult = evaluate(values: combination)
            print(combination.map { $0 ? "1" : "0" }.joined(separator: "\t") + "\t" + String(evaluationResult))
        }
    }

}

let input = readLine()!
let boolean = BooleanEvaluator(equation: input)
boolean.createTruthTable()

