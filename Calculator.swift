//
//  Calculator.swift
//  CalculatorProject
//
//  Created by Edoardo Franco Vianelli on 6/11/16.
//  Copyright © 2016 Edoardo Franco Vianelli. All rights reserved.
//

import Foundation

typealias RPNTokens = [String]

enum Operation
{
    case BinaryOperation( (Double, Double) -> Double)
    case UnaryOperation( Double -> Double )
}

enum ExpressionElement
{
    case Variable ( String )
    case Number (Double)
    case Operator ( Operation )
}

extension String
{
    var doubleValue : Double?
    {
        return NSNumberFormatter().numberFromString(self)?.doubleValue
    }
    
    func Tokenize(str : String) -> [String]
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
    private var variables = Dictionary<String, Double>()
    
    private var _exp = ""
    var Expression : String { return _exp }
    
    var Result : Double
    {
        get { return self.EvaluateExpression() }
    }
    
    func SetVariableValue(variable : String, value : Double)
    {
        variables[variable] = value
    }
    
    func VariableValue(variableName : String) -> Double
    {
        if let Value = variables[variableName]
        {
            return Value
        }
        return 0.0
    }
    
    
    private func EvaluateExpression() -> Double
    {
        var numberStack = [Double]()
        let pfConverter = InfixToPostfixConverter(infixString: Expression)
        let items = pfConverter.PostfixExpression
        for item in items
        {
            switch item {
            case .Number(let Value):
                //found a number
                numberStack.append(Value)
            case .Operator(let AssociatedOperation):
                switch AssociatedOperation {
                case .BinaryOperation(let BinaryOperation):
                    if numberStack.count >= 2
                    {
                        let second = numberStack.popLast()!
                        let first = numberStack.popLast()!
                        numberStack.append(BinaryOperation(first, second))
                    }
                case .UnaryOperation(let UnaryOp):
                    if numberStack.count >= 1
                    {
                        numberStack.append(UnaryOp(numberStack.popLast()!))
                    }
                }
            case .Variable(let VariableName):
                numberStack.append(VariableValue(VariableName))
            }
        }
        
        if numberStack.count == 1
        {
            return numberStack.popLast()!
        }
        
        return Double.NaN
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
    private let TokenString = "()^*/+-÷×−"
    
    private var infixString = "" {
        didSet{
            self.saved_expression = self.PostfixExpression(infixString)
        }
    }
    
    private let OperationTable = ["+" : Operation.BinaryOperation({ $0 + $1 }), "-" : Operation.BinaryOperation({ $0 - $1 }),
                                  "*" : Operation.BinaryOperation({ $0 * $1 }), "/" : Operation.BinaryOperation({ $0 / $1 }),
                                  "^" : Operation.BinaryOperation({ pow($0, $1) }), "÷" : Operation.BinaryOperation({ $0 / $1 }),
                                  "×" : Operation.BinaryOperation({ $0 * $1 }), "−" : Operation.BinaryOperation({ $0 - $1 })]
    
    private var saved_expression = [ExpressionElement]()
    
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
    
    private func IsOperator(op : String) -> Bool
    {
        return OperationTable[op] != nil
    }
    
    private func HasHigherPrecendence(left : Character, right : Character) -> Bool
    {
        if !TokenString.characters.contains(left) || !TokenString.characters.contains(right) { return false }
        return TokenString.characters.indexOf(left) <= TokenString.characters.indexOf(right)
    }
    
    private func PostfixExpression(input : String) -> [ExpressionElement]
    {
        var outputList = [ExpressionElement]()
        var opstack = [String]()
        
        let Tokens = input.Tokenize(TokenString)
        for token in Tokens
        {
            if let number = token.doubleValue
            {
                outputList.append(ExpressionElement.Number(number))
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
                        outputList.append(ExpressionElement.Operator(OperationTable[current]!))
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
                            outputList.append(ExpressionElement.Operator(OperationTable[current]!))
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
                outputList.append(ExpressionElement.Variable(token))
            }
        }
        
        while let last = opstack.popLast()
        {
            outputList.append(ExpressionElement.Operator(OperationTable[last]!))
        }
        
        return outputList
    }
    
    init(infixString : String)
    {
        self.infixString = infixString
    }
}