//
//  GraphViewController.swift
//  CalculatorProject
//
//  Created by Edoardo Franco Vianelli on 6/11/16.
//  Copyright © 2016 Edoardo Franco Vianelli. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController, GraphViewDelegate {
    
    var debugging = false
    
    @IBOutlet weak var graph: GraphView!
    @IBOutlet weak var StatusLabel: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    var start = NSDate(timeIntervalSinceNow: 0)

    override func viewDidLoad() {
        super.viewDidLoad()
        spinner.hidesWhenStopped = true
        debugging = true
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func MoveGraphUp() {
        graph.MoveDown()
    }
    
    @IBAction func MoveGraphRight() {
        graph.MoveLeft()
    }
    
    @IBAction func MoveGraphLeft() {
        graph.MoveRight()
    }
    
    @IBAction func MoveGraphDown() {
        graph.MoveUp()
    }
    
    @IBAction func ZoomIn() {
        graph.ZoomIn()
    }
    
    @IBAction func ZoomOut() {
        graph.ZoomOut()
    }
    
    @IBAction func DisplayInfo() {
        let title = "Useful Information"
        let message = "Use the arrows to move the graph up, down, left and right.\nUse the + and - buttons to zoom in and out, respectively"
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
        let informationAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        informationAlert.addAction(okAction)
        self.presentViewController(informationAlert, animated: true, completion: nil)
    }
    
    func SetButtons(enabled : Bool){
        for view in graph.subviews{
            if let button = view as? UIButton{
                button.enabled = enabled
            }
        }
    }
    
    //MARK: GraphViewDelegate
    
    func RenderingStarted(){
        start = NSDate(timeIntervalSinceNow: 0)
    }
    
    func RenderingEnded(iterations : Int){
        let timeTaken = NSDate().timeIntervalSinceDate(start)
        print("Time taken is \(timeTaken)")
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
