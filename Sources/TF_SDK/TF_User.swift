//
//  TF_User.swift
//  
//
//  Created by kin nam on 2022/12/14.
//

import Foundation
class TF_User {
    static func configure(appKey:String, appSecret:String) {
        shared.appKey = appKey
        shared.appSecret = appSecret
    }
    static let shared:TF_User = .init()
    var appKey:String?
    var appSecret:String?
    var approval_key:String?
    var access_token:String? {
        willSet {
            if newValue != access_token {
                UserDefaults.standard.set(newValue, forKey: "accessToken")
                UserDefaults.standard.synchronize()
            }
        }
    }
    var token_type:String?
    
    init() {
        if let aToken = UserDefaults.standard.string(forKey: "accessToken"), aToken != self.access_token {
            self.access_token = aToken
        }
    }
}
