//
//  PlayGameViewController.swift
//  Tiger's Memory
//
//  Created by 柴田晃輔 on 2019/08/05.
//  Copyright © 2019 shibata. All rights reserved.
//

import UIKit
import FirebaseDatabase

class PlayGameViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var user1Card: UserCardView!
    @IBOutlet weak var user2Card: UserCardView!

    // カード名のインデックス
    var cardNoArray = [1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9, 10, 10]
    // カードオブジェクトを格納する配列
    var cards = [CardData]()
    // 1枚目に選択したカードのオブジェクト
    var firstCard: CardData?
    // 2枚目に選択したカードのオブジェクト
    var secondCard: CardData?
    // カードのステータス
    var status: CardStatus = .none
    // ユーザのポイント
    var userPoint = 0
    // ゲームモード
    var gameMode: String?
    // 部屋名
    var roomName: String?
    // DB接続用
    let database = Database.database().reference().child("room").child("Room1")

    // カードステータスの列挙型
    enum CardStatus {
        case firstOpen, secondOpen, none
    }

    override func awakeFromNib() {
        // 配列をランダムに並び替え
        let shuffledCardNoArray = cardNoArray.shuffled()

        // カードオブジェクトを配列に格納
        for (index, cardNo) in zip(shuffledCardNoArray.indices, shuffledCardNoArray) {
            let card = CardData(no: cardNo)
            cards.append(card)

            card.index = index
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // delegateとdataSourceを設定
        self.collectionView.delegate = self
        self.collectionView.dataSource = self

        // ユーザデータをインスタンス化
        let userData = UserData()

        switch gameMode {
        case "Solo":
            // 1人プレイの場合
            // ユーザデータの反映
            self.user1Card.userName.text = userData.readData()
            self.user1Card.userPoint.text = String(userPoint)

            // ユーザカードの枠線を設定
            self.user1Card.layer.borderWidth = 5.0
            self.user1Card.layer.borderColor = UIColor.blue.cgColor

            // 対戦相手のカード非表示
            self.user2Card.isHidden = true

        case "Multi":
            // マルチプレイの場合
            // ユーザ名の反映
            database.child("userName").observeSingleEvent(of: .value, with: { [weak self] snapshot in
                if let data = snapshot.value as? NSDictionary {
                    if let user1 = data["user1"] as! String?, let user2 = data["user2"] as! String? {
                        if user1 == "none" {
                            // ユーザがいない場合、user1に自分を設定
                            self?.database.child("userName/user1").setValue(userData.readData())
                            self?.user1Card.userName.text = userData.readData()
                            self?.user2Card.userName.text = user2
                        } else {
                            // user1が存在する場合、user2に自分を設定
                            self?.database.child("userName/user2").setValue(userData.readData())
                            self?.user1Card.userName.text = user1
                            self?.user2Card.userName.text = userData.readData()
                        }
                    }
                }
            })

            // ユーザが自分1人の場合は対戦相手を待機
            observeOpponent()

        default:
            break
        }

    }

    func observeOpponent() {
        database.child("userName").observe(.value, with: { [weak self] snapshot in
            if let data = snapshot.value as? NSDictionary {
                if let user2 = data["user2"] as! String? {
                    if user2 != "none" {
                        // user2が入室したらラベルを更新
                        self?.user2Card.userName.text = user2
                    }
                }
            }
        })
    }

    @IBAction func exitButton(_ sender: Any) {
        // UIAlertControllerクラスのインスタンスを生成
        let alert: UIAlertController = UIAlertController(title: "確認",
                                                         message: "終了しますか？",
                                                         preferredStyle: UIAlertController.Style.alert)

        // Actionの設定
        let defaultAction: UIAlertAction = UIAlertAction(title: "終了", style: UIAlertAction.Style.default,
                                                         handler: { (_: UIAlertAction!) -> Void in
                                                            print("終了")
                                                            self.performSegue(withIdentifier: "exitGameSegue",
                                                                              sender: true)
        })
        // キャンセルボタン
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel,
                                                        handler: { (_: UIAlertAction!) -> Void in
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

        let card = self.cards[indexPath.row]

        switch status {
        case .none:
            // カードを一枚も開いていない、かつ選択したカードが裏である場合
            if !card.isFront {
                // 一枚目のカードを反転
                firstCard = card
                firstCard?.reverseCard(collectionView: self.collectionView)

                // ステータスを更新
                status = .firstOpen
            }
        case .firstOpen:
            // カードを一枚開いている、かつ選択したカードが裏である場合
            if !card.isFront {
                // 二枚目のカードを反転
                secondCard = card
                secondCard?.reverseCard(collectionView: self.collectionView)

                // ステータスを更新
                status = .secondOpen

                // 一枚目と二枚目のカード名が一致する場合
                if firstCard?.imageName == secondCard?.imageName {
                    print("Matching!!!")

                    firstCard?.matchingAnimation(collectionView: self.collectionView)
                    secondCard?.matchingAnimation(collectionView: self.collectionView)

                    // ポイントを加算
                    userPoint += 1
                    self.user1Card.userPoint.text = String(userPoint)

                    // マッチングのアニメーション中にタップさせないようにステータス更新を遅らせる
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                        // ステータスを更新
                        self.status = .none
                    }

                    // 一枚目と二枚目のカード名が一致しない場合
                } else {
                    // 1.5秒後にカードを戻す
                    print("Not Matching...")
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
                        self.firstCard?.reverseCard(collectionView: self.collectionView)
                        self.secondCard?.reverseCard(collectionView: self.collectionView)

                        // 反転中もタップさせないようにステータス更新を1秒遅らせる
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                            // ステータスを更新
                            self.status = .none
                        }
                    }
                }
            }
        case .secondOpen:
            // 2枚目が開いている場合は選択させない
            break
        }
    }
}

extension PlayGameViewController: UICollectionViewDataSource {

    // 表示セル数
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.cards.count
    }

    // セルのデータを管理
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCell", for: indexPath)

        let imageView = cell.contentView.viewWithTag(1) as! UIImageView
        imageView.image = UIImage(named: cards[indexPath.row].getImageName())

        return cell
    }
}

extension PlayGameViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        // セルサイズを設定
        let cellWidth: CGFloat = self.view.bounds.width / 5 - 4
        let cellHeight: CGFloat = self.collectionView.frame.height / 4 - 55
        return CGSize(width: cellWidth, height: cellHeight)
    }
}
