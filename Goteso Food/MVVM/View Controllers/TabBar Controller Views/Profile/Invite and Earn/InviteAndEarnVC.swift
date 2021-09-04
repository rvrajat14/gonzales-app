//
//  InviteAndEarnVC.swift
//  FoodApplication
//
//  Created by Kishore on 04/06/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit

class InviteAndEarnVC: UIViewController {

    var referral_code = ""
    var points = "0"
    var invite_string = ""
    var user_id = ""
    
    @IBOutlet weak var pageTitleLbl: UILabel!
    
    @IBOutlet weak var shareYourReffalCodeLbl: UILabel!
    @IBOutlet weak var inviteFriendsLbl: UILabel!
    @IBOutlet weak var earnRewardsLbl: UILabel!
    @IBAction func backButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func inviteFriendsButton(_ sender: UIButton) {
     print(invite_string)
            let vc = UIActivityViewController(activityItems: [invite_string], applicationActivities: [])
         self.present(vc, animated: true, completion: nil)
        if let pop = vc.popoverPresentationController {
            let v = sender as UIView 
            pop.sourceView = v
            pop.sourceRect = v.bounds
        }
 
    }
    
   
    
    @IBOutlet weak var inviteFriendsButton: UIButton!
    @IBOutlet weak var promoCodeLbl: UILabel!
    
    @IBOutlet weak var rewardPointsLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pageTitleLbl.text = "y_invite_page_title".getLocalizedValue()
        earnRewardsLbl.text = "y_invite_title".getLocalizedValue()
        inviteFriendsLbl.text = "y_invite_desc".getLocalizedValue()
        shareYourReffalCodeLbl.text = "y_invite_share".getLocalizedValue()
        inviteFriendsButton.setTitle("y_invite_button".getLocalizedValue(), for: .normal)
        promoCodeLbl.text = referral_code
        self.inviteFriendsButton.layer.cornerRadius = 6
        self.rewardPointsLbl.text = "You have \(points) reward points"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    
}
