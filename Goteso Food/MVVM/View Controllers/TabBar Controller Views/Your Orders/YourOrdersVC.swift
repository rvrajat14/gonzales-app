
//
//  YourOrdersVC.swift
//  Food App
//
//  Created by Kishore on 05/06/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit
import CRRefresh
import Shimmer

class YourOrdersVC: UIViewController {
    
    
    @IBOutlet weak var noDataFoundDescLbl: UILabel!
    @IBOutlet weak var noOrderPlaceLbl: UILabel!
    @IBOutlet weak var pageTitleLbl: UILabel!
    
    var selectedColor = UIColor(red: 51/255.0, green: 88/255.0, blue: 101/255.0, alpha: 1)
    var unSelectedColor = UIColor.lightGray
    var selectedAppType = "laundry"
    var refreshControl = UIRefreshControl()
    @IBOutlet weak var serverErrorView: UIView!
    @IBAction func orderNowButton(_ sender: UIButton) {
        tabBarController?.selectedIndex = 0
    }
    @IBOutlet weak var orderNowButton: UIButton!
    
    var shimmerView:FBShimmeringView!
    var isShimmerOn = true
    
    @IBOutlet weak var noDataView: UIView!
    var user_data:UserDataClass!
    var ordersArray = NSMutableArray.init()
   
    var currentPage = 1
    var total_page = 0
    var to_page = 0
    
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        pageTitleLbl.text = "z_orders".getLocalizedValue()
        noOrderPlaceLbl.text = "e_order_title".getLocalizedValue()
        noDataFoundDescLbl.text = "e_order_desc".getLocalizedValue()
        orderNowButton.setTitle("e_order_button_title".getLocalizedValue(), for: .normal)
        
