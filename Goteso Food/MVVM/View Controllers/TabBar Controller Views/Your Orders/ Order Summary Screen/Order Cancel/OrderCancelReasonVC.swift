//
//  OrderCancelReasonVC.swift
//  My MM
//
//  Created by Kishore on 16/11/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit
import IQKeyboardManager

class OrderCancelReasonVC: UIViewController {

    @IBOutlet weak var serverErrorView: UIView!
    var order_id = ""
    var cancel_reason = ""
    var user_id = ""
    var cancelReasonDataArray = NSMutableArray.init()
     var isTxtBoxHidden = true
    @IBOutlet weak var backView: UIView!
    @IBAction func cancelOrderButton(_ sender: UIButton) {
        
        if cancel_reason.isEmpty {
            
            if isTxtBoxHidden
            {
                 self.view.makeToast("y_order_reason_title".getLocalizedValue())
            }
            else
            {
                 self.view.makeToast("enter_cancel_reason".getLocalizedValue())
            }
            
             
            self.view.clearToastQueue()
        }
        else
        {
        orderCancelAPI()
        }
    }
    
    @IBOutlet weak var cancelOrderButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBAction func backButton(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name.init("BlurVHideNotification"), object: nil)
        self.dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var orderNumberLbl: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        backButton.setTitle("z_back".getLocalizedValue(), for: .normal)
        cancelOrderButton.setTitle("z_cancel_order".getLocalizedValue(), for: .normal)
        
        let nib = UINib(nibName: "RadioButtonTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "RadioButtonTableViewCell")
        serverErrorView.isHidden = true
        self.backView.layer.masksToBounds = true
        self.backView.layer.cornerRadius = 10
        self.orderNumberLbl.text = "#\(order_id)"
        if cancelReasonDataArray.count > 0
        {
            if (cancelReasonDataArray[0] as! NSDictionary)["title"] as! String == "z_other".getLocalizedValue()
            {
                cancelReasonDataArray.removeObject(at: 0)
            }
        }
        self.cancelReasonDataArray.add(NSDictionary(dictionaryLiteral: ("title","z_other".getLocalizedValue()),("isSelected","0")))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
   
    
    //MARK: Order Cancel API
    func orderCancelAPI()  {
        let api_name = APINAME().ORDER_CANCEL + "/\(order_id)"
        let param = ["user_id":user_id ,"user_type":"1","reason":cancel_reason]
        print(param)
      
       WebService.requestPUTUrlWithJSONDictionaryParameters(strURL: api_name , is_loader_required: true, params: param, success: { (response) in
            print(response)
            
            
            
            DispatchQueue.main.async {
                if response["status_code"] as! NSNumber == 1
                {
                    NotificationCenter.default.post(name: NSNotification.Name.init("BlurVHideNotification"), object: nil, userInfo: ["toastMsg":(response["message"] as! String)])
                    self.dismiss(animated: true, completion: nil)
                }
                else
                {
                    self.view.makeToast((response["message"] as! String))
                    self.view.clearToastQueue()
                }
            }
            
            
        }) { (error) in
            
        }
        
    }
    
    //MARK: Selector
    
    @objc func checkBoxButtonAction(sender: UIButton,event:AnyObject?)
    {
        let touches : Set<UITouch>
        touches = (event?.allTouches)!
        let touchPoint = touches.first?.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: touchPoint!)!
        let cell = self.tableView.cellForRow(at: indexPath) as! RadioButtonTableViewCell
        let tmpArray = (cancelReasonDataArray as! [NSDictionary])
        
        for (index,value) in tmpArray.enumerated() {
            let dataDic = value.mutableCopy() as! NSMutableDictionary
            
            if index == indexPath.row
            {
                dataDic.setObject("1", forKey: "isSelected" as NSCopying )
            }
            else
            {
                dataDic.setObject("0", forKey: "isSelected" as NSCopying )
            }
            cancelReasonDataArray.replaceObject(at: index, with: dataDic)
        }
        if cell.variantsNameLbl.text == "z_other".getLocalizedValue() {
             isTxtBoxHidden = false
            cancel_reason = ""
        }
        else
        {
            isTxtBoxHidden = true
            cancel_reason = cell.variantsNameLbl.text!
        }
     self.tableView.reloadData()
    }
    
    
}

