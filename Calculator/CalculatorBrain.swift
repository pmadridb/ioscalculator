//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Pedro Madrid on 13/04/15.
//  Copyright (c) 2015 edu.stanford.cs193p.pmadrid. All rights reserved.
//

import Foundation

class CalculatorBrain {
    private enum Op: Printable {
        case Variable(String)
        case Operand(Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        
        var description: String {
            get {
                switch self {
                case .Variable(let operand):
                    return operand
                case .Operand(let operand):
                    return "\(operand)"
                case .UnaryOperation(let operation, _):
                    return operation
                case .BinaryOperation(let operation, _):
                    return operation
                }
            }
        }

    }
    var description: String {
        get {
            let (desc,remOps) = getDescription(opVisualStack)
            return desc!
        }
    }
    private var opStack = [Op]()
    
    private var opVisualStack = [Op]()
    
    var variableValues = Dictionary<String,Double>()
    
    private var knownOps = [String:Op]()
    
//    var program: AnyObject {
//        get {
//            return opStack.map({$0.description})
//        }
//        set {
//            if let opSymbols = newValue as? Array<String> {
//                var newOpStack = [Op]()
//                for opSymbol in opSymbols {
//                    if let op = knownOps[opSymbol] {
//                        newOpStack.append(op)
//                    } else if let operand = NSNumberFormatter().numberFromString(opSymbol)?.doubleValue {
//                        newOpStack.append(Op.Operand(operand))
//                    }
//                }
//                opStack = newOpStack
//            }
//        }
//    }
    
    private func getDescription(ops: [Op]) -> (result: String?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case Op.Variable(let operand):
                return ("\(variableValues[operand])", remainingOps)
            case Op.Operand(let operand):
                return ("\(operand)", remainingOps)
            case Op.UnaryOperation(let symbol, let operation):
                let operandEvaluation = getDescription(remainingOps)
                if let operand = operandEvaluation.result {
                    return (symbol + "\(operand)", operandEvaluation.remainingOps)
                }
            case Op.BinaryOperation(let symbol, let operation):
                let op1Evaluation = getDescription(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = getDescription(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return ("\(operand2)" + symbol + "\(operand1)", op2Evaluation.remainingOps)
                    }
                }
            }
        }
        return ("", ops)
    }
    
    init() {
        knownOps["X"] = Op.BinaryOperation("X", *)
        knownOps["/"] = Op.BinaryOperation("/") { $1 / $0 }
        knownOps["+"] = Op.BinaryOperation("+", +)
        knownOps["-"] = Op.BinaryOperation("-") { $1 - $0 }
        knownOps["√"] = Op.UnaryOperation("√", sqrt)
        knownOps["sin"] = Op.UnaryOperation("sin", sin)
        knownOps["cos"] = Op.UnaryOperation("cos", cos)
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case Op.Variable(let operand):
                return (variableValues[operand], remainingOps)
            case Op.Operand(let operand):
                return (operand, remainingOps)
            case Op.UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case Op.BinaryOperation(_, let operation):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
            }
        }
        return (nil, ops)
    }
    
    func evaluate() -> Double? {
        let (result, remaining) = evaluate(opStack)
        opStack.removeAll(keepCapacity: false)
        opStack += remaining
        opStack.append(Op.Operand(result!))
        return result
    }
    
    func pushOperand(operand: Double?) -> Double? {
        opStack.append(Op.Operand(operand!))
        opVisualStack.append(Op.Operand(operand!))
        return evaluate()
    }
    
    func pushOperand(symbol: String) -> Double? {
        opStack.append(Op.Variable(symbol))
        opVisualStack.append(Op.Variable(symbol))
        return evaluate()
    }
    
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
            opVisualStack.append(operation)
        }
        return evaluate()
    }
    func clear() {
        opStack.removeAll(keepCapacity: false)
        opVisualStack.removeAll(keepCapacity: false)
    }
    
}