        self.serverErrorView.isHidden = true
        if #available(iOS 11.0, *) {
            self.automaticallyAdjustsScrollViewInsets = true
        }
        else
        {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        self.view.layoutIfNeeded()
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        self.addRefreshFunctionality()
        tableView.addSubview(refreshControl)
        self.noDataView.isHidden = true
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 1))
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        
      self.addRefreshFunctionality()
        orderNowButton.layer.borderWidth = 1
        orderNowButton.layer.borderColor = MAIN_COLOR.cgColor
        orderNowButton.layer.cornerRadius = 2
         navigationController?.isNavigationBarHidden = true
         NotificationCenter.default.addObserver(self, selector: #selector(viewWillAppear(_:)), name: NSNotification.Name("login_update_notitfication"), object: nil)
        self.viewWillAppear(true)
    }
    
    
    
    
    //MARK: -CALL API
    
    func CallApi(loader:Bool,page:Int) -> Void{
        
        let api_name = APINAME()
        let url = api_name.ORDERS_API + "?page=\(page)&customer_id=\(user_data.user_id!)&orderby=updated_at&timezone=\(localTimeZoneName)"
        
        print(url)
        WebService.requestGetUrl(strURL: url, params: NSDictionary.init(), is_loader_required: loader, success: { (response) in
           if !self.serverErrorView.isHidden
           {
            COMMON_FUNCTIONS.setView(view: self.serverErrorView, hidden: true, option: .transitionCurlUp)
            }
            print(response)
            
            
            
            
            
           if response["status_code"] as! NSNumber == 1
            {
                 self.isShimmerOn = false
                self.tableView.isScrollEnabled = true
                self.noDataView.isHidden = true
                
                if page == 1
                {
                    
                    self.ordersArray.removeAllObjects()
                    self.currentPage = 1
                }
                
                self.ordersArray.addObjects(from: ((response["data"] as! NSDictionary).object(forKey: "data") as! NSArray).mutableCopy() as! NSMutableArray as! [Any])
                
                if self.ordersArray.count == 0
                {
                    self.noDataView.isHidden = false
                    self.tableView.reloadData()
                    self.tableView.cr.endHeaderRefresh()
                    self.tableView.cr.endFooterRefresh()
                    
                    return
                }
                
                self.total_page = Int(truncating: ((response["data"] as! NSDictionary).mutableCopy() as! NSMutableDictionary).object(forKey: "total") as! NSNumber)
                self.to_page = Int(truncating: ((response["data"] as! NSDictionary).mutableCopy() as! NSMutableDictionary).object(forKey: "to") as! NSNumber)
                if ((response["data"] as! NSDictionary).object(forKey: "next_page_url") as? String) != nil
                {
                    self.currentPage += 1
                }
                
                DispatchQueue.main.async {
                     self.tableView.reloadData()
                    self.refreshControl.endRefreshing()
                   // self.tableView.cr.endHeaderRefresh()
                    self.tableView.cr.endFooterRefresh()
                   
                }
                
            }
           else
           {
            
            if self.shimmerView.isShimmering
            {
                self.shimmerView.isShimmering = false
                self.isShimmerOn = false
                
            }
            self.ordersArray.removeAllObjects()
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
            // self.tableView.cr.endHeaderRefresh()
            self.tableView.cr.endFooterRefresh()
            self.noDataView.isHidden = false
            
            }
        }) { (failure) in
            if self.shimmerView.isShimmering
            {
                self.shimmerView.isShimmering = false
                self.isShimmerOn = false
               
            }
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
            //self.tableView.cr.endHeaderRefresh()
           self.tableView.cr.endFooterRefresh()
            
              self.view.makeToast("a_internet".getLocalizedValue(), duration: 5, position: .bottom, title: "", image: nil, style: .init(), completion: { (result) in
               return
            })
        }
    }
    
  
    
    override func viewWillAppear(_ animated: Bool) {
        
        let userDefaults = UserDefaults.standard
        
        if userDefaults.object(forKey: "user_data") != nil {
            let decoded  = userDefaults.object(forKey: "user_data") as! Data
              NSKeyedUnarchiver.setClass(UserDataClass.self, forClassName: "UserDataClass")
            user_data = (NSKeyedUnarchiver.unarchiveObject(with: decoded) as! UserDataClass)
            // getLocalJSON()
            self.CallApi(loader: false, page: 1)
            self.tabBarController?.tabBar.isHidden = false
            self.navigationController?.navigationBar.barTintColor = UIColor.white
            self.navigationItem.title = "Orders"
        }
        else
        {
            let alert = UIAlertController(title: "Login Required", message: "You have to login first to continue", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Login", style: .default, handler: { (action) in
                let viewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! UINavigationController
                
                isFromAppdelegate = false
                self.present(viewController, animated: true, completion: nil)
                
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) in
                self.tabBarController?.selectedIndex = 0
            }))
            
            let popPresenter = alert.popoverPresentationController
            popPresenter?.sourceView = self.view
            popPresenter?.sourceRect = self.view.bounds
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: -Add Pull To Down and Pull To Up Refresh
    
    @objc func refresh(_ sender:AnyObject) {
        self.tableView.cr.resetNoMore()
        self.CallApi(loader: false, page: 1)
        
    }
    
    func addRefreshFunctionality()  {
        
//        tableView.cr.addHeadRefresh(animator: NormalHeaderAnimator()) { [weak self] in
//           self?.CallApi(loader: false, page: 1)
//            self?.tableView.cr.resetNoMore()
//        }
        
        
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

extension YourOrdersVC:UITableViewDataSource
{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.ordersArray.count > 0 {
            return self.ordersArray.count
        }
        
        if isShimmerOn
        {
            let deviceHeight = self.view.frame.size.height
            return  Int(deviceHeight / 101)
        }else
        {
            return 0
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 30))
        headerView.backgroundColor =  .groupTableViewBackground
        var title = ""
        if self.total_page == 1 {
            title = "\(total_page)  " + "z_order".getLocalizedValue()
        }
        else
        {
             title = "\(total_page)  " + "z_orders".getLocalizedValue()
        }
        
        
        
        let titleLbl = UILabel()
        headerView.addSubview(titleLbl)
        titleLbl.translatesAutoresizingMaskIntoConstraints = false
        titleLbl.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 15).isActive = true
        titleLbl.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -15).isActive = true
        titleLbl.heightAnchor.constraint(equalToConstant: 20).isActive = true
        titleLbl.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 10).isActive = true
        
        titleLbl.font = UIFont(name: SEMIBOLD, size: 17)
        titleLbl.text = title
        titleLbl.textColor = UIColor.lightGray
        
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        
        if self.ordersArray.count == 0 && isShimmerOn {
            let nib1 = UINib(nibName: "OrderShimmerTableCell", bundle: nil)
            
            tableView.register(nib1, forCellReuseIdentifier: "OrderShimmerTableCell")
            
            let cell = tableView.dequeueReusableCell(withIdentifier:"OrderShimmerTableCell") as! OrderShimmerTableCell
             cell.isUserInteractionEnabled = false
            shimmerView = FBShimmeringView(frame: cell.frame)
            shimmerView.contentView = cell
            shimmerView.isShimmering = true
            return cell
        }
        if let sm = shimmerView {
            sm.isShimmering = false
        }
        
       
        
        //self.tableView.backgroundColor = self.processing_text_color
        let nib:UINib = UINib(nibName: "OrderTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "OrderTableViewCell")
        let cell  = tableView.dequeueReusableCell(withIdentifier: "OrderTableViewCell") as! OrderTableViewCell
        if self.ordersArray.count > 0 {
    
            let dataDic = (self.ordersArray[indexPath.row] as! NSDictionary)
            
           
            print(self.ordersArray.object(at: indexPath.row))
            cell.storeNameLbl.text = ((dataDic["store_info"] as! NSDictionary)["store_title"] as! String)
            cell.orderNumberLbl.text = "#" + String(format: "%@", dataDic.object(forKey: "order_id") as! CVarArg)
            cell.orderDateLbl.text = dataDic["created_at_formatted"] as? String
            //cell.orderPriceLbl.padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
            let price = (dataDic.value(forKey: "total_display") as! String)
             
            cell.orderPriceLbl.text = currency_type + price
           cell.priceLblWidthConstraints.constant = cell.orderPriceLbl.optimalWidth + 30
            cell.orderPriceLbl.layer.cornerRadius = 10
            cell.orderStatusLbl.layer.cornerRadius = cell.orderStatusLbl.frame.size.height / 2
            cell.orderStatusLbl.text = (dataDic["order_status"] as! String).uppercased()
            cell.statusWidthConstraints.constant = cell.orderStatusLbl.optimalWidth + 30
            cell.orderStatusLbl.backgroundColor = self.hexStringToUIColor(hex: (dataDic.object(forKey: "label_color") as! String))
           
            var imageUrl : URL!
            
            if let image = ((dataDic["store_info"] as! NSDictionary)["store_photo"] as? String)
            {
                imageUrl = URL(string: IMAGE_BASE_URL + "store/" +  image)
            }
            cell.storeImageV.sd_setImage(with: imageUrl, placeholderImage: #imageLiteral(resourceName: "empty_item"), options: .refreshCached, completed: nil)

        }
        cell.selectionStyle = .none
        return cell
    }
    
    //MARK: Check For Null
    
    
    func checkForNull(string: AnyObject) -> (Bool) {
        
        if string is NSNull {
            return (true)
        }
        return (false)
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
}
////////////////////////////////////////////

//MARK : -TableView DataSource Methods///////

extension YourOrdersVC:UITableViewDelegate
{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "OrderSummaryVC") as! OrderSummaryVC
       viewController.order_id =  ((self.ordersArray.object(at: indexPath.row) as! NSDictionary).object(forKey: "order_id") as! NSNumber).stringValue
        viewController.appType = selectedAppType
       self.navigationController?.pushViewController(viewController, animated: true)
    }
    
 
}
/////////////////////////////////////////////







