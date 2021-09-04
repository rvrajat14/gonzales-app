 

//
//  HelpAndFAQViewController.swift
//  FoodApplication
//
//  Created by Kishore on 07/06/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit

 
class HelpAndFAQViewController: UIViewController {
    
    
    @IBOutlet weak var noDataFoundLbl: UILabel!
    @IBOutlet weak var pageTitleLbl: UILabel!
    
    @IBOutlet weak var noFaqsYetLbl: UILabel!
    
    @IBOutlet weak var noFaqsDescLbl: UILabel!
    @IBOutlet weak var supportButton: UIButton!
    
    
    @IBOutlet weak var noDataV: UIView!
     var isFirstScroll = true
    var headerDataArray = NSMutableArray.init()
    var selectedHeader = ""
    var tmpHelpFaqDataArray = NSMutableArray.init()
    var headerCollectionView : UICollectionView!
    @IBOutlet weak var serverErrorView: UIView!
    @IBOutlet weak var okayButton: UIButton!
    @IBAction func okayButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
   

    @IBAction func supportButton(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SupportVC") as! SupportVC
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    @IBAction func backButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBOutlet weak var noDataView: UIView!
    let kHeaderSectionTag: Int = 6900;
    var expandedSectionHeaderNumber: Int = -1
    //var expandedSectionHeader: UITableViewHeaderFooterView!
    
    var allFAQDataArray = NSMutableArray.init()
    var allDataDictionary:NSMutableDictionary!
   
   
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        
        self.serverErrorView.isHidden = true
        okayButton.layer.borderWidth = 1
        okayButton.layer.borderColor = MAIN_COLOR.cgColor
        okayButton.layer.cornerRadius = 2
        
        allFAQDataArray = NSMutableArray.init()
      
        allDataDictionary = NSMutableDictionary.init()
        getFAQAPIData(loader: true, page: 1)
       
        self.tableView.separatorStyle = .none
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 50
        self.tableView!.tableFooterView = UIView()
        if #available(iOS 11.0, *) {
            self.automaticallyAdjustsScrollViewInsets = true
        }
        else
        {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        SHADOW_EFFECT.makeBottomShadow(forView: noDataV)
     
        pageTitleLbl.text = "y_faq_title".getLocalizedValue()
        noFaqsYetLbl.text = "e_faq_title".getLocalizedValue()
        noFaqsYetLbl.text = "e_faq_title".getLocalizedValue()
        noFaqsDescLbl.text = "e_faq_desc".getLocalizedValue()
        okayButton.setTitle("z_okay".getLocalizedValue(), for: .normal)
        supportButton.setTitle("z_support".getLocalizedValue(), for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue): UIColor.black]
        
        self.navigationItem.title = "Help & FAQ"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getTableViewHeader() -> UIView {
        
        
        let headerMainView = UIView(frame: CGRect(x: 0, y: 0.0, width: Double(self.view.frame.size.width - 20), height: 140 ))
        headerMainView.backgroundColor = .white
        
        let topLbl = UILabel(frame: CGRect(x: 20, y: 15, width: Double(self.view.frame.size.width - 20), height: 24))
        topLbl.font = UIFont(name: SEMIBOLD, size: 18)
        topLbl.text = "y_faq_title2".getLocalizedValue()
        headerMainView.addSubview(topLbl)
        //Collection View Coding
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        
        headerCollectionView = UICollectionView(frame: CGRect(x: 0, y: 50, width: Double(self.view.frame.size.width), height: 80.0 ), collectionViewLayout: flowLayout)
        headerCollectionView.delegate = self
        headerCollectionView.dataSource = self
        headerCollectionView.showsHorizontalScrollIndicator = false
        headerCollectionView.backgroundColor = UIColor.white
        
        
        
        let nib = UINib(nibName: "SelectionCollectionCell", bundle: nil)
        headerCollectionView.register(nib, forCellWithReuseIdentifier: "SelectionCollectionCell")
        
        headerCollectionView.reloadData()
        
       
        //if allBannersListData.count > 0 {
        headerMainView.addSubview(headerCollectionView)
        if headerDataArray.count > 0 &&  Language.isRTL &&  self.isFirstScroll {
            
            headerCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .right, animated: false)
            isFirstScroll = false
        }
        
        //}
        
