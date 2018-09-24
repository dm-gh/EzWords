//
//  ViewController.swift
//  EzWords
//
//  Created by Fedor on 24.09.2018.
//  Copyright © 2018 rodiv. All rights reserved.
//

import UIKit
import SQLite3


class ViewController: UIViewController {
    
    @IBOutlet weak var wordLabel: UILabel!
    
    @IBOutlet weak var translationTextField: UITextField!
    
    @IBOutlet weak var blueLine: UIImageView!
    let blueLineName = "blue-line-png.png"
    
    var db: OpaquePointer?
    
    var wordsRus = ["отменять", "зависимость", "сельское хозяйство", "любитель", "посол", "скорая помощь", "злость", "одобрять", "фартук", "организовывать", "высокомерный", "хвастаться", "телохранитель", "столовая"]
    var wordsEng = ["abolish", "addiction", "agricultule", "amateur", "ambassador", "ambulance", "anger", "approve", "apron", "arrange", "arrogant", "boast", "bodyguard", "canteen"]
    
    let queryStatementString = "SELECT * FROM Words;"

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        blueLine.image = UIImage(named:blueLineName)
        
        openDatabase();
        //query();
        deleteWordFromDB()
        
    }
    
    func openDatabase(){
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("WordsDB.sqlite")
        
        if sqlite3_open(fileURL.path, &db) == SQLITE_OK {
            print("Database opened")
        }
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS Words (Rus_tr TEXT, Eng_tr TEXT)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
    }
    
    func insertWordsIntoDB(){
        for i in 0...13{
            print(i)
            var stmt: OpaquePointer?
            let rusTr = wordsRus[i]
            let engTr = wordsEng[i]
            
            let queryString = "INSERT INTO Words (Rus_tr, Eng_tr) VALUES (?,?)"
            
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing insert: \(errmsg)")
                return
            }
            sqlite3_bind_text(stmt, 1, rusTr, -1, nil)
            sqlite3_bind_text(stmt, 2, engTr, -1, nil)
            if sqlite3_step(stmt) == SQLITE_DONE {
                print("successfully inserted row")
            }
            sqlite3_finalize(stmt)
        }
    }
    
    func query() {
        var queryStatement: OpaquePointer? = nil
        // 1
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            // 2
            var step = 0
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                
                // 4
                let queryResultCol1 = sqlite3_column_text(queryStatement, 0)
                let Rus_Tr = String(cString: queryResultCol1!)
                
                let queryResultCol2 = sqlite3_column_text(queryStatement, 1)
                let Eng_Tr = String(cString: queryResultCol2!)
                
                // 5
                print(Rus_Tr)
                print("\(Rus_Tr) | \(Eng_Tr)")
                step += 1
                
            }
            if step == 0 {
                print("Query returned no results")
                insertWordsIntoDB()
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        
        // 6
        sqlite3_finalize(queryStatement)
    }
    
    func deleteWordFromDB() {
        let deleteStatementString = "DELETE FROM Words WHERE Eng_tr = approve;"
        var deleteStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, deleteStatementString, -1, &deleteStatement, nil) == SQLITE_OK {
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                print("Successfully deleted row.")
            } else {
                print("Could not delete row.")
            }
        } else {
            print("DELETE statement could not be prepared")
        }
        query()
        sqlite3_finalize(deleteStatement)
    }

}
