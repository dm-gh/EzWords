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


extension String {
    
    var length: Int {
        return count
    }
    
    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }
    
    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }
    
    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }
    
    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
    
}

class ViewController: UIViewController {
    // comment
    
    
    @IBOutlet weak var modeControl: UISegmentedControl!
    
    @IBOutlet weak var wordLabel1: UILabel!
    
    @IBOutlet weak var wordLabel: UILabel!
    
    @IBOutlet weak var infoButton: UILabel!
    
    @IBOutlet weak var translationTextField: UITextField!
    
    @IBOutlet weak var blueLine: UIImageView!
    let blueLineName = "blue-line-png.png"
    
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var switchMode: UISwitch!
    
    @IBOutlet weak var passButton: UIButton!
    
    @IBOutlet weak var nextButton: UIButton!
    
    @IBAction func switchValueChanged(_ sender: Any) {
        configureView()
    }
    @IBAction func passButtonPressed(_ sender: Any) {
        if modeControl.selectedSegmentIndex == 1{
            wordLabel1.text = wordsRand.removeFirst()
        } else {
            translationTextField.text = wordLabel.text
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // change 2 to desired number of seconds
                self.translationTextField.text = ""
            }
        }
    }
    @IBAction func nextButtonPressed(_ sender: Any) {
        if modeControl.selectedSegmentIndex == 1{
            if translationTextField.text != "" {
                let elem = translationTextField.text!
                var i = elem.count - 1
                var char = elem[i]
                while (char == " "){
                    i-=1
                    char = elem[i]
                }
                if elem[0..<i+1] != ""{
                    insertWordIntoDB(wordLang: elem[0..<i+1], wordEng: wordLabel1.text!)
                    wordLabel1.text = wordsRand.removeFirst()
                    translationTextField.text = ""
                }
            }
        }
    }
    
    
    
    @IBAction func modeChanged(_ sender: Any) {
        /*switch modeControl.selectedSegmentIndex
        {
        case 0:
            switchMode.isOn = false
        case 1:
            switchMode.isOn = true
        default:
            break
        }*/
        configureView()
    }
    
    
    internal let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

    
    var db: OpaquePointer?
    
    var stmt: OpaquePointer?
    
    var wordsRus = ["отменять", "зависимость", "сельское хозяйство", "любитель", "посол", "скорая помощь", "злость", "одобрять", "фартук", "организовывать", "высокомерный", "хвастаться", "телохранитель", "столовая"]
    var wordsEng = ["abolish", "addiction", "agriculture", "amateur", "ambassador", "ambulance", "anger", "approve", "apron", "arrange", "arrogant", "boast", "bodyguard", "canteen"]
    var wordsCn = ["废除","成瘾","农业","业余","大使","救护车","愤怒","批准","围裙","安排","傲慢","吹嘘"," 保镖","食堂"]
    
    var wordsRand = Set<String>()
    
    
    // This is for the line under the words
    var counter:Int = 0 {
        didSet {
            let fractionalProgress = Float(counter) / 100.0
            let animated = counter != 0
            
            progressView.setProgress(fractionalProgress, animated: animated)
            if fractionalProgress >= 1{
                counter = 0
            }
        }
    }
    
    
    let queryStatementString = "SELECT * FROM Words;"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        openDatabase()
        opentxt()
        configureView()
        //dropDB()
        
        //blueLine.image = UIImage(named:blueLineName)
        
        
    }
    
    func configureView(){
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background.jpg")!)
        wordLabel.isHidden = true
        passButton.layer.cornerRadius = 8
        nextButton.layer.cornerRadius = 8
        
        if modeControl.selectedSegmentIndex == 1{
            passButton.isHidden = false
            nextButton.isHidden = false
            wordLabel1.text = wordsRand.removeFirst()
        } else {
            passButton.isHidden = false
            nextButton.isHidden = true
            translationTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            getWordFromDB()
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if modeControl.selectedSegmentIndex == 0{
            if textField.text == wordLabel.text{
                counter += 10
                progressView.progressTintColor = UIColor.green
                textField.text = ""
                deleteWordFromDB(word: wordLabel.text!)
                getWordFromDB()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // change 2 to desired number of seconds
                    self.progressView.progressTintColor = UIColor.blue
                }
            }
        }
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
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS Words (Lang_tr TEXT, Eng_tr TEXT)", nil, nil, nil) != SQLITE_OK {
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
    
    func insertWordIntoDB(wordLang: String, wordEng: String){
        let queryString = "INSERT INTO Words (Lang_tr, Eng_tr) VALUES (?, ?)"
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        sqlite3_bind_text(stmt, 1, wordLang, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(stmt, 2, wordEng, -1, SQLITE_TRANSIENT)
        if sqlite3_step(stmt) == SQLITE_DONE {
            print("successfully inserted row")
        }
        
        sqlite3_finalize(stmt)
    }
    
    func getWordFromDB(){
        let getStatementString = "SELECT * FROM Words ORDER BY ROWID ASC LIMIT 1"
        var getStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, getStatementString, -1, &getStatement, nil) == SQLITE_OK {
            if sqlite3_step(getStatement) == SQLITE_ROW {
                let queryResultCol1 = sqlite3_column_text(getStatement, 0)
                let queryResultCol2 = sqlite3_column_text(getStatement, 1)
                let Lang_Tr = String(cString: queryResultCol1!)
                let Eng_Tr = String(cString: queryResultCol2!)
                wordLabel.text = Eng_Tr
                wordLabel1.text = Lang_Tr
                print(Lang_Tr)
            } else {
                print("Get statement could not be prepared")
                modeControl.selectedSegmentIndex = 1
                configureView()
            }
        }
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
        //query_all()
        sqlite3_finalize(deleteStatement)
    }
    /*
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
 */
    
    
    
    
    func opentxt(){
        let fileURL = Bundle.main.path(forResource: "words", ofType: "txt")
        // Read from the file
        var readStringProject = ""
        do {
            readStringProject = try String(contentsOfFile: fileURL!, encoding: String.Encoding.utf16)
            
        } catch let error as NSError {
            print("Failed reading from URL: \(fileURL ?? ""), Error: " + error.localizedDescription)
        }
        let mas = readStringProject.components(separatedBy: ["\r", "\n"])
        for elem in mas{
            if (elem != ""){
                var i = 0
                var char = elem[0]
                while (i != elem.count && char != " "){
                    i+=1
                    char = elem[i]
                }
                
                wordsRand.insert(elem[0..<i].lowercased())
            }
        }
        wordLabel1.text = wordsRand.removeFirst()
    }
    

}

