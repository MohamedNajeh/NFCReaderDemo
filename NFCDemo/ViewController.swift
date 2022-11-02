//
//  ViewController.swift
//  NFCDemo
//
//  Created by Najeh on 01/11/2022.
//

import UIKit
import CoreNFC
class ViewController: UIViewController,NFCNDEFReaderSessionDelegate {
   
   var session:NFCNDEFReaderSession?
    
    @IBOutlet weak var TFOutlet: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func readBtnPressed(_ sender: Any) {
        guard NFCNDEFReaderSession.readingAvailable else {
            let alertController = UIAlertController(
                title: "Scanning Not Supported",
                message: "This device doesn't support tag scanning.",
                preferredStyle: .alert
            )
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            return
        }

        session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        session?.alertMessage = "Hold your iPhone near the item to learn more about it."

        session?.begin()
    }

    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        // Check the invalidation reason from the returned error.
        if let readerError = error as? NFCReaderError {
            // Show an alert when the invalidation reason is not because of a
            // successful read during a single-tag read session, or because the
            // user canceled a multiple-tag read session from the UI or
            // programmatically using the invalidate method call.
            if (readerError.code != .readerSessionInvalidationErrorFirstNDEFTagRead)
                && (readerError.code != .readerSessionInvalidationErrorUserCanceled) {
                let alertController = UIAlertController(
                    title: "Session Invalidated",
                    message: error.localizedDescription,
                    preferredStyle: .alert
                )
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                DispatchQueue.main.async {
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }

        // To read new tags, a new session instance is required.
        self.session = nil
    }

    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        //        for message in messages {
        //            for record in message.records {
        //                if let string = String(data: record.payload, encoding: .utf8) {
        //                    print(string)
        //                    TFOutlet.text = string
        //                }
        //            }
        //        }
        let record = messages[0].records[0]
        if record.typeNameFormat == .media && record.type == Data("application/com.lnkr.nfcwriter".utf8){
            TFOutlet.text = String(data: messages[0].records[0].payload, encoding: .utf8)
        }else {
            session.alertMessage = "Unsupported NFCTag"
            session.invalidate()
        }
        
        


    }

    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {

        if tags.count > 1 {
            session.alertMessage = "More than tag detected"
            session.invalidate()
        }

        let tag = tags.first!
        session.connect(to: tag) { error in
            if error != nil {
                session.invalidate(errorMessage: "Failed to connect")
            }
        }
    }
}
