//
//  ViewController.swift
//  EzWords
//
//  Created by Fedor on 24.09.2018.
//  Copyright © 2018 rodiv. All rights reserved.
//


// App Logic:
// at the first app launch the database is empty
// then a random word from a database of english words pops on the screen
// after typing its translation into the field the pair
// word-translation is added to the first database


import UIKit
import SQLite3


class ViewController: UIViewController {
    
    @IBOutlet weak var wordLabel1: UILabel!
    
    @IBOutlet weak var wordLabel: UILabel!
    
    @IBOutlet weak var translationTextField: UITextField!
    
    @IBOutlet weak var blueLine: UIImageView!
    let blueLineName = "blue-line-png.png"
    
    @IBOutlet weak var progressView: UIProgressView!
    
    internal let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

    
    var db: OpaquePointer?
    
    var stmt: OpaquePointer?
    
    var wordsRus = ["отменять", "зависимость", "сельское хозяйство", "любитель", "посол", "скорая помощь", "злость", "одобрять", "фартук", "организовывать", "высокомерный", "хвастаться", "телохранитель", "столовая"]
    var wordsEng = ["abolish", "addiction", "agriculture", "amateur", "ambassador", "ambulance", "anger", "approve", "apron", "arrange", "arrogant", "boast", "bodyguard", "canteen"]
    var wordsCn = ["废除","成瘾","农业","业余","大使","救护车","愤怒","批准","围裙","安排","傲慢","吹嘘"," 保镖","食堂"]
    
    
    // This is for the line under the words
    var counter:Int = 0 {
        didSet {
            let fractionalProgress = Float(counter) / 100.0
            let animated = counter != 0
            
            progressView.setProgress(fractionalProgress, animated: animated)
        }
    }
    
    
    let queryStatementString = "SELECT * FROM Words;"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        
        //blueLine.image = UIImage(named:blueLineName)
        
        openDatabase();
        dropDB();
        //query();
        //deleteWordFromDB(word: "'anger'")
        
    }
    
    func configureView(){
        wordLabel.isHidden = true
        translationTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        /*
        if textField.text == wordLabel.text{
            counter += 10
            progressView.progressTintColor = UIColor.green
            textField.text = ""
            deleteWordFromDB(word: wordLabel.text!)
            wordLabel1.text = query1()
            wordLabel.text = query()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // change 2 to desired number of seconds
                self.progressView.progressTintColor = UIColor.blue
            }
        }
 */
    }
    
    
    
    
    
    //--------------------------------------------------------------
    //                  Database functions
    //--------------------------------------------------------------
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
    
    func dropDB(){
        let deleteStatementString = "DROP TABLE Words;"
        var deleteStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, deleteStatementString, -1, &deleteStatement, nil) == SQLITE_OK {
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                print("Successfully dropped table.")
            } else {
                print("Could not drop table.")
            }
        } else {
            print("DELETE statement could not be prepared")
        }
        sqlite3_finalize(deleteStatement)
    }
    
    func insertWordsIntoDB(){
        for i in 0...13{
            print(i)
            let rusTr = wordsRus[i]
            let engTr = wordsEng[i]
            if rusTr != engTr {
                
                let queryString = "INSERT INTO Words (Rus_tr, Eng_tr) VALUES (?, ?)"
                
                if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                    let errmsg = String(cString: sqlite3_errmsg(db)!)
                    print("error preparing insert: \(errmsg)")
                    return
                }
                sqlite3_bind_text(stmt, 1, rusTr, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(stmt, 2, engTr, -1, SQLITE_TRANSIENT)
                if sqlite3_step(stmt) == SQLITE_DONE {
                    print("successfully inserted row")
                }
                
                
                query_all();
            }
            sqlite3_finalize(stmt)
        }
    }
    
    func query_all() {
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
    
    func deleteWordFromDB(word: String) {
        let deleteStatementString = "DELETE FROM Words WHERE Eng_tr ='" + word + "';"
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
        query_all()
        sqlite3_finalize(deleteStatement)
    }
    
    func query() -> String {
        var queryStatement: OpaquePointer? = nil
        // 1
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            // 2
            if sqlite3_step(queryStatement) == SQLITE_ROW {
                
                // 4
                let queryResultCol2 = sqlite3_column_text(queryStatement, 1)
                let Eng_Tr = String(cString: queryResultCol2!)
                
                // 5
                
                return Eng_Tr
                
            } else {
                print("Query returned no results")
                insertWordsIntoDB()
                return "Null"
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        
        // 6
        sqlite3_finalize(queryStatement)
        return ""
        
    }
    
    func query1() -> String {
        var queryStatement: OpaquePointer? = nil
        // 1
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            // 2
            if sqlite3_step(queryStatement) == SQLITE_ROW {
                
                // 4
                let queryResultCol1 = sqlite3_column_text(queryStatement, 0)
                let Rus_Tr = String(cString: queryResultCol1!)
                
                // 5
                
                return Rus_Tr
                
            } else {
                print("Query returned no results")
                insertWordsIntoDB()
                return "Null"
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        
        // 6
        sqlite3_finalize(queryStatement)
        return ""
        
    }
    

}

