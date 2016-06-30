//
//  UIScrollview+ScrollDockMenu.swift
//  ScrollDockMenuDemo
//
//  Created by LawLincoln on 16/6/24.
//  Copyright © 2016年 SelfStudio. All rights reserved.
//

import UIKit
import KVOBlock
private struct AssociatedKeys {
	static var Manager = "Manager"
	static var Enable = "Enable"
}
public extension UIScrollView {

	private var manager: Manager? {
		get { return objc_getAssociatedObject(self, &AssociatedKeys.Manager) as? Manager }
		set(val) {
			objc_setAssociatedObject(self, &AssociatedKeys.Manager, val, .OBJC_ASSOCIATION_RETAIN)
		}
	}

	public var ss_menuView: UICollectionView? { return manager?.menu }

	public var ss_dataList: [ScrollDockMenuData]? {
		get { return manager?.menu?.datas }
		set(value) { manager?.menu?.datas = value }
	}

	public func ss_enableScrollDockMenu(underNavigationBar: Bool = true, cellBorderColor: UIColor = UIColor.redColor(), selectedId: String) {
		guard let value = superview else {
			assert(false, "scrollView must has superview ")
			return
		}
		manager = Manager()
		let menu = ScrollDockMenu()
		value.layoutIfNeeded()
		value.addSubview(menu)
		menu.selectedId = selectedId
		menu.cellBorderColor = cellBorderColor
		manager?.menu = menu
		manager?.sc = self
		let w = Int(CGRectGetWidth(frame))
		let h = CGRectGetHeight(menu.frame)
		let ih = Int(CGRectGetHeight(menu.frame))
		let y = underNavigationBar ? 64 : 0
		contentInset.top = underNavigationBar ? (h + 64) : (h)
		scrollIndicatorInsets.top = contentInset.top
		value.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[menu(\(w))]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["menu": menu]))
		value.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-\(y)-[menu(\(ih))]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["menu": menu]))
		observeKeyPath("contentOffset") { [weak self](target, _, _) in
			guard let sself = self, value = target as? UIScrollView else { return }
			if sself.manager?.isManualOpening == true { return }
			self?.manager?.dealWithScroll(value)
		}
		manager?.initTimer()
	}

	public func toggleMenu() {
		guard let value = manager, hh = manager?.menu?.frame.size.height else { return }
		let h: CGFloat = value.opening ? -hh : 64
		value.isManualOpening = true
		value.setOffset(h, animated: true)
	}

	public func updateFirstImage(url: String) {
		manager?.menu?.updateFirstCell()
	}

}

private final class Manager: NSObject, UIScrollViewDelegate {

	weak var menu: ScrollDockMenu?
	weak var sc: UIScrollView?

	var isManualOpening = false
	var scrolling = false {
		didSet { if !scrolling { isManualOpening = false } }
	}
	var lastOffset = CGPointZero
	var opening = true

	private func dealWithScroll(scrollView: UIScrollView) {
		if isManualOpening { return }
		guard let value = menu else { return }
		var offset = (-scrollView.contentOffset.y) - (value.frame.height ?? 0)
		var animated = false
		if offset > 64 { offset = 64 }
		else if offset < -72 { animated = true }
		setOffset(offset, animated: animated)
	}

	private func setOffset(offset: CGFloat, animated: Bool = false) {
		guard let value = menu, scrollview = sc else { return }
		opening = value.frame.origin.y >= 0
		if let constraints = value.superview?.constraints {
			for c in constraints {
				if c.firstItem is ScrollDockMenu && c.firstAttribute == .Top {
					value.superview?.removeConstraint(c)
					break
				}
			}
		}
		let constriant = NSLayoutConstraint(item: value, attribute: .Top, relatedBy: .Equal, toItem: value.superview, attribute: .Top, multiplier: 1, constant: offset)
		value.superview?.addConstraint(constriant)
		if animated {
			let standrY = -64 - CGRectGetHeight(value.frame)
			let scY = scrollview.contentOffset.y
			UIView.animateWithDuration(0.2,
				animations: {
					value.superview?.layoutIfNeeded()
					if self.opening == false {
						if scY == standrY {
							scrollview.setContentOffset(CGPointMake(0, -64), animated: false)
						} else if scY == -64 {
							scrollview.setContentOffset(CGPointMake(0, standrY), animated: false)
						}
					} else {
						if scY == -64 {
							scrollview.setContentOffset(CGPointMake(0, standrY), animated: false)
						} else if scY <= -64 {
							scrollview.setContentOffset(CGPointMake(0, -64), animated: false)
						}
					}
				},
				completion: {
					[weak self] b in
					guard let sself = self else { return }
					if !sself.scrolling {
						sself.opening = value.frame.origin.y > 0
						sself.isManualOpening = false
					}
				}
			)
		} else { if isManualOpening != false { isManualOpening = false } }
	}

	@objc private func scrollDetech() {
		guard let value = sc else { return }
		if lastOffset != value.contentOffset {
			lastOffset = value.contentOffset
			if scrolling != true { scrolling = true }
			if lastOffset.y == -64 && scrolling != false { scrolling = false }
		} else { if scrolling != false { scrolling = false } }
	}

	private func initTimer() {
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC))), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { [weak self]() -> Void in
			self?.scrollDetech()
			self?.initTimer()
		}

	}
}