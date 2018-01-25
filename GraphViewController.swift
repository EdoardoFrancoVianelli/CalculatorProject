//
//  GraphViewController.swift
//  CalculatorProject
//
//  Created by Edoardo Franco Vianelli on 6/11/16.
//  Copyright © 2016 Edoardo Franco Vianelli. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController, GraphViewDelegate {
    
    @IBOutlet weak var menuView: RoundedView!
    @IBOutlet weak var roundView: RoundedView!
    
    @IBAction func toggleMenu(_ sender: Any) {
        guard let button = sender as? UIButton else {
            return
        }
        let menuToggled = !(self.roundView.transform == .identity)
        let stretchAmount : CGFloat = menuToggled ? -168 : 168
        let image = menuToggled ? UIImage(named: "Left Arrow") : UIImage(named: "Right Arrow")
        UIView.animate(withDuration: 0.75, animations: {
            if !menuToggled{
                let xStretch : CGFloat = 2*(self.menuView.frame.size.width + stretchAmount) / (button.frame.size.width)
                let yStretch : CGFloat = xStretch
                self.roundView.transform = CGAffineTransform.init(scaleX: xStretch, y: yStretch)
            }else{
                self.roundView.transform = .identity
            }
            self.menuView.frame.origin.x -= stretchAmount
            self.menuView.frame.size.width += stretchAmount
        }, completion: {
            
            (argument : Bool) in
            
                UIView.animate(withDuration: 0.5, animations: {
                    button.setBackgroundImage(image, for: .normal)
                })
            
        })
    }
    
    var delegate : GraphViewControllerDelegate?
    
    var debugging = false
    
    @IBOutlet weak var graph: GraphView!
    @IBOutlet weak var StatusLabel: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView?
    var start = Date(timeIntervalSinceNow: 0)

    override func viewWillAppear(_ animated: Bool) {
        delegate?.GraphViewDidAppear(newXMax: Settings.XMax,
                                     newXMin: Settings.XMin,
                                     newXScale: Settings.XScale,
                                     newYMax: Settings.YMax,
                                     newYMin: Settings.YMin,
                                     newYScale: Settings.YScale)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.graph.delegate = self
        self.delegate = graph
        spinner?.hidesWhenStopped = true
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
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
        let informationAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        informationAlert.addAction(okAction)
        self.present(informationAlert, animated: true, completion: nil)
    }
    
    func SetButtons(_ enabled : Bool){
        for view in graph.subviews{
            if let button = view as? UIButton{
                button.isEnabled = enabled
            }
        }
    }
    
    //MARK: GraphViewDelegate
    
    func RenderingStarted(){
        start = Date(timeIntervalSinceNow: 0)
    }
    
    func RenderingEnded(_ iterations : Int){
        let timeTaken = Date().timeIntervalSince(start)
        print("Time taken is \(timeTaken)")
    }
    
    func minXDidChange(minX : CGFloat){
        Settings.XMin = Double(minX)
    }
    
    func maxXDidChange(maxX : CGFloat){
        Settings.XMax = Double(maxX)
    }
    
    func xScaleDidChange(xScale : CGFloat){
        Settings.XScale = Double(xScale)
    }
    
    func minYDidChange(minY : CGFloat){
        Settings.YMin = Double(minY)
    }
    
    func maxYDidChange(maxY : CGFloat){
        Settings.YMax = Double(maxY)
    }
    
    func yScaleDidChange(yScale : CGFloat){
        Settings.YScale = Double(yScale)
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
