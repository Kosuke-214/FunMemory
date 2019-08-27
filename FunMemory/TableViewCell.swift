//
//  TableViewCell.swift
//  FunMemory
//
//  Created by 柴田晃輔 on 2019/08/21.
//  Copyright © 2019 shibata. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
    @IBOutlet weak var roomNameLabel: UILabel!
    @IBOutlet weak var roomCountLabel: UILabel!

    weak var delegate: RoomListViewController?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func enterButton(_ sender: Any) {
        // 「入室」押下で画面遷移実行
        delegate?.goPlayGameView()
    }

    func setRoomName(name: String) {
        // 部屋名を設定
        self.roomNameLabel.text = name

    }

}
