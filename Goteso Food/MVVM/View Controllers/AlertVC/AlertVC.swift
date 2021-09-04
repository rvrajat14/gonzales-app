//
//  AlertVC.swift
//  Taco Manager
//
//  Created by IOS on 18/01/20.
//  Copyright © 2020 Kishore. All rights reserved.
//

import UIKit

protocol LogoutDelegate {
    func logout(value:String)
}


class AlertVC: UIViewController {

    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var payBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    @IBOutlet weak var okBtn: UIButton!
    
    @IBOutlet weak var centerV: UIView!
    @IBOutlet weak var btnsView: UIView!
    var titleText = ""
    var isFromLoginVC = false
    
    var logoutDelegate : LogoutDelegate!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.okBtn.setTitle("z_ok".getLocalizedValue(), for: .normal)
        self.cancelBtn.setTitle("z_no".getLocalizedValue(), for: .normal)
        self.payBtn.setTitle("z_yes".getLocalizedValue(), for: .normal)
        
        self.titleLbl.text = self.titleText
        self.alertView.layer.cornerRadius = 5
        self.btnsView.layer.cornerRadius = 5
        
        if isFromLoginVC {
            self.okBtn.isHidden = false
            self.payBtn.isHidden = true
            self.cancelBtn.isHidden = true
            self.centerV.isHidden = true
        }
        else {
            self.okBtn.isHidden = true
            self.payBtn.isHidden = false
            self.cancelBtn.isHidden = false
            self.centerV.isHidden = false
        }
    }
    
    @IBAction func cancelBtnTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        logoutDelegate.logout(value: "z_no".getLocalizedValue())
    }
    
    @IBAction func payBtnTapped(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
        logoutDelegate.logout(value: "z_yes".getLocalizedValue())
    }
    
    
    @IBAction func okBtnTapped(_ sender: UIButton) {
  
    }
}
