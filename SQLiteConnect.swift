//
//  SQLiteConnect.swift
//  SQLiteConnectDemo
//
//  Created by Trista on 2021/2/15.
//
import UIKit
import SQLite3

//選擇iOS > Source > Swift File這個模版的檔案，建立一個類別，SQLite功能獨立寫成一個類別，其他應用程式需要時可重複使用
class SQLiteConnect {

    //宣告一個變數儲存 SQLite 的連線資訊
    var db :OpaquePointer?
    //取得資料庫檔案的路徑
    let sqlitePath :String
    //宣告一個變數statement取得操作資料庫後回傳的資訊
    var statement :OpaquePointer?
    
    
    //為類別建立一個可失敗建構器( failable initializer )，為了確保有正確連結上資料庫
    init?(path :String)
    {
        sqlitePath = path
        db = self.openDatabase(path: sqlitePath)

        if db == nil {
            return nil
        }
    }

    
    //連結資料庫 connect database
    //使用sqlite3_open()函式開啟資料庫連線
    func openDatabase(path :String) -> OpaquePointer?
    {
        //第一個參數是取得資料庫檔案的路徑
        //第二個參數也是宣告儲存 SQLite 的連線資訊，型別為OpaquePointer的變數,前必須加上&，這是一個指標的概念(與輸入輸出參數 In-Out Parameters類似)，函式內使用的就是傳入參數本身，操作資料庫時可以直接使用這個db變數
        if sqlite3_open(path, &db) == SQLITE_OK
        {
            print("Successfully opened database \(path)")
            return db
        }
        else {
            print("Unable to open database.")
            return nil
        }
    }

    
    //建立資料表 create table
    //使用sqlite3_exec()函式建立資料表
    func createTable(tableName :String, columnsInfo :[String])-> Bool
    {
        let sql = "create table if not exists \(tableName) "
            + "(\(columnsInfo.joined(separator: ",")))" as NSString

        //第一個參數就是建立資料庫連線的傳入參數，也是宣告儲存 SQLite 的連線資訊，型別為OpaquePointer的變數
        //第二個參數是 SQL 指令，會先轉成NSString型別，再將文字編碼轉成 UTF8。
        //如果返回為SQLITE_OK，則表示建立成功
        if sqlite3_exec(
            self.db, sql.utf8String, nil, nil, nil) == SQLITE_OK
        {
            return true
        }

        return false
    }

    
    //新增資料
    //使用sqlite3_prepare_v2()和sqlite3_step()函式新增資料
    func insert(tableName :String, rowInfo :[String:String]) -> Bool
    {
        let sql = "insert into \(tableName) "
            + "(\(rowInfo.keys.joined(separator: ","))) "
            + "values "
            + "(\(rowInfo.values.joined(separator: ",")))" as NSString

        //第一個參數就是建立資料庫連線的傳入參數，也是宣告儲存 SQLite 的連線資訊，型別為OpaquePointer的變數
        //第二個參數是 SQL 指令，會先轉成NSString型別，再將文字編碼轉成 UTF8。如果返回為SQLITE_OK，則表示建立成功
        //第三個參數則是設定資料庫可以讀取的最大資料量，單位是位元組(Byte)，設為-1表示不限制讀取量
        //第四個參數，也是宣告取得操作資料庫後回傳的資訊，型別為OpaquePointer的變數，參數前面要加上&
        if sqlite3_prepare_v2(self.db, sql.utf8String, -1, &statement, nil) == SQLITE_OK
        {
            //宣告取得操作資料庫後回傳的資訊，型別為OpaquePointer的變數,要再當做sqlite3_step()函式的參數傳入
            //返回SQLITE_DONE，則是表示新增資料成功
            if sqlite3_step(statement) == SQLITE_DONE
            {
                return true
            }
            
            //使用sqlite3_finalize()函式釋放掉，宣告取得操作資料庫後回傳的資訊，型別為OpaquePointer的變數，以免發生記憶體洩漏的問題
            sqlite3_finalize(statement)
        }

        return false
    }

    
    //讀取資料
    //使用sqlite3_prepare_v2()函式讀取資料
    func fetch(tableName :String, cond :String?, order :String?)
      -> OpaquePointer?
    {
        var sql = "select * from \(tableName)"
        if let condition = cond {
            sql += " where \(condition)"
        }

        if let orderBy = order {
            sql += " order by \(orderBy)"
        }

        //第一個參數就是建立資料庫連線的傳入參數，也是宣告儲存 SQLite 的連線資訊，型別為OpaquePointer的變數
        //第二個參數是 SQL 指令，會先轉成NSString型別，再將文字編碼轉成 UTF8。如果返回為SQLITE_OK，則表示建立成功
        //第三個參數則是設定資料庫可以讀取的最大資料量，單位是位元組(Byte)，設為-1表示不限制讀取量
        //第四個參數，也是宣告取得操作資料庫後回傳的資訊，型別為OpaquePointer的變數，參數前面要加上&
        sqlite3_prepare_v2(self.db, (sql as NSString).utf8String, -1,
          &statement, nil)

        //回傳的資料存在，宣告取得操作資料庫後回傳的資訊，型別為OpaquePointer的變數中
        return statement
    }

    
    //更新資料
    //使用sqlite3_prepare_v2()和sqlite3_step()函式更新資料
    func update(tableName :String,cond :String?,
                rowInfo :[String:String])-> Bool
    {
        var sql = "update \(tableName) set "

        //row info
        var info :[String] = []
        for (k, v) in rowInfo {
            info.append("\(k) = \(v)")
        }
        sql += info.joined(separator: ",")

        //condition
        if let condition = cond {
            sql += " where \(condition)"
        }

        //第一個參數就是建立資料庫連線的傳入參數，也是宣告儲存 SQLite 的連線資訊，型別為OpaquePointer的變數
        //第二個參數是 SQL 指令，會先轉成NSString型別，再將文字編碼轉成 UTF8。如果返回為SQLITE_OK，則表示建立成功
        //第三個參數則是設定資料庫可以讀取的最大資料量，單位是位元組(Byte)，設為-1表示不限制讀取量
        //第四個參數，也是宣告取得操作資料庫後回傳的資訊，型別為OpaquePointer的變數，參數前面要加上&
        if sqlite3_prepare_v2(self.db, (sql as NSString).utf8String, -1,&statement, nil) == SQLITE_OK
        {
            //宣告取得操作資料庫後回傳的資訊，型別為OpaquePointer的變數,要再當做sqlite3_step()函式的參數傳入
            //返回SQLITE_DONE，則是表示更新資料成功
            if sqlite3_step(statement) == SQLITE_DONE
            {
                return true
            }
            
            //使用sqlite3_finalize()函式釋放掉，宣告取得操作資料庫後回傳的資訊，型別為OpaquePointer的變數，以免發生記憶體洩漏的問題
            sqlite3_finalize(statement)
        }

        return false
    }

    
    //刪除資料
    //使用sqlite3_prepare_v2()和sqlite3_step()函式刪除資料
    func delete(tableName :String, cond :String?) -> Bool
    {
        var sql = "delete from \(tableName)"

        //condition
        if let condition = cond
        {
            sql += " where \(condition)"
        }

        //第一個參數就是建立資料庫連線的傳入參數，也是宣告儲存 SQLite 的連線資訊，型別為OpaquePointer的變數
        //第二個參數是 SQL 指令，會先轉成NSString型別，再將文字編碼轉成 UTF8。如果返回為SQLITE_OK，則表示建立成功
        //第三個參數則是設定資料庫可以讀取的最大資料量，單位是位元組(Byte)，設為-1表示不限制讀取量
        //第四個參數，也是宣告取得操作資料庫後回傳的資訊，型別為OpaquePointer的變數，參數前面要加上&
        if sqlite3_prepare_v2(self.db, (sql as NSString).utf8String, -1, &statement, nil) == SQLITE_OK
        {
            //宣告取得操作資料庫後回傳的資訊，型別為OpaquePointer的變數,要再當做sqlite3_step()函式的參數傳入
            //返回SQLITE_DONE，則是表示刪除資料成功
            if sqlite3_step(statement) == SQLITE_DONE
            {
                return true
            }
            
            //使用sqlite3_finalize()函式釋放掉，宣告取得操作資料庫後回傳的資訊，型別為OpaquePointer的變數，以免發生記憶體洩漏的問題
            sqlite3_finalize(statement)
        }

        return false
    }

}

