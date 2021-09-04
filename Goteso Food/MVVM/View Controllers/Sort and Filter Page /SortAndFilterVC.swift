//
//  SortAndFilterVC.swift
//  MY MM Provider APP
//
//  Created by Kishore on 29/11/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit
import NotificationCenter

class SortAndFilterVC: UIViewController {
    
    
    @IBOutlet weak var pageTitleLbl: UILabel!
    var selectedIndex = -1
    
    @IBOutlet weak var serverErrorView: UIView!
    var filterFieldsArray = NSMutableArray.init()
    var sortFieldsDataArray = NSMutableArray.init()
    var tmpSideMenuDataArray = NSMutableArray.init()
    
    
    @IBOutlet weak var mainV: UIView!
    @IBOutlet weak var optionsTableView: UITableView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sideViewWidth: NSLayoutConstraint!
    
    @IBOutlet weak var sideV: UIView!
   
    @IBAction func clearAllButton(_ sender: UIButton) {
        filterURL = ""
         NotificationCenter.default.post(name: NSNotification.Name.init("filterNotification"), object: nil, userInfo: ["url":""])
        clearAllData()
        sideMenuDataArray = NSMutableArray(array: tmpSideMenuDataArray)
        print(sideMenuDataArray)
    }
    @IBOutlet weak var applyButton: UIButton!
    @IBOutlet weak var clearAllButton: UIButton!
    
