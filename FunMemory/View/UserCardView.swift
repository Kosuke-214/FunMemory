//
//  UserCardView.swift
//  FunMemory
//
//  Created by 柴田晃輔 on 2019/08/16.
//  Copyright © 2019 shibata. All rights reserved.
//

import UIKit

class UserCardView: UIView {

    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userPoint: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadFromNib()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadFromNib()
    }

    private func loadFromNib() {
        let view = UINib(nibName: "UserCardView",
                         bundle: Bundle(for: UserCardView.self))
            .instantiate(withOwner: self, options: nil)[0] as! UIView
        view.frame = self.bounds
        addSubview(view)
    }

    override func prepareForInterfaceBuilder() {
        loadFromNib()
    }

}
