//
//  MissingDataViewController.swift
//  DropboxPhotoTest
//
//  Created by Bryton Moeller on 3/17/16.
//  Copyright © 2016 citruscircuits. All rights reserved.
//

import UIKit
import Firebase

class MissingDataViewController : UIViewController {
    @IBOutlet weak var mdTextView: UITextView!
    
    let firebase = Firebase(url: "https://1678-scouting-2016.firebaseio.com/Teams")
    
    let firebaseKeys = ["pitBumperHeight", "pitDriveBaseWidth", "pitDriveBaseLength", "pitNumberOfWheels", "pitOrganization", "pitPotentialLowBarCapability", "pitPotentialMidlineBallCapability", "pitPotentialShotBlockerCapability", "selectedImageUrl", "pitNotes", "pitHeightOfBallLeavingShooter"]
    
    let ignoreKeys = ["pitNotes"]
    
    override func viewWillAppear(animated: Bool) {
        mdTextView.bounds.size.height = mdTextView.contentSize.height + 100
        self.preferredContentSize.height = mdTextView.bounds.size.height
    }
    
    override func viewDidLoad() {
        
        firebase?.authWithCustomToken(compToken, withCompletionBlock: { (E, A) -> Void in
            self.firebase?.observeSingleEventOfType(.Value, withBlock: { (snap) -> Void in
                for team in snap.children.allObjects {
                    let t = (team as! FDataSnapshot).value as! [String: AnyObject]
                    if t["selectedImageUrl"] == nil {
                        self.updateWithText("\nTeam \(t["number"]!) has no selected image URL.", color: UIColor.blueColor())
                    }
                    var dataNils : [String] = []
                    for key in self.firebaseKeys {
                        if t[key] == nil && !self.ignoreKeys.contains(key) {
                            dataNils.append(key)
                        }
                    }
                    if dataNils.count == 2 {
                        self.updateWithText("\nTeam \(t["number"]!) is missing datapoint: \(dataNils[0]).", color: UIColor.orangeColor())
                        self.updateWithText("\nTeam \(t["number"]!) is missing datapoint: \(dataNils[1]).", color: UIColor.orangeColor())
                    } else if dataNils.count == 1 {
                        self.updateWithText("\nTeam \(t["number"]!) is missing datapoint: \(dataNils[0]).", color: UIColor.orangeColor())
                    } else if dataNils.count > 2 {
                        self.updateWithText("\nTeam \(t["number"]!) is missing many datapoints.", color: UIColor.redColor())
                    }
                }
            })
        })
    }
    
    func updateWithText(text : String, color: UIColor) {
        let currentText : NSMutableAttributedString = NSMutableAttributedString(attributedString: self.mdTextView.attributedText)
        currentText.appendAttributedString(NSMutableAttributedString(string: text, attributes: [NSForegroundColorAttributeName: color]))
        self.mdTextView.attributedText = currentText
        mdTextView.bounds.size.height = mdTextView.contentSize.height + 100
        self.preferredContentSize.height = mdTextView.bounds.size.height
    }
    
    
    func adaptivePresentationStyleForPresentationController(
        controller: UIPresentationController!) -> UIModalPresentationStyle {
            return .None
    }
}