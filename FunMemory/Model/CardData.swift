//
//  CardData.swift
//  FunMemory
//
//  Created by 柴田晃輔 on 2019/08/12.
//  Copyright © 2019 shibata. All rights reserved.
//

import Foundation
import UIKit

class CardData {
    let no: Int
    let imageName: String
    var index: Int = 0

    var isFront: Bool

    init(no: Int) {
        self.no = no
        self.imageName = NSString(format: "c%d", no) as String
        self.isFront = false
    }

    func getImageName() -> String {
        // 表であればカード名を、裏であれば裏カードの名前を返す
        if isFront {
            return imageName
        }
        return "CardBack"
    }

    func reverseCard(collectionView: UICollectionView) {
        // 表裏のBool値を反転
        isFront.toggle()

        let indexPath = IndexPath(item: index, section: 0)
        let cell = collectionView.cellForItem(at: indexPath)

        let imageView = cell?.contentView.viewWithTag(1) as! UIImageView
        imageView.image = UIImage(named: getImageName())

        // 反転時のアニメーション
        UIView.transition(with: imageView, duration: 1.0,
                          options: [.transitionFlipFromLeft], animations: nil, completion: nil)
    }

    func matchingAnimation(collectionView: UICollectionView) {

        let indexPath = IndexPath(item: index, section: 0)
        let cell = collectionView.cellForItem(at: indexPath)

        let imageView = cell?.contentView.viewWithTag(1) as! UIImageView
        imageView.image = UIImage(named: getImageName())

        // マッチング時のアニメーション
        UIView.animate(withDuration: 0.5, delay: 1.0, options: .repeat, animations: {
            imageView.alpha = 0.0
        }, completion: nil)

        // 2秒後にアニメーションを停止
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { (_) in
            imageView.alpha = 1.0
        }

    }
}