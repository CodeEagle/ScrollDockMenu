//
//  ScrollDockMenu.swift
//  ScrollDockMenuDemo
//
//  Created by LawLincoln on 16/6/24.
//  Copyright © 2016年 SelfStudio. All rights reserved.
//

import UIKit
//MARK:- ScrollDockMenuData
public protocol ScrollDockMenuData {
	var name: String { get }
	var id: String { get }
	var image: (String?, UIImage?) { get }
	var tapClosure: (String) -> Void { get }
}
//MARK:- ScrollDockMenu
final class ScrollDockMenu: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {

	var cellBorderColor: UIColor? = UIColor.redColor()
	var selectedId: String = "0"

	var datas: [ScrollDockMenuData]? {
		didSet { reloadData() }
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
		super.init(frame: frame, collectionViewLayout: layout)
	}

	convenience init() {
		let layout = UICollectionViewFlowLayout()
		layout.scrollDirection = .Horizontal
		self.init(frame: CGRectMake(0, 0, 72, 72), collectionViewLayout: layout)
		registerClass(ScrollDockMenuCell.self, forCellWithReuseIdentifier: ScrollDockMenuCell.idf)
		dataSource = self
		delegate = self
		scrollsToTop = false
		backgroundColor = UIColor.whiteColor()
		translatesAutoresizingMaskIntoConstraints = false
		showsHorizontalScrollIndicator = false
	}

	// MARK: UICollectionViewDataSource
	func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
		return 1
	}

	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return datas?.count ?? 0
	}

	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ScrollDockMenuCell.idf, forIndexPath: indexPath) as! ScrollDockMenuCell
		if let item = datas?[safe: indexPath.item] {
			cell.configure(item)
			cell.selected = item.id == selectedId
		}
		updateSelected(cell)
		return cell
	}

	// MARK: UICollectionViewDelegateFlowLayout

	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
		return UIEdgeInsetsMake(6, 6, 6, 6)
	}

	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
		return 6
	}

	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
		return 6
	}

	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
		return CGSizeMake(60, 60)
	}

	// MARK:- UICollectionViewDelegate
	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		if let item = datas?[safe: indexPath.item] {
			selectedId = item.id
			item.tapClosure(selectedId)
		}
		if let cell = collectionView.cellForItemAtIndexPath(indexPath) {
			updateSelected(cell)
		}
	}

	func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
		if let cell = collectionView.cellForItemAtIndexPath(indexPath) {
			cell.selected = false
			updateSelected(cell)
		}
	}

	func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
		if let item = datas?[safe: indexPath.item] {
			if item.id == selectedId {
				collectionView.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: .None)
			}
		}
	}

	private func updateSelected(cell: UICollectionViewCell) {
		if cell.selected {
			cell.contentView.layer.borderWidth = 0.5
			cell.contentView.layer.borderColor = cellBorderColor?.CGColor
		} else {
			cell.contentView.layer.borderWidth = 0
			cell.contentView.layer.borderColor = nil
		}
	}
}

//MARK:- ScrollDockMenuCell
private final class ScrollDockMenuCell: UICollectionViewCell {

	static let idf = "ScrollDockMenuCell"
	private var cover = SSDimLayer(opacity: 0.4)

	required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder); initialize() }
	override init(frame: CGRect) { super.init(frame: frame); initialize() }

	private func initialize() {
		contentView.layer.addSublayer(cover)
		cover.contentsGravity = kCAGravityResizeAspect
		contentView.layer.borderWidth = 0.5
	}

	func configure(item: ScrollDockMenuData) {
		if let url = item.image.0 { cover.ss_setImageBy(url) }
		if let img = item.image.1 { cover.contents = img.CGImage }
	}

	private override func layoutSubviews() {
		super.layoutSubviews()
		cover.frame = contentView.bounds
	}
}
private final class SSDimLayer: CALayer {

	private lazy var _dimLayer = CALayer()

	init(opacity: Float) {
		super.init()
		setup(opacity)
	}

	override init() { super.init() }

	override init(layer: AnyObject) { super.init(layer: layer) }

	required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

	private func setup(alpha: Float) {
		_dimLayer.backgroundColor = UIColor.blackColor().CGColor
		_dimLayer.opacity = alpha
		_dimLayer.opaque = false
		addSublayer(_dimLayer)
		opaque = true
		contentsScale = UIScreen.mainScreen().scale
	}

	override func layoutSublayers() {
		super.layoutSublayers()
		_dimLayer.frame = bounds
	}
}

extension Array {
	subscript(safe index: Int) -> Element? {
		return indices.contains(index) ? self[index]: nil
	}
}