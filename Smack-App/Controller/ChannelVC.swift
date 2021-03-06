//
//  ChannelVC.swift
//  Smack-App
//
//  Created by Johnny Perdomo on 1/13/18.
//  Copyright © 2018 Johnny Perdomo. All rights reserved.
//

//this is for the channel VC that slides out
import UIKit

class ChannelVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var userImg: CircleImage!
    @IBOutlet weak var tableView: UITableView!
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {}
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
 
        tableView.delegate = self
        tableView.dataSource = self
        
        self.revealViewController().rearViewRevealWidth = self.view.frame.size.width - 60 //this is the width of the reveal view when its open..../{the rear view should take all of the screen size, except 60 points}
        NotificationCenter.default.addObserver(self, selector: #selector(ChannelVC.userDataDidChange(_:)), name: NOTIFICATION_USER_DATA_DID_CHANGE, object: nil) //this observes whenever the notification is posted
        NotificationCenter.default.addObserver(self, selector: #selector(ChannelVC.channelsLoaded(_:)), name: NOTIFICATION_CHANNELS_LOADED, object: nil) //observer, then calls this channelLoaded func, and reloads the table
        
        
        
        SocketService.instance.getChannel { (success) in //we have to call the function here
            if success {
                self.tableView.reloadData() //this reloads the tableView if successful
            }
        }
        
        SocketService.instance.getChatMessage { (newMessage) in //we want to see notifications for channels we are not in
            if newMessage.channelId != MessageService.instance.selectedChannel?.id && AuthService.instance.isLoggedIn { //if the newMessage does not equal the selected channel when we're logged in
                MessageService.instance.unreadChannels.append(newMessage.channelId) //append to the unread channels dictionary
                self.tableView.reloadData()
            }
        }
        
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        setupUserInfo()
    }
    
    @IBAction func addChannelPressed(_ sender: Any) {
        if AuthService.instance.isLoggedIn { //to check if its logged in 
            let addChannel = AddChannelVC() //to instantiate VC
            addChannel.modalPresentationStyle = .custom //lets us present it the custom way we did it
            present(addChannel, animated: true, completion: nil) //to present it
        }
       
        
    }
    
    @IBAction func loginBtnPressed(_ sender: Any) {
        if AuthService.instance.isLoggedIn { //if logged in, show the profile page when clicking on button
            let profile = ProfileVC() //this is to present the profileVC since its a xib file, but not on story board
            profile.modalPresentationStyle = .custom
            present(profile, animated: true, completion: nil)
            
        } else {
            performSegue(withIdentifier: TO_LOGIN, sender: nil) //if not logged in, when Btn is pressed, go to login page
        }
    }
    
     @objc func userDataDidChange(_ notification: Notification) { //if notification is posted and we receive it, we will call this function as stated above
       setupUserInfo()
     }
    
    @objc func channelsLoaded(_ notif: Notification) {
        tableView.reloadData() //reloads tableview
    }
    
    func setupUserInfo() {
        if AuthService.instance.isLoggedIn { //if we logged in successfully it should show up in the channel vc
            loginBtn.setTitle(UserDataService.instance.name, for: .normal) // it should set our name
            userImg.image = UIImage(named: UserDataService.instance.avatarName) //it should show what avatar we picked
            userImg.backgroundColor = UserDataService.instance.returnUIColor(components: UserDataService.instance.avatarColor)
        } else { //if we didnt login successfully
            loginBtn.setTitle("Login", for: .normal) //set the title to "Login"
            userImg.image = UIImage(named: "menuProfileIcon") //sets a default image
            userImg.backgroundColor = UIColor.clear //and the background color is clear
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "channelCell", for: indexPath) as? ChannelCell {
        let channel = MessageService.instance.channels[indexPath.row]
        cell.configureCell(channel: channel)
        return cell
    } else {
        return UITableViewCell()  //if it doesn't return cells, show an empty table
        }
    }
        func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }
        
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MessageService.instance.channels.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let channel = MessageService.instance.channels[indexPath.row] //choose our channel and set it.
        MessageService.instance.selectedChannel = channel //set the selected channel
        
        
        if MessageService.instance.unreadChannels.count > 0 { //if there are unread channels, we want this function to put the font back to normal once we click on it
            MessageService.instance.unreadChannels = MessageService.instance.unreadChannels.filter{$0 != channel.id} //equal to itself, but filter out the one we clicked on
            
        }
        let index = IndexPath(row: indexPath.row, section: 0) //reload it so that its not an unread channel
        tableView.reloadRows(at: [index], with: .none)
        tableView.selectRow(at: index, animated: false, scrollPosition: .none) //shows it as a normal channel
        
        NotificationCenter.default.post(name: NOTIFICATION_CHANNEL_SELECTED, object: nil) //then it posts a notif letting the system know you chose a channel
        
        self.revealViewController().revealToggle(animated: true) //to slide the menu back and hide it.
    }
    
    
    
    

}
        


        

