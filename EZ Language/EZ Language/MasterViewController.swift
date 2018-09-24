//
//  MasterViewController.swift
//  EZ Language
//
//  Created by Fedor on 15.09.2018.
//  Copyright © 2018 rodiv. All rights reserved.
//

import UIKit
import SQLite3

class Word {
    var id: Int
    var Rus_tr: String?
    var Eng_tr: String?
    init(id: Int, Rus_tr: String?, Eng_tr: String?){
        self.id = id
        self.Rus_tr = Rus_tr
        self.Eng_tr = Eng_tr
    }
}

class MasterViewController: UITableViewController {

    var db: OpaquePointer?

    var detailViewController: DetailViewController? = nil
    var objects = [Any]()
    var wordsStack = [Word]()
    var wordsRus = ["отменять", "зависимость", "сельское хозяйство", "любитель", "посол", "скорая помощь", "злость", "одобрять", "фартук", "организовывать", "высокомерный", "хвастаться", "телохранитель", "столовая"]
    var wordsEng = ["abolish", "addiction", "agricultule", "amateur", "ambassador", "ambulance", "anger", "approve", "apron", "arrange", "arrogant", "boast", "bodyguard", "canteen"]
    
    let queryStatementString = "SELECT * FROM Words;"


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.leftBarButtonItem = editButtonItem

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        navigationItem.rightBarButtonItem = addButton
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        openDatabase();
        insertWordsIntoDB();
        
        
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    @objc
    func insertNewObject(_ sender: Any) {
        objects.insert(NSDate(), at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    func openDatabase() {
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
    
    func insertWordsIntoDB() {
        for i in 0...13{
            print(i)
            var stmt: OpaquePointer?
            let rusTr = wordsRus[i]
            let engTr = wordsEng[i]
            wordsStack.insert(Word(id: i, Rus_tr: rusTr, Eng_tr: engTr), at: 0)
            let indexPath = IndexPath(row: 0, section: 0)
            tableView.insertRows(at: [indexPath], with: .automatic)
            
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
    
    func deleteWordFromDB() {
        let deleteStatementString = "DELETE FROM Words WHERE Eng_tr = abolish;"
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
        
        sqlite3_finalize(deleteStatement)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                //tableView.deleteRows(at: [indexPath], with: .fade) //        not working
                //tableView.insertRows(at: [indexPath], with: .automatic)
                print("ok")
                let word = wordsStack[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                // т.е. detailItem - это аргумент DetailViewController
                controller.detailItem = word.Eng_tr
                controller.detailItem2 = word.Rus_tr
                controller.isTranslated = false
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wordsStack.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let word = wordsStack[indexPath.row]
        cell.textLabel?.text = word.Rus_tr
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            wordsStack.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            deleteWordFromDB()
            query()
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    func query() {
        var queryStatement: OpaquePointer? = nil
        // 1
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            // 2
            if sqlite3_step(queryStatement) == SQLITE_ROW {
                
                // 4
                let queryResultCol1 = sqlite3_column_text(queryStatement, 0)
                let Rus_Tr = String(cString: queryResultCol1!)
                
                let queryResultCol2 = sqlite3_column_text(queryStatement, 1)
                let Eng_Tr = String(cString: queryResultCol2!)
                
                // 5
                print("Query Result:")
                print("\(Rus_Tr) |\(Eng_Tr)")
                
            } else {
                print("Query returned no results")
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        
        // 6
        sqlite3_finalize(queryStatement)
    }
    


}

