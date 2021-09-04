//
//  EditInstructionVC.swift
//  My MM
//
//  Created by Kishore on 17/01/19.
//  Copyright © 2019 Kishore. All rights reserved.
//

import UIKit

class EditInstructionVC: UIViewController {

     @IBOutlet weak var serverErrorView: UIView!
     @IBOutlet weak var backView: UIView!
    @IBOutlet weak var tableView: UITableView!
    var selectedIndex = 0
    var itemDataDic = NSMutableDictionary.init()
    var instructionDataArray = NSMutableArray.init()
    
    @IBAction func updateButton(_ sender: UIButton) {
        itemDataDic["instructions"] = instructionDataArray
        productCartArray[selectedIndex] = itemDataDic
         NotificationCenter.default.post(name: NSNotification.Name.init("EditInstructionNotification"), object: nil, userInfo: ["msg":"Instructions updated successfully"])
       
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var updateButton: UIButton!
    
    @IBAction func backButton(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name.init("EditInstructionNotification"), object: nil)
        self.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        self.backView.layer.masksToBounds = true
        self.backView.layer.cornerRadius = 10
        instructionDataArray = (itemDataDic["instructions"] as! NSArray).mutableCopy() as! NSMutableArray
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  

}

extension EditInstructionVC : UITableViewDelegate,UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return instructionDataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let addInstructionNib = UINib(nibName: "AddInstructionTableViewCell", bundle: nil)
        self.tableView.register(addInstructionNib, forCellReuseIdentifier: "AddInstructionTableViewCell")
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddInstructionTableViewCell", for: indexPath) as! AddInstructionTableViewCell
        let dataDic = instructionDataArray[indexPath.row] as! NSDictionary
        cell.courierDetailsView.isHidden = true
        cell.instructionView.isHidden = false
        cell.instructionDetailsView.layer.cornerRadius = 6
        cell.instructionDetailsView.layer.borderWidth = 1
        cell.instructionDetailsView.layer.borderColor = UIColor.lightGray.cgColor
        cell.instructionTitleLbl.text = (dataDic["order_item_instructions_type_title"] as! String)
        cell.instructionDetailsTxt.delegate = self
        cell.instructionDetailsTxt.tag = indexPath.row
        print(dataDic)
        let placeholder = dataDic["order_item_instructions_type_placeholder"] as! String
       if let value = dataDic["value"] as? String
       {
            if value.isEmpty
            {
                cell.instructionDetailsTxt.placeholder = placeholder
            }
            else
            {
                cell.instructionDetailsTxt.text = value
            }
     }
        else
       {
        cell.instructionDetailsTxt.placeholder = placeholder
        }
        
        
        cell.selectionStyle = .none
        return cell
    }
}


extension EditInstructionVC : UITextFieldDelegate
{
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        
        let datadic = (instructionDataArray[textField.tag] as! NSDictionary).mutableCopy() as! NSMutableDictionary
        datadic.setObject(textField.text!, forKey: "value" as NSCopying)
        instructionDataArray.replaceObject(at: textField.tag, with: datadic)
        
        let cell = tableView.cellForRow(at: IndexPath(row: textField.tag, section: 0)) as! AddInstructionTableViewCell
        cell.instructionDetailsTxt.text = textField.text!
        
    }
}

