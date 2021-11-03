//
//  GameBoardViewController.swift
//  Gomoku
//
//  Created by Josh Kelleran on 6/2/19.
//  Copyright © 2019 Josh Kelleran. All rights reserved.
//

import UIKit
import AWSAppSync

class GameBoardViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate
{
    var appSyncClient: AWSAppSyncClient?
    
    var game = Gomoku()
    let reuseIdentifier = "cell"
    
    var gameId = ""
    var gameMode = 0
    var playerNumber = 0
    var playerTurn = 0
    var player1 = ""
    var player2 = ""
    
    // Declare an instance of the Timer class.
    var countingTimer: Timer?
    // Declare an Int to keep track of each time Timer fires/ticks.
    var tickCount = 0
    // Declare Double to specify seconds between Timer ticks.
    let tickRate = 1.0
    // Declare Int to specify total timer ticks possible.
    let totalTicks = 120
    // Declare Float to specify progress bar increments.
    var progressIncrement: Float = 0.0
    
    
    let bibleVerses = ["Humble yourselves before the Lord, and he will lift you up. James 4:10",
                       "Before a downfall the heart is haughty, but humility comes before honor. Proverbs 18:12",
                       "For the LORD takes delight in his people; he crowns the humble with victory. Psalm 149:4",
                       "For those who exalt themselves will be humbled, and those who humble themselves will be exalted. Matthew 23:12",
                       "For those who exalt themselves will be humbled, and those who humble themselves will be exalted. Proverbs 3:34",
                       "But he gives us more grace. That is why Scripture says: God opposes the proud but shows favor to the humble. James 4:6",
                       "God brings down the proud and saves the humble. Job 22:29",
                       "He guides the humble in what is right and teaches them his way. Psalm 25:9",
                       "Set your minds on things above, not on earthly things. Colossians 3:2",
                       "Be kind and compassionate to one another, forgiving each other, just as in Christ God forgave you. Ephesians 4:32",
                       "For God so loved the world that he gave his one and only Son, that whoever believes in him shall not perish but have eternal life. John 3:16",
                       "Rejoice in the Lord always. I will say it again: Rejoice! Philippians 4:4",
                       "As iron sharpens iron, so one person sharpens another. Proverbs 27:17",
                       "Hatred stirs up conflict, but love covers over all wrongs. Proverbs 10:12"]
    

    @IBOutlet weak var myCollectionView: UICollectionView!
    
    
    @IBOutlet weak var myCollectionViewFlowLayout: UICollectionViewFlowLayout!
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appSyncClient = appDelegate.appSyncClient
        
        // Do any additional setup after loading the view.
        if let flowLayout = myCollectionViewFlowLayout
        {
            let margins = 20
            let borders = 15
            let viewBounds = self.view.bounds
            let cellWidth = (Int(viewBounds.width) - borders - margins) / 15
            flowLayout.estimatedItemSize = CGSize(width: cellWidth, height: cellWidth)
            print("Initial cell size: \(cellWidth)")
        }
        
