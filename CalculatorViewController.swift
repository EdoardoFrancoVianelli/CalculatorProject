//
//  CalculatorViewController.swift
//  CalculatorProject
//
//  Created by Edoardo Franco Vianelli on 6/11/16.
//  Copyright © 2016 Edoardo Franco Vianelli. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {

    @IBOutlet weak var DisplayLabel: UILabel!

    fileprivate var UserTyping = false
    
    var DisplayValue : Double?{
        get
        {
            return NumberFormatter().number(from: DisplayLabel.text!)?.doubleValue
        }
        set
        {
            if newValue == nil { self.DisplayText = "0"; return }
            self.DisplayText = "\(newValue!)"
        }
    }
    
    var DisplayText : String
    {
        get { return self.DisplayLabel.text! }
        set
        {
            self.DisplayLabel.text = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func TouchButton(_ sender: UIButton) {
        if !UserTyping
        {
            self.DisplayText = sender.currentTitle!
            UserTyping = true
            return
        }
        
        self.DisplayText += sender.currentTitle!
    }

    @IBAction func Backspace() {
        if DisplayText.characters.count > 1
        {
            DisplayText.remove(at: DisplayText.characters.index(before: DisplayText.endIndex))
        }
    }
    
    @IBAction func Clear() {
        DisplayValue = 0.0
    }
    
    @IBAction func Enter() {
        DisplayValue = ExpressionEvaluator(expression: DisplayText).Result
        UserTyping = false
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}













