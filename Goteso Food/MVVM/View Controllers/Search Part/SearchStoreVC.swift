//
//  SearchStoreVC.swift
//  FoodApplication
//
//  Created by Kishore on 19/07/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit
import CRRefresh
import CoreLocation

class SearchStoreVC: UIViewController,UITextFieldDelegate {

    var bannerDataArray = NSArray.init()
    var currentPage = 1
    var total_page = 0
    var to_page = 0
    
    @IBOutlet weak var pageTitleLbl: UILabel!
    
    @IBOutlet weak var noDataFoundLbl: UILabel!
    
    var isGPSLocationOn = false
    
    @IBOutlet weak var serverErrorView: UIView!
    @IBAction func backButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
   
    @IBOutlet weak var noDataFoundView: UIView!
   var allStoresDataArray = NSMutableArray.init()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchView: UIView!
    var isFormFrontPage = false
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageTitleLbl.text = "z_search".getLocalizedValue()
        noDataFoundLbl.text = "e_store".getLocalizedValue()
        searchTextField.placeholder = "h_search_store".getLocalizedValue()
        NotificationCenter.default.addObserver(self, selector: #selector(locationUpdateNotification(_:)), name: NSNotification.Name?.init(NSNotification.Name.init(rawValue: "locationUpdateNotification")), object: nil)
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                self.isGPSLocationOn = false
                UserDefaults.standard.set(false, forKey: "locationStatus")
                
            case .authorizedAlways, .authorizedWhenInUse:
                self.isGPSLocationOn = true
                UserDefaults.standard.set(true, forKey: "locationStatus")
                print("Access")
            }
        } else {
             self.isGPSLocationOn = false
            print("Location services are not enabled")
        }
        CLLocationManager.init().startUpdatingHeading()
        
        if Language.isRTL {
            searchTextField.textAlignment = .right
        }
        else
        {
            searchTextField.textAlignment = .left
        }
        
        let userDefaults = UserDefaults.standard
     
        self.serverErrorView.isHidden = true
       
       self.searchView.layer.cornerRadius = 6
        self.searchView.layer.borderWidth = 1
        self.searchView.layer.borderColor = UIColor.lightGray.cgColor
       
        let nib = UINib(nibName: "StoreTableCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "StoreTableCell")
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.searchTextField.becomeFirstResponder()
        SHADOW_EFFECT.makeBottomShadow(forView: noDataFoundView)
        addRefreshFunctionality()
        self.getStoresListDataAPI(search_key: "", page: 1)
    }

    override func viewWillAppear(_ animated: Bool) {
         self.tabBarController?.tabBar.isHidden = true
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @objc func locationUpdateNotification(_ notification: Notification)
    {
        if notification.userInfo != nil {
            self.isGPSLocationOn = false
        }
        else
        {
            viewDidLoad()
        }
        
    }
    
    //MARK: -Add Pull To Down and Pull To Up Refresh
    
    func addRefreshFunctionality()  {
        
        tableView.cr.addHeadRefresh(animator: NormalHeaderAnimator()) { [weak self] in
            
            self?.getStoresListDataAPI(search_key:(self?.searchTextField.text!)!, page: 1)
            
            self?.tableView.cr.resetNoMore()
        }
        
        
        tableView.cr.addFootRefresh(animator: NormalFooterAnimator()) {
            [weak self] in
            if (self?.to_page)! == (self?.total_page)!
            {
                self?.tableView.cr.noticeNoMoreData()
                return
            }
            self?.getStoresListDataAPI(search_key:(self?.searchTextField.text!)!, page: (self?.currentPage)!)
           
        }
    }

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return false
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        self.noDataFoundView.isHidden = true
        getStoresListDataAPI(search_key:"", page: currentPage)
        return true
    }
    
    //MARK: -Search Field Delegate
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        let newString = NSString(string: textField.text!).replacingCharacters(in: range, with: string)

        
        if textField.tag == 99
        {
            print((newString.count))
            if (newString.count) > 0
            {
                self.noDataFoundView.isHidden = true
                print(newString)
                getStoresListDataAPI(search_key:newString, page: 1)
               
            }
            else
            {
                self.noDataFoundView.isHidden = true
                getStoresListDataAPI(search_key:newString, page: 1)
               
              
            }
            
            
        }
        return true
        
    }
    
    
    //MARK: -Call Search API
    func getStoresListDataAPI(search_key:String,page:Int) -> Void{
         var lat = "", long = ""
        #if targetEnvironment(simulator)
        lat = "30.7135"
        long = "76.6972"
        #else
        lat = latitude
        long = longitude
        //        lat = latitude
        //        long = longitude
        #endif
        var distance = "20"
        
        if !isGPSLocationOn {
            lat = appDefaultLati
            long = appDefaultLong
        }
        
        let api_name = APINAME()
        var url = api_name.STORES_API + "?include_meta=true&coordinates=\(lat),\(long)&search=\(search_key)"
         url = url.replacingOccurrences(of: " ", with: "%20", options: .literal, range: nil)

        print(url)
        WebService.requestGetUrl(strURL: url, params: NSDictionary.init(), is_loader_required: true, success: { (response) in
            print(response)
            if !self.serverErrorView.isHidden
            {
                COMMON_FUNCTIONS.setView(view: self.serverErrorView, hidden: true, option: .transitionCurlUp)
            }
            
             
            
           
            
             if response["status_code"] as! NSNumber == 1
            {
                if page == 1
                {
                    
                    self.allStoresDataArray.removeAllObjects()
                    self.currentPage = 1
                }
                  self.noDataFoundView.isHidden = true
                 let dataArray = ((response["data"] as! NSDictionary).object(forKey: "data") as! NSArray)
                
                if dataArray.count == 0
                {
                    self.noDataFoundView.isHidden = false
                    self.tableView.reloadData()
                    self.tableView.cr.endHeaderRefresh()
                    self.tableView.cr.endFooterRefresh()
                    
                    return
                }
                
                for storeData in dataArray as! [NSDictionary]
                {
                    let storeModel = StoreModel()
                    storeModel.store_id = COMMON_FUNCTIONS.checkForNull(string: storeData["store_id"] as AnyObject).1
                    storeModel.store_title = COMMON_FUNCTIONS.checkForNull(string: storeData["store_title"] as AnyObject).1
                    storeModel.store_description = COMMON_FUNCTIONS.checkForNull(string: storeData["store_description"] as AnyObject).1
                    storeModel.store_photo = COMMON_FUNCTIONS.checkForNull(string: storeData["store_photo"] as AnyObject).1
                    storeModel.store_rating = COMMON_FUNCTIONS.checkForNull(string: storeData["store_rating"] as AnyObject).1
                    storeModel.address = COMMON_FUNCTIONS.checkForNull(string: storeData["address"] as AnyObject).1
                    storeModel.available_status = COMMON_FUNCTIONS.checkForNull(string: storeData["available_status"] as AnyObject).1
                    self.allStoresDataArray.add(storeModel)
                }
                
                self.total_page = Int(truncating: ((response["data"] as! NSDictionary).mutableCopy() as! NSMutableDictionary).object(forKey: "total") as! NSNumber)
                self.to_page = Int(truncating: ((response["data"] as! NSDictionary).mutableCopy() as! NSMutableDictionary).object(forKey: "to") as! NSNumber)
                if (((response["data"] as! NSDictionary).mutableCopy() as! NSMutableDictionary).object(forKey: "next_page_url") as? String) != nil
                {
                    self.currentPage += 1
                }
                
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.tableView.cr.endHeaderRefresh()
                self.tableView.cr.endFooterRefresh()
            }
            }
             else{
                print(response["message"] as! String)
                self.noDataFoundView.isHidden = false
                
                self.allStoresDataArray.removeAllObjects()
                self.tableView.reloadData()
                self.tableView.cr.endHeaderRefresh()
                self.tableView.cr.endFooterRefresh()
            }
        }) { (failure) in
              self.view.makeToast("a_internet".getLocalizedValue(), duration: 5, position: .bottom, title: "", image: nil, style: .init(), completion: { (result) in
               return
            })
        }
    }
    
    
}


