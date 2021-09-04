  
//
//  DeliveryAddressVC.swift
//  Dry Clean City
//
//  Created by Kishore on 05/06/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit
import CRRefresh
import Shimmer

class DeliveryAddressVC: UIViewController {
    
    
    @IBOutlet weak var noDataDescLbl: UILabel!
    @IBOutlet weak var noAddressSavedYetLnl: UILabel!
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var serverErrorView: UIView!
    @IBOutlet weak var addNowButton: UIButton!
    @IBAction func addNowButton(_ sender: UIButton) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "AddNewAddressVC") as! AddNewAddressVC
        viewController.isForAddressEditing = false
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    @IBOutlet weak var noDataView: UIView!
    var shimmerView = FBShimmeringView(frame: .zero)
    var isShimmerOn = true
    var selectedIndex:Int = 0
    var isFromCheckOut = false
    var allAddressArray = NSMutableArray.init()
    var user_data:UserDataClass!
    var currentPage = 1
    var total_page = 0
    var to_page = 0
    var isForDeliveryAddress = false
    
    @IBAction func addAddressButton(_ sender: UIButton) {
        
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "AddNewAddressVC") as! AddNewAddressVC
        viewController.isForAddressEditing = false
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    @IBOutlet weak var addAddressButton: UIButton!
    @IBAction func backButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        noAddressSavedYetLnl.text = "e_address_title".getLocalizedValue()
        noDataDescLbl.text = "e_address_desc".getLocalizedValue()
        addNowButton.setTitle("z_add_address".getLocalizedValue(), for: .normal)
        self.serverErrorView.isHidden = true
        addNowButton.layer.borderWidth = 1
        addNowButton.layer.borderColor = MAIN_COLOR.cgColor
        addNowButton.layer.cornerRadius = 2
      self.addRefreshFunctionality()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
       
       
        if #available(iOS 11.0, *) {
            self.automaticallyAdjustsScrollViewInsets = true
        }
        else
        {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let userDefaults = UserDefaults.standard
        let decoded  = userDefaults.object(forKey: "user_data") as! Data
          NSKeyedUnarchiver.setClass(UserDataClass.self, forClassName: "UserDataClass")
        user_data = (NSKeyedUnarchiver.unarchiveObject(with: decoded) as! UserDataClass)
        if isShimmerOn {
            self.CallApi(loader: false, page: 1)
        }
        else
        {
            self.CallApi(loader: true, page: 1)
        }
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue): UIColor.black]
        
        
        if isFromCheckOut == true {
            
            if isForDeliveryAddress {
                self.titleLbl.text = "z_delivery_address".getLocalizedValue()
            }
            else
            {
                self.titleLbl.text = "Pickup Addresses"
            }
           
        }
        else
        {
            self.titleLbl.text = "z_delivery_address".getLocalizedValue()
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: -Selector Methods
    
    
    @objc func sideMenuButton(_ sender: UIButton)
    {
        
            let alert:UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
            alert.addAction(UIAlertAction(title: "z_edit".getLocalizedValue(),
                                          style: UIAlertActionStyle.default,
                                          handler: {(alert: UIAlertAction!) in
                                            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "AddNewAddressVC") as! AddNewAddressVC
                                            
                                            viewController.addressDataDictionary = self.allAddressArray[sender.tag] as! AddressModel
                                            viewController.isForAddressEditing = true
                                            self.navigationController?.pushViewController(viewController, animated: true)
                                            
            }))
            alert.addAction(UIAlertAction(title: "z_delete".getLocalizedValue(),
                                          style: UIAlertActionStyle.default,
                                          handler: {(alert: UIAlertAction!) in
                                            let addressModel = self.allAddressArray[sender.tag] as! AddressModel
                                            self.deleteAddressAPI(address_id: addressModel.id)
            }))
            
            alert.addAction(UIAlertAction(title: "z_cancel".getLocalizedValue(),
                                          style: UIAlertActionStyle.cancel,
                                          handler: {(alert: UIAlertAction!) in print("Cancel")}))
            if UIDevice().userInterfaceIdiom == .pad {
                if let popoverController = alert.popoverPresentationController {
                    popoverController.sourceView = self.view
                    popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                    popoverController.permittedArrowDirections = []
                }
            }
            self.present(alert, animated: true, completion: nil)
        
        
    }
    
    
    @objc func setDefaultCheckBoxButton(_ sender: UIButton)
    {
        let addressModel = allAddressArray.object(at: sender.tag) as! AddressModel
        
        self.updateAddressAPI(loader: true, addressModel: addressModel)
    }
    
    
    
    @objc func popVC(_ sender: UIBarButtonItem)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    /////////////////////////
    
    
    
    //MARK: UPDATE DEFAULT ADDRESS
    
    
    
    
    
    func updateAddressAPI(loader:Bool,addressModel:AddressModel) {
        
        
        let params = ["linked_id":user_data.user_id!,"default":"1"]
        
       let url = APINAME().ADDRESS_API + "/\(addressModel.id)"
        WebService.requestPUTUrlWithJSONDictionaryParameters(strURL: url , is_loader_required: true, params: params, success: { (response) in
            if !self.serverErrorView.isHidden
            {
                COMMON_FUNCTIONS.setView(view: self.serverErrorView, hidden: true, option: .transitionCurlUp)
            }
            
            
            
            if response["status_code"] as! NSNumber == 1
            {        
                                self.CallApi(loader: false, page: 1)
                                if self.isFromCheckOut == true {
                                    
                                    if self.isForDeliveryAddress {
                                        selectedAddressDictionary =  addressModel
                                    }
                                    else
                                    {
                                        selectedPickUpAddressDictionary = addressModel
                                    }
                                    
                                    self.navigationController?.popViewController(animated: true)
                                }
                
            }
            else
            {
                COMMON_FUNCTIONS.showAlert(msg: response["message"] as! String)
                return
            }
        }) { (failure) in
              self.view.makeToast("a_internet".getLocalizedValue(), duration: 5, position: .bottom, title: "", image: nil, style: .init(), completion: { (result) in
               return
            })
        }
        

    }
    
    
    //MARK: -Call API
    func CallApi(loader:Bool,page:Int) -> Void{

        let api_name = APINAME().ADDRESS_API + "/\(user_data.user_id!)?page=\(page)"
       
        print(api_name)
      
        WebService.requestGetUrl(strURL: api_name, params: NSDictionary.init(), is_loader_required: loader, success: { (response) in
            print(response)
             self.isShimmerOn = false
            if !self.serverErrorView.isHidden
            {
                COMMON_FUNCTIONS.setView(view: self.serverErrorView, hidden: true, option: .transitionCurlUp)
            }
            
            
            
            
            
           if response["status_code"] as! NSNumber == 1
            {
                self.tableView.isScrollEnabled = true
                self.noDataView.isHidden = true
                if page == 1
                {
                 
                    self.allAddressArray.removeAllObjects()
                    self.currentPage = 1
                }
                
                let  array = ((response["data"] as! NSDictionary).object(forKey: "data") as! NSArray)
                
                if array.count == 0
                {
                    self.noDataView.isHidden = true
                    self.tableView.cr.endHeaderRefresh()
                    self.tableView.cr.endFooterRefresh()
                    return
                }
                
                self.total_page = Int(truncating: ((response["data"] as! NSDictionary).mutableCopy() as! NSMutableDictionary).object(forKey: "total") as! NSNumber)
                self.to_page = Int(truncating: ((response["data"] as! NSDictionary).mutableCopy() as! NSMutableDictionary).object(forKey: "to") as! NSNumber)
                
                for value in array as! [NSDictionary]
                {
                        let addressModel = AddressModel()
                        addressModel.id = COMMON_FUNCTIONS.checkForNull(string: value["address_id"] as AnyObject).1
                        addressModel.title = COMMON_FUNCTIONS.checkForNull(string: value["address_title"] as AnyObject).1
                        addressModel.line1 = COMMON_FUNCTIONS.checkForNull(string: value["address_line1"] as AnyObject).1
                        addressModel.line2 = COMMON_FUNCTIONS.checkForNull(string: value["address_line2"] as AnyObject).1
                        addressModel.phone = COMMON_FUNCTIONS.checkForNull(string: value["address_phone"] as AnyObject).1
                        addressModel.city = COMMON_FUNCTIONS.checkForNull(string: value["city"] as AnyObject).1
                        addressModel.country = COMMON_FUNCTIONS.checkForNull(string: value["country"] as AnyObject).1
                        addressModel.state = COMMON_FUNCTIONS.checkForNull(string: value["state"] as AnyObject).1
                        addressModel.latitude = COMMON_FUNCTIONS.checkForNull(string: value["latitude"] as AnyObject).1
                        addressModel.longitude = COMMON_FUNCTIONS.checkForNull(string: value["longitude"] as AnyObject).1
                        addressModel.linked_id = COMMON_FUNCTIONS.checkForNull(string: value["linked_id"] as AnyObject).1
                        addressModel.address_default = COMMON_FUNCTIONS.checkForNull(string: value["default"] as AnyObject).1
                        addressModel.pincode = COMMON_FUNCTIONS.checkForNull(string: value["pincode"] as AnyObject).1
                    self.allAddressArray.add(addressModel)
                }
                
              
                if (((response["data"] as! NSDictionary).mutableCopy() as! NSMutableDictionary).object(forKey: "next_page_url") as? String) != nil
                {
                    self.currentPage += 1
                }
                
               DispatchQueue.main.async {
                    self.tableView.cr.endHeaderRefresh()
                    self.tableView.cr.endFooterRefresh()
                    self.tableView.reloadData()
                }
            
             
            }
            else
           {
            self.allAddressArray.removeAllObjects()
            self.noDataView.isHidden = false
            self.tableView.cr.endHeaderRefresh()
            self.tableView.cr.endFooterRefresh()
            self.tableView.reloadData()
            //  self.tableView.isScrollEnabled = false
            }
        }) { (failure) in
             self.isShimmerOn = false
            self.tableView.cr.endHeaderRefresh()
            self.tableView.cr.endFooterRefresh()
           self.view.makeToast("a_internet".getLocalizedValue(), duration: 5, position: .bottom, title: "", image: nil, style: .init(), completion: { (result) in
               return
            })
        }
    }
    
    
    //MARK: -Add Pull To Down and Pull To Up Refresh
    func addRefreshFunctionality()  {
        
        tableView.cr.addHeadRefresh(animator: NormalHeaderAnimator()) { [weak self] in
          self?.CallApi(loader: false, page: 1)
            self?.tableView.cr.resetNoMore()
            
        }
        
        
        tableView.cr.addFootRefresh(animator: NormalFooterAnimator()) {
            [weak self] in
            if (self?.to_page)! == (self?.total_page)!
            {
                self?.tableView.cr.noticeNoMoreData()
                return
            }
            self?.CallApi(loader: false, page: (self?.currentPage)!)
            
        }
    }
    
}
//MARK : -TableView DataSource Methods///////

