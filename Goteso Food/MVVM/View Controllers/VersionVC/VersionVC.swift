//
//  VersionVC.swift
//  OneTime
//
//  Created by Apple on 03/12/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class VersionVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.msgLbl.text = versionMsg
    }

    @IBOutlet weak var msgLbl: UILabel!
    @IBAction func updateBtnTaped(_ sender: Any) {
        
        print("updated pres")
      
        if let aLink = URL(string: ITUNESLINK) {
            UIApplication.shared.open(aLink, options: [:], completionHandler: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
