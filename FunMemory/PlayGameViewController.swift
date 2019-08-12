//
//  PlayGameViewController.swift
//  Tiger's Memory
//
//  Created by 柴田晃輔 on 2019/08/05.
//  Copyright © 2019 shibata. All rights reserved.
//

import UIKit

class PlayGameViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    // カード名のインデックス
    var cardIndexArray = [1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6]
    // カードオブジェクトを格納する配列
    var cards = [CardData]()
    
    
    override func awakeFromNib() {
        // 配列をランダムに並び替え
        let shuffledCardIndexArray = cardIndexArray.shuffled()
        
        // カードオブジェクトを配列に格納
        for cardIndex in shuffledCardIndexArray {
            let card = CardData(no: cardIndex)
            cards.append(card)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
    }
    
    
    @IBAction func exitButton(_ sender: Any) {
        // UIAlertControllerクラスのインスタンスを生成
        let alert: UIAlertController = UIAlertController(title: "確認", message: "終了しますか？", preferredStyle:  UIAlertController.Style.alert)
        
        // Actionの設定
        let defaultAction: UIAlertAction = UIAlertAction(title: "終了", style: UIAlertAction.Style.default, handler:{
            // ボタンが押された時の処理
            (action: UIAlertAction!) -> Void in
            print("終了")
            self.performSegue(withIdentifier: "exitGameSegue", sender: true)
        })
        // キャンセルボタン
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{
            // ボタンが押された時の処理
            (action: UIAlertAction!) -> Void in
            print("Cancel")
        })
        
        // UIAlertControllerにActionを追加
        alert.addAction(cancelAction)
        alert.addAction(defaultAction)
        
        // Alertを表示
        present(alert, animated: true, completion: nil)
    }
    
    
}

extension PlayGameViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // 選択したカードを反転
        let card = self.cards[indexPath.row]
        card.reverseCard(collectionView: self.collectionView)
        
        let cell = collectionView.cellForItem(at: indexPath)
        
        let imageView = cell?.contentView.viewWithTag(1) as! UIImageView
        imageView.image = UIImage(named: cards[indexPath.row].getImageName())
    }
    
}


extension PlayGameViewController: UICollectionViewDataSource {
    
    // 表示セル数
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.cards.count
    }
    
    // セルのデータを管理
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCell", for: indexPath)
        
        let imageView = cell.contentView.viewWithTag(1) as! UIImageView
        imageView.image = UIImage(named: cards[indexPath.row].getImageName())

        return cell
    }
}

//extension PlayGameViewController: UICollectionViewDelegateFlowLayout {
//    
//    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,
//                        sizeForItemAt indexPath: IndexPath) -> CGSize {
//        
//        let cellSize:CGFloat = self.view.bounds.width / 5
//        return CGSize(width: cellSize, height: cellSize)
//    }
//}
