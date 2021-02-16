//
//  ViewController.swift
//  SQLiteConnectDemo
//
//  Created by Trista on 2021/2/15.
//

import UIKit
import SQLite3

class ViewController: UIViewController {
    
    //宣告一個變數statement取得操作資料庫後回傳的資訊
    var statement :OpaquePointer?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //使用SQLiteConnect類別來操作資料庫
        //取得資料庫檔案的路徑
        //取得應用程式的 Documents 目錄--開放給開發者儲存檔案的路徑，有任何需要儲存的檔案都是放在這裡
        //sqlite3.db是這個資料庫檔案名稱，也可以命名為db.sqlite之類，其他可供辨識的檔案名稱。如果沒有這個檔案，系統會自動嘗試建立起來
        let sqlitePath = NSHomeDirectory() + "/Documents/sqlite3.db"
        
        //SQLite 資料庫
        //SQLiteConnect類別init
        let db = SQLiteConnect(path: sqlitePath)
        
        if let mydb = db
        {
            //create table
            //func createTable(tableName :String, columnsInfo :[String])-> Bool
            _ = mydb.createTable(tableName: "students", columnsInfo: [
                    "id integer primary key autoincrement",
                    "name text",
                    "height double"])
            
            
            //insert
            //func insert(tableName :String, rowInfo :[String:String]) -> Bool
            _ = mydb.insert(
                tableName: "students", rowInfo:
                    ["name":"'John'","height":"173.5"])
            
            
            //select
            //func fetch(tableName :String, cond :String?, order :String?)-> OpaquePointer?
            statement = mydb.fetch(tableName: "students", cond: nil, order: nil)
                
            //回傳的資料存在，宣告取得操作資料庫後回傳的資訊，型別為OpaquePointer的變數中，以while迴圈來一筆一筆取出，當等於SQLITE_ROW時就是有資料，會一直取到不為SQLITE_ROW，就會結束迴圈。(如果只有一筆資料的話，也可以使用if條件句即可。)
            while sqlite3_step(statement) == SQLITE_ROW
            {
                //使用sqlite3_column_資料類型()函式來取出迴圈中每筆資料的每個欄位，像是 int 的欄位就是使用sqlite3_column_int()， text 的欄位就是使用sqlite3_column_text()， double 的欄位就是使用sqlite3_column_double()，以此類推。
                //取出欄位的函式有兩個參數
                //第一個都固定是，宣告取得操作資料庫後回傳的資訊，型別為OpaquePointer的變數
                //第二個是這個欄位的索引值，範例有三個欄位： id, name, height ，則索引值從 0 開始算起，依序為 0, 1, 2 。
                let id = sqlite3_column_int(statement, 0)
                let name = String(cString: sqlite3_column_text(statement, 1))
                let height = sqlite3_column_double(statement, 2)
                    
                print("\(id). \(name) 身高： \(height)")
                
            }
             
            //使用sqlite3_finalize()函式釋放掉，宣告取得操作資料庫後回傳的資訊，型別為OpaquePointer的變數，以免發生記憶體洩漏的問題
            sqlite3_finalize(statement)
            
            
            //update
            //func update(tableName :String,cond :String?,rowInfo :[String:String])-> Bool
            _ = mydb.update(tableName: "students",
                  cond: "id = 3",
                  rowInfo: ["name":"'May'","height":"158.3"])

            
            //select
            //func fetch(tableName :String, cond :String?, order :String?)-> OpaquePointer?
            statement = mydb.fetch(tableName: "students", cond: nil, order: nil)
                
            //回傳的資料存在，宣告取得操作資料庫後回傳的資訊，型別為OpaquePointer的變數中，以while迴圈來一筆一筆取出，當等於SQLITE_ROW時就是有資料，會一直取到不為SQLITE_ROW，就會結束迴圈。(如果只有一筆資料的話，也可以使用if條件句即可。)
            while sqlite3_step(statement) == SQLITE_ROW
            {
                //使用sqlite3_column_資料類型()函式來取出迴圈中每筆資料的每個欄位，像是 int 的欄位就是使用sqlite3_column_int()， text 的欄位就是使用sqlite3_column_text()， double 的欄位就是使用sqlite3_column_double()，以此類推。
                //取出欄位的函式有兩個參數
                //第一個都固定是，宣告取得操作資料庫後回傳的資訊，型別為OpaquePointer的變數
                //第二個是這個欄位的索引值，範例有三個欄位： id, name, height ，則索引值從 0 開始算起，依序為 0, 1, 2 。
                let id = sqlite3_column_int(statement, 0)
                let name = String(cString: sqlite3_column_text(statement, 1))
                let height = sqlite3_column_double(statement, 2)
                    
                print("\(id). \(name) 身高： \(height)")
                
            }
             
            //使用sqlite3_finalize()函式釋放掉，宣告取得操作資料庫後回傳的資訊，型別為OpaquePointer的變數，以免發生記憶體洩漏的問題
            sqlite3_finalize(statement)
            
            
            //delete
            //func delete(tableName :String, cond :String?) -> Bool
            _ = mydb.delete(tableName: "students", cond: "id = 4")
            
            
            //select
            //func fetch(tableName :String, cond :String?, order :String?)-> OpaquePointer?
            statement = mydb.fetch(tableName: "students", cond: nil, order: nil)
                
            //回傳的資料存在，宣告取得操作資料庫後回傳的資訊，型別為OpaquePointer的變數中，以while迴圈來一筆一筆取出，當等於SQLITE_ROW時就是有資料，會一直取到不為SQLITE_ROW，就會結束迴圈。(如果只有一筆資料的話，也可以使用if條件句即可。)
            while sqlite3_step(statement) == SQLITE_ROW
            {
                //使用sqlite3_column_資料類型()函式來取出迴圈中每筆資料的每個欄位，像是 int 的欄位就是使用sqlite3_column_int()， text 的欄位就是使用sqlite3_column_text()， double 的欄位就是使用sqlite3_column_double()，以此類推。
                //取出欄位的函式有兩個參數
                //第一個都固定是，宣告取得操作資料庫後回傳的資訊，型別為OpaquePointer的變數
                //第二個是這個欄位的索引值，範例有三個欄位： id, name, height ，則索引值從 0 開始算起，依序為 0, 1, 2 。
                let id = sqlite3_column_int(statement, 0)
                let name = String(cString: sqlite3_column_text(statement, 1))
                let height = sqlite3_column_double(statement, 2)
                    
                print("\(id). \(name) 身高： \(height)")
                
            }
             
            //使用sqlite3_finalize()函式釋放掉，宣告取得操作資料庫後回傳的資訊，型別為OpaquePointer的變數，以免發生記憶體洩漏的問題
            sqlite3_finalize(statement)
            
        }
    
    }

}
