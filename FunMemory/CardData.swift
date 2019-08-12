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
    }
}
