//
//  SockOpcode.swift
//  viossvc
//
//  Created by yaowang on 2016/11/22.
//  Copyright © 2016年 ywwlcom.yundian. All rights reserved.
//

import Foundation

class SocketConst: NSObject {
    enum OPCode:UInt16 {
        // 心跳包
        case heart = 1000
        // 获取图片上传token
        case imageToken = 1047
        // 获取分时信息
        case minDealInfo = 10001
        // 登录
        case login = 3003
        // 注册
        case register = 3001
        // 重设密码
        case repwd = 3005
        // 声音验证码
        case voiceCode = 1006
        // 设置用户信息

        case userInfo = 10010

        //设置账号信息
        case accountNews = 1007
        
       case accinfo = 1003
        //修改个人信息
        case changeUserInfo = 1031
        //流水列表
        case flowList = 1005
        //流水详情
        case flowDetails = 1010
        //银行卡列表
        case bankcardList = 1009
        
        //银行卡详情
        case bingcard = 1011
        //解绑银行卡
        case unbindcard = 1013
        //获取银行卡名称
        case getbankname = 1017
        //获取验证码
        case verifycode = 1029
        //提现详情
        case withdrawDetail = 101
        // 我的晒单
        case userShare = 1020
        // 充值列表
        case rechageList = 1019
        // 充值详情
        case recharge = 10012
        // 提现列表
        case withdrawList = 1025
        // 提现
        case withdrawCash = 1023
        //仓位列表
        case currentDeals = 2000
        //仓位详情
        case currentDealDetail = 2001
        //历史仓位列表
        case historyDeals = 2002
        //历史仓位详情
        case historyDealDetail = 2003
        //建仓
        case buildDeal = 2004
        //平仓
        case sellOutDeal = 2005
        //修改持仓
        case changeDeal = 2006
        //商品列表
        case products = 2007
        //当前K线数据
        case kChart = 2008
        //当前分时数据
        case timeline = 2009
        //当前报价
        case realtime = 2010
        
    }
    enum type:UInt8 {
        case error = 0
        case user = 3
        case chat = 2
        case wp = 1
    }
    
    class Key {
        static let last_id = "last_id_"
        static let count = "count_"
        static let share_id = "share_id_"
        static let page_type = "page_type_"
        static let uid = "uid"
        static let from_uid = "from_uid_"
        static let to_uid = "to_uid_"
        static let order_id = "order_id_"
        static let order_status = "order_status_"
        static let change_type = "change_type_"
        static let skills = "skills_"
        static let type = "type"
        static let phone = "phone"
        static let pwd = "pwd"
        static let code = "vCode"
        static let voiceCode = "voiceCode"
        static let appid = "appid"
        static let secret = "secret"
        static let grant_type = "grant_type"
        static let flowType = "flowType"
        static let startPos = "startPos"
        static let countNuber = "count"
        static let flowld = "flowld"
        static let bank = "bank"
        static let branchBank = "branchBank"
        static let province = "province"
        static let city = "city"
        static let cardNo = "cardNo"
        static let name = "name"
        static let bankId = "bankId"
        static let source = "source"
        static let memberId = "memberId"
        static let agentId = "agentId"
        static let recommend = "recommend"
        static let status = "status"
        static let pos = "startPos"
        static let rid = "rid"
        static let money = "money"
        static let bld = "bld"
        static let password = "password"
        static let withdrawld = "withdrawld"
        static let id = "id"
        static let positionId = "positionId"
        static let token = "token"
        static let position = "position"
        static let price = "price"
        static let pid = "pid"
        static let goodType = "goodType"
        static let exchange_name = "exchange_name"
        static let platform_name = "platform_name"
        static let bid = "bid"
        static let newid = "uid"
        static let verifyType = "verifyType"
        static let screenName = "screenName"
        static let avatarLarge = "avatarLarge"

        
    }
    
    
}
