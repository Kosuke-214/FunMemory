//
//  PlayGameViewController+UICollectionViewDelegate.swift
//  FunMemory
//
//  Created by 柴田晃輔 on 2019/09/07.
//  Copyright © 2019 shibata. All rights reserved.
//

import UIKit

extension PlayGameViewController: UICollectionViewDelegate {

    // 終了結果ステータスの列挙型
    enum ResultStatus {
        case user1Win, user2Win, draw, soloFinish
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let card = self.cards[indexPath.row]

        switch status {
        case .none:
            // カードを一枚も開いていない、かつ選択したカードが裏である場合
            if !card.isFront {
                // 一枚目のカードを反転
                firstCard = card
                firstCard?.reverseCard(collectionView: self.collectionView)

                if myPosition == "user1" {
                    database.child("cardData/selected/user1").setValue(firstCard?.index)
                } else if myPosition == "user2" {
                    database.child("cardData/selected/user2").setValue(firstCard?.index)
                }

                // ステータスを更新
                status = .firstOpen
            }
        case .firstOpen:
            // カードを一枚開いている、かつ選択したカードが裏である場合
            if !card.isFront {
                // 二枚目のカードを反転
                secondCard = card
                secondCard?.reverseCard(collectionView: self.collectionView)

                if myPosition == "user1" {
                    database.child("cardData/selected/user1").setValue(secondCard?.index)
                } else if myPosition == "user2" {
                    database.child("cardData/selected/user2").setValue(secondCard?.index)
                }

                // ステータスを更新
                status = .secondOpen

                // 一枚目と二枚目のカード名が一致する場合
                if firstCard?.imageName == secondCard?.imageName {
                    print("Matching!!!")

                    firstCard?.matchingAnimation(collectionView: self.collectionView)
                    secondCard?.matchingAnimation(collectionView: self.collectionView)

                    // ポイントを加算
                    userPoint += 1
                    if gameMode == "Multi" {
                        if myPosition == "user1" {
                            database.child("point/user1").setValue(userPoint)
                        } else {
                            database.child("point/user2").setValue(userPoint)
                        }
                    } else {
                        user1Card.userPoint.text = String(userPoint)
                    }

                    // マッチングのアニメーション中にタップさせないようにステータス更新を遅らせる
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                        // ステータスを更新
                        self.status = .none
                    }

                    // 終了判定
                    self.checkFinish()

                    // 一枚目と二枚目のカード名が一致しない場合
                } else {
                    // 1.5秒後にカードを戻す
                    print("Not Matching...")
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
                        self.firstCard?.reverseCard(collectionView: self.collectionView)
                        self.secondCard?.reverseCard(collectionView: self.collectionView)

                        if self.myPosition == "user1" {
                            self.database.child("cardData/selected/user1").setValue(self.firstCard?.index)
                            self.database.child("cardData/selected/user1").setValue(self.secondCard?.index)
                        } else if self.myPosition == "user2" {
                            self.database.child("cardData/selected/user2").setValue(self.firstCard?.index)
                            self.database.child("cardData/selected/user2").setValue(self.secondCard?.index)
                        }

                        // 反転中もタップさせないようにステータス更新を1秒遅らせる
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                            // ステータスを更新
                            self.status = .none

                            // ターン交代
                            if self.myPosition == "user1" {
                                self.database.child("turn/user1").setValue(false)
                                self.database.child("turn/user2").setValue(true)
                            } else {
                                self.database.child("turn/user1").setValue(true)
                                self.database.child("turn/user2").setValue(false)
                            }
                        }
                    }
                }
            }
        case .secondOpen:
            // 2枚目が開いている場合は選択させない
            break
        }
    }

    func checkFinish() {

        if gameMode == "Multi" {
            database.child("point").observeSingleEvent(of: .value, with: { [weak self] snapshot in
                if let data = snapshot.value as? NSDictionary {
                    if let point1 = data["user1"] as! Int?, let point2 = data["user2"] as! Int? {
                        let totalPoint = point1 + point2
                        if totalPoint == 10 {
                            if point1 > point2 {
                                self?.showFinishAlert(result: .user1Win)
                            } else if point2 > point1 {
                                self?.showFinishAlert(result: .user2Win)
                            } else {
                                self?.showFinishAlert(result: .draw)
                            }
                        }
                    }
                }
            })
        } else {
            if userPoint == 10 {
                showFinishAlert(result: .soloFinish)
            }
        }
    }

    func showFinishAlert(result: ResultStatus) {

        let resultTitle: String?
        let resultMessage: String?

        switch result {
        case .user1Win:
            resultTitle = "\(user1Card.userName.text!)が勝利しました"

            if myPosition == "user1" {
                resultMessage = "あなたの勝ちです"
            } else {
                resultMessage = "あなたの負けです"
            }

        case .user2Win:
            resultTitle = "\(user2Card.userName.text!)が勝利しました"

            if myPosition == "user1" {
                resultMessage = "あなたの負けです"
            } else {
                resultMessage = "あなたの勝ちです"
            }

        case .draw:
            resultTitle = "引き分けです"
            resultMessage = ""

        case .soloFinish:
            resultTitle = "ゲーム終了です"
            resultMessage = ""
        }

        let alert: UIAlertController = UIAlertController(title: resultTitle,
                                                         message: resultMessage,
                                                         preferredStyle: UIAlertController.Style.alert)

        // Actionの設定
        let okAction: UIAlertAction = UIAlertAction(title: "終了", style: UIAlertAction.Style.default,
                                                    handler: { (_: UIAlertAction!) -> Void in

                                                        // DB情報をクリア
                                                        self.clearDB()

                                                        // 画面遷移実行
                                                        self.performSegue(withIdentifier:
                                                            "exitGameSegue",
                                                                          sender: true)
        })

        // UIAlertControllerにActionを追加
        alert.addAction(okAction)

        // マッチングのアニメーション完了後にアラートを表示
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            self.present(alert, animated: true, completion: nil)
        }
    }

}
