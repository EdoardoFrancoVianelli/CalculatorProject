//
//  MoreViewController.swift
//  CalculatorProject
//
//  Created by Edoardo Franco Vianelli on 6/15/16.
//  Copyright © 2016 Edoardo Franco Vianelli. All rights reserved.
//

import UIKit

class MoreViewController: UITableViewController, MoreModelDelegate {

    fileprivate let DataModel = MoreModel()
    fileprivate let CellIdentifier = "MoreCell"
    fileprivate let NamesForSection = [0 : ["X Max", "X Min", "X Scale"] , 1 : ["Y Max", "Y Min", "Y Scale"],
                                   2 : ["Y 1", "Y 2", "Y 3", "Y 4", "Y 5", "Y 6"] ]
    fileprivate let SetterFunctions : Dictionary<String, (MoreModel, Double) -> Void> =
        [ "XMax"    : { $0.XMax = $1 },
          "X Min"   : { $0.XMin = $1 } ,
          "X Scale" : { $0.XScale = $1 },
          "Y Max"   : { $0.YMax = $1 },
          "Y Min"   : { $0.YMin = $1 },
          "Y Scale" : { $0.YScale = $1 } ]
    fileprivate let ValuesForNames : Dictionary<String, (MoreModel) -> String> = ["X Max" : { $0.XMax.description },
                                                                              "X Min"  : { $0.XMin.description },
                                                                              "X Scale"  : { $0.XScale.description },
                                                                              "Y Max" : { $0.YMax.description },
                                                                              "Y Min"  : { $0.YMin.description },
                                                                              "Y Scale"  : { $0.YScale.description },
                                                                              "Y 1" : { _ in "x" },
                                                                              "Y 2" : { _ in "x^2" },
                                                                              "Y 3" : { _ in "x^3" },
                                                                              "Y 4" : { _ in "x^4" },
                                                                              "Y 5" : { _ in "x^5" },
                                                                              "Y 6" : { _ in "x^6" }]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DataModel.delegate = self
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
        sender.resignFirstResponder()
        if let CurrentValue = sender.text{
            if let NewValue = NumberFormatter().number(from: CurrentValue)?.doubleValue
            {
                print("The new value is \(NewValue)")
            }
            else
            {
                print("\(CurrentValue) is not a valid number")
            }
        }else {
            print("The text field is empty")
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

    
    //MARK: UITableViewDelegate and Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0, 1:
            return 3
        default:
            return 6
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "X Parameters"
        case 1:
            return "Y Parameters"
        case 2:
            return "Functions"
        default:
            return "Error"
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let currentCell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier) as? MoreTableViewCell
        {
            if let Names = NamesForSection[indexPath.section]
            {
                currentCell.Label.text = Names[indexPath.row]
                if let value = ValuesForNames[currentCell.Label.text!]{
                    currentCell.TextField.text = value(DataModel)
                }
            }
            else
            {
                currentCell.Label.text = "Error"
            }
            return currentCell
        }
        
        return UITableViewCell()
    }
    
    //MARK: MoreModelDelegate
    
    func XScaleChanged(_ newXScale : Double){
        tableView.reloadData()
    }
    
    func XMinChanged(_ newXMin : Double){
        tableView.reloadData()
    }
    
    func XMaxChanged(_ newXMax : Double){
        tableView.reloadData()
    }
    
    func YScaleChanged(_ newYScale : Double){
        tableView.reloadData()
    }
    
    func YMinChanged(_ newYMin : Double){
        tableView.reloadData()
    }
    
    func YMaxChanged(_ newYMax : Double){
        tableView.reloadData()
    }
}















