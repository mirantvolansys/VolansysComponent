    //
//  LogWrapper.swift
//  Component_Mirant
//
//  Created by Mirant Patel on 16/07/19.
//  Copyright © 2019 Mirant Patel. All rights reserved.
//

import Foundation
    
    //Log type enum which you have to pass for log type
    enum logType : String {
        case Click = "Click"
        case Navigation = "Navigation"
        case API = "API"
        case Info = "Info"
        case Error = "Error"
        
        case Debug = "Debug"
        case Verbose = "Verbose"
        case Warning = "Warning"
        case Critical = "Critical"
        case Message = "Message"
        case TryCatch = "TryCatch"
        case Trace = "Trace"
    }
    
    /**
     File exist or not on given URL that we can fetch
     
     urlFile :- its optional , you have to pass path Url of specific file else it will fetch URL of todays log file automatically
     */
    func isFileExist(urlFile : URL? = nil) -> Bool {
        let pathComponent = urlFile ?? getFilePath()
        let filePath = pathComponent.path
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: filePath) {
            return true
        } else {
            return false
        }
    }
    
    /**
     Directory exist or not of log files that provides
     */
    func isDirectroryExist() -> Bool {
        
        let directoryName = "logDirectory"
        let DocumentDirURL = getDocumentsDirectory()
        
        let fileURL = DocumentDirURL.appendingPathComponent(directoryName)
        
        var isDir: ObjCBool = false
        if FileManager.default.fileExists(atPath: fileURL.path, isDirectory: &isDir) {
            return isDir.boolValue
        }
        return false
    }
    
    /**
     Will give filename as per today's date
     */
    func getTodayFileName() -> String {
        let myString = "logDebugger_File_\(Date().dateToString(format: "MM-dd-yyyy"))"
        return myString
    }
    
    /**
     Will give filename as per specific date
     
     date:- date object for which date's filename you want
     */
    func getFileNameByDate(date : Date) -> String {
        let myString = "logDebugger_File_\(date.dateToString(format: "MM-dd-yyyy"))"
        return myString
    }
    
    /**
     Will give URL for default path of document directory
     */
    func getDocumentsDirectory() -> URL {
        return try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    }
    
    /**
     If logfiles directory is not exist then it will create directory
     */
    func createLogDirectory() {
        let logsPath = getDocumentsDirectory().appendingPathComponent("logDirectory")
        do
        {
            try FileManager.default.createDirectory(atPath: logsPath.path, withIntermediateDirectories: true, attributes: nil)
        }
        catch let error as NSError
        {
            NSLog("Unable to create directory \(error.debugDescription)")
        }
    }
    
    /**
     Will give URL/path of today's log file
     */
    func getFilePath() -> URL {
        let directoryName = "logDirectory"
        let DocumentDirURL = getDocumentsDirectory()
        
        let fileURL = DocumentDirURL.appendingPathComponent(directoryName).appendingPathComponent(getTodayFileName()).appendingPathExtension("txt")
        return fileURL
    }
    
    /**
     Will give URL/path of file as per specific date
     
     date:- date object for which date's file path you want
     */
    func getFilePathbyDate(date : Date) -> URL? {
        let directoryName = "logDirectory"
        let DocumentDirURL = getDocumentsDirectory()
        
        let fileURL = DocumentDirURL.appendingPathComponent(directoryName).appendingPathComponent(getFileNameByDate(date: date)).appendingPathExtension("txt")
        
        return isFileExist(urlFile: fileURL) ? fileURL : URL(string: "")
    }
    
    /**
     Create/Append file. If same date file is not ready then file created and if already available then append the log into it.
     
     username :- It's optional, If we want to store username into log pass it.
     data :- Message/Log details which we want to store
     type :- type of log like api, click etc
     */
    func createAppendFileForToday(username : String? = nil, data : String, type : logType) {
        if(!isFileExist()) {
            if(!isDirectroryExist()) {
                createLogDirectory()
            }
            removeOldFiles()
            
            // Save data to file
            let writeString = "================ Start logging ================\n"
            do {
                // Write to the file
                try writeString.write(to: getFilePath(), atomically: true, encoding: String.Encoding.utf8)
            } catch let error as NSError {
                print("Failed writing to URL: \(getFilePath()), Error: " + error.localizedDescription)
            }
        }
        
        //All data
        
        var dataString: String
        if(username != nil) {
            dataString = "\nType:\(type.rawValue)\tUsername:\(username ?? "")\tLogData:~ \(data)\n"
        } else {
            dataString = "\nType:\(type.rawValue)\tLogData:~ \(data)\n"
        }
        
        do {
            let fileHandle = try FileHandle(forWritingTo: getFilePath())
            fileHandle.seekToEndOfFile()
            fileHandle.write(dataString.data(using: .utf8)!)
            fileHandle.closeFile()
        } catch {
            print("Error writing to file \(error)")
        }
    }
    
    /**
     It will provide array of all file's URLS of log directory
     */
    func getAllFilesOfDirectory() -> [URL]? {
        let directoryName = "logDirectory"
        let DocumentDirURL = getDocumentsDirectory()
        
        let documentsURL = DocumentDirURL.appendingPathComponent(directoryName)
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
            
            
            // process files
            return fileURLs
        } catch {
            print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
            return nil
        }
    }
    
    /**
     It will remove old files which is older than specific days
     
     days:- It's optional, If you want to remove log files which are older than specific days. That number pass in it else it will remove files older than 15 days from current date.
     */
    func removeOldFiles(days : Int? = -15) {
        let fileURLs = getAllFilesOfDirectory()
        
        guard (fileURLs != nil) else {
            return
        }
        
        for url : URL in fileURLs! {
            var stringPath = url.lastPathComponent
            stringPath = stringPath.removeSubString(removeString: "logDebugger_File_")
            stringPath = stringPath.removeSubString(removeString: ".txt")
            print(stringPath)
            
            if(stringPath == ".DS_Store") {
                continue
            }
            
            let date1 = stringPath.stringToDate(format: "MM-dd-yyyy")!
            let date2 = Date().dateBeforeAfterDays(days: days ?? -15)
            
            if(date1 < date2) {
                do {
                    try FileManager.default.removeItem(at: url)
                } catch {
                    print("Could not clear temp folder: \(error)")
                }
            }
        }
        
    }
    
    /**
     Print log and save log as click type
     
     username :- It's optional, If we want to store username into log pass it.
     data :- Message/Log details which we want to store
     */
    func logPrintClick(username : String? = nil, data : String) {
        createAppendFileForToday(username: username, data: data, type: .Click)
    }
    
    /**
     Print log and save log as Navigation type
     
     username :- It's optional, If we want to store username into log pass it.
     data :- Message/Log details which we want to store
     */
    func logPrintNavigation(username : String? = nil, data : String) {
        createAppendFileForToday(username: username, data: data, type: .Navigation)
    }
    
    /**
     Print log and save log as API type
     
     username :- It's optional, If we want to store username into log pass it.
     data :- Message/Log details which we want to store
     */
    func logPrintAPI(username : String? = nil, data : String) {
        createAppendFileForToday(username: username, data: data, type: .API)
    }
    
    /**
     Print log and save log as Info type
     
     username :- It's optional, If we want to store username into log pass it.
     data :- Message/Log details which we want to store
     */
    func logPrintInfo(username : String? = nil, data : String) {
        createAppendFileForToday(username: username, data: data, type: .Info)
    }
    
    /**
     Print log and save log as Error type
     
     username :- It's optional, If we want to store username into log pass it.
     data :- Message/Log details which we want to store
     */
    func logPrintError(username : String? = nil, data : String) {
        createAppendFileForToday(username: username, data: data, type: .Error)
    }
    
    
    
    /**
     Print log and save log as Debug type
     
     username :- It's optional, If we want to store username into log pass it.
     data :- Message/Log details which we want to store
     */
    func logPrintDebug(username : String? = nil, data : String) {
        createAppendFileForToday(username: username, data: data, type: .Debug)
    }
    
    /**
     Print log and save log as Verbose type
     
     username :- It's optional, If we want to store username into log pass it.
     data :- Message/Log details which we want to store
     */
    func logPrintVerbose(username : String? = nil, data : String) {
        createAppendFileForToday(username: username, data: data, type: .Verbose)
    }
    
    /**
     Print log and save log as Warning type
     
     username :- It's optional, If we want to store username into log pass it.
     data :- Message/Log details which we want to store
     */
    func logPrintWarning(username : String? = nil, data : String) {
        createAppendFileForToday(username: username, data: data, type: .Warning)
    }
    
    /**
     Print log and save log as Critical type
     
     username :- It's optional, If we want to store username into log pass it.
     data :- Message/Log details which we want to store
     */
    func logPrintCritical(username : String? = nil, data : String) {
        createAppendFileForToday(username: username, data: data, type: .Critical)
    }
    
    /**
     Print log and save log as Message type
     
     username :- It's optional, If we want to store username into log pass it.
     data :- Message/Log details which we want to store
     */
    func logPrintMessage(username : String? = nil, data : String) {
        createAppendFileForToday(username: username, data: data, type: .Message)
    }
    
    /**
     Print log and save log as TryCatch type
     
     username :- It's optional, If we want to store username into log pass it.
     data :- Message/Log details which we want to store
     */
    func logPrintTryCatch(username : String? = nil, data : String) {
        createAppendFileForToday(username: username, data: data, type: .TryCatch)
    }
    
    /**
     Print log and save log as Trace type
     
     username :- It's optional, If we want to store username into log pass it.
     data :- Message/Log details which we want to store
     */
    func logPrintTrace(username : String? = nil, data : String) {
        createAppendFileForToday(username: username, data: data, type: .Trace)
    }
    
    
