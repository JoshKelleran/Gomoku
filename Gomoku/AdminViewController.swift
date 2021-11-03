//
//  AdminViewController.swift
//  Gomoku
//
//  Created by Josh Kelleran on 6/4/19.
//  Copyright © 2019 Josh Kelleran. All rights reserved.
//

import UIKit
import AWSAppSync

class AdminViewController: UIViewController {
    
    var appSyncClient: AWSAppSyncClient?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appSyncClient = appDelegate.appSyncClient
    }
    

    func deleteGomokuGame(gameId: String)
    {
        var retval = ""
        let gomokuInput = DeleteGomokuInput(id: gameId)
        appSyncClient?.perform(mutation: DeleteGomokuMutation(input: gomokuInput)) { (result, error) in
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
            self.onDeleteGomokuGame(result: retval)
        }
    }
    
    func onDeleteGomokuGame(result: String)
    {
        statusLabel.text = "Delete result: \(result)"
    }
    
    
    func listGomokuGames()
    {
        appSyncClient?.fetch(query: ListGomokusQuery(), cachePolicy: .fetchIgnoringCacheData) {(result, error) in
            var retval = ""
            if error != nil {
                retval = (error?.localizedDescription ?? "")
            }
            var row = 0
            
            result?.data?.listGomokus?.items!.forEach
                {
                    let currentData: String = ($0?.data == nil ? "" : ($0?.data)!)
                    let currentValue = "row \(row): " + ($0?.id)! + " p1: " + ($0?.player1 == nil ? "(nil)" : ($0?.player1)!)  + " p2: " + ($0?.player2 == nil ? "(nil)" : ($0?.player2)!) + ", data: " + currentData.prefix(10)
                    print(currentValue)
                    retval += currentValue + "\n"
                    row += 1
                    // let currentID = $0?.id
                    // print(currentID == nil ? "(nil)" : String(currentID!))
                    // retval.append(currentID == nil ? "(nil)" : String(currentID!))
            }
            self.onListGomokuGames(result: retval)
        }
    }
    
    func onListGomokuGames(result: String)
    {
        statusLabel.text = result
    }
    
    
    @IBOutlet weak var statusLabel: UITextView!
    
    @IBAction func deleteGameButton(_ sender: UIButton)
    {
        deleteGomokuGame(gameId: deleteGameTextField.text!)
    }
    
    @IBAction func listGamesButton(_ sender: UIButton)
    {
        listGomokuGames()
    }
    

    @IBOutlet weak var deleteGameTextField: UITextField!
    
    @IBAction func closeButton(_ sender: UIButton)
    {
        self.dismiss(animated: true, completion: nil)
    }
}
