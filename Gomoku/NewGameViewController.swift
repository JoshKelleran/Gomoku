//
//  NewGameViewController.swift
//  Gomoku
//
//  Created by Josh Kelleran on 6/2/19.
//  Copyright © 2019 Josh Kelleran. All rights reserved.
//

import UIKit
import AWSAppSync


class NewGameViewController: UIViewController
{
    
    var appSyncClient: AWSAppSyncClient?
    
    override func viewDidLoad() {
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
            vc?.gameId = newGameId.text!
            vc?.gameMode = 1 // online game
            vc?.playerNumber = 1
        }
    }
    
    func createGomokuGame(gameId: String, player1 p1Name: String)
    {
        let rowData = "000000000000000"
        var gameData = ""
        for _ in 0...14
        {
            gameData += rowData
        }
        var retval = ""
        let gomokuInput = CreateGomokuInput(id: gameId, player1: p1Name, player2: nil, playerTurn: 0, data: gameData, status: 0)
        appSyncClient?.perform(mutation: CreateGomokuMutation(input: gomokuInput)) { (result, error) in
            if let error = error as? AWSAppSyncClientError
            {
                retval = "Error occurred: \(error.localizedDescription )"
            }
            if let resultError = result?.errors
            {
                retval =  "Error saving the item on server: \(resultError)"
            }
            else
            {
                retval = "Success!"
            }
            self.onCreateGomokuGame(result: retval)
        }
    }
    
    func onCreateGomokuGame(result: String)
    {
        statusTextView.text = "Create result: \(result)"
    }
    
    @IBOutlet weak var statusTextView: UITextView!
    
    @IBAction func playButton(_ sender: UIButton)
    {
        createGomokuGame(gameId: newGameId.text!, player1: newGamePlayerName1.text!)
    }
    
    @IBOutlet weak var newGameId: UITextField!
    
    @IBOutlet weak var newGamePlayerName1: UITextField!
    
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
