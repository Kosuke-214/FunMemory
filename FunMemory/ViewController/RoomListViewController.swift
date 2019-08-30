//
//  RoomListViewController.swift
//  FunMemory
//
//  Created by 柴田晃輔 on 2019/08/19.
//  Copyright © 2019 shibata. All rights reserved.
//

import UIKit

class RoomListViewController: UIViewController {

    @IBOutlet weak var roomTableView: UITableView!

    let rooms = ["部屋1"]

    override func viewDidLoad() {
        super.viewDidLoad()

        // dataSourceを設定
        roomTableView.dataSource = self
        // カスタムセルを登録
        roomTableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "TableViewCell")
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // マルチプレイの場合
        guard let identifier = segue.identifier else {
            return
        }

        if identifier == "toMultiPlay" {
            let multi = segue.destination as! UINavigationController
            let playGameViewController = multi.topViewController as! PlayGameViewController

            playGameViewController.gameMode = "Multi"

        }
    }

    func goPlayGameView() {
        // プレイ画面への遷移を実行
        performSegue(withIdentifier: "toMultiPlay", sender: nil)
    }

}

extension RoomListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rooms.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを取得する
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell",
                                                 for: indexPath) as! TableViewCell
        // セルに表示する値を設定する
        cell.setRoomName(name: rooms[indexPath.row])

        // delegateを自身に設定
        cell.delegate = self

        return cell
    }

}
