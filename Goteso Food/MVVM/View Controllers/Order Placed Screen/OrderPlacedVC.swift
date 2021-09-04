//
//  OrderPlacedVC.swift
//  FoodApplication
//
//  Created by Kishore on 08/06/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit

class OrderPlacedVC: UIViewController {
    
    
    @IBOutlet weak var pleaseNoteDownLbl: UILabel!
    @IBOutlet weak var pageTitleLbl: UILabel!
    var order_number = ""
    
    @IBOutlet weak var yourOrderNoLbl: UILabel!
    @IBOutlet weak var orderPlacedLbl: UILabel!
    
    @IBOutlet weak var thanksForPlacingLbl: UILabel!
    @IBOutlet weak var continueShoppingButton: UIButton!
    @IBOutlet weak var orderNumberLbl: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        pageTitleLbl.text = "y_order_placed".getLocalizedValue()
        pleaseNoteDownLbl.text = "y_order_placed_bottom".getLocalizedValue()
        yourOrderNoLbl.text = "y_order_placed_desc2".getLocalizedValue()
        thanksForPlacingLbl.text = "y_order_placed_desc".getLocalizedValue()
        continueShoppingButton.setTitle("y_order_view_details".getLocalizedValue(), for: .normal)
        orderPlacedLbl.text = "y_order_placed_title".getLocalizedValue()
        self.continueShoppingButton.layer.cornerRadius = 6
        self.orderNumberLbl.text = order_number
        self.navigationController?.isNavigationBarHidden = true
          productCartArray.removeAllObjects()
        let userDefault = UserDefaults.standard
        
        if  userDefault.value(forKey: "productCartArray")  != nil{
            userDefault.removeObject(forKey: "productCartArray")
            userDefault.synchronize()
        }
       
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    @IBAction func continueShoppingButton(_ sender: UIButton) {
      
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "OrderSummaryVC") as! OrderSummaryVC
        viewController.appType = app_type
        viewController.order_id = order_number
        viewController.isFromOrderPlace = true
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    
}
