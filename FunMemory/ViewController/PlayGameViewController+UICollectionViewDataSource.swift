//
//  PlayGameViewController+UICollectionViewDataSource.swift
//  FunMemory
//
//  Created by 柴田晃輔 on 2019/09/07.
//  Copyright © 2019 shibata. All rights reserved.
//

import UIKit

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
