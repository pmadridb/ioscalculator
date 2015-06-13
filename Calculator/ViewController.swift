//
//  ViewController.swift
//  Calculator
//
//  Created by Pedro Madrid on 11/04/15.
//  Copyright (c) 2015 edu.stanford.cs193p.pmadrid. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var display: UILabel!
    
    @IBOutlet weak var stack: UILabel!
    
    var typingANumber = false
    
    var operandStack = Array<Double>()
    
    var brain = CalculatorBrain()
    
    var displayValue: Double? {
        get {
            if let number = NSNumberFormatter().numberFromString(display.text!) {
                return number.doubleValue
            } else {
                return nil
            }
        }
        set {
            display.text = "\(newValue!)"
            typingANumber = false
        }
    }

    @IBAction func operate(sender: UIButton) {
        if typingANumber {
            enter()
        }
        if let operation = sender.currentTitle {
            if let result = brain.performOperation(operation) {
                displayValue = result
            } else {
                displayValue = 0
            }
        }
        stack.text = brain.description
    }

    @IBAction func clear() {
        brain.clear()
        typingANumber = false
        display.text = "0"
        stack.text = ""
    }
    
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if typingANumber {
            if digit == "." && display.text!.rangeOfString(".") != nil {
                return
            }
            display.text = display.text! + digit
        } else {
            display.text = digit
            typingANumber = true
        }
    }
    
    @IBAction func enter() {
        typingANumber = false
        if let result = brain.pushOperand(displayValue!) {
            displayValue = result
        }
        stack.text = brain.description
    }
}

