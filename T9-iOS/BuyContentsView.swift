//
//  BuyContentsView.swift
//  BuyContentsView
//
//  Created by Hrt on 2018/08/23.
//  Copyright © 2018年 Takahiro Hirata. All rights reserved.
//

import UIKit

@IBDesignable class BuyContentsView: UIView {
    
    var isPurchased:Bool = false
    @IBOutlet weak var contentsName: UILabel!
    @IBOutlet weak var purchasedLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadFromNib()
    }
    
    private func loadFromNib() {
        let v = UINib(nibName: "BuyContentsView", bundle: Bundle(for: BuyContentsView.self)).instantiate(withOwner: self, options: nil)[0] as! UIView
        v.frame = self.bounds
        addSubview(v)
    }
    
    override func prepareForInterfaceBuilder() {
        loadFromNib()
    }
    
    override func draw(_ rect: CGRect) {
        print("draw")
        if isPurchased {
            purchasedLabel.text = "購入済み"
        } else {
            purchasedLabel.text = "未購入"
        }
    }
    
    func  setImage(name: String) {
        imageView.image = UIImage(named:name)
    }
}
