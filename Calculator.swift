//
//  Calculator.swift
//  CalculatorProject
//
//  Created by Edoardo Franco Vianelli on 6/11/16.
//  Copyright © 2016 Edoardo Franco Vianelli. All rights reserved.
//

import Foundation
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}


typealias RPNTokens = [String]

enum Operation
{
    case binaryOperation( (Double, Double) -> Double)
    case unaryOperation( (Double) -> Double )
}

enum ExpressionElement
{
    case variable ( String )
    case number (Double)
    case `operator` ( Operation )
}

extension String
{
    var doubleValue : Double?
    {
        return NumberFormatter().number(from: self)?.doubleValue
    }
    
    func Tokenize(_ str : String) -> [String]
    {
        var Tokens = [String]()
        var Buffer = ""
        for item in self.characters
        {
            if str.characters.contains(item)
            {
                if Buffer != ""
                {
                    Tokens.append(Buffer)
                    Buffer = ""
                }
                Tokens.append("\(item)")
            }
            else
            {
                Buffer.append(item)
            }
        }
        
        if Buffer != "" { Tokens.append(Buffer) }
        
        return Tokens
    }
}

class ExpressionEvaluator
{
    fileprivate var variables = Dictionary<String, Double>()
    
    fileprivate var _exp = ""
    var Expression : String { return _exp }
    
    var Result : Double
    {
        get { return self.EvaluateExpression() }
    }
    
    func SetVariableValue(_ variable : String, value : Double)
    {
        variables[variable] = value
    }
    
    func VariableValue(_ variableName : String) -> Double
    {
        if let Value = variables[variableName]
        {
            return Value
        }
        return 0.0
    }
    
    
    fileprivate func EvaluateExpression() -> Double
    {
        var numberStack = [Double]()
        let pfConverter = InfixToPostfixConverter(infixString: Expression)
        let items = pfConverter.PostfixExpression
        for item in items
        {
            switch item {
            case .number(let Value):
                //found a number
                numberStack.append(Value)
            case .operator(let AssociatedOperation):
                switch AssociatedOperation {
                case .binaryOperation(let BinaryOperation):
                    if numberStack.count >= 2
                    {
                        let second = numberStack.popLast()!
                        let first = numberStack.popLast()!
                        numberStack.append(BinaryOperation(first, second))
                    }
                case .unaryOperation(let UnaryOp):
                    if numberStack.count >= 1
                    {
                        numberStack.append(UnaryOp(numberStack.popLast()!))
                    }
                }
            case .variable(let VariableName):
                numberStack.append(VariableValue(VariableName))
            }
        }
        
        if numberStack.count == 1
        {
            return numberStack.popLast()!
        }
        
        return Double.nan
    }
    
    
    init(expression : String)
    {
        if expression.hasPrefix("-") || expression.hasPrefix("−")
        {
            self._exp = "0" + expression
            return
        }
        self._exp = expression
    }
}

class InfixToPostfixConverter
{
    fileprivate let TokenString = "()^*/+-÷×−"
    
    fileprivate var infixString = "" {
        didSet{
            self.saved_expression = self.PostfixExpression(infixString)
        }
    }
    
    fileprivate let OperationTable = ["+" : Operation.binaryOperation({ $0 + $1 }), "-" : Operation.binaryOperation({ $0 - $1 }),
                                  "*" : Operation.binaryOperation({ $0 * $1 }), "/" : Operation.binaryOperation({ $0 / $1 }),
                                  "^" : Operation.binaryOperation({ pow($0, $1) }), "÷" : Operation.binaryOperation({ $0 / $1 }),
                                  "×" : Operation.binaryOperation({ $0 * $1 }), "−" : Operation.binaryOperation({ $0 - $1 })]
    
    fileprivate var saved_expression = [ExpressionElement]()
    
    var PostfixExpression : [ExpressionElement]
        {
        get
        {
            if saved_expression.isEmpty {
                saved_expression = PostfixExpression(infixString)
            }
            return saved_expression
        }
    }
    
    fileprivate func IsOperator(_ op : String) -> Bool
    {
        return OperationTable[op] != nil
    }
    
    fileprivate func HasHigherPrecendence(_ left : Character, right : Character) -> Bool
    {
        if !TokenString.characters.contains(left) || !TokenString.characters.contains(right) { return false }
        return TokenString.characters.index(of: left) <= TokenString.characters.index(of: right)
    }
    
    fileprivate func PostfixExpression(_ input : String) -> [ExpressionElement]
    {
        var outputList = [ExpressionElement]()
        var opstack = [String]()
        
        let Tokens = input.Tokenize(TokenString)
        for token in Tokens
        {
            if let number = token.doubleValue
            {
                outputList.append(ExpressionElement.number(number))
            }
            else if token == "("
            {
                opstack.append(token)
            }
            else if token == ")"
            {
                while !opstack.isEmpty
                {
                    let current = opstack.popLast()!
                    if current != "("
                    {
                        outputList.append(ExpressionElement.operator(OperationTable[current]!))
                    }else { break }
                }
            }
            else if IsOperator(token)
            {
                //If the token is an operator, *, /, +, or -, push it on the opstack. However, first remove any operators already on the opstack that have higher or equal precedence and append them to the output list.
                
                while !opstack.isEmpty
                {
                    let current = opstack.popLast()!
                    if current != "(" && current != ")"{
                        if HasHigherPrecendence(current.characters.first!, right: token.characters.first!)
                        {
                            outputList.append(ExpressionElement.operator(OperationTable[current]!))
                        }
                        else
                        {
                            opstack.append(current)
                        }
                    }
                    else
                    {
                        opstack.append(current)
                        break
                    }
                }
                
                opstack.append(token)
            }else {
                outputList.append(ExpressionElement.variable(token))
            }
        }
        
        while let last = opstack.popLast()
        {
            outputList.append(ExpressionElement.operator(OperationTable[last]!))
        }
        
        return outputList
    }
    
    init(infixString : String)
    {
        self.infixString = infixString
    }
}
