//
//  Gomoku.swift
//  Gomoku: Five In A Row
//
//  Created by Josh Kelleran on 5/29/19.
//  Copyright © 2019 Josh Kelleran. All rights reserved.
//

import Foundation

class Gomoku
{
    var id = ""
    
    var isComplete = false
    lazy var board = createNewBoard()
    //var changingBoard
    var turn = 1
    var mode = 0
    var winningPlayer: Int = 0
    var winningCells = [(row: Int, column: Int)]()
 //   var coordinates = [Int]()
    
    func getCell(index: Int) -> (row: Int, column: Int)
    {
        let row: Int = index / 15
        let column: Int = index % 15
        return (row, column)
    }

    func getBoardSize() -> (rows: Int, columns: Int)
    {
        let rowCount = board.count
        let columnCount = board[0].count
        return (rows: rowCount, columns: columnCount)
    }
    
    func isWinningCell(cellIndex: Int) -> Bool
    {
        if winningCells.count == 0 {return false}
        let currentCell = getCell(index: cellIndex)
        for cell in winningCells
        {
            if cell == currentCell {return true}
        }
        return false
    }
    
    
    func getBoardCell(index: Int) -> Int
    {
        let cell = getCell(index: index)
        if board[cell.row][cell.column] == true {return 1}
        else if board[cell.row][cell.column] == false {return 2}
        else {return 0}
    }
    
    func setBoardCell(index: Int) -> Bool
    {
        // if game is over don't set any cells
        if isComplete {return false}
        
        // get cell get's the cell row and column
        let cell = getCell(index: index)
        
        // if cell is already set then return false
        if board[cell.row][cell.column] != nil {return false}
        
        // set the cell value for the current player
        board[cell.row][cell.column] = (turn == 1 ? true : false)
        
        // determine if there is a winner
        setBoardStatus()
        
        // change player's turn
        if !isComplete
        {
            turn = (turn == 1 ? 2 : 1)
        }
        
        // indicate that we set the board cell successfully
        return true
    }
    
    func resetGame()
    {
        isComplete = false
        board = createNewBoard()
        winningPlayer = 0
        turn = 1
        winningCells.removeAll()
    }
    
    func setBoardStatus()
    {
        testBoard(turn: 1)
        if winningCells.count != 0 {winningPlayer = 1}
        
        if winningPlayer != 1
        {
            testBoard(turn: 2)
            if winningCells.count != 0 {winningPlayer = 2}
        }
        
        if winningCells.count != 0
        {
            isComplete = true
            turn = -1
        }
    }
    
    func createNewBoard() -> [[Bool?]]
    {
        var  board = [[Bool?]]()
        
        for _ in 1...15
        {
            var row = [Bool?]()
            for _ in 1...15
            {
                row.append(nil)
            }
            board.append(row)
        }
        return board
    }
    
//    func returnGameWinningCells() -> [Int]
//    {
//        for i in 0...4
//        {
//            let rowCounter = winningCells[i].row * 15
//            let indexCounter = rowCounter + winningCells[i].column
//            coordinates.append(indexCounter)
//        }
//        return coordinates
//    }
    
    func testBoard(turn: Int)
    {
        testFiveInARow(testFor: (turn == 1 ? true : false))
        if winningCells.count == 0
        {
            print("No Match-\(turn)")
        }
        else
        {
            for i in 0...4
            {
                print("Match-\(turn) start at: \(winningCells[i].row) \(winningCells[i].column)")
            }
        }
    }
    
    
    func createRandomBoard() -> [[Bool?]]
    {
        var  board = [[Bool?]]()
        
        for _ in 1...15
        {
            var row = [Bool?]()
            for _ in 1...15
            {
                let value = Int.random(in: 0...2)
                switch value
                {
                case 0:
                    row.append(nil)
                case 1:
                    row.append(true)
                case 2:
                    row.append(false)
                default:
                    row.append(nil)
                }
            }
            board.append(row)
        }
        return board
    }
    
    func debugPrintBoard(board: [[Bool?]])
    {
        for row in board
        {
            for index in row.indices
            {
                switch row[index]
                {
                case true:
                    print("X-", terminator:"")
                case false:
                    print("O-", terminator:"")
                default:
                    print("+-", terminator:"")
                }
            }
            print("")
        }
    }
    
    func dataToString() -> String
    {
        var items = [String]()
        for row in board
        {
            for index in row.indices
            {
                switch row[index]
                {
                case true:
                    items.append("1")
                case false:
                    items.append("2")
                default:
                    items.append("0")
                }
            }
        }
        return items.joined(separator: "")
    }
    
