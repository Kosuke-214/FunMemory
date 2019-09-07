//
//  PlayGameViewController+UICollectionViewDelegate.swift
//  FunMemory
//
//  Created by 柴田晃輔 on 2019/09/07.
//  Copyright © 2019 shibata. All rights reserved.
//

import UIKit

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

}
