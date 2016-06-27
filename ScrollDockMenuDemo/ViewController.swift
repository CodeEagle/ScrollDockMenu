//
//  ViewController.swift
//  ScrollDockMenuDemo
//
//  Created by LawLincoln on 16/6/24.
//  Copyright © 2016年 SelfStudio. All rights reserved.
//

import UIKit
import ScrollDockMenu

final class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

	let sc = UITableView(frame: CGRectZero, style: .Plain)

	override func viewDidLoad() {
		super.viewDidLoad()
		sc.translatesAutoresizingMaskIntoConstraints = false
		automaticallyAdjustsScrollViewInsets = false
		view.addSubview(sc)
		view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[sc]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["sc": sc]))
		view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[sc]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["sc": sc]))
		sc.ss_enableScrollDockMenu(selectedId: "0")
		sc.dataSource = self
		sc.delegate = self
		sc.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
		var datas = [ScrollDockMenuData]()
		for i in 0...10 {
			var d = MenuData()
			d.id = "\(i)"
			datas.append(d)
		}
		sc.ss_dataList = datas
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	// MARK: UITableViewDataSource

	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}

	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 30
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
		configureCell(cell, forRowAtIndexPath: indexPath)
		return cell
	}

	func configureCell(cell: UITableViewCell, forRowAtIndexPath: NSIndexPath) {
		cell.textLabel?.text = "\(forRowAtIndexPath.row)"
	}

	// MARK: UITableViewDelegate

	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		print("didTap:\(indexPath)")
	}

	@IBAction func toggle(sender: AnyObject) {
		sc.toggleMenu()
	}
}

struct MenuData: ScrollDockMenuData {

	var name: String { return "abc" }
	var id: String = "1"
	var image: (String?, UIImage?) { return ("https://d13yacurqjgara.cloudfront.net/users/43762/screenshots/2699420/thankful.gif", nil) }
	var tapClosure: (String) -> Void = {
		txt in
		print("tap:\(txt)")
	}
}