extension DeliveryAddressVC:UITableViewDataSource
{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isShimmerOn
        {
            let deviceHeight = self.view.frame.size.height
            return  Int(deviceHeight / 88)
        }
        else
        {
            return allAddressArray.count
        }
       
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        if self.isShimmerOn {
            let nib1 = UINib(nibName: "OfferShimmerTableCell", bundle: nil)
            
            tableView.register(nib1, forCellReuseIdentifier: "OfferShimmerTableCell")
            
            let cell = tableView.dequeueReusableCell(withIdentifier:"OfferShimmerTableCell") as! OfferShimmerTableCell
            
            cell.isUserInteractionEnabled = false
            shimmerView = FBShimmeringView(frame: cell.frame)
            shimmerView.contentView = cell
            shimmerView.isShimmering = true
            return cell
            
        }
        else
        {
            shimmerView.isShimmering = false
            
        let nib:UINib = UINib(nibName: "DeliveryAddressTableViewCell", bundle: nil)
        
        tableView.register(nib, forCellReuseIdentifier: "DeliveryAddressTableViewCell")
        let cell  = tableView.dequeueReusableCell(withIdentifier: "DeliveryAddressTableViewCell") as! DeliveryAddressTableViewCell
        
            let addressModel = allAddressArray.object(at: indexPath.row) as! AddressModel
         let default_status = addressModel.address_default
        var addressString = ""
        
            cell.addressTitleLbl.text =  addressModel.title
            addressString =  addressModel.line1
            if addressModel.line2.isNotEmpty
            {
                addressString += ", " +  addressModel.line2
            }
            if addressModel.city.isNotEmpty
            {
                addressString += ", " +  addressModel.city
            }
            
            if addressModel.state.isNotEmpty
            {
                addressString += ", " +  addressModel.state
            }
            if addressModel.country.isNotEmpty
            {
                addressString += ", " +  addressModel.country
            }
        
         cell.address1Lbl.text = addressString
            cell.sideMenuButton.tag = indexPath.row
        cell.sideMenuButton.addTarget(self, action: #selector(sideMenuButton(_:)), for: .touchUpInside)
        
            if default_status == "0" {
                cell.circleImgV.image = #imageLiteral(resourceName: "empty_circle")
            }
            else if default_status == "1"
            {
                cell.circleImgV.image = #imageLiteral(resourceName: "check_circle")
            }
        cell.setDefaultCheckBoxButton.tag = indexPath.row
       
        cell.setDefaultCheckBoxButton.layer.borderColor = MAIN_COLOR.cgColor
        cell.setDefaultCheckBoxButton.layer.cornerRadius = 1
            
            if isFromCheckOut
            {
                cell.circleImgV.isHidden = true
                cell.defaultButtonWidthConstraints.constant = 0
                cell.setDefaultCheckBoxButton.isHidden = true
            }
            else
            {
                cell.circleImgV.isHidden = false
                cell.defaultButtonWidthConstraints.constant = 35
                cell.setDefaultCheckBoxButton.isHidden = false
            }
        cell.setDefaultCheckBoxButton.addTarget(self, action: #selector(setDefaultCheckBoxButton(_:)), for: .touchUpInside)
        
        cell.selectionStyle = .none
        return cell
             }
        
    }
    
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView:UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44))
        headerView.backgroundColor = UIColor.groupTableViewBackground
        let infoLabel:UILabel = UILabel(frame: CGRect(x: 16, y: 10, width: self.view.frame.size.width - 32, height: 24))
        infoLabel.textColor = UIColor.lightGray
        
        if total_page > 1 {
              infoLabel.text = "\(total_page) " + "z_addresses".getLocalizedValue()
        }
        else
        {
              infoLabel.text = "\(total_page)  " + "z_address".getLocalizedValue()
        }
      
        //infoLabel.alpha = 0.80
        infoLabel.font = UIFont(name: REGULAR_FONT, size: 17)
        
        headerView.addSubview(infoLabel)
        return headerView
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let addressModel = allAddressArray.object(at: indexPath.row) as! AddressModel
        
      
        if isFromCheckOut == true {
            
            if isForDeliveryAddress {
                selectedAddressDictionary =  addressModel
            }
            else
            {
                selectedPickUpAddressDictionary = addressModel
            }
            self.navigationController?.popViewController(animated: true)
        }
        else
        {
            let addressModel = allAddressArray.object(at: indexPath.row) as! AddressModel
            self.updateAddressAPI(loader: true, addressModel: addressModel)
        }
        
    }
    
    //MARK: Check For Null
    
    
    func checkForNull(string: AnyObject) -> (Bool,String) {
        
        if string is NSNull {
            return (true,"")
        }
        return (false,string as! String)
    }
    
}
////////////////////////////////////////////


