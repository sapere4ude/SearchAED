//
//  ResultTableViewCell.swift
//  SearchAED
//
//  Created by sapere4ude on 2020/10/19.
//

import UIKit

class ResultTableViewCell: UITableViewCell {
    @IBOutlet weak var orgImageView: UIImageView!
    @IBOutlet weak var addressImageView: UIImageView!
    
    @IBOutlet weak var orgLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        orgImageView.image = UIImage(systemName: "house.fill", withConfiguration: UIImage.SymbolConfiguration(weight: .regular))?.withTintColor(.systemPink, renderingMode: .alwaysOriginal)
        
        addressImageView.image = UIImage(systemName: "info.circle.fill", withConfiguration: UIImage.SymbolConfiguration(weight: .regular))?.withTintColor(.systemPink, renderingMode: .alwaysOriginal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        orgLabel.text = nil
        addressLabel.text = nil
    }
    
}
