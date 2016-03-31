//
//  ViewController.swift
//  VexApp
//
//  Created by Simon Burfield on 24/03/2016.
//  Copyright © 2016 Simon Burfield. All rights reserved.
//

import UIKit

class ViewController: UIViewController, SmartControllerDelegate {

    var myController : SmartController!
    
    var pollTimer : NSTimer!
    var connected = false
    
    @IBOutlet weak var connectedLabel: UILabel!
    @IBOutlet weak var SSIDTextField: UITextField!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var connectionButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        connectedLabel.text = "Disconnected"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // l for led : m for motor
    @IBAction func bluePressed(sender: AnyObject) {
        sendData("l1")
    }
    
    @IBAction func greenPressed(sender: AnyObject) {
        sendData("l3")
    }
    
    @IBAction func redPressed(sender: AnyObject) {
        sendData("l2")
    }
    
    @IBAction func backwardPressed(sender: AnyObject) {
        sendData("m2")
    }
    
    @IBAction func forwardPressed(sender: AnyObject) {
        sendData("m1")
    }
    @IBAction func stopPressed(sender: AnyObject) {
        sendData("m0")
    }
    
    @IBAction func connectPressed(sender: AnyObject) {
        
        connect()
    }
    
    /*-----------------------------------------------------------------------------*/
    /** @brief User pressed one of the buttons                                     */
    /*-----------------------------------------------------------------------------*/

    
    func sendData (message: String)
    {
        if( self.myController != nil ) {
            
            let cmd : NSData = NSData(bytes: [UInt8](message.utf8), length: message.characters.count)
            myController.robotcUserMessageSend(cmd, withReply: false)
        }
    }
    

    /*-----------------------------------------------------------------------------*/
    /** @brief User pressed connect switch                                         */
    /*-----------------------------------------------------------------------------*/
    
    func connect()
    {
        if (!connected)
        {
            if let SSID = UInt32(SSIDTextField.text!)
            {
                myController = SmartController(SSID,withDelagate: self)
                connectedLabel.text = "Connecting"
            }
        }
        else
        {
            connectedLabel.text = "Disconnecting"
            stopPolling();
        }
        
    }
    
    /*-----------------------------------------------------------------------------*/
    /** @brief Status of data link changed                                         */
    /*-----------------------------------------------------------------------------*/
    
    func dataStatus(status: Bool) {
        
        if (status)
        {
            connectedLabel.text = "Connected"
            connected = true
            self.startPolling()
            self.connectionButton.titleLabel?.text = "Disconnect"
        }
        else
        {
            connected = false
            self.stopPolling()
            self.connectionButton.titleLabel?.text = "Connect"
        }
    }
    
    /*-----------------------------------------------------------------------------*/
    /** @brief Stop poll timer                                                     */
    /*-----------------------------------------------------------------------------*/
    
    func stopPolling()
    {
        if (pollTimer != nil)
        {
            pollTimer.invalidate()
            pollTimer = nil;
            connectedLabel.text = "Disconnected"
        }
    }
    
    /*-----------------------------------------------------------------------------*/
    /** @brief Init poll timer                                                     */
    /*-----------------------------------------------------------------------------*/
    
    func startPolling()
    {
        let timeoutTime = 0.20;
        pollTimer = NSTimer.scheduledTimerWithTimeInterval(timeoutTime, target: self, selector:#selector(ViewController.timeoutCallback), userInfo: nil, repeats: true)
        
    }
    
    /*-----------------------------------------------------------------------------*/
    /** @brief poll timer callback - ask for user message data from brain          */
    /*-----------------------------------------------------------------------------*/
    
    func timeoutCallback()
    {
        //print("Poll Timer")
        
        if (myController != nil)
        {
            myController.robotcUserMessageRequest()
        }
    }
    
    func joystickStatus(status: Bool) {
        
        // not used
    }
    
    /*-----------------------------------------------------------------------------*/
    /** @brief user message payload received                                       */
    /*-----------------------------------------------------------------------------*/
    
    func userMessage(msg: NSData!) {
        
        var bytes = [CUnsignedChar](count: msg.length, repeatedValue: 0)
        msg.getBytes(&bytes, length: sizeofValue(bytes))

        if (bytes[0].char() == "t") // t for touch
        {
            if(bytes[1] == 1 ) {
                //print("pressed");
                self.statusLabel.text = "(pressed)";
            }
            else if(bytes[1] == 0 ) {
                //print("release");
                self.statusLabel.text = "(release)";
            }
            else
            {
                //print("unknown msg");
                self.statusLabel.text = "(----)";
            }

        }
        
    }
    
}

extension UInt8 {
    func char() -> Character {
        return Character(UnicodeScalar(Int(self)))
    }
}

extension String {
    var utf8Array: [UInt8] {
        return Array(utf8)
    }
}