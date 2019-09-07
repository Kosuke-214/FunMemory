//
//  PlayGameViewController+UICollectionViewDelegateFlowLayout.swift
//  FunMemory
//
//  Created by 柴田晃輔 on 2019/09/07.
//  Copyright © 2019 shibata. All rights reserved.
//

import UIKit

extension PlayGameViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        // セルサイズを設定
        let cellWidth: CGFloat = self.view.bounds.width / 5 - 4
        let cellHeight: CGFloat = self.collectionView.frame.height / 4 - 55
        return CGSize(width: cellWidth, height: cellHeight)
    }
}
