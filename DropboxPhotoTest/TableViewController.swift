//
//  TableViewController.swift
//  DropboxPhotoTest
//
//  Created by Bryton Moeller on 1/18/16.
//  Copyright © 2016 citruscircuits. All rights reserved.
//
import UIKit
import Foundation
import Firebase
import firebase_schema_2016_ios
//import SwiftyJSON
import FirebaseUI
import SwiftyDropbox

class TableViewController: UITableViewController, UISearchBarDelegate {
    
    let cellReuseId = "teamCell"
    let data = ["1678-Circus Circus", "254-Chezy Poffs"]
    var comp : Competition?
    var firebase : Firebase?
    var teams : NSMutableArray = []
    var teamNums : [Int] = []
    var donePitscouting : NSMutableArray = []
    var timer = NSTimer()
    var photoUploader : PhotoUploader?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(Dropbox.authorizedClient == nil) {
            Dropbox.authorizeFromController(self)
        }
        tableView.delegate = self
        tableView.dataSource = self
        self.firebase = Firebase(url: "https://1678-dev2-2016.firebaseio.com/Teams")
        firebase?.observeEventType(.Value, withBlock: { (snap) -> Void in
            var urlsDict : [Int : NSMutableArray] = [Int: NSMutableArray]()
            for t in snap.children.enumerate() {
                let team = t.element
                self.teams.addObject(team)
                let teamNum = team.childSnapshotForPath("number").value as! Int
                self.teamNums.append(teamNum)
                
                if let urlsForTeam = team.childSnapshotForPath("otherImageUrls").value as? NSMutableDictionary {
                    let urlsArr = NSMutableArray()
                    for (_, value) in urlsForTeam {
                        urlsArr.addObject(value)
                    }
                    urlsDict[teamNum] = urlsArr
                } else {
                    urlsDict[teamNum] = NSMutableArray()
                }
                if(self.teamHasBeenPitScouted(team as! FDataSnapshot)) {
                    self.donePitscouting[t.index] = true
                } else {
                    self.donePitscouting[t.index] = false
                }
            }
            let tempArray : NSMutableArray = NSMutableArray(array: self.teamNums)
            tempArray.sortedArrayUsingComparator({ (obj1, obj2) -> NSComparisonResult in
                let o = obj1 as! Int
                let t = obj2 as! Int

                if(o > t) { return NSComparisonResult.OrderedAscending }
                else if(t > o) { return NSComparisonResult.OrderedDescending }
                else { return NSComparisonResult.OrderedSame }
            })
            self.teamNums = tempArray as [AnyObject] as! [Int]
            self.tableView.reloadData()
            
            if self.photoUploader == nil {
                self.photoUploader = PhotoUploader(teamsFirebase: self.firebase!, teamNumbers: self.teamNums)
                self.photoUploader?.sharedURLs = urlsDict
            } else {
                self.photoUploader?.sharedURLs = urlsDict
            }
            
            
        })
        
    }
    
    func teamHasBeenPitScouted(snap: FDataSnapshot) -> Bool {
        if (snap.childSnapshotForPath("pitBumperHeight").value as! Int) <= -1 { return false }
        if (snap.childSnapshotForPath("pitDriveBaseWidth").value as! Int) <= -1 { return false }
        if (snap.childSnapshotForPath("pitDriveBaseLength").value as! Int) <= -1 { return false }
        //if (snap.childSnapshotForPath("pitNotes").value as! String) == "-1" { return false }
        if (snap.childSnapshotForPath("pitNumberOfWheels").value as! Int) <= -1 { return false }
        if (snap.childSnapshotForPath("pitOrganization").value as! Int) == -1 { return false }
        if (snap.childSnapshotForPath("pitPotentialLowBarCapability").value as! Int) == -1 { return false }
        if (snap.childSnapshotForPath("pitPotentialMidlineBallCapability").value as! Int) == -1 { return false }
        if (snap.childSnapshotForPath("pitPotentialShotBlockerCapability").value as! Int) == -1 { return false }
        if (snap.childSnapshotForPath("selectedImageUrl").value as! String) == "-1" { return false }
        return true
    }
    
    // MARK:  UITextFieldDelegate Methods
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.teamNums.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(self.cellReuseId, forIndexPath: indexPath) as UITableViewCell
        let text  = self.teamNums[indexPath.row]
        cell.textLabel?.text = "\(text)"
        if(self.donePitscouting[indexPath.row] as! Bool == true) {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        
        
        return cell
    }
    
    // MARK:  UITableViewDelegate Methods
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Team View Segue" {
            let indexPath = self.tableView.indexPathForCell(sender as! UITableViewCell)
            
            if let number : Int = self.teamNums[(indexPath?.row)!] {
                let teamViewController = segue.destinationViewController as! ViewController
                
                let teamFB = self.firebase?.childByAppendingPath("\(number)")
                teamViewController.ourTeam = teamFB
                teamViewController.firebase = self.firebase
                teamViewController.teamNum = number
                teamViewController.title = "\(number)"
                teamViewController.photoUploader = self.photoUploader

                teamFB!.observeSingleEventOfType(.Value, withBlock: { (snap) -> Void in
                    teamViewController.teamNam = snap.childSnapshotForPath("name").value as! String
                })
            }
        }
    }
    
    
    
    
    
}