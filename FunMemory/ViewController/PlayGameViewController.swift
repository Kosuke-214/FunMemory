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
    // 自分がuser1かuser2かを格納する変数
    var myPosition: String?
    // カードインデックス配列初期化用
    let initializeArray = [0]

    // カードステータスの列挙型
    enum CardStatus {
        case firstOpen, secondOpen, none
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // delegateとdataSourceを設定
        self.collectionView.delegate = self
        self.collectionView.dataSource = self

        // 配列をランダムに並び替え
        let shuffledCardNoArray = cardNoArray.shuffled()

        if gameMode == "Multi" {
            // カードのインデックス配列をDBから取得
            database.child("cardData").observeSingleEvent(of: .value, with: { [weak self] snapshot in
                if let data = snapshot.value as? NSArray {
                    if data.count == 1 {
                        // 初期配列が格納されている場合はカードのインデックス配列をDBへ格納
                        self?.database.child("cardData").setValue(shuffledCardNoArray)

                        // カードオブジェクトを配列に格納
                        for (index, cardNo) in zip(shuffledCardNoArray.indices, shuffledCardNoArray) {
                            let card = CardData(no: cardNo)
                            self?.cards.append(card)

                            card.index = index
                        }
                    } else {
                        //既に配列格納済みの場合は取得した配列を使用する
                        // カードオブジェクトを配列に格納
                        for (index, cardNo) in zip(shuffledCardNoArray.indices, data) {
                            let card = CardData(no: cardNo as! Int)
                            self?.cards.append(card)

                            card.index = index
                        }
                    }
                }
                self?.collectionView.reloadData()
            })
        } else {
            // カードオブジェクトを配列に格納
            for (index, cardNo) in zip(shuffledCardNoArray.indices, shuffledCardNoArray) {
                let card = CardData(no: cardNo)
                cards.append(card)

                card.index = index
            }
        }

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
            setUserDataOnMulti()
            // ユーザが自分1人の場合は対戦相手を待機
            observeOpponent()
            // 対戦相手の退出を監視
            observeMember()
            // ポイントを監視
            observePoint()

        default:
            break
        }

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

                                                            // DB情報をクリア
                                                            self.clearDB()
                                                            // 画面遷移実行
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

    func setUserDataOnMulti() {

        // ユーザデータをインスタンス化
        let userData = UserData()

        database.child("userName").observeSingleEvent(of: .value, with: { [weak self] snapshot in
            if let data = snapshot.value as? NSDictionary {
                if let user1 = data["user1"] as! String?, let user2 = data["user2"] as! String? {
                    if user1 == "none" {
                        // ユーザがいない場合、user1に自分を設定
                        self?.database.child("userName/user1").setValue(userData.readData())
                        self?.myPosition = "user1"
                        self?.user1Card.userName.text = userData.readData()
                        self?.user2Card.userName.text = user2

                        // DB上のポイント数を0に設定
                        self?.database.child("point/user1").setValue(0)
                        self?.database.child("point/user2").setValue(0)
                    } else {
                        // user1が存在する場合、user2に自分を設定
                        self?.database.child("userName/user2").setValue(userData.readData())
                        self?.myPosition = "user2"
                        self?.user1Card.userName.text = user1
                        self?.user2Card.userName.text = userData.readData()

                        // DB上のポイント数を0に設定
                        self?.database.child("point/user1").setValue(0)
                        self?.database.child("point/user2").setValue(0)
                    }
                }
            }
        })
    }

    func observeOpponent() {

        // インジケータ表示用アラート
        let alert = UIAlertController(title: "対戦相手を待機中...", message: "\n", preferredStyle: .alert)

        // インジゲータ表示
        let indicator = UIActivityIndicatorView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.isUserInteractionEnabled = false
        indicator.color = UIColor.lightGray
        indicator.startAnimating()
        alert.view.addSubview(indicator)

        // アラート内の制約設定
        let views: [String: UIView] = ["alert": alert.view, "indicator": indicator]
        var constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[indicator]-(12)-|",
                                                         options: [],
                                                         metrics: nil,
                                                         views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[indicator]|",
                                                      options: [],
                                                      metrics: nil,
                                                      views: views)
        alert.view.addConstraints(constraints)

        // アラート表示
        present(alert, animated: true, completion: {
            self.database.child("userName").observe(.value, with: { [weak self] snapshot in
                if let data = snapshot.value as? NSDictionary {
                    if let user2 = data["user2"] as! String? {
                        if user2 != "none" {
                            // user2が入室したらアラートを消去
                            alert.dismiss(animated: true, completion: nil)
                            // user2が入室したらラベルを更新
                            self?.user2Card.userName.text = user2
                        }
                    }
                }
            })
        })
    }

    func observeMember() {
        database.observe(.value, with: { [weak self] snapshot in
            if let data = snapshot.value as? NSDictionary {
                if let userCount = data["userCount"] as! Int? {
                    if userCount == 0 {

                        let alert: UIAlertController = UIAlertController(title: "通知",
                                                                         message: "対戦相手が退出しました",
                                                                         preferredStyle: UIAlertController.Style.alert)

                        // Actionの設定
                        let okAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default,
                                                                    handler: { (_: UIAlertAction!) -> Void in
                                                                        // 画面遷移実行
                                                                        self?.performSegue(withIdentifier:
                                                                            "exitGameSegue",
                                                                                           sender: true)
                        })
                        // UIAlertControllerにActionを追加
                        alert.addAction(okAction)

                        // Alertを表示
                        self?.present(alert, animated: true, completion: nil)

                    }
                }
            }
        })
    }

    func observePoint() {
        database.child("point").observe(.value, with: { [weak self] snapshot in
            if let data = snapshot.value as? NSDictionary {
                if let point1 = data["user1"] as! Int?, let point2 = data["user2"] as! Int? {
                    self?.user1Card.userPoint.text = String(point1)
                    self?.user2Card.userPoint.text = String(point2)
                }
            }
        })

    }

    func clearDB() {
        // DB情報をクリア
        self.database.child("userName/user1").setValue("none")
        self.database.child("userName/user2").setValue("none")
        self.database.child("point/user1").setValue(0)
        self.database.child("point/user2").setValue(0)
        self.database.child("userCount").setValue(0)
        self.database.child("cardData").setValue(initializeArray)
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
                    if myPosition == "user1" {
                        database.child("point/user1").setValue(userPoint)
                    } else {
                        database.child("point/user2").setValue(userPoint)
                    }

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

                    if myPosition == "user1" {
                        database.child("turn/user1").setValue(false)
                        database.child("turn/user2").setValue(true)
                    } else {
                        database.child("turn/user1").setValue(true)
                        database.child("turn/user2").setValue(false)
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
