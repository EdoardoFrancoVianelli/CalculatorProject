//
//  MoreViewController.swift
//  CalculatorProject
//
//  Created by Edoardo Franco Vianelli on 6/15/16.
//  Copyright © 2016 Edoardo Franco Vianelli. All rights reserved.
//

extension String{
    func removeSpaces() -> String{
        return self.replacingOccurrences(of: " ", with: "")
    }
}

import UIKit

class MoreViewController: UITableViewController {

    private let DefaultsForName = ["XMax" : "10",
                                   "XMin" : "-10",
                                   "XScale" : "1.0",
                                   "YMax" : "10.0",
                                   "YMin" : "-10.0",
                                   "YScale" : "1.0",
                                   "Y1" : "x",
                                   "Y2" : "x^2",
                                   "Y3" : "x^3",
                                   "Y4" : "x^4",
                                   "Y5" : "x^5",
                                   "Y6" : "x^6"]
    fileprivate let CellIdentifier = "MoreCell"
    fileprivate let NamesForSection = [1 : ["X Max", "X Min", "X Scale"] , 2 : ["Y Max", "Y Min", "Y Scale"],
                                   3 : ["Y1", "Y2", "Y3", "Y4", "Y5", "Y6"] ]
    
    private func initSettings(){
        if Settings.getSaved("XMax") == nil{
            Settings.setSaved("XMax", 10.0)
        }
        if Settings.getSaved("XMin") == nil{
            Settings.setSaved("XMin", -10.0)
        }
        if Settings.getSaved("XScale") == nil{
            Settings.setSaved("XScale", 1.0)
        }
        if Settings.getSaved("YMax") == nil{
            Settings.setSaved("YMax", 10.0)
        }
        if Settings.getSaved("YMin") == nil{
            Settings.setSaved("YMin", -10.0)
        }
        if Settings.getSaved("YScale") == nil{
            Settings.setSaved("YScale", 1.0)
        }
        
        for expressionName in ["Y1","Y2","Y3","Y4","Y5","Y6"]{
            if Settings.getSaved(expressionName) == nil{
                Settings.setSaved(expressionName, "")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSettings()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func ParameterChanged(_ sender: UITextField) {
    
        sender.resignFirstResponder()
    }
    
    @IBAction func SetParameter(_ sender : UITextField)
    {
        guard let cell = sender.superview?.superview as? MoreTableViewCell else { return }
        guard let parameterName = cell.Label?.text?.removeSpaces() else { return }
        guard let CurrentValue = sender.text else { return }
        let equationNames = ["Y1","Y2","Y3", "Y4", "Y5", "Y6"]
        if !equationNames.contains(parameterName)
        {
            guard let NewValue = NumberFormatter().number(from: CurrentValue)?.doubleValue else { return }
            let current_value = Settings.getSavedOrDefaultDouble(parameterName, 1.0)
            Settings.setSaved(parameterName, NewValue)
            
            if (parameterName == "XScale" || parameterName == "YScale") { //scale needs to be non-negative
                if NewValue < 0{
                    sender.text = "\(current_value)"
                    Settings.setSaved(parameterName, current_value)
                }
            }else if (parameterName.hasPrefix("X")){                 //mins need to be smaller than max
                if Settings.XMin >= Settings.XMax{
                    sender.text = "\(current_value)"
                    Settings.setSaved(parameterName, current_value)
                }
            }else if (parameterName.hasPrefix("Y")){
                if Settings.YMin >= Settings.YMax{
                    sender.text = "\(current_value)"
                    Settings.setSaved(parameterName, current_value)
                }
            }
        }
        else
        {
            Settings.setSaved(parameterName, CurrentValue)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @objc func confirmSettings(){
        dismiss(animated: true, completion: nil)
        print("Confirmed")
    }
    
    @objc func cancelSettings(){
        dismiss(animated: true, completion: nil)
        print("Cancelled")
    }
    
    
    //MARK: UITableViewDelegate and Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1, 2:
            return 3
        default:
            return 6
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return ""
        case 1:
            return "X Parameters"
        case 2:
            return "Y Parameters"
        case 3:
            return "Functions"
        default:
            return "Error"
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section > 0{
            guard let currentCell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier) as? MoreTableViewCell else{
                return UITableViewCell()
            }
            if let Names = NamesForSection[indexPath.section]
            {
                currentCell.Label.text = Names[indexPath.row]
                let parameter_id = currentCell.Label.text!.removeSpaces()
                let default_value = DefaultsForName[parameter_id]!
                currentCell.TextField.text = "\(Settings.getSavedOrDefault(parameter_id, default_value))"
            }
            else
            {
                currentCell.Label.text = "Error"
            }
            return currentCell
        }else{
            guard let currentCell = tableView.dequeueReusableCell(withIdentifier: "ConfirmCell", for: indexPath) as? ConfirmCellTableViewCell else {
                return UITableViewCell()
            }
            currentCell.cancelButton?.addTarget(self, action: #selector(MoreViewController.cancelSettings), for: UIControlEvents.touchUpInside)
            currentCell.confirmButton?.addTarget(self, action: #selector(MoreViewController.confirmSettings), for: UIControlEvents.touchUpInside)
            return currentCell
        }
    }
    
}















