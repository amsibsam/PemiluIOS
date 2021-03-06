//
//  DebatCommentCell.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma Setya Putra on 19/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common
import Networking

class DebatCommentCell: UITableViewCell {

    @IBOutlet weak var lbCreatedAt: Label!
    @IBOutlet weak var lbContent: Label!
    @IBOutlet weak var lbName: Label!
    @IBOutlet weak var ivAvatar: CircularUIImageView!
    @IBOutlet weak var viewRedDot: RoundView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        transform = CGAffineTransform(rotationAngle: -CGFloat(Double.pi))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.ivAvatar.image = #imageLiteral(resourceName: "icDummyPerson")
        self.ivAvatar.af_cancelImageRequest()
    }
    
}

extension DebatCommentCell: IReusableCell {
    public struct Input {
        let word: Word
    }
    
    func configureCell(item: Input) {
        if let url = item.word.author.avatar.thumbnail.url {
            self.ivAvatar.af_setImage(withURL: URL(string: url)!)
        }
        self.lbContent.text = item.word.body
        self.lbCreatedAt.text = item.word.createdAt.timeAgoSinceDateForm2
        self.lbName.text = item.word.author.fullName
        
    }
}
