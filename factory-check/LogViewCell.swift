//
//  LogViewCell.swift
//  factory-check
//
//  Created by mizota takaaki on 2019/06/11.
//  Copyright © 2019 conol, Inc. All rights reserved.
//

import UIKit

class LogViewCell: UITableViewCell
{
    @IBOutlet weak var ImageView: UIImageView!
    @IBOutlet weak var datetime: UILabel!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var step: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
