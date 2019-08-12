//
//  SettingViewController.swift
//  FunMemory
//
//  Created by 柴田晃輔 on 2019/08/08.
//  Copyright © 2019 shibata. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {

    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userNameTextField: UITextField!

    // UserDataのインスタンス
    let userData = UserData()

    override func viewDidLoad() {
        super.viewDidLoad()
        // UserDefaultsに保存したユーザ名を表示
        userNameLabel.text = userData.readData()
    }

    @IBAction func changeNameButton(_ sender: Any) {

        // 制限文字数
        let maxLength = 10
        // 保存するユーザ名
        let saveName: String

        // テキストフィールドの文字列を定数に保持
        // テキストフィールドがnilまたは空白文字、空文字の場合は何もしない
        guard let enteredName = userNameTextField.text,
            enteredName.count != 0,
            !enteredName.contains(" ") else {
                // テキストフィールドの値をクリア
                userNameTextField.text = ""
                return
        }

        // 文字数制限
        if enteredName.count >= maxLength {
            // 制限文字数を超える場合は超えた分を切り捨て
            saveName = String(enteredName.prefix(maxLength))
        } else {
            // 制限文字数内であればそのまま
            saveName = enteredName
        }

        // 保存するユーザ名をラベルに設定
        userNameLabel.text = saveName

        // ユーザ名を保存
        userData.saveData(str: saveName)

        // テキストフィールドの値をクリア
        userNameTextField.text = ""

    }

}
