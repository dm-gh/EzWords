//
//  DetailViewController.swift
//  EZ Language
//
//  Created by Fedor on 15.09.2018.
//  Copyright © 2018 rodiv. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController{

    @IBOutlet weak var detailDescriptionLabel: UILabel!

    @IBOutlet weak var detailDescriptionTextField: UITextField!
    
    @IBOutlet weak var ShowTranslationButton: UIButton!
    
    var detailItem: String?
    var detailItem2: String?
    var isTranslated: Bool?
    
    func configureView() {
        
        ShowTranslationButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        // Update the user interface for the detail item.
        if let label = detailDescriptionLabel {
            label.text = "Enter the word's translation"
            //label.isHidden = true
        }
        
        if let textField = detailDescriptionTextField {
            textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField.text == detailItem{
            textField.text = "Correct"
            isTranslated = true
            
        }
    }
    
    
    @objc func buttonAction(sender: UIButton!) {
        detailDescriptionTextField.text = detailItem
    }
    
}

