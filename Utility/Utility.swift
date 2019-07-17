//
//  Utility.swift
//  BasicUtilities
//
//  Created by Shrenik on 15/07/19.
//  Copyright © 2019 Volansys. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications
import QuickLook

extension String {
    var isValidEmail: Bool {
        // Regex to check email id is proper validated or not
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return range(of: emailRegEx, options: .regularExpression, range: nil, locale: nil) != nil
    }
    
    var isValidPassword : Bool {
        // Regex to check one Capital letter, one Special Character, one Digit, One Lowercase Character and Minimum 6 Length
        let passwordRegEx = "^(?=.*[A-Z])(?=.*[!@#$&*])(?=.*[0-9])(?=.*[a-z]).{6,}$"
        return range(of: passwordRegEx, options: .regularExpression, range: nil, locale: nil) != nil
    }
    
    var isValidPhoneNumber: Bool {
        // 9999999999, +919999999999 both are valid phone numbers. Max 14 digit length
        let phoneNumRegex = "^(?:(\\+)|(00))?[0-9]{6,14}$"
        return range(of: phoneNumRegex, options: .regularExpression, range: nil, locale: nil) != nil
    }
    
    func trim() -> String{
        // Remove white spaces and trim the string
        return trimmingCharacters(in: CharacterSet.whitespaces)
    }
    
    var isBlank: Bool {
        // Remove white space and then check the string is empty or not
        return trimmingCharacters(in: CharacterSet.whitespaces).isEmpty
    }
    
    /**
     Convert string object to date
     
     format :- Which format of string you provide that you have to pass. Like MM-dd-yyyy or dd-MM-yyyy etc
     */
    func stringToDate(format : String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.date(from: self)
    }
    
    /**
     Remove any sub string from string
     
     removeString :- String which you want to remove from your main string
     */
    func removeSubString(removeString : String) -> String {
        return self.replacingOccurrences(of: removeString, with: "")
    }
}

extension UIViewController : QLPreviewControllerDataSource{
    
    //This url of file which you want to open in QLPreview
    private static var urlManageForQuickLook : URL?
    
    //MARK: Datasource methods of QLPreviewController
    public func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    public func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return UIViewController.urlManageForQuickLook! as QLPreviewItem
    }
    
    /**
     Show preview of any log file by proper date
     
     dateFile :- date object need to pass for proper file
     */
    func showPreview(_ dateFile : Date?) {
        
        guard (dateFile != nil && (getFilePathbyDate(date: dateFile!) != nil)) else {
            showAlert(title: "Please give perfect date", message: "No data found")
            return
        }
        
        UIViewController.urlManageForQuickLook = getFilePathbyDate(date: dateFile!)
        
        let quickLookController = QLPreviewController()
        quickLookController.dataSource = self
        self.present(quickLookController, animated: true, completion: nil)
    }
    
    /**
     Show preview of any file by proper url
     
     urlFile :- pass url to see any file in QLPreview
     */
    func showPreviewByPath(_ urlFile : URL) {
        
        UIViewController.urlManageForQuickLook = urlFile
        
        let quickLookController = QLPreviewController()
        quickLookController.dataSource = self
        self.present(quickLookController, animated: true, completion: nil)
    }
    
    /**
     Show Alert view and once pass proper date in to textfield it will give log file in QLPreview
     */
    func showLogFile() {
        let alertController = UIAlertController(title: "Enter date", message: "enter date in MM-dd-yyyy", preferredStyle: UIAlertController.Style.alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter Date in MM-dd-yyyy"
        }
        let saveAction = UIAlertAction(title: "Save", style: UIAlertAction.Style.default, handler: { alert -> Void in
            let firstTextField = alertController.textFields![0] as UITextField
            self.showPreview((firstTextField.text?.stringToDate(format: "MM-dd-yyyy")))
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: {
            (action : UIAlertAction!) -> Void in })
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    /**
        Default alert controller with Ok button and title and message are that which passed as passing parameter
     
        title :- String title of alert
        message :- String message of alert
     */
    func showAlert(title :String,message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension Date {
    /**
     Convert date object to string
     
     format :- Which format of string you want that you have to pass. Like MM-dd-yyyy or dd-MM-yyyy etc
     */
    func dateToString(format : String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    /**
     Get date of past/future by passign days
     
     days :- if you pass positive number then it will give future date and if minus then past date according to number of days
     */
    func dateBeforeAfterDays(days : Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: days, to: self)!
    }
}

//MARK: Register for local/remote push notification and get device token
extension AppDelegate {
    static var deviceTokenMain = ""
    
    func registerForRemotePushNotification(_ application: UIApplication) {
        //We can register for remote notification by this method
    UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]){ (granted, error) in }
        application.registerForRemoteNotifications()
        UNUserNotificationCenter.current().delegate = self
    }
    
    func registerForLocalNotification(_ application: UIApplication) {
        //We can register for local notification by this method
        let notificationCenter = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        
        notificationCenter.requestAuthorization(options: options) {
            (didAllow, error) in
            if !didAllow {
                print("User has declined notifications")
            }
        }
        
        UNUserNotificationCenter.current().delegate = self
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        //We can get device token by deviceTokenMain by this delegate method
        
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)}) // Convert token to string
        AppDelegate.deviceTokenMain = deviceTokenString
        print("APNs device token: \(deviceTokenString)")
    }
}

//MARK: extension of appdelegate when app is in foreground then also we can get notification pop up
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print(response.notification.request.content.userInfo)
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
}