    func dataFromString(value: String)
    {
        var index = 0
        board = [[Bool?]]()
        var chars = [Character]()
        for char in value
        {
            chars.append(char)
        }
        
        for _ in 1...15
        {
            var row = [Bool?]()
            for _ in 1...15
            {
                let currentCell = chars[index]
                switch currentCell
                {
                case "0":
                    row.append(nil)
                case "1":
                    row.append(true)
                case "2":
                    row.append(false)
                default:
                    row.append(nil)
                }
                index += 1
            }
            board.append(row)
        }
        
    }
    
    func testFiveInARow(testFor: Bool?) -> [(row: Int, column: Int)]? //(startCell:(row: Int, column: Int), endCell:(row: Int, column: Int)) // -> [(row: Int, column: Int)]?
    {
        // var cells = [(row: Int, column: Int)]()
        // return (cells.count == 0 ? nil : cells)

        var startCell = (-1, -1)
        var endCell = (-1,-1)
        
        // Test Horizontal
        var rowIndex = 0
        for row in board
        {
            var counter = 0
            for index in row.indices
            {
                if row[index] == testFor
                {

                    counter += 1
                }
                else
                {
                    startCell = (-1,-1)
                    counter = 0
                }
                if counter == 5
                {
                    winningCells.removeAll()
                    endCell = (rowIndex, index)
                    startCell = (rowIndex, index - 4)
                    for i in 0...4
                    {
                        winningCells.append((rowIndex, index - i))
                    }
                    return winningCells
                }
            }
            rowIndex += 1
        }

        // Test Vertical
        for columnIndex in board[0].indices
        {
            var counter = 0
            for rowIndex in 0..<board.count //check rowIndex if no worko
            {
                if board[rowIndex][columnIndex] == testFor
                {

                    counter += 1
                }
                else
                {
                    startCell = (-1,-1)
                    counter = 0
                }
                if counter == 5
                {
                    winningCells.removeAll()
                    endCell = (rowIndex, columnIndex)
                    startCell = (rowIndex - 4, columnIndex)
                    for i in 0...4
                    {
                        winningCells.append((rowIndex - i, columnIndex))
                    }
                    return winningCells
                }
            }
        }

        // Test Diagonal positive slope left column

        for rowIndex in 4..<board.count
        {
            var counter = 0
            var testSlope = 0

            for columnIndex in 0...rowIndex
            {
                if board[rowIndex - testSlope][columnIndex] == testFor
                {

                    counter += 1
                }
                else
                {
                    startCell = (-1,-1)
                    counter = 0
                }
                if counter == 5
                {
                    winningCells.removeAll()
                    endCell = ((rowIndex - testSlope), columnIndex)
                    startCell = ((rowIndex - testSlope + 4), (columnIndex - 4))
                    for i in 0...4
                    {
                        winningCells.append((rowIndex - testSlope + i, columnIndex - i))
                    }
                    return winningCells
                }
                testSlope += 1
            }
        }

        // on bottom row positive slope

        for columnIndex in 0..<(board.count - 4)
        {
            var counter = 0
            var testSlope = 0

            for rowIndex in stride(from: 14, to: columnIndex, by: -1)
            {
                if board[rowIndex][columnIndex + testSlope] == testFor
                {

                    counter += 1
                }
                else
                {
                    startCell = (-1,-1)
                    counter = 0
                }
                if counter == 5
                {
                    winningCells.removeAll()
                    endCell = (rowIndex, (columnIndex + testSlope))
                    startCell = ((rowIndex + 4), (columnIndex + testSlope - 4))
                    for i in 0...4
                    {
                        winningCells.append((rowIndex + i, columnIndex + testSlope - i))
                    }
                    return winningCells
                }
                testSlope += 1
            }
        }

        // Test Diagonal negative slope right column

        for rowIndex in 4..<board.count
        {
            var counter = 0
            var testSlope = 0

            for columnIndex in stride(from: 14, to: (14 - rowIndex), by: -1)
            {
                if board[rowIndex - testSlope][columnIndex] == testFor
                {

                    counter += 1
                }
                else
                {
                    startCell = (-1,-1)
                    counter = 0
                }
                if counter == 5
                {
                    winningCells.removeAll()
                    endCell = ((rowIndex - testSlope), columnIndex)
                    startCell = ((rowIndex - testSlope + 4), (columnIndex + 4))
                    for i in 0...4
                    {
                        winningCells.append((rowIndex - testSlope + i, columnIndex + i))
                    }
                    return winningCells
                }
                testSlope += 1
            }
        }
        
        // on bottom row negative slope
        
        for columnIndex in stride(from: 14, to: 4, by: -1)
        {
            var counter = 0
            var testSlope = 0
            
            for rowIndex in stride(from: 14, to: (14 - columnIndex), by: -1)
            {
                if board[rowIndex][columnIndex - testSlope] == testFor
                {
                    
                    counter += 1
                }
                else
                {
                    startCell = (-1,-1)
                    counter = 0
                }
                if counter == 5
                {
                    winningCells.removeAll()
                    endCell = (rowIndex, (columnIndex - testSlope))
                    startCell = ((rowIndex + 4), (columnIndex - testSlope + 4))
                    for i in 0...4
                    {
                        winningCells.append((rowIndex + i, columnIndex - testSlope + i))
                    }
                    return winningCells
                }
                testSlope += 1
            }
        }
        // NO MATCHES
        winningCells.removeAll()
        return winningCells
    }
}


