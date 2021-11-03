//
//  ViewController.swift
//  Gomoku
//
//  Created by Josh Kelleran on 6/1/19.
//  Copyright © 2019 Josh Kelleran. All rights reserved.
//

import UIKit
import AWSAppSync

class ViewController: UIViewController {

    //Reference AppSync client
    var appSyncClient: AWSAppSyncClient?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appSyncClient = appDelegate.appSyncClient
        
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
        let gomokuInput = CreateGomokuInput(id: gameId, player1: p1Name, player2: nil, playerTurn: 1, data: gameData, status: 0)
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
    
    func updateGomokuGame(gameId: String, data: String)
    {
        var retval = ""
        let gomokuInput = UpdateGomokuInput(id: gameId, data: data)
        appSyncClient?.perform(mutation: UpdateGomokuMutation(input: gomokuInput)) { (result, error) in
            if let error = error as? AWSAppSyncClientError
            {
                retval = "Error occurred: \(error.localizedDescription )"
            }
            if let resultError = result?.errors
            {
                retval =  "Error uploading the item on server: \(resultError)"
            }
            else
            {
                retval = "Success!"
            }
            self.onUpdateGomokuGame(result: retval)
        }
    }
    
    func onCreateGomokuGame(result: String)
    {
        statusLabel.text = "Create result: \(result)"
    }
    
    
    func onJoinGomokuGame(result: String)
    {
        statusLabel.text = "Join result: \(result)"
    }
    
    func onUpdateGomokuGame(result: String)
    {
        statusLabel.text = "Upload result: \(result)"
    }
    


    
    
    @IBAction func createGame(_ sender: UIButton)
    {
        //createGomokuGame(gameId: gameIdCreate.text!, player1: playerName1Create.text!)
    }
    
    
    @IBAction func joinGame(_ sender: UIButton)
    {
        
    }
    
   
    
    @IBOutlet weak var statusLabel: UILabel!
    
    
    
    
    @IBOutlet weak var gameIdDelete: UITextField!
    
    
   
    
}