    @IBAction func applyButton(_ sender: UIButton) {
        if isValid() {
             sideMenuDataArray = NSMutableArray(array: tmpSideMenuDataArray)
            NotificationCenter.default.post(name: NSNotification.Name.init("filterNotification"), object: nil, userInfo: ["url":makeURL()])
            print(tmpSideMenuDataArray)
            self.dismiss(animated: true, completion: nil)
        }
        else
        {
           // self.view.makeToast("Select one option")
             //self.view.clearToastQueue()
            //return
        }
       
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        pageTitleLbl.text = "y_homepage_filter".getLocalizedValue()
        clearAllButton.setTitle("e_task_title".getLocalizedValue(), for: .normal)
        applyButton.setTitle("z_apply".getLocalizedValue(), for: .normal)
        self.mainV.layer.masksToBounds = true
        self.mainV.layer.cornerRadius = 12
       
        print(appDataDic)
        if sideMenuDataArray.count == 0 {
            
            if let filter = appDataDic["sort"] as? NSArray {
                let value = (filter as! [NSDictionary])[0]
                    sideMenuDataArray.add(NSDictionary(dictionaryLiteral: ("identifier",value["identifier"] as! String),("type",value["type"] as! String),("key",value["key"] as! String),("value",value["value"] as! NSArray),("isTypeSelected","1")))
            }
            
            
//            sideMenuDataArray.add(NSDictionary(dictionaryLiteral: ("identifier",""),("type","single"),("key","Sort"),("value",appDataDic["sort"] as! NSArray),("isTypeSelected","1")))
            if let filter = appDataDic["filter"] as? NSArray {
                for value in filter as! [NSDictionary]
                {
                    sideMenuDataArray.add(NSDictionary(dictionaryLiteral: ("identifier",value["identifier"] as! String),("type",value["type"] as! String),("key",value["key"] as! String),("value",value["value"] as! NSArray),("isTypeSelected","0")))
                }
            }
        }
        
        if appDataDic.count > 0 {
            for (index,value) in (sideMenuDataArray as! [NSDictionary]).enumerated()
            {
               if value["isTypeSelected"] as!String == "1"
               {
                selectedIndex = index
                break;
                }
            }
        }
        
        self.tmpSideMenuDataArray = NSMutableArray(array: sideMenuDataArray)
        if tmpSideMenuDataArray.count > 0 && selectedIndex == -1 {
            selectedIndex = 0
        }
        
        print(tmpSideMenuDataArray)
         self.tableView.separatorStyle = .none
        self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 1))
        let sideCellNib = UINib(nibName: "SideMenuTableCell", bundle: nil)
        self.tableView.register(sideCellNib, forCellReuseIdentifier: "SideMenuTableCell")
       self.tableView.reloadData()
        self.optionsTableView.reloadData()
        print(sideMenuDataArray)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
    func makeURL() -> String {
        
        var result = ""
        
        for mainValue in tmpSideMenuDataArray as! [NSDictionary] {
             var sortResult = ""
            var filterResult = ""
            if mainValue["type"] as! String != "single"
            {
               filterResult = "&" + (mainValue["identifier"] as! String) + "="
            }
            let valueArray = mainValue["value"] as! NSArray
            
                for value in valueArray as! [NSDictionary]
                {
                    if value["selected"] as! NSNumber == 1
                    {
                        //let title = value["title"] as! String
                        if mainValue["type"] as! String != "single"
                        {
                            if filterResult.hasSuffix("=")
                            {
                                filterResult += COMMON_FUNCTIONS.checkForNull(string: value["value"] as AnyObject).1
                            }
                            else
                            {
                                filterResult += "," + COMMON_FUNCTIONS.checkForNull(string: value["value"] as AnyObject).1
                            }
                        }
                        if mainValue["type"] as! String == "single"
                        {
                           sortResult = "orderby=" + COMMON_FUNCTIONS.checkForNull(string: value["value"] as AnyObject).1
                        }
                        
                    
                    }
                }
            if !sortResult.isEmpty
            {
                result += "&" + sortResult
            }
            
            if !filterResult.isEmpty
            {
                result += filterResult
            }
        }
        print(result)
        return result
    }
    
    //MARK: External Functions
    
    //MARK: Check For empty value
    func isValid() -> Bool {
        var result = false
        
        for  mainValue  in tmpSideMenuDataArray as! [NSDictionary] {
            let mainDataDic = mainValue.mutableCopy() as! NSMutableDictionary
            let valueArray = (mainDataDic["value"] as! NSArray).mutableCopy() as! NSMutableArray
            for subValue in valueArray as! [NSDictionary]
            {
                if subValue["selected"] as! NSNumber == 1
                {
                    return true
                }
                result = false
            }
        }
      return result
    }
    
    
    //MARK: Clear All Data
    
    func clearAllData()  {
        let tmpDataArray = tmpSideMenuDataArray
        for (mainIndex,mainValue) in (tmpDataArray as! [NSDictionary]).enumerated() {
            let mainDataDic = mainValue.mutableCopy() as! NSMutableDictionary
            mainDataDic["isTypeSelected"] = "0"
            let valueArray = (mainDataDic["value"] as! NSArray).mutableCopy() as! NSMutableArray
            for (subIndex,subValue) in (valueArray as! [NSDictionary]).enumerated()
            {
                let subDataDic = subValue.mutableCopy() as! NSMutableDictionary
                subDataDic["selected"] = 0
                valueArray.replaceObject(at: subIndex, with: subDataDic)
            }
            mainDataDic["value"] = valueArray
            tmpSideMenuDataArray.replaceObject(at: mainIndex, with: mainDataDic)
        }
        self.tableView.reloadData()
        self.optionsTableView.reloadData()
    }
    
    //MARK: Update allData array
    
    func updateAllDataArray(selectedIndex:Int) {
        let tmpDataArray = tmpSideMenuDataArray
        
        for (index,value) in (tmpDataArray as! [NSDictionary]).enumerated() {
            let dataDic = value.mutableCopy() as! NSMutableDictionary
            if index == selectedIndex
            {
                dataDic["isTypeSelected"] = "1"
            }
            else
            {
                dataDic["isTypeSelected"] = "0"
            }
            tmpSideMenuDataArray.replaceObject(at: index, with: dataDic)
        }
        self.tableView.reloadData()
    }
    
    
    //MARK: Check for single value
    
    func checkForSingleValue(index:Int) -> String {
        var result = ""
        
        for value in ((tmpSideMenuDataArray[index] as! NSDictionary)["value"] as! NSArray) as! [NSDictionary] {
            if value["selected"] as! NSNumber == 1
            {
                result = (value["title"] as! String)
            }
        }
        
        return result
    }
    
    //MARK: Check for multiple value
    
    func checkForMultipleValue(index:Int) -> String {
        var count = 0
        
        for value in ((tmpSideMenuDataArray[index] as! NSDictionary)["value"] as! NSArray) as! [NSDictionary] {
            if value["selected"] as! NSNumber == 1
            {
                count += 1
            }
        }
        
        if count == 0 {
            return ""
        }
        
        return "\(count) selected"
    }
    
    
    func setSingleTypeRow(indexPath: IndexPath,mainDic: NSDictionary)  {
        let dataArray = (mainDic["value"] as! NSArray).mutableCopy() as! NSMutableArray
        
        for (index,value) in (dataArray as! [NSDictionary]).enumerated()
        {
            let dataDic = value.mutableCopy() as! NSMutableDictionary
            if index == indexPath.row
            {
                dataDic.setObject(1, forKey: "selected" as NSCopying)
                dataArray.replaceObject(at: index, with: dataDic)
            }
            else
            {
                dataDic.setObject(0, forKey: "selected" as NSCopying)
                dataArray.replaceObject(at: index, with: dataDic)
            }
            
        }
        let dataDic = (mainDic.mutableCopy() as! NSMutableDictionary)
        dataDic["value"] = dataArray
        tmpSideMenuDataArray.replaceObject(at: selectedIndex, with: dataDic)
        
    }
    
    func setMultipleTypeRow(indexPath: IndexPath,mainDic: NSDictionary) -> Bool{
        let dataArray = (mainDic["value"] as! NSArray).mutableCopy() as! NSMutableArray
        let dataDic = (dataArray[indexPath.row] as! NSDictionary).mutableCopy() as! NSMutableDictionary
        var isSelected = false
        
        if dataDic["selected"] as! NSNumber == 1 {
            isSelected = false
            dataDic["selected"] = 0
        }
        else
        {
            isSelected = true
            dataDic["selected"] = 1
        }
        
        dataArray.replaceObject(at: indexPath.row, with: dataDic)
        let dataDic1 = (mainDic.mutableCopy() as! NSMutableDictionary)
        dataDic1["value"] = dataArray
        tmpSideMenuDataArray.replaceObject(at: selectedIndex, with: dataDic1)
        return isSelected
    }
    
    //MARK: Selector
    
    
    
    @objc func checkBoxButtonAction(sender:UIButton, event: AnyObject?)
    {
        let touches : Set<UITouch>
        touches = (event?.allTouches)!
        let firstTouch = touches.first!
        let touchPoint = firstTouch.location(in: self.optionsTableView)
        let indexPath = self.optionsTableView.indexPathForRow(at: touchPoint)
        let cell = self.optionsTableView.cellForRow(at: indexPath!) as! RadioButtonTableViewCell
        let mainDataDic = (tmpSideMenuDataArray[selectedIndex] as! NSDictionary)
         let sideMenuCell = tableView.cellForRow(at: IndexPath(row: selectedIndex, section: 0)) as! SideMenuTableCell
        if mainDataDic["type"] as! String == "single" {
            setSingleTypeRow(indexPath: indexPath!, mainDic: mainDataDic)
            sideMenuCell.sideLbl.isHidden = true
            sideMenuCell.valueLbl.text =  checkForSingleValue(index: selectedIndex)
        }
        else
        {
          if setMultipleTypeRow(indexPath: indexPath!, mainDic: mainDataDic)
            {
                  cell.variantsNameLbl.font = UIFont(name: SEMIBOLD, size: 17)
                cell.checkBoxButton.setImage(#imageLiteral(resourceName: "checkBox"), for: .normal)
            }
            else
          {
            cell.variantsNameLbl.font = UIFont(name: REGULAR_FONT, size: 15)
                cell.checkBoxButton.setImage(#imageLiteral(resourceName: "emptyCheckBox"), for: .normal)
            }
            sideMenuCell.sideLbl.isHidden = false
            sideMenuCell.valueLbl.text =  checkForMultipleValue(index: selectedIndex)
        }
        
       optionsTableView.reloadData()
        self.tableView.reloadData()
    }
    
    
    
}

extension SortAndFilterVC : UITableViewDelegate,UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        
        if tmpSideMenuDataArray.count > 0 {
            if tableView == optionsTableView {
                return ((tmpSideMenuDataArray[selectedIndex] as! NSDictionary)["value"] as! NSArray).count
            }
            else
            {
                return tmpSideMenuDataArray.count
            }
        }
        return 0
       
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == optionsTableView {
            let mainDataDic = (tmpSideMenuDataArray[selectedIndex] as! NSDictionary)
             let dataDic = (mainDataDic["value"] as! NSArray)[indexPath.row] as! NSDictionary
            
                let nib:UINib = UINib(nibName: "RadioButtonTableViewCell", bundle: nil)
                tableView.register(nib, forCellReuseIdentifier: "RadioButtonTableViewCell")
                let cell = tableView.dequeueReusableCell(withIdentifier: "RadioButtonTableViewCell", for: indexPath) as! RadioButtonTableViewCell
            
            if mainDataDic["type"] as! String == "multiple"
                {
                    if dataDic["selected"] as! NSNumber == 0
                        {
                             cell.variantsNameLbl.font = UIFont(name: REGULAR_FONT, size: 15)
                            cell.checkBoxButton.setImage(#imageLiteral(resourceName: "emptyCheckBox"), for: .normal)
                        }
                    else
                        {
                            cell.variantsNameLbl.font = UIFont(name: SEMIBOLD, size: 17)
                            cell.checkBoxButton.setImage(#imageLiteral(resourceName: "checkBox"), for: .normal)
                        }
                }
                else
                {
                    if dataDic["selected"] as! NSNumber == 0
                        {
                             cell.variantsNameLbl.font = UIFont(name: REGULAR_FONT, size: 15)
                            cell.checkBoxButton.setImage(#imageLiteral(resourceName: "radio_off"), for: .normal)
                        }
                    else
                        {
                            cell.variantsNameLbl.font = UIFont(name: SEMIBOLD, size: 17)
                            cell.checkBoxButton.setImage(#imageLiteral(resourceName: "round-checked"), for: .normal)
                        }
                }
             cell.checkBoxButton.addTarget(self, action: #selector(checkBoxButtonAction(sender:event:)), for: .touchUpInside)
                cell.variantsNameLbl.text = (dataDic["title"] as! String)
                cell.selectionStyle = .none
                return cell
            
        }
       let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuTableCell", for: indexPath) as! SideMenuTableCell
        
        print((tmpSideMenuDataArray[indexPath.row] as! NSDictionary))
        cell.titleLbl.text = ((tmpSideMenuDataArray[indexPath.row] as! NSDictionary)["key"] as! String)
        let type = ((tmpSideMenuDataArray[indexPath.row] as! NSDictionary)["type"] as! String)
        let isTypeSelected = ((tmpSideMenuDataArray[indexPath.row] as! NSDictionary)["isTypeSelected"] as! String)
        if isTypeSelected == "0" {
            cell.sideLbl.isHidden = true
            cell.mainV.backgroundColor = UIColor.groupTableViewBackground
        }
        else
        {
             cell.sideLbl.isHidden = false
            cell.mainV.backgroundColor = .white
        }
        
        if type == "single" {
            cell.valueLbl.text =  checkForSingleValue(index: indexPath.row)
        }
        else
        {
             cell.valueLbl.text =  checkForMultipleValue(index: indexPath.row)
        }
        cell.selectionStyle = .none
        return cell
    }
    

    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == optionsTableView {
            let cell = self.optionsTableView.cellForRow(at: indexPath) as! RadioButtonTableViewCell
            let mainDataDic = (tmpSideMenuDataArray[selectedIndex] as! NSDictionary)
            
            if mainDataDic["type"] as! String == "single" {
                 setSingleTypeRow(indexPath: indexPath, mainDic: mainDataDic)
            }
            else
            {
                if setMultipleTypeRow(indexPath: indexPath, mainDic: mainDataDic)
                {
                    cell.variantsNameLbl.font = UIFont(name: SEMIBOLD, size: 17)
                    cell.checkBoxButton.setImage(#imageLiteral(resourceName: "checkBox"), for: .normal)
                }
                else
                {
                    cell.variantsNameLbl.font = UIFont(name: REGULAR_FONT, size: 15)
                    cell.checkBoxButton.setImage(#imageLiteral(resourceName: "emptyCheckBox"), for: .normal)
                }
            }
            
        }
        else
        {
            let cell = tableView.cellForRow(at: indexPath) as! SideMenuTableCell
            selectedIndex = indexPath.row
            cell.mainV.backgroundColor = .white
            let type = ((tmpSideMenuDataArray[indexPath.row] as! NSDictionary)["type"] as! String)
            if type == "single" {
                cell.sideLbl.isHidden = true
                cell.valueLbl.text =  checkForSingleValue(index: indexPath.row)
            }
            else
            {
                cell.sideLbl.isHidden = false
                cell.valueLbl.text =  checkForMultipleValue(index: indexPath.row)
            }
            self.optionsTableView.reloadData()
        }
         let sideMenuCell = self.tableView.cellForRow(at: IndexPath(row: selectedIndex, section: 0)) as! SideMenuTableCell
        let mainDataDic = (tmpSideMenuDataArray[selectedIndex] as! NSDictionary)
        
        if mainDataDic["type"] as! String == "single" {
            sideMenuCell.sideLbl.isHidden = true
            sideMenuCell.valueLbl.text =  checkForSingleValue(index: selectedIndex)
        }
        else
        {
            sideMenuCell.sideLbl.isHidden = false
            sideMenuCell.valueLbl.text =  checkForMultipleValue(index: selectedIndex)
        }
         updateAllDataArray(selectedIndex: selectedIndex)
        optionsTableView.reloadData()
        self.tableView.reloadData()
    }
    
    
}


