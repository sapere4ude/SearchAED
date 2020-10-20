//
//  ResultTableViewCell.swift
//  SearchAED
//
//  Created by sapere4ude on 2020/10/19.
//

import UIKit

class ResultTableViewCell: UITableViewCell {

    @IBOutlet weak var orgLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
