//
//  GraphViewController.swift
//  CalculatorProject
//
//  Created by Edoardo Franco Vianelli on 6/11/16.
//  Copyright © 2016 Edoardo Franco Vianelli. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController, GraphViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var menuView: RoundedView!
    @IBOutlet weak var roundView: RoundedView!
    @IBOutlet weak var pannableView: UIView!
    @IBOutlet weak var pannableMenuToggleButton: UIButton!
    @IBOutlet weak var toggleNavigationMenuButton: UIButton!
    
    var pannableMenuToggled = false
    @IBAction func toggleOptionMenu(_ sender: UIButton) {
        toggleOptionMenue(toggle: !pannableMenuToggled, sender: sender)
    }
    
    func toggleOptionMenue(toggle : Bool, sender : UIButton){
        UIView.animate(withDuration: 0.5, animations: {
            if toggle{
                self.pannableView.frame.origin.x = self.view.frame.size.width - self.pannableView.frame.size.width
                self.graph.frame.origin.x = self.pannableView.frame.origin.x - self.graph.frame.size.width
            }else{
                self.pannableView.frame.origin.x = self.view.frame.size.width
                self.graph.frame.origin.x = 0
            }
            sender.frame.origin.x = self.pannableView.frame.origin.x - sender.frame.size.width - 8
            self.menuView.frame.origin.x = self.pannableView.frame.origin.x - self.menuView.frame.size.width - 8
        })
        pannableMenuToggled = toggle
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        toggleOptionMenue(toggle: false, sender: pannableMenuToggleButton)
        toggleNavigationMenu(button: toggleNavigationMenuButton, toggleMenu: false)
    }
    
    @IBAction func toggleNavigationMenu(_ sender: Any) {
        let menuToggled = (self.roundView.transform == .identity)
        toggleNavigationMenu(button: sender as! UIButton, toggleMenu: menuToggled)
    }
    
    func navigationMenuSize(toggled : Bool) -> CGFloat{
        
        if !toggled{
            return 40
        }
        
        var total : CGFloat = 0.0
        
        for view in self.menuView.subviews{
            if view is UIButton{
                total += view.frame.size.width
            }
        }
        
        return total
    }
    
    func toggleNavigationMenu(button : UIButton, toggleMenu : Bool){
        let image = toggleMenu ? UIImage(named: "Right Arrow") : UIImage(named: "Left Arrow")
        let xStretch : CGFloat = 20//2*(self.menuView.frame.size.width + stretchAmount) / (button.frame.size.width)
        let yStretch : CGFloat = xStretch
        UIView.animate(withDuration: 0.75, animations: {
            if toggleMenu{
                self.roundView.transform = CGAffineTransform.init(scaleX: xStretch, y: yStretch)
            }else{
                self.roundView.transform = .identity
            }
            self.menuView.frame.size.width = self.navigationMenuSize(toggled: toggleMenu)
            self.menuView.frame.origin.x = self.pannableView.frame.origin.x - self.menuView.frame.size.width - 8
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
        graph.MoveUp()
    }
    
    @IBAction func MoveGraphRight() {
        graph.MoveLeft()
    }
    
    @IBAction func MoveGraphLeft() {
        graph.MoveRight()
    }
    
    @IBAction func MoveGraphDown() {
        graph.MoveDown()
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
    
    //MARK: Table View Data Source and Delegate
    
    let options : [(title : String, subtitle : String)] = [("Settings","Graph range settings")]
    let optionImages = [UIImage(named:"Settings")]
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0){
            return "Information"
        }else {
            return "Settings"
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "OptionsMenuCell", for: indexPath)
        
        if indexPath.section == 0{
            cell.textLabel?.text = "Grapher"
            cell.detailTextLabel?.text = "Version 1.0"
        }else{
            cell.textLabel?.text = options[indexPath.row].title
            cell.detailTextLabel?.numberOfLines = 2
            cell.detailTextLabel?.text = options[indexPath.row].subtitle
            cell.imageView?.image = optionImages[indexPath.row]
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 1{
            if indexPath.row == 0{
                let segueIdentifier = "rangesSetterSegue"
                toggleOptionMenue(toggle: false, sender: pannableMenuToggleButton)
                toggleNavigationMenu(button: toggleNavigationMenuButton, toggleMenu: false)
                self.performSegue(withIdentifier: segueIdentifier, sender: self)
            }
        }
    }
    
}







