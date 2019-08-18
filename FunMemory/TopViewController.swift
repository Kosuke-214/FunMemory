//
//  ViewController.swift
//  Tiger's Memory
//
//  Created by 柴田晃輔 on 2019/08/03.
//  Copyright © 2019 shibata. All rights reserved.
//

import UIKit

class TopViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func returnToTop(sender: UIStoryboardSegue) {
        // ゲーム終了時処理実装
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        // 1人プレイの場合
        guard let identifier = segue.identifier else {
            return
        }

        if identifier == "toSoloPlay" {
            let solo = segue.destination as! UINavigationController
            let playGameViewController = solo.topViewController as! PlayGameViewController

            playGameViewController.gameMode = "Solo"

        }

    }

}
