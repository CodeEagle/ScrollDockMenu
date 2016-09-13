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

	let sc = UITableView(frame: CGRect.zero, style: .plain)
    let co: UICollectionView = {
        let l = UICollectionViewFlowLayout()
        l.scrollDirection = .vertical
       return UICollectionView(frame: CGRect.zero, collectionViewLayout: l)
    }()

	override func viewDidLoad() {
		super.viewDidLoad()
        co.backgroundColor = UIColor.white
        co.alwaysBounceVertical = true
		co.translatesAutoresizingMaskIntoConstraints = false
		automaticallyAdjustsScrollViewInsets = false
		view.addSubview(co)
		view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[sc]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["sc": co]))
		view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[sc]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["sc": co]))
		co.ss_enableScrollDockMenu(selectedId: "0")
//		sc.dataSource = self
//		sc.delegate = self
//		sc.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
		var datas = [ScrollDockMenuData]()
		for i in 0...10 {
			var d = MenuData()
			d.id = "\(i)"
			datas.append(d)
		}
		co.ss_dataList = datas
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	// MARK: UITableViewDataSource

	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 30
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as UITableViewCell
		configureCell(cell, forRowAtIndexPath: indexPath)
		return cell
	}

	func configureCell(_ cell: UITableViewCell, forRowAtIndexPath: IndexPath) {
		cell.textLabel?.text = "\((forRowAtIndexPath as NSIndexPath).row)"
	}

	// MARK: UITableViewDelegate

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		print("didTap:\(indexPath)")
	}

	@IBAction func toggle(_ sender: AnyObject) {
		co.toggleMenu()
	}
}

struct MenuData: ScrollDockMenuData {

	var name: NSAttributedString { return NSAttributedString(string: "中文测试") }
	var id: String = "1"
	var image: (String?, UIImage?) { return ("https://d13yacurqjgara.cloudfront.net/users/43762/screenshots/2699420/thankful.gif", nil) }
	var tapClosure: (String) -> Void = {
		txt in
		print("tap:\(txt)")
	}
}
