//
//  UserData.swift
//  FunMemory
//
//  Created by 柴田晃輔 on 2019/08/08.
//  Copyright © 2019 shibata. All rights reserved.
//

import Foundation

class UserData {
    // UserDefaults のインスタンス
    let userDefaults = UserDefaults.standard
    
    init() {
        // デフォルト値
        userDefaults.register(defaults: ["UserName": "default"])
    }
    
    func saveData(str: String){
        // Keyを指定して保存
        userDefaults.set(str, forKey: "UserName")
        userDefaults.synchronize()
    }
    
    func readData() -> String {
        // Keyを指定して読み込み
        let str: String = userDefaults.object(forKey: "UserName") as! String
        
        return str
    }
    
}