extension OrderCancelReasonVC : UITableViewDelegate,UITableViewDataSource
{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cancelReasonDataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RadioButtonTableViewCell", for: indexPath) as! RadioButtonTableViewCell
        cell.variantsNameLbl.text = ((cancelReasonDataArray[indexPath.row] as! NSDictionary)["title"] as! String)
        cell.checkBoxButton.tag = indexPath.row
        let isSelected = (cancelReasonDataArray[indexPath.row] as! NSDictionary)["isSelected"] as! String
        if isSelected == "1" {
             cell.variantsNameLbl.textColor = MAIN_COLOR
            cell.checkBoxButton.setImage(#imageLiteral(resourceName: "round-checked"), for: .normal)
        }
        else
        {
            cell.variantsNameLbl.textColor = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.63)
            cell.checkBoxButton.setImage(#imageLiteral(resourceName: "radio_off"), for: .normal)
        }
        cell.checkBoxButton.addTarget(self, action: #selector(checkBoxButtonAction(sender:event:)), for: .touchUpInside)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if isTxtBoxHidden {
            return 0
        }
        else
        {
            return 150
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if isTxtBoxHidden {
            return UIView(frame: .zero)
        }
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 150))
        let subFooterView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 100))
        subFooterView.backgroundColor = .white
        footerView.backgroundColor = UIColor.groupTableViewBackground
        let txtView = IQTextView(frame: CGRect(x: 30, y: 0, width: self.view.frame.size.width - 60, height: 80))
        txtView.layer.cornerRadius = 2
        txtView.layer.borderWidth = 1
        txtView.layer.borderColor = UIColor.lightGray.cgColor
        txtView.font = UIFont(name: REGULAR_FONT, size: 16)
        txtView.placeholder = "h_type_here".getLocalizedValue()
        txtView.textColor = .black
        txtView.delegate = self
        
        subFooterView.addSubview(txtView)
        footerView.addSubview(subFooterView)
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 40))
        headerView.backgroundColor = UIColor.groupTableViewBackground
        let titleLbl = UILabel(frame: CGRect(x: 16, y: 10, width: self.view.frame.size.width - 32, height: 20))
        titleLbl.font = UIFont(name: REGULAR_FONT, size: 16)
        titleLbl.textColor = UIColor.darkGray
        titleLbl.text = "y_order_reason_desc".getLocalizedValue()
        headerView.addSubview(titleLbl)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = self.tableView.cellForRow(at: indexPath) as! RadioButtonTableViewCell
        let tmpArray = (cancelReasonDataArray as! [NSDictionary])
        
        for (index,value) in tmpArray.enumerated() {
            let dataDic = value.mutableCopy() as! NSMutableDictionary
            
            if index == indexPath.row
            {
                dataDic.setObject("1", forKey: "isSelected" as NSCopying )
            }
            else
            {
                dataDic.setObject("0", forKey: "isSelected" as NSCopying )
            }
            cancelReasonDataArray.replaceObject(at: index, with: dataDic)
        }
        if cell.variantsNameLbl.text == "z_other".getLocalizedValue() {
            isTxtBoxHidden = false
            cancel_reason = ""
        }
        else
        {
            isTxtBoxHidden = true
            cancel_reason = cell.variantsNameLbl.text!
        }
        self.tableView.reloadData()
    }
    
}


extension OrderCancelReasonVC : UITextViewDelegate
{
    public func textViewDidEndEditing(_ textView: UITextView)
    {
        self.cancel_reason = textView.text
    }
}