        game.id = gameId
        game.mode = gameMode
        game.turn = playerTurn
        checkGameStatus(gameId: game.id)
    }
    
    func checkGameStatus(gameId: String)
    {
        // If this is an offline game, none of this is necessary
        if game.mode == 0 {return}
        
        // Print the game ID
        print("GameID = \(game.id)")
        
        // Create and configure the timer for 1.0 second ticks.
        countingTimer = Timer.scheduledTimer(timeInterval: tickRate, target: self, selector: #selector(onTimerTick), userInfo: "Tick: ", repeats: true)
        // Make the timer efficient.
        countingTimer?.tolerance = 1 //.15
        // Helps UI stay responsive even with timer.
        RunLoop.current.add(countingTimer!, forMode: RunLoop.Mode.common)
        
    }
    
    func getGomokuGame(gameId: String)
    {
        appSyncClient?.fetch(query: GetGomokuQuery(id:gameId), cachePolicy: .fetchIgnoringCacheData) {(result, error) in
            if error != nil {
                print (error?.localizedDescription ?? "")
            }
            self.onGetGomokuGame(result: result?.data)
        }
    }
    
    func onGetGomokuGame(result: GetGomokuQuery.Data?)
    {

        game.turn = result?.getGomoku?.playerTurn ?? 0
        if (game.turn == self.playerNumber || game.turn  == -1)
        {
            player1 = result?.getGomoku?.player1 ?? "(nil)"
            player2 = result?.getGomoku?.player2 ?? "(nil)"
            let gameData = result?.getGomoku?.data ?? "(nil)"
            countingTimer?.invalidate() // Destroy timer.
            tickCount = 0
            game.dataFromString(value: gameData)
            game.setBoardStatus()
            redrawBoard()
            print ("Game is unlocked!")
        }
        else
        {
            print("Still polling...")
        }
        // statusLabel.text = result
    }
    
    @objc func onTimerTick(timer: Timer) -> Void
    {
        
        //let preface = timer.userInfo as? String
        print("Calling Timer: \(tickCount)")

        // BOUNDARY: I only let the timer for a fixed number of ticks
        if tickCount >= totalTicks {
            countingTimer?.invalidate() // Destroy timer.
        }
            // We haven't hit the boundary, so count
            // the current tick and display.
        else {
            tickCount += 1
        }
        
        getGomokuGame(gameId: gameId)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        let size = game.getBoardSize()
        return (size.rows * size.columns)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MyCollectionViewCell
        
        cell.backgroundColor = UIColor.init(displayP3Red: 200/255.0, green: 150/255.0, blue: 90/255.0, alpha: 1)
        cell.myLabel.adjustsFontSizeToFitWidth = true
        cell.myLabel.minimumScaleFactor = 0.5
        cell.myLabel.numberOfLines = 0 // or 1
        
        cell.myLabel.translatesAutoresizingMaskIntoConstraints = false
        cell.myLabel.topAnchor.constraint(equalTo: cell.topAnchor).isActive = true
        cell.myLabel.bottomAnchor.constraint(equalTo: cell.bottomAnchor).isActive = true
        cell.myLabel.leadingAnchor.constraint(equalTo: cell.leadingAnchor).isActive = true
        cell.myLabel.trailingAnchor.constraint(equalTo: cell.trailingAnchor).isActive = true
        
        // TODO: Update switch statement to set the label for 1 (true), 2 (false), 3 - change background color, 0 = ""
        let cellValue = game.getBoardCell(index: indexPath.item)
        switch cellValue
        {
        case 1:
            cell.myLabel.text = "⚪️"
        case 2:
            cell.myLabel.text =  "⚫️" //"🧠"
        default:
            cell.myLabel.text = ""
        }
        
        if game.isWinningCell(cellIndex: indexPath.item)
        {
            cell.backgroundColor = UIColor.red
            
        }
        
        //        if game.isComplete
        //        {
        //            let redCells = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: game.returnGameWinningCells() as! MyCollectionViewCell
        //            for _ in 0..<redCells.count
        //            {
        //                redCell.backgroundColor = UIColor.red
        //            }
        //            //self.myCollectionView.reloadData()
        //        }
        
        return cell
    }
    
    @IBOutlet weak var verseField: UITextView!
    
    @IBOutlet weak var playerTurnLabel: UILabel!
    
    func redrawBoard()
    {
        self.myCollectionView.reloadData()
        setPlayerLabel()
    }
    
    func setPlayerLabel()
    {

        switch game.turn {
        case -1:
            playerTurnLabel.text = "Game is over! " + (game.winningPlayer == 1 ? (game.mode == 0 ? "Player 2" : player1) : (game.mode == 0 ? "Player 1" : player2)) + " won!"
            verseField.text = bibleVerses[Int.random(in: 0..<bibleVerses.count)]
        case 0:
            playerTurnLabel.text = "Waiting for game to start..."
        case 1:
            playerTurnLabel.text = "Current turn: " + (game.mode == 0 ? "Player 2" : player1)
        case 2:
            playerTurnLabel.text = "Current turn: " + (game.mode == 0 ? "Player 1" : player2)
        default:
            playerTurnLabel.text = "(Error)"
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        if game.turn != playerNumber && game.mode == 1 {return}
        let didSetCell = game.setBoardCell(index: indexPath.item)
        if didSetCell
        {
            // redraw board
            redrawBoard()
            
            // update the board on the server
            if game.mode == 1
            {
                updateGomokuGame()

                // wait for our turn
                if (!game.isComplete)
                {
                    checkGameStatus(gameId: game.id)
                }
            }
            

        }
        
    }
    
    @IBAction func closeButton(_ sender: UIButton)
    {
        self.presentingViewController?.dismiss(animated: false, completion: nil)
        self.dismiss(animated: true, completion: nil)
        self.presentingViewController?.dismiss(animated: false, completion: nil)
        
    }
    
    func updateGomokuGame()
    {
        var retval = ""
        let gameData = game.dataToString()
        print("Updating Gomoku game: player turn = \(game.turn)")
        let gomokuInput = UpdateGomokuInput(id: gameId, playerTurn: game.turn, data:gameData)
        appSyncClient?.perform(mutation: UpdateGomokuMutation(input: gomokuInput)) { (result, error) in
            if let error = error as? AWSAppSyncClientError
            {
                retval = "Error occurred, update Gomoku game: \(error.localizedDescription )"
            }
            if let resultError = result?.errors
            {
                retval =  "Error updating the Gomoku game on server: \(resultError)"
            }
            else
            {
                retval = "Update Gomoku game: Success!"
            }
            self.onUpdateGomokuGame(result: retval)
        }
    }
    
    func onUpdateGomokuGame(result: String)
    {
        // TODO: Need a status label
        // statusViewJoin.text = "Join result: \(result)"
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