//MARK: - TableView Delegate Methds///////

extension DeliveryAddressVC:UITableViewDelegate
{
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .destructive , title: "Delete") { (action, index) in
            
            let alert = UIAlertController(title: nil, message: "a_delete".getLocalizedValue(), preferredStyle: .alert)
           
            alert.addAction(UIAlertAction(title: "z_yes".getLocalizedValue(), style: .default, handler: { (action) in
                let addressModel = self.allAddressArray.object(at: index.row) as! AddressModel
                self.deleteAddressAPI(address_id: addressModel.id)
            }))
            
            alert.addAction(UIAlertAction(title: "z_no".getLocalizedValue(), style: .destructive, handler: { (action) in
                return
            }))
            if UIDevice.current.userInterfaceIdiom == .pad
            {
            let popPresenter = alert.popoverPresentationController
            popPresenter?.sourceView = self.view
            popPresenter?.sourceRect = self.view.bounds
            }
            self.present(alert, animated: true, completion: nil)
          
        }
        return [delete]
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    
    //MARK: -Delete Address Api Call
    func deleteAddressAPI(address_id: String) {
        let api_name = APINAME().ADDRESS_API + "/\(address_id)?timezone=\(localTimeZoneName)"
        
        //let paramDic = ["user_address_id": address_id]
        
        WebService.requestDelUrl(strURL: api_name , is_loader_required: true, success: { (response) in
            if !self.serverErrorView.isHidden
            {
                COMMON_FUNCTIONS.setView(view: self.serverErrorView, hidden: true, option: .transitionCurlUp)
            }
            
             
            
            
           
           if response["status_code"] as! NSNumber == 1
            {
                DispatchQueue.main.async {
                 
                   self.CallApi(loader: false, page: (self.currentPage))
                }
                
            }
           else {
            COMMON_FUNCTIONS.showAlert(msg: response["message"] as! String)
            }
            
            
        }) { (failure) in
           self.view.makeToast("a_internet".getLocalizedValue(), duration: 5, position: .bottom, title: "", image: nil, style: .init(), completion: { (result) in
               return
            })
        }
        
    }
}



