//
//  DealVC.swift
//  wp
//
//  Created by 木柳 on 2016/12/25.
//  Copyright © 2016年 com.yundian. All rights reserved.
//

import UIKit
import SVProgressHUD
import DKNightVersion
class DealVC: BaseTableViewController, TitleCollectionviewDelegate {
    
    @IBOutlet weak var myMoneyLabel: UILabel!
    @IBOutlet weak var myMoneyView: UIView!
    @IBOutlet weak var myQuanLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var highLabel: UILabel!
    @IBOutlet weak var lowLabel: UILabel!
    @IBOutlet weak var openLabel: UILabel!
    @IBOutlet weak var closeLabel: UILabel!
    @IBOutlet weak var changeLabel: UILabel!
    @IBOutlet weak var changePerLabel: UILabel!
    @IBOutlet weak var kLineView: KLineView!
    @IBOutlet weak var dealTable: MyDealTableView!
    @IBOutlet weak var titleView: TitleCollectionView!
    @IBOutlet weak var klineTitleView: TitleCollectionView!
    @IBOutlet weak var productsView: ProductsiCarousel!
    private var klineBtn: UIButton?
    private var priceTimer: Timer?
    private var klineTimer: Timer?
    let klineTitles = ["分时图","5分K","15分K","30分K","1小时K"]
    //MARK: --Test
    @IBAction func testItemTapped(_ sender: Any) {
        //        initDealTableData()
        AppDataHelper.instance().initProductData()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        showTabBarWithAnimationDuration()

        if let money = UserModel.share().currentUser?.balance{
            myMoneyLabel.text = String.init(format: "%.2f", money)
        }
    }
    //MARK: --LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
        initUI()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
      //  hideTabBarWithAnimationDuration()
    }
    deinit {
        DealModel.share().removeObserver(self, forKeyPath: AppConst.KVOKey.allProduct.rawValue)
        priceTimer?.invalidate()
        priceTimer = nil
        klineTimer?.invalidate()
        klineTimer = nil
    }
    //MARK: --DATA
    func initData() {
        //初始化持仓数据
        initDealTableData()
        //初始化下商品数据
        titleView.objects = DealModel.share().productKinds
        if let selectProduct = DealModel.share().selectProduct{
            didSelectedObject(titleView, object: selectProduct)
        }
        //每隔3秒请求商品报价
        priceTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(initRealTimeData), userInfo: nil, repeats: true)
        //持仓点击
        DealModel.share().addObserver(self, forKeyPath: AppConst.KVOKey.allProduct.rawValue, options: .new, context: nil)
        //k线选择器
        klineTitleView.objects = klineTitles as [AnyObject]?
        if let flowLayout: UICollectionViewFlowLayout = klineTitleView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.itemSize = CGSize.init(width: UIScreen.width()/CGFloat(klineTitles.count), height: 40)
            
        }
        kLineView.selectModelBlock = { [weak self](result) -> () in
            if let model: KChartModel = result as? KChartModel{
                self?.updatePrice(model: model)
            }
        }
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == AppConst.KVOKey.allProduct.rawValue{
            let allProducets: [ProductModel] = DealModel.share().productKinds
            titleView.objects = allProducets
        }
    }
    //MARK: --我的资产
    @IBAction func jumpToMyWallet(_ sender: AnyObject) {
        
        
        if checkLogin(){
            let storyboard = UIStoryboard.init(name: "Share", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: MyWealtVC.className())
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    //TitleCollectionView's Delegate
    internal func didSelectedObject(_ collectionView: UICollectionView, object: AnyObject?) {
        if collectionView == titleView {
            if let model: ProductModel = object as? ProductModel {
                DealModel.share().selectProduct = model
                initRealTimeData()
                kLineView.refreshKLine()
                reloadProducts()
            }
        }
        
        if collectionView ==  klineTitleView{
            if let klineTitle = object as? String{
                for (index, title) in klineTitles.enumerated() {
                    if title == klineTitle {
                        kLineView.selectIndex = index
                        break
                    }
                }
            }
        }

    }
    //刷新商品数据
    func reloadProducts() {
        var products: [ProductModel] = []
        for product in DealModel.share().allProduct {
            if product.symbol == DealModel.share().selectProduct!.symbol{
                products.append(product)
            }
        }
        productsView.objects = products
    }
    // 持仓列表数据
    func initDealTableData() {
        
        dealTable.dataArray = DealModel.getAllPositionModel()
        YD_CountDownHelper.shared.countDownWithDealTableView(tableView: dealTable)

        AppAPIHelper.deal().currentDeals(complete: { [weak self](result) -> ()? in
            
            if result == nil{
                return nil
            }
            if let resultModel: [PositionModel] = result as! [PositionModel]?{
                DealModel.cachePositionWithArray(positionArray: resultModel)
                self?.dealTable.dataArray = DealModel.getAllPositionModel()
                YD_CountDownHelper.shared.countDownWithDealTableView(tableView: (self?.dealTable)!)
            }
            return nil
            }, error: errorBlockFunc())


    }
    // 当前报价
    func initRealTimeData() {
        if let product = DealModel.share().selectProduct {
            let good = [SocketConst.Key.aType: SocketConst.aType.currency.rawValue,
                        SocketConst.Key.exchangeName: product.exchangeName,
                        SocketConst.Key.platformName: product.platformName,
                        SocketConst.Key.symbol: product.symbol] as [String : Any]
            let param: [String: Any] = [SocketConst.Key.id: UserModel.currentUserId,
                                        SocketConst.Key.token: UserModel.token ?? "",
                                        SocketConst.Key.symbolInfos: [good]]
            AppAPIHelper.deal().realtime(param: param, complete: { [weak self](result) -> ()? in
                if let models: [KChartModel] = result as! [KChartModel]?{
                    for model in models{
                        if model.symbol == product.symbol{
                            self?.updatePrice(model: model)
                        }
                    }
                }
                return nil
            }, error: errorBlockFunc())
        }
    }
    
    func updatePrice(model: KChartModel) {
        priceLabel.text = String.init(format: "%.4f", model.currentPrice)
        highLabel.text = String.init(format: "%.4f", model.highPrice)
        lowLabel.text = String.init(format: "%.4f", model.lowPrice)
        openLabel.text = String.init(format: "%.4f", model.openingTodayPrice)
        closeLabel.text = String.init(format: "%.4f", model.closedYesterdayPrice)
        changePerLabel.text = String.init(format: "%.4f", model.change)
        changeLabel.text = String.init(format: "%.2f%%", model.change/model.currentPrice)
        let colorKey = model.change > 0 ? AppConst.Color.buyUp : AppConst.Color.buyDown
        changeLabel.dk_textColorPicker = DKColorTable.shared().picker(withKey: colorKey)
        changePerLabel.dk_textColorPicker = DKColorTable.shared().picker(withKey: colorKey)
        priceLabel.dk_textColorPicker = DKColorTable.shared().picker(withKey: colorKey)
        updatePrice(price: model.currentPrice)
    }
    
    func updatePrice(price: Double) {
        for product in DealModel.share().allProduct {
            if product.symbol == DealModel.share().selectProduct!.symbol {
                product.price = price * product.depositFee
            }
        }
        productsView.reloadData()
    }
    
    //MARK: --UI
    func initUI() {
        myMoneyView.dk_backgroundColorPicker = DKColorTable.shared().picker(withKey: AppConst.Color.main)
        titleView.itemDelegate = self
        titleView.reuseIdentifier = ProductTitleItem.className()
        
        klineTitleView.itemDelegate = self
        klineTitleView.reuseIdentifier = KLineTitleItem.className()
    }
    
   
    //MARK: --买涨/买跌
    @IBAction func dealBtnTapped(_ sender: UIButton) {
        if true || checkLogin(){
            
            tableView.scrollToRow(at: IndexPath.init(row: 3, section: 0), at: .top, animated: false)
            
            if DealModel.share().selectProduct == nil {
                SVProgressHUD.showWainningMessage(WainningMessage: "暂无商品信息", ForDuration: 1.5, completion: nil)
                return
            }
            DealModel.share().dealUp = sender.tag == 1
            DealModel.share().isDealDetail = false
            
            let controller = UIStoryboard.init(name: "Deal", bundle: nil).instantiateViewController(withIdentifier: BuyProductVC.className()) as! BuyProductVC
            controller.modalPresentationStyle = .custom
            controller.resultBlock = { [weak self](result) in
                if let status: BuyProductVC.BuyResultType = result as! BuyProductVC.BuyResultType? {
                    switch status {
                    case .lessMoney:
                        let moneyAlter = UIAlertController.init(title: "余额不足", message: "余额不足，请前往充值", preferredStyle: .alert)
                        let cancelAction = UIAlertAction.init(title: "取消", style: .cancel, handler: nil)
                        let sureAction = UIAlertAction.init(title: "确认", style: .default, handler: { [weak self](alter) in
                             let controller = UIStoryboard.init(name: "Share", bundle: nil).instantiateViewController(withIdentifier: RechargeVC.className()) as! RechargeVC
                            self?.navigationController?.pushViewController(controller, animated: true)
                        })
                        moneyAlter.addAction(cancelAction)
                        moneyAlter.addAction(sureAction)
                        self?.present(moneyAlter, animated: true, completion: nil)
                        break
                    default:
                        break
                    }
                }
                return nil
            }
            present(controller, animated: true, completion: nil)
            
        }
    }
    
}
//    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
//        if identifier == BuyVC.className() {
//            return checkLogin()
//        }
//        return true
//    }
