//
//  ViewController.swift
//  EzWords
//
//  Created by Fedor on 24.09.2018.
//  Copyright © 2018 rodiv. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var wordLabel: UILabel!
    
    @IBOutlet weak var translationTextField: UITextField!
    
    @IBOutlet weak var blueLine: UIImageView!
    let blueLineName = "blue-line-png.png"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        blueLine.image = UIImage(named:blueLineName)
        
        // Do any additional setup after loading the view, typically from a nib.
    }


}

