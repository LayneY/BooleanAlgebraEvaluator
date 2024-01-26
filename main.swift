import Foundation

enum BooleanAlgebra {
    enum TokenError: Error {
        case noneFound
    }
    
    case variable(value: String)
    case operatorToken(value: String)
    case trueVal
    case falseVal
    case openParenthesis
    case closedParenthesis
    case empty

    static func nextToken(from line: Substring) throws -> (token: BooleanAlgebra, text: Substring, characters: Int) {
        if let match = try #/(T)/#.prefixMatch(in: line) {
            return (token: .trueVal, text: match.1, characters: match.0.count)
        }else if let match = try #/(F)/#.prefixMatch(in: line) {
            return (token: .falseVal, text: match.1, characters: match.0.count)
        }else if let match = try #/([A-Za-z]+)/#.prefixMatch(in: line) {
            return (token: .variable(value: String(match.1)), text: match.1, characters: match.0.count)
        }else if let match = try #/([&|0>=!])/#.prefixMatch(in:line) {
            return (token: .operatorToken(value: String(match.1)), text: match.1, characters: match.0.count)
        }else{
            throw TokenError.noneFound
        }
    }
}

struct TokenSource {
    let token: BooleanAlgebra
    let text: String
    let lineIndex: Int
    let columnIndex: Int

    static func lex(line: String) throws -> [BooleanAlgebra] {
        var workingLine = Substring(line)
        var tokens: [BooleanAlgebra] = []
        while workingLine.count > 0 {
            let (token, _, characters) = try BooleanAlgebra.nextToken(from: workingLine)
            workingLine = workingLine.dropFirst(characters)
            tokens.append(token)
        }
        return tokens
    }
}

class Stack {
    public var items: [BooleanAlgebra] = Array()

    public var topIndex = 0

    init() {
        for _ in 0..<10 {
            items.append(.empty)
        }
    }
    
    func push(_ item: BooleanAlgebra) {
        items[topIndex] = item
        topIndex += 1
    }

    func pop() -> BooleanAlgebra {
        topIndex -= 1
        return items[topIndex]
    }
    
    func peek() -> BooleanAlgebra {
        return items[topIndex - 1]
    }

    func isEmpty() -> Bool {
        return topIndex == 0
    }

    func getCount() -> Int {
        return topIndex
    }

    func copy() -> Stack {
        let new = Stack()
        new.topIndex = topIndex
        new.items = items
        return new
    }

    // func dump() {
    //     var list = ""
    //     for i in 0 ..< topIndex {
    //         list += items[i] + " "
    //     }
    //     print(list)
    // }

}

func main() {
    print("Enter a boolean expression and press ENTER when done.")
    print("Operators include: & (and), | (or), 0 (xor), = (equal), ! (not equal), > (imply), T (true), F (false).")
    print("Variables must be at least one lowercase or uppercase letter, not including uppercase T and F.")
    
    let line = readLine()!
    let stack = Stack()
    var variables: [String] = []
    do {
        var tokens = try TokenSource.lex(line:line)
        tokens.reverse()
        for token in tokens {
            switch token {
            case .variable(let value):
                variables.append(value)
                stack.push(token)
            default:
                stack.push(token)   
            }
        }
    } catch {
        print("Failed bc: \(error)")
    }

    switch stack.peek() {
    case .operatorToken:
        print("Expression ends in an operator.")
    default:
        variables.reverse()
        createTruthTable(variables: variables, stack: stack)
    }
}

func evaluate(variables: [String], values: [Bool], stack: Stack) -> String {
    while stack.getCount() > 1 {
        let leftOp = stack.pop()
        let op = stack.pop()
        let rightOp = stack.pop()
        var rightVal = false
        var leftVal = false

        if case .trueVal = rightOp {
            rightVal = true
        } else if case .variable(let val) = rightOp {
            let varIndex = variables.firstIndex(of: val)!
            rightVal = values[varIndex]
        }

        if case .trueVal = leftOp {
            leftVal = true
        } else if case .variable(let val) = leftOp {
            let varIndex = variables.firstIndex(of: val)!
            leftVal = values[varIndex]
        }

        if case .operatorToken(let val) = op {
            switch val {
            case "&"://and
                if leftVal && rightVal {
                    stack.push(.trueVal)
                }else{
                    stack.push(.falseVal)
                }
            case "|"://or
                if leftVal || rightVal {
                    stack.push(.trueVal)
                }else{
                    stack.push(.falseVal)
                }
            case "0", "!"://xor and not equal
                if leftVal != rightVal {
                    stack.push(.trueVal)
                }else{
                    stack.push(.falseVal)
                }
            case ">": //implies
                if leftVal == false || (leftVal && rightVal) {
                    stack.push(.trueVal)
                }else{
                    stack.push(.falseVal)
                }
            case "=": //equal
                if leftVal == rightVal {
                    stack.push(.trueVal)
                }else{
                    stack.push(.falseVal)
                }
            default:
                return "no"
            }
        }else{
            return "badop"
        }
    }
    let final = stack.peek()
    switch final {
    case .trueVal:
        return "T"
    case .falseVal:
        return "F"
    default:
        return "F"
    }
 
}

func createTruthTable(variables: [String], stack: Stack) {
    let variableCombinations = 1 << variables.count
    
    print(variables.joined(separator: ", "), " | Result")

    for i in 0..<variableCombinations {
        var variableValues: [String: Bool] = [:]
        var rowValues: [Bool] = []

        for (index, variable) in variables.enumerated() {
            let bit = (i >> index) & 1
            let value = (bit == 1)
            variableValues[variable] = value
            rowValues.append(value)
        }

        // Print truth table row
        let row = variables.map { variableValues[$0]! ? "T" : "F" }.joined(separator: ", ")
        let stackCopy = stack.copy()
        let result = evaluate(variables: variables, values: rowValues, stack: stackCopy)
        print(row, " | \(result)")
    }
}

main()
