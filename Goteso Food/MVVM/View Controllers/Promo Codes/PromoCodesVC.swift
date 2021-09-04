//
//  PromoCodesVC.swift
//  Mataem
//
//  Created by Kishore on 14/09/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit
import CRRefresh
import Shimmer


class PromoCodesVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var noDataFoundLbl: UILabel!
    @IBOutlet weak var pageTitleLbl: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBAction func backButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var serverErrorView: UIView!
    @IBOutlet weak var topView: UIView!
    var params = NSDictionary.init()
    
    @IBOutlet weak var applyButton: UIButton!
    @IBAction func applyButton(_ sender: UIButton) {
        if (couponTxtField.text?.isEmpty)! {
            self.view.makeToast("h_order_coupon".getLocalizedValue())
            self.view.clearToastQueue()
            return
        }
        self.coupon_code = couponTxtField.text!
        applyCouponAPI(loader: true)
    }
    @IBOutlet weak var couponTxtField: UITextField!
    
    var coupon_code = "",responseMsg = ""
    
    var itemDataArray = NSMutableArray.init()
    var allDataArray = NSMutableArray.init()
    var paymentDataDic = NSMutableDictionary.init()
    
    var currentPage = 1
    var total_page = 0
    var to_page = 0
    var isShimmerOn = true
     @IBOutlet weak var noDataView: UIView!
    var shimmerView:FBShimmeringView!
    var user_data:UserDataClass!
    
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        backButton.setTitle("z_back".getLocalizedValue(), for: .normal)
        pageTitleLbl.text = "z_offers".getLocalizedValue()
        couponTxtField.placeholder = "h_order_coupon".getLocalizedValue()
        applyButton.setTitle("z_apply".getLocalizedValue(), for: .normal)
        noDataFoundLbl.text = "e_coupon".getLocalizedValue()
        
        self.serverErrorView.isHidden = true
        let userDefaults = UserDefaults.standard
        let decoded  = userDefaults.object(forKey: "user_data") as! Data
          NSKeyedUnarchiver.setClass(UserDataClass.self, forClassName: "UserDataClass")
        user_data = (NSKeyedUnarchiver.unarchiveObject(with: decoded) as! UserDataClass)
        addRefreshFunctionality()
        if #available(iOS 11.0, *) {
            self.automaticallyAdjustsScrollViewInsets = true
        }
        else
        {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        self.tableView.backgroundColor = UIColor.groupTableViewBackground
        self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 12))
        self.tableView.tableFooterView = UIView(frame: .zero)
      SHADOW_EFFECT.makeBottomShadow(forView: self.noDataView, shadowHeight: 5)
        getCouponListDataAPI(loader:false,page:1)
        self.topView.layer.masksToBounds = true
        self.topView.layer.cornerRadius = 10
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: -TableView Methods /////////////////////
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
            if self.allDataArray.count > 0
            {
                return self.allDataArray.count
            }
            
            if isShimmerOn
            {
                let deviceHeight = self.view.frame.size.height
                return  Int(deviceHeight / 72)
            }
            return 0
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.allDataArray.count == 0 {
            let nib1 = UINib(nibName: "OfferShimmerTableCell", bundle: nil)
            tableView.register(nib1, forCellReuseIdentifier: "OfferShimmerTableCell")
            
            let cell = tableView.dequeueReusableCell(withIdentifier:"OfferShimmerTableCell") as! OfferShimmerTableCell
            cell.isUserInteractionEnabled = false
            shimmerView = FBShimmeringView(frame: cell.frame)
            shimmerView.contentView = cell
            shimmerView.isShimmering = true
            return cell
        }
        shimmerView.isShimmering = false
        
        let nib:UINib = UINib(nibName: "OrderNotificationTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "OrderNotificationTableViewCell")
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderNotificationTableViewCell") as! OrderNotificationTableViewCell
        
        let tmpDataDic = self.allDataArray.object(at: indexPath.row) as! NSDictionary
        cell.tag = indexPath.row
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressGesture(_:)))
        
        cell.addGestureRecognizer(longPressGesture)
        cell.notificationTitleLbl.text = (tmpDataDic.object(forKey: "coupon_title") as! String)
        let coupon_code = (tmpDataDic.object(forKey: "coupon_code") as! String)
        let coupon_desc = (tmpDataDic.object(forKey: "coupon_desc") as! String)
        cell.couponCodeLbl.text = coupon_code
        if !coupon_desc.isEmpty
        {
            cell.notificationDescriptionLbl.text = (tmpDataDic.object(forKey: "coupon_desc") as! String)
        }
        else
        {
            cell.notificationDescriptionLbl.text = ""
        }
        
        cell.notificationTimeLbl.text = "y_offers_expires_on".getLocalizedValue() + ": " + (tmpDataDic.object(forKey: "expiry") as! String)
        
        cell.selectionStyle = .none
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tmpDataDic = self.allDataArray.object(at: indexPath.row) as! NSDictionary
        let couponCode = (tmpDataDic.object(forKey: "coupon_code") as! String)
        self.couponTxtField.text = couponCode
        
    }
    
    
    //    //MARK: - Selector Methods//////////
    //
    
    @objc func longPressGesture(_ sender: UILongPressGestureRecognizer)
    {
        let tag_value = sender.view?.tag
        let tmpDataDic = self.allDataArray.object(at: tag_value!) as! NSDictionary
        print(tmpDataDic)
        let pasteBoard = UIPasteboard.general
        pasteBoard.string = ""
        pasteBoard.string = (tmpDataDic.object(forKey: "coupon_code") as! String)
        sender.view?.makeToast("y_offers_copied".getLocalizedValue())
        print(pasteBoard.string!)
    }
    
    @objc func applyButtonAction(_ sender: UIButton)
    {
        let tmpDataDic = self.allDataArray.object(at: sender.tag) as! NSDictionary
        print(tmpDataDic)
       coupon_code = (tmpDataDic.object(forKey: "coupon_code") as! String)
        applyCouponAPI(loader: true)
    }
    
    
    //MARK: Add Refresh Functionality
    
    func addRefreshFunctionality()  {
        
        self.tableView.cr.addHeadRefresh(animator: NormalHeaderAnimator()) { [weak self] in
            
          
                self?.getCouponListDataAPI(loader: false, page: 1)
            
            self?.tableView.cr.resetNoMore()
            
        }
        
        
        self.tableView.cr.addFootRefresh(animator: NormalFooterAnimator()) {
            [weak self] in
            
            if (self?.to_page)! == (self?.total_page)!
            {
                self?.tableView.cr.noticeNoMoreData()
                return
            }
            
                self?.getCouponListDataAPI(loader: false, page: (self?.currentPage)!)
           
        }
    }
    
    
    
    
    //MARK: - Call API
    func getCouponListDataAPI(loader:Bool,page:Int)  {
        
        let api_name = APINAME()
        let url = api_name.GET_COUPONS_LIST + "?page=\(page)"
        
        print(url)
        WebService.requestGetUrl(strURL: url, params: NSDictionary.init(), is_loader_required: loader, success: { (response) in
            print(response)
            
            if !self.serverErrorView.isHidden
            {
                COMMON_FUNCTIONS.setView(view: self.serverErrorView, hidden: true, option: .transitionCurlUp)
            }
           
             self.isShimmerOn = false
             if response["status_code"] as! NSNumber == 1
            {
                self.tableView.isScrollEnabled = true
                self.noDataView.isHidden = true
                if page == 1
                {
                    
                    self.allDataArray.removeAllObjects()
                    self.currentPage = 1
                }
                
                self.allDataArray.addObjects(from: ((response["data"] as! NSDictionary).object(forKey: "data") as! NSArray).mutableCopy() as! NSMutableArray as! [Any])
                
                if self.allDataArray.count == 0
                {
                    self.noDataView.isHidden = false
                    self.tableView.reloadData()
                    self.tableView.cr.endHeaderRefresh()
                    self.tableView.cr.endFooterRefresh()
                    
                    return
                }
                
                self.total_page = Int(truncating: ((response["data"] as! NSDictionary).mutableCopy() as! NSMutableDictionary).object(forKey: "total") as! NSNumber)
                self.to_page = Int(truncating: ((response["data"] as! NSDictionary).mutableCopy() as! NSMutableDictionary).object(forKey: "to") as! NSNumber)
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
                if self.shimmerView.isShimmering
                {
                    self.shimmerView.isShimmering = false
                    self.isShimmerOn = false
                    
                }
                self.tableView.reloadData()
                //  self.selectedTableView.isScrollEnabled = false
                self.tableView.cr.endHeaderRefresh()
                self.tableView.cr.endFooterRefresh()
                self.view.bringSubview(toFront: self.noDataView)
                self.noDataView.isHidden = false
            }
            
        }) { (failure) in
            
            if self.shimmerView.isShimmering
            {
                self.shimmerView.isShimmering = false
                self.isShimmerOn = false
                self.tableView.reloadData()
            }
            self.view.bringSubview(toFront: self.noDataView)
            self.tableView.cr.endHeaderRefresh()
            self.tableView.cr.endFooterRefresh()
           self.view.makeToast("a_internet".getLocalizedValue(), duration: 5, position: .bottom, title: "", image: nil, style: .init(), completion: { (result) in
               return
            })
        }
    }
    
    //MARK: Apply Coupon API
    func applyCouponAPI(loader:Bool)  {
        let api_name = APINAME().COUPON_API + "?timezone=\(localTimeZoneName)"
        var param:[String:Any]!
        let paramMutabaledic = params.mutableCopy() as! NSMutableDictionary
        paramMutabaledic.setObject(coupon_code, forKey: "coupon_code" as NSCopying)
       
        param = (paramMutabaledic as! [String : Any])

        WebService.requestPostUrlWithJSONDictionaryParameters(strURL: api_name , is_loader_required: loader, params: param, success: { (response) in
           if !self.serverErrorView.isHidden
           {
            COMMON_FUNCTIONS.setView(view: self.serverErrorView, hidden: true, option: .transitionCurlUp)
            }
            
            
            
            if response["status_code"] as! NSNumber == 1
            {
              self.responseMsg = (response["message"] as! String)
                self.tableView.isScrollEnabled = true
                self.isShimmerOn = false
                 self.paymentDataDic = (response["data"] as! NSDictionary).mutableCopy() as! NSMutableDictionary
                DispatchQueue.main.async {
                   
                        NotificationCenter.default.post(name: NSNotification.Name.init("couponNotification"), object: nil, userInfo: ["coupon_code":self.coupon_code,"payment_data":self.paymentDataDic,"responseMsg":self.responseMsg])
                        self.dismiss(animated: true, completion: nil)
                        return
                    }
                    
                    self.tableView.reloadData()
                    self.tableView.cr.endHeaderRefresh()
                }
            else
            {
                self.view.makeToast((response["message"] as! String))
                if self.shimmerView.isShimmering
                {
                    self.shimmerView.isShimmering = false
                    self.isShimmerOn = false
                    self.tableView.reloadData()
                }
                self.tableView.cr.endHeaderRefresh()
            }
            
        }) { (error) in
         
            if self.shimmerView.isShimmering
            {
                self.shimmerView.isShimmering = false
                self.isShimmerOn = false
                self.tableView.reloadData()
            }
            self.tableView.cr.endHeaderRefresh()
           self.view.makeToast("a_internet".getLocalizedValue(), duration: 5, position: .bottom, title: "", image: nil, style: .init(), completion: { (result) in
               return
            })
            
        }
    }
    
    
}
