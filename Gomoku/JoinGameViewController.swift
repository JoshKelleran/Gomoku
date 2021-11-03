//
//  JoinGameViewController.swift
//  Gomoku
//
//  Created by Josh Kelleran on 6/3/19.
//  Copyright © 2019 Josh Kelleran. All rights reserved.
//

import UIKit
import AWSAppSync

class JoinGameViewController: UIViewController
{
    var appSyncClient: AWSAppSyncClient?

    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appSyncClient = appDelegate.appSyncClient
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is GameBoardViewController
        {
            let vc = segue.destination as? GameBoardViewController
            vc?.gameId = gameIdJoin.text!
            vc?.gameMode = 1 // online game
            vc?.playerNumber = 2
            vc?.playerTurn = 1
        }
    }
    
    func joinGomokuGame(gameId: String, player2: String)
    {
        var retval = ""
        let gomokuInput = UpdateGomokuInput(id: gameId, player2: player2, playerTurn: 1)
        appSyncClient?.perform(mutation: UpdateGomokuMutation(input: gomokuInput)) { (result, error) in
            if let error = error as? AWSAppSyncClientError
            {
                retval = "Error occurred: \(error.localizedDescription )"
            }
            if let resultError = result?.errors
            {
                retval =  "Error deleting the item on server: \(resultError)"
            }
            else
            {
                retval = "Success!"
            }
            self.onJoinGomokuGame(result: retval)
        }
    }
    
    func onJoinGomokuGame(result: String)
    {
        statusViewJoin.text = "Join result: \(result)"
    }
    
    @IBOutlet weak var gameIdJoin: UITextField!
    
    @IBOutlet weak var playerNameJoin: UITextField!
    
    @IBAction func joinGameButton(_ sender: UIButton)
    {
        joinGomokuGame(gameId: gameIdJoin.text!, player2: playerNameJoin.text!)
    }
    
    @IBOutlet weak var statusViewJoin: UITextView!
    
    @IBAction func closeButton(_ sender: UIButton)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
