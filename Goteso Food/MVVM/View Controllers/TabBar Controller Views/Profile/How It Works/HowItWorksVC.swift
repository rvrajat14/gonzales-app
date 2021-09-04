//
//  HowItWorksVC.swift
//  My MM
//
//  Created by Kishore on 28/11/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit

class HowItWorksVC: UIViewController {

    @IBAction func backButton(_ sender: UIButton) {
    self.navigationController?.popViewController(animated: true)
    }
    @IBOutlet weak var txtField: UITextView!
    @IBOutlet weak var backButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = true
        self.tabBarController?.tabBar.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

     

}