extension SearchStoreVC:UITableViewDataSource,UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        if self.allStoresDataArray.count > 0  {
            return allStoresDataArray.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "StoreTableCell", for: indexPath) as! StoreTableCell
        
        let storeModel = allStoresDataArray.object(at: indexPath.row) as! StoreModel
        
        cell.storeNameLbl.text = storeModel.store_title
        let description = storeModel.store_description
        if !description.isEmpty {
            cell.storeInfoLbl.text = description
            cell.storeInfoLbl.isHidden = false
            cell.storeInfoLbl.numberOfLines = 1
        }
        else
        {
            cell.storeInfoLbl.numberOfLines = 0
            cell.storeInfoLbl.text = ""
            cell.storeInfoLbl.numberOfLines = 0
            cell.storeInfoLbl.isHidden = true
            
        }
        
        cell.storeAddressNameLbl.text = storeModel.address
        cell.ratingLbl.text = storeModel.store_rating
        cell.ratingView.layer.cornerRadius = 13
         let imageUrl = URL(string: IMAGE_BASE_URL + "store/" + storeModel.store_photo)
        var img = #imageLiteral(resourceName: "store_placeholder")
        let store_status = storeModel.available_status
        cell.imageV.sd_setImage(with: imageUrl, placeholderImage: #imageLiteral(resourceName: "store_placeholder"), options: .refreshCached) { (image, error, cacheType, imageURL) in
            
            
            if image == nil
            {
                img = #imageLiteral(resourceName: "store_placeholder")
            }
            else
            {
                img = image!
            }
            
            if store_status == "1"
            {
                cell.imageV.image = img
                cell.locationImgV.image = #imageLiteral(resourceName: "location_placeholder")
                cell.ratingView.isHidden = false
                cell.storeStatusView.isHidden = true
            }
            else
            {
                cell.imageV.image = img.noir
                cell.locationImgV.image = #imageLiteral(resourceName: "dark_location")
                cell.ratingView.isHidden = true
                cell.storeStatusView.isHidden = false
            }
            
        }
       
       
        cell.selectionStyle =  .none
        return cell
    }
    
    func getBlackAndWhiteImg(originalImage : UIImageView) -> UIImageView {
        let context = CIContext(options: nil)
        
        //Auto Adjustment to Input Image
        var inputImage = CIImage(image: originalImage.image!)
        let options:[String : AnyObject] = [CIDetectorImageOrientation:1 as AnyObject]
        let filters = inputImage!.autoAdjustmentFilters(options: options)
        
        for filter: CIFilter in filters {
            filter.setValue(inputImage, forKey: kCIInputImageKey)
            inputImage =  filter.outputImage
        }
        let cgImage = context.createCGImage(inputImage!, from: inputImage!.extent)
        originalImage.image =  UIImage(cgImage: cgImage!)
        
        //Apply noir Filter
        let currentFilter = CIFilter(name: "CIPhotoEffectTonal")
        currentFilter!.setValue(CIImage(image: UIImage(cgImage: cgImage!)), forKey: kCIInputImageKey)
        
        let output = currentFilter!.outputImage
        let cgimg = context.createCGImage(output!, from: output!.extent)
        let processedImage = UIImage(cgImage: cgimg!)
        originalImage.image = processedImage
        return originalImage
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storeModel = allStoresDataArray.object(at: indexPath.row) as! StoreModel
        if storeModel.store_id.isEmpty {
            storeModel.store_id = store_id
            storeModel.store_title = store_name
        }
        else
        {
            store_name = storeModel.store_title
            store_id = storeModel.store_id
        }
        let store_status = storeModel.available_status
        if store_status == "0"
        {
            COMMON_FUNCTIONS.showAlert(msg: "a_store_closed".getLocalizedValue())
            return
        }
        if super_app_type == "supermarket" {
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SuperMarketAllMainCategoriesVC") as! SuperMarketAllMainCategoriesVC
            viewController.allBannersListData = bannerDataArray.mutableCopy() as! NSMutableArray
             viewController.storeModel = storeModel
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        else
        {
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "LaundryHomePageVC") as! LaundryHomePageVC
            viewController.storeModel = storeModel
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        
    }
    
    
}
