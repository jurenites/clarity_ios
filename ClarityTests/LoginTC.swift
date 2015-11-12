//
//  LoginTC.swift
//  Clarity
//
//  Created by Oleg Kasimov on 10/23/15.
//  Copyright © 2015 Spring. All rights reserved.
//

import XCTest

@available(iOS 9.0, *)
class LoginTC: XCTestCase {
    
    internal typealias WaitCompletionHandler = (NSError?) -> Void
    let splashWaitTime: Double = 30
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        let app = XCUIApplication()
        app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func waitSplash(completion: WaitCompletionHandler?) {
        let app = XCUIApplication()
        let splash = app.otherElements["VCtrlSplash"]
        
        if !splash.exists {
            if let compl = completion {
                compl(nil)
            }
        }
        
        let exists = NSPredicate(format: "exists == false")
        
        expectationForPredicate(exists, evaluatedWithObject: splash, handler: nil)
        waitForExpectationsWithTimeout(splashWaitTime){ (error: NSError?) in
            if let compl = completion {
                compl(error)
            }
        }
    }
    
    func waitActivity(completion: WaitCompletionHandler?) {
        let app = XCUIApplication()
        let activity = app.otherElements["LoadingOverlay"]
        if !activity.exists {
            if let compl = completion {
                compl(nil)
            }
        }
        
        let exists = NSPredicate(format: "exists == false")
        
        expectationForPredicate(exists, evaluatedWithObject: activity, handler: nil)
        waitForExpectationsWithTimeout(splashWaitTime){ (error: NSError?) in
            if let compl = completion {
                compl(error)
            }
        }
    }
    
    func performLogout(completion: WaitCompletionHandler?) {
        //IF login UI -> ok
        //IF other UI -> Make logout, wait for opening login UI -> ok
        let app = XCUIApplication()
        
        if app.otherElements["VCtrlLogin"].exists {
            if let compl = completion {
                compl(nil)
            }
        }
        
        app.navigationBars["Order List"].buttons["LogoutButton"].tap()
        let logoutOverlay = app.otherElements["LogoutMenu"]
        logoutOverlay.buttons["LogoutButton"].tap()
        
        self.waitActivity { (error: NSError?) -> Void in
            let loginUI = app.otherElements["VCtrlLogin"]
            let exists = NSPredicate(format: "exists == true")
            self.expectationForPredicate(exists, evaluatedWithObject: loginUI, handler: nil)
            self.waitForExpectationsWithTimeout(5.0){ (error: NSError?) in
                if let compl = completion {
                    compl(error)
                }
            }
        }
    }
    
    func testLogin() {
        self.waitSplash { (error: NSError?) -> Void in
            let app = XCUIApplication()
            
            let vctrlloginElement = XCUIApplication().otherElements["VCtrlLogin"]
            let loginTextField = vctrlloginElement.textFields["logintf"]

            
            loginTextField.tap()
            loginTextField.typeText("larry")
            
            let passTextField = app.secureTextFields["passtf"]
            passTextField.tap()
            passTextField.typeText("qwerty")
            
            let loginButton = app.buttons["CBLogin"]
            XCTAssert(loginButton.exists)
            loginButton.tap()
            
            self.waitActivity({ (error: NSError?) -> Void in
                
            })
        }
    }
    
    func testLogout() {
        self.waitSplash { (error: NSError?) -> Void in
            self.performLogout({ (error: NSError?) -> Void in
                
            })
        }
    }
    
}