        return headerMainView
    }
    
    //MARK: - Selector Methods//////////
    
    @objc func popVC(_ sender: UIBarButtonItem)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Call API
    
    func getFAQAPIData(loader:Bool,page:Int) {
        let api_name =  APINAME().FAQ_API  + "/1"
      
        WebService.requestGetUrl(strURL: api_name, params: NSDictionary.init(), is_loader_required: loader, success: { (response) in
            if !self.serverErrorView.isHidden
            {
                COMMON_FUNCTIONS.setView(view: self.serverErrorView, hidden: true, option: .transitionCurlUp)
            }
           if response["status_code"] as! NSNumber == 1
           {
             self.tableView.isUserInteractionEnabled = true
            
                self.noDataView.isHidden = true
                if page == 1
                {
                    self.allFAQDataArray.removeAllObjects()
                  
                }
                
                self.allFAQDataArray = ((response["data"]  as! NSArray).mutableCopy() as! NSMutableArray)
                if self.headerDataArray.count == 0
                    {
                        self.headerDataArray = ((response["header"] as! NSArray).mutableCopy() as! NSMutableArray)
                        for (index,value) in (self.headerDataArray as! [NSDictionary]).enumerated()
                        {
                            let dataDic = value.mutableCopy() as! NSMutableDictionary
                                dataDic["isSelected"] = "0"
                            self.headerDataArray.replaceObject(at: index, with: dataDic)
                        }
                        let newObj = NSDictionary(dictionaryLiteral: ("isSelected", "1"),("title","z_all".getLocalizedValue()),("type","all"))
                        self.selectedHeader = "all"
                        self.headerDataArray.insert(newObj, at: 0)
                    }
            
            if self.allFAQDataArray.count == 0
            {
                self.noDataView.isHidden = false
                
                return
            }
            
            
                self.getFilterData()
                DispatchQueue.main.async {
                     self.noDataView.isHidden = true
                   
                    self.tableView.reloadData()
                }
            
          // self.noDataView.isHidden = true
           
            }else
           {
             self.tableView.isUserInteractionEnabled = true
           
             self.noDataView.isHidden = false
            }
        }) { (failure) in
             self.tableView.isUserInteractionEnabled = true
           
             self.view.makeToast("a_internet".getLocalizedValue(), duration: 5, position: .bottom, title: "", image: nil, style: .init(), completion: { (result) in
               return
            })
        }
    }
 
   
    
    
    //MARK: Get Filter Data
    
    func getFilterData()  {
        
         self.tmpHelpFaqDataArray.removeAllObjects()
        if selectedHeader == "all" {
            noDataV.isHidden = true
             self.tmpHelpFaqDataArray = NSMutableArray(array: self.allFAQDataArray)
            if isFirstScroll
            {
           
                tableView.tableHeaderView = getTableViewHeader()
            }
            
            self.tableView.reloadData()
            self.headerCollectionView.reloadData()
            return
        }
        
        for value in self.allFAQDataArray as!  [NSDictionary] {
            
            if value["type"] as! String == selectedHeader
            {
                tmpHelpFaqDataArray.add(value)
            }
            
        }
        if tmpHelpFaqDataArray.count == 0 {
            self.noDataV.isHidden = false
        }
        else
        {
            noDataV.isHidden = true
        }
       self.tableView.reloadData()
        self.headerCollectionView.reloadData()
    }
    
    
}


 
 extension HelpAndFAQViewController : UITableViewDelegate, UITableViewDataSource
 {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tmpHelpFaqDataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.register(UINib(nibName: "HelpAndFAQTableCell", bundle: nil), forCellReuseIdentifier: "HelpAndFAQTableCell")
        let cell = tableView.dequeueReusableCell(withIdentifier: "HelpAndFAQTableCell", for: indexPath) as! HelpAndFAQTableCell
        cell.titleLbl.text = ((tmpHelpFaqDataArray[indexPath.row] as! NSDictionary)["question"] as! String)
        
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            cell.separatorV.isHidden = true
        }
        else
        {
            cell.separatorV.isHidden = false
        }
        
        cell.selectionStyle = .none
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let fieldOptionsDic = (tmpHelpFaqDataArray[indexPath.row] as! NSDictionary)
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "QuestionAndAnswerVC") as! QuestionAndAnswerVC
        viewController.questionDataDic = fieldOptionsDic
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
 }
 


 extension HelpAndFAQViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
 {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        
        return headerDataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.register(UINib(nibName: "SelectionCollectionCell", bundle: nil), forCellWithReuseIdentifier: "SelectionCollectionCell")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectionCollectionCell", for: indexPath) as! SelectionCollectionCell
        
        let fieldOptionsDic = (headerDataArray[indexPath.row] as! NSDictionary)
        print(fieldOptionsDic)
        
        
         DispatchQueue.main.async {
        if fieldOptionsDic.object(forKey: "isSelected") as! String == "0"
        {
            cell.backV.layer.borderColor = UIColor.lightGray.cgColor
            cell.selectionTypeLbl.textColor = UIColor.lightGray
            cell.backV.backgroundColor = .clear
            
        }
        else
        {
            self.selectedHeader = (fieldOptionsDic["type"] as! String)
            cell.backV.backgroundColor = MAIN_COLOR
            cell.selectionTypeLbl.textColor = .white
            cell.backV.layer.borderColor = MAIN_COLOR.cgColor
           
        }
        }
        cell.imageV.isHidden = true
        cell.selectionTypeLbl.text = (fieldOptionsDic.object(forKey: "title") as! String)
        cell.backV.layer.cornerRadius = 20
        cell.backV.layer.borderWidth = 1
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        
        for (index,value) in (self.headerDataArray as! [NSDictionary]).enumerated() {
            let dataDic = (value.mutableCopy() as! NSMutableDictionary)
            if index == indexPath.row
            {
                dataDic["isSelected"] = "1"
                self.selectedHeader = (dataDic["type"] as! String)
            }
            else
            {
                 dataDic["isSelected"] = "0"
            }
            self.headerDataArray.replaceObject(at: index, with: dataDic)
        }
        collectionView.reloadData()
        getFilterData()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        
        return CGSize(width: 120, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
    }
    
 }
 
