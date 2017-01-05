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
	var name: NSAttributedString { get }
	var id: String { get }
	var image: (String?, UIImage?) { get }
	var tapClosure: (String) -> Void { get }
}
//MARK:- ScrollDockMenu
public final class ScrollDockMenu: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {

	var cellBorderColor: UIColor? = UIColor.red
	var selectedId: String = "0"
	var imageContentMode = UIViewContentMode.scaleAspectFit
    public var cellBackgroundColor: UIColor = .white
    public var cellEnableDim: Bool = true

	var datas: [ScrollDockMenuData]? {
		didSet { if reloadAll { reloadData() } }
	}

	fileprivate var reloadAll = true
	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
		super.init(frame: frame, collectionViewLayout: layout)
	}

	convenience init() {
		let layout = UICollectionViewFlowLayout()
		layout.scrollDirection = .horizontal
		self.init(frame: CGRect(x: 0, y: 0, width: 72, height: 92), collectionViewLayout: layout)
		register(ScrollDockMenuCell.self, forCellWithReuseIdentifier: ScrollDockMenuCell.idf)
		dataSource = self
		delegate = self
		scrollsToTop = false
		backgroundColor = UIColor.white
		translatesAutoresizingMaskIntoConstraints = false
		showsHorizontalScrollIndicator = false
	}

	// MARK: UICollectionViewDataSource
	public func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}

	public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return datas?.count ?? 0
	}

	public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ScrollDockMenuCell.idf, for: indexPath) as! ScrollDockMenuCell
		if let item = datas?[safe: indexPath.item] {
			cell.configure(item)
			cell.isSelected = item.id == selectedId
            cell.cover.isHidden = !cellEnableDim
            cell.contentView.backgroundColor = cellBackgroundColor
		}
		cell.cover.contentsGravity = imageContentMode.caGravityName
		updateSelected(cell)
		return cell
	}

	// MARK: UICollectionViewDelegateFlowLayout

	public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		return UIEdgeInsetsMake(6, 6, 6, 6)
	}

	public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return 6
	}

	public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return 6
	}

	public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: 90, height: 70)
	}

	// MARK:- UICollectionViewDelegate
	public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if let item = datas?[safe: (indexPath as NSIndexPath).item] {
			selectedId = item.id
			item.tapClosure(selectedId)
		}
		if let cell = collectionView.cellForItem(at: indexPath) {
			updateSelected(cell)
		}
	}

	public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
		if let cell = collectionView.cellForItem(at: indexPath) {
			cell.isSelected = false
			updateSelected(cell)
		}
	}

	public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		if let item = datas?[safe: (indexPath as NSIndexPath).item] {
			if item.id == selectedId {
				collectionView.selectItem(at: indexPath, animated: false, scrollPosition: UICollectionViewScrollPosition())
			}
		}
	}

	fileprivate func updateSelected(_ cell: UICollectionViewCell) {
		if cell.isSelected {
			cell.contentView.layer.borderWidth = 0.5
			cell.contentView.layer.borderColor = cellBorderColor?.cgColor
		} else {
			cell.contentView.layer.borderWidth = 0
			cell.contentView.layer.borderColor = nil
		}
	}

	func updateFirstCell(data list: [ScrollDockMenuData]) {
		reloadAll = false
		datas = list
		let path = IndexPath(item: 0, section: 0)
		if indexPathsForVisibleItems.contains(path) { reloadItems(at: [path]) }
		reloadAll = true
	}
}

//MARK:- ScrollDockMenuCell
private final class ScrollDockMenuCell: UICollectionViewCell {

	static let idf = "ScrollDockMenuCell"
	fileprivate var cover = SSDimLayer(opacity: 0.4)
	fileprivate var text = CATextLayer()

	required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder); initialize() }
	override init(frame: CGRect) { super.init(frame: frame); initialize() }

	fileprivate func initialize() {
		contentView.layer.addSublayer(cover)
		contentView.layer.addSublayer(text)
		text.alignmentMode = "center"
		text.contentsScale = UIScreen.main.scale
		cover.contentsScale = UIScreen.main.scale
		cover.contentsGravity = kCAGravityResizeAspect
		contentView.layer.borderWidth = 0.5
		contentView.clipsToBounds = true
	}

	func configure(_ item: ScrollDockMenuData) {
		if let url = item.image.0 { cover.ss_setImageBy(url) }
		if let img = item.image.1 { cover.contents = img.cgImage }
		text.string = item.name
		let rect = item.name.boundingRect(with: contentView.bounds.size, options: [.usesFontLeading, .usesLineFragmentOrigin], context: nil)
		let size = contentView.bounds.size
		let x = (size.width - rect.width) / 2
		let y = (size.height - rect.height) / 2
		text.frame = CGRect(x: x, y: y, width: rect.width, height: rect.height)
	}

	fileprivate override func layoutSubviews() {
		super.layoutSubviews()
		cover.frame = contentView.bounds
	}
}
private final class SSDimLayer: CALayer {

	fileprivate lazy var _dimLayer = CALayer()

	init(opacity: Float) {
		super.init()
		setup(opacity)
	}

	override init() { super.init() }

	override init(layer: Any) { super.init(layer: layer) }

	required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

	fileprivate func setup(_ alpha: Float) {
		_dimLayer.backgroundColor = UIColor.black.cgColor
		_dimLayer.opacity = alpha
		_dimLayer.isOpaque = false
		addSublayer(_dimLayer)
		isOpaque = true
		contentsScale = UIScreen.main.scale
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
