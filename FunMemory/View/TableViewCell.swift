//
//  TableViewCell.swift
//  FunMemory
//
//  Created by 柴田晃輔 on 2019/08/21.
//  Copyright © 2019 shibata. All rights reserved.
//

import UIKit
import FirebaseDatabase

class TableViewCell: UITableViewCell {
    @IBOutlet weak var roomNameLabel: UILabel!
    @IBOutlet weak var roomCountLabel: UILabel!
    @IBOutlet weak var enter: UIButton!

    // DB接続用
    let database = Database.database().reference().child("room").child("Room1")
    // 画面遷移用のdelegate
    weak var delegate: RoomListViewController?

    override func awakeFromNib() {
        super.awakeFromNib()

        // デフォルトはボタンを非活性にしておく
        enter.isEnabled = false
        // Realtime Databaseの部屋のユーザ数を監視
        database.observe(.value, with: { [weak self] snapshot in
            if let data = snapshot.value as? NSDictionary {
                if let userCount = data["userCount"] as! Int? {

                    if userCount < 2 {
                        // ユーザ数が0または1の場合はボタンを活性化
                        self?.enter.isEnabled = true
                    } else {
                        // ユーザ数が2の場合はボタンを非活性化
                        self?.enter.isEnabled = false
                    }
                    self?.roomCountLabel.text = "\(userCount)/2"
                }
            }
            // ユーザ数に変更があった場合にTableViewを再読み込み
            let roomList = RoomListViewController()
            roomList.roomTableView?.reloadData()
        })
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func enterButton(_ sender: Any) {

        // Realtime Databaseから部屋のユーザ数を取得
        database.observeSingleEvent(of: .value, with: { [weak self] snapshot in
            if let data = snapshot.value as? NSDictionary {
                if let userCount = data["userCount"] as! Int? {
                    // 入室時にuserCountを+1
                    self?.database.child("userCount").setValue(userCount + 1)
                }
            }
        })
        // 画面遷移実行
        delegate?.goPlayGameView()
    }

    func setRoomName(name: String) {
        // 部屋名を設定
        self.roomNameLabel.text = name

    }

}
