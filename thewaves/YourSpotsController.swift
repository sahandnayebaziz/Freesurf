//
//  YourSpotsController.swift
//  thewaves
//
//  Created by Sahand Nayebaziz on 8/3/14.
//  Copyright (c) 2014 Sahand Nayebaziz. All rights reserved.
//

import UIKit

class YourSpotsController: UITableViewController {

}

//import UIKit
//
//@objc(ToDoListTableViewController)class ToDoListTableViewController: UITableViewController {
//    
//    @IBAction func unwindToList(segue:UIStoryboardSegue){
//        var source: AddToDoViewController = segue.sourceViewController as AddToDoViewController
//        if var item: ToDoItem = source.toDoItem{
//            self.toDoItems += item
//            self.tableView.reloadData()
//        }
//        
//    }
//    
//    var toDoItems:[ToDoItem] = []
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//    }
//    
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//    
//    override func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
//        return 1
//    }
//    
//    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
//        return self.toDoItems.count
//    }
//    
//    
//    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
//        let cellIdentifier:String = "ListPrototypeCell"
//        var cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as UITableViewCell
//        var toDoItem:ToDoItem = toDoItems[indexPath.row] as ToDoItem
//        cell.textLabel.text = toDoItem.itemName
//        if toDoItem.completed {
//            cell.accessoryType = .Checkmark
//        }
//        else {
//            cell.accessoryType = .None
//        }
//        return cell
//    }
//    
//    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath:NSIndexPath!) {
//        tableView.deselectRowAtIndexPath(indexPath, animated: false)
//        var tappedItem:ToDoItem = toDoItems[indexPath.row] as ToDoItem
//        tappedItem.completed = !tappedItem.completed
//        tableView.reloadData()
//    }
//    
//    override func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
//        return true
//    }
//    
//    override func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
//        if (editingStyle == UITableViewCellEditingStyle.Delete) {
//            toDoItems.removeAtIndex(indexPath.row)
//            tableView.reloadData()
//        }
//    }
//    
//    /*
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
//    // Get the new view controller using [segue destinationViewController].
//    // Pass the selected object to the new view controller.
//    }
//    */
//    
//}
