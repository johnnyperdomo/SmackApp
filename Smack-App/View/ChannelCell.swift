//
//  ChannelCell.swift
//  Smack-App
//
//  Created by Johnny Perdomo on 2/9/18.
//  Copyright © 2018 Johnny Perdomo. All rights reserved.
//

import UIKit

class ChannelCell: UITableViewCell {

    //Outlets
    @IBOutlet weak var channelName: UILabel!
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected { //if channel selected
            self.layer.backgroundColor = UIColor(white: 1, alpha: 0.2).cgColor
        } else {
            self.layer.backgroundColor = UIColor.clear.cgColor //if not selected, show clear
        }
    }
    
    func configureCell(channel: Channel) {
        let title = channel.channelTitle ?? "" //nil coalescing, if cant find title, show empty string
        channelName.text = "#\(title)"
        channelName.font = UIFont(name: "HelveticaNeue-Regular", size: 17) // defaults fonts
        
        for id in MessageService.instance.unreadChannels { //loop through the unreadChannelIds with our channel id's to see which ones match, match = unread channel
            if id == channel.id { // if the id is the same, to make the font bold and bigger if its unread channel
                channelName.font = UIFont(name: "HelveticaNeue-Bold", size: 22)
            }
        }
    }
}