//func testFiveInARow(testFor: Bool?) -> [(row: Int, column: Int)]? //(startCell:(row: Int, column: Int), endCell:(row: Int, column: Int)) // -> [(row: Int, column: Int)]?
//{
//    // var cells = [(row: Int, column: Int)]()
//    // return (cells.count == 0 ? nil : cells)
//    var startCell = (-1, -1)
//    var endCell = (-1,-1)
//
//    // Test Horizontal
//    var rowIndex = 0
//    for row in board
//    {
//        var counter = 0
//        for index in row.indices
//        {
//            if row[index] == testFor
//            {
//
//                counter += 1
//            }
//            else
//            {
//                startCell = (-1,-1)
//                counter = 0
//            }
//            if counter == 5
//            {
//                w
//                endCell = (rowIndex, index)
//                startCell = (rowIndex, index - 4)
//                return (startCell, endCell)
//            }
//        }
//        rowIndex += 1
//    }
//
//    // Test Vertical
//    for columnIndex in board[0].indices
//    {
//        var counter = 0
//        for rowIndex in 0..<board.count //check rowIndex if no worko
//        {
//            if board[rowIndex][columnIndex] == testFor
//            {
//
//                counter += 1
//            }
//            else
//            {
//                startCell = (-1,-1)
//                counter = 0
//            }
//            if counter == 5
//            {
//                endCell = (rowIndex, columnIndex)
//                startCell = (rowIndex - 4, columnIndex)
//                return (startCell, endCell)
//            }
//        }
//    }
//
//    // Test Diagonal positive slope left column
//
//    for rowIndex in 4..<board.count
//    {
//        var counter = 0
//        var testSlope = 0
//
//        for columnIndex in 0...rowIndex
//        {
//            if board[rowIndex - testSlope][columnIndex] == testFor
//            {
//
//                counter += 1
//            }
//            else
//            {
//                startCell = (-1,-1)
//                counter = 0
//            }
//            if counter == 5
//            {
//                endCell = ((rowIndex - testSlope), columnIndex)
//                startCell = ((rowIndex - testSlope + 4), (columnIndex - 4))
//                return (startCell, endCell)
//            }
//            testSlope += 1
//        }
//    }
//
//    // on bottom row positive slope
//
//    for columnIndex in 0..<(board.count - 4)
//    {
//        var counter = 0
//        var testSlope = 0
//
//        for rowIndex in stride(from: 14, to: columnIndex, by: -1)
//        {
//            if board[rowIndex][columnIndex + testSlope] == testFor
//            {
//
//                counter += 1
//            }
//            else
//            {
//                startCell = (-1,-1)
//                counter = 0
//            }
//            if counter == 5
//            {
//                endCell = (rowIndex, (columnIndex + testSlope))
//                startCell = ((rowIndex + 4), (columnIndex + testSlope - 4))
//                return (startCell, endCell)
//            }
//            testSlope += 1
//        }
//    }
//
//    // Test Diagonal negative slope right column
//
//    for rowIndex in 4..<board.count
//    {
//        var counter = 0
//        var testSlope = 0
//
//        for columnIndex in stride(from: 14, to: (14 - rowIndex), by: -1)
//        {
//            if board[rowIndex - testSlope][columnIndex] == testFor
//            {
//
//                counter += 1
//            }
//            else
//            {
//                startCell = (-1,-1)
//                counter = 0
//            }
//            if counter == 5
//            {
//                endCell = ((rowIndex - testSlope), columnIndex)
//                startCell = ((rowIndex - testSlope + 4), (columnIndex + 4))
//                return (startCell, endCell)
//            }
//            testSlope += 1
//        }
//    }
//
//    // on bottom row negative slope
//
//    for columnIndex in stride(from: 14, to: 4, by: -1)
//    {
//        var counter = 0
//        var testSlope = 0
//
//        for rowIndex in stride(from: 14, to: (14 - columnIndex), by: -1)
//        {
//            if board[rowIndex][columnIndex - testSlope] == testFor
//            {
//
//                counter += 1
//            }
//            else
//            {
//                startCell = (-1,-1)
//                counter = 0
//            }
//            if counter == 5
//            {
//                endCell = (rowIndex, (columnIndex - testSlope))
//                startCell = ((rowIndex + 4), (columnIndex - testSlope + 4))
//                return (startCell, endCell)
//            }
//            testSlope += 1
//        }
//    }
//    // NO MATCHES
//    return ((-1,-1), (-1,-1))
//}
