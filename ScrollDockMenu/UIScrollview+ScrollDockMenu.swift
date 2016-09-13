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

	fileprivate var manager: Manager? {
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

	public var ss_imageContentMode: UIViewContentMode? {
		get { return manager?.menu?.imageContentMode }
		set(value) { if let v = value { manager?.menu?.imageContentMode = v } }
	}

	public func ss_enableScrollDockMenu(_ underNavigationBar: Bool = true, cellBorderColor: UIColor = UIColor.red, selectedId: String) {
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
		let w = Int(frame.width)
		let h = menu.frame.height
		let ih = Int(menu.frame.height)
		let y = underNavigationBar ? 64 : 0
		contentInset.top = underNavigationBar ? (h + 64) : (h)
		scrollIndicatorInsets.top = contentInset.top
		value.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[menu(\(w))]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["menu": menu]))
		value.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-\(y)-[menu(\(ih))]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["menu": menu]))
		observeKeyPath("contentOffset") { [weak self](target, _, _) in
			guard let sself = self, let value = target as? UIScrollView else { return }
			if sself.manager?.isManualOpening == true { return }
			self?.manager?.dealWithScroll(value)
		}
		manager?.initTimer()
	}

	public func toggleMenu() {
		guard let value = manager, let hh = manager?.menu?.frame.size.height else { return }
		let h: CGFloat = value.opening ? 0 - hh: 64
		value.isManualOpening = true
		value.setOffset(h, animated: true)
	}

	public func updateFirstImage(with datas: [ScrollDockMenuData]) {
		manager?.menu?.updateFirstCell(data: datas)
	}

}

extension UIViewContentMode {
	var caGravityName: String {
		switch self {
		case .center: return kCAGravityCenter
		case .bottom: return kCAGravityBottom
		case .left: return kCAGravityLeft
		case .right: return kCAGravityRight
		case .topLeft: return kCAGravityTopLeft
		case .topRight: return kCAGravityTopRight
		case .bottomLeft: return kCAGravityBottomLeft
		case .bottomRight: return kCAGravityBottomRight
		case .scaleToFill: return kCAGravityResize
		case .scaleAspectFit: return kCAGravityResizeAspect
		case .scaleAspectFill: return kCAGravityResizeAspectFill
		default: return kCAGravityResizeAspect
		}
	}
}

private final class Manager: NSObject, UIScrollViewDelegate {

	weak var menu: ScrollDockMenu?
	weak var sc: UIScrollView?

	var isManualOpening = false
	var scrolling = false {
		didSet { if !scrolling { isManualOpening = false } }
	}
	var lastOffset = CGPoint.zero
	var opening = true

	fileprivate func dealWithScroll(_ scrollView: UIScrollView) {
		if isManualOpening { return }
		guard let value = menu else { return }
		var offset = (-scrollView.contentOffset.y) - value.frame.height
		var animated = false
		if offset > 64 { offset = 64 }
		else if offset < -72 { animated = true }
		setOffset(offset, animated: animated)
	}

	fileprivate func setOffset(_ offset: CGFloat, animated: Bool = false) {
		guard let value = menu, let scrollview = sc else { return }
		opening = value.frame.origin.y >= 0
		if let constraints = value.superview?.constraints {
			for c in constraints {
				if c.firstItem is ScrollDockMenu && c.firstAttribute == .top {
					value.superview?.removeConstraint(c)
					break
				}
			}
		}
		let constriant = NSLayoutConstraint(item: value, attribute: .top, relatedBy: .equal, toItem: value.superview, attribute: .top, multiplier: 1, constant: offset)
		value.superview?.addConstraint(constriant)
		if animated {
			let standrY = -64 - value.frame.height
			let scY = scrollview.contentOffset.y
			UIView.animate(withDuration: 0.2,
				animations: {
					value.superview?.layoutIfNeeded()
					if self.opening == false {
						if scY == standrY {
							scrollview.setContentOffset(CGPoint(x: 0, y: -64), animated: false)
						} else if scY == -64 {
							scrollview.setContentOffset(CGPoint(x: 0, y: standrY), animated: false)
						}
					} else {
						if scY == -64 {
							scrollview.setContentOffset(CGPoint(x: 0, y: standrY), animated: false)
						} else if scY <= -64 {
							scrollview.setContentOffset(CGPoint(x: 0, y: -64), animated: false)
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

	@objc fileprivate func scrollDetech() {
		guard let value = sc else { return }
		if lastOffset != value.contentOffset {
			lastOffset = value.contentOffset
			if scrolling != true { scrolling = true }
			if lastOffset.y == -64 && scrolling != false { scrolling = false }
		} else { if scrolling != false { scrolling = false } }
	}

	fileprivate func initTimer() {
        DispatchQueue.global(qos: .default).asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) { [weak self] in
            self?.scrollDetech()
            self?.initTimer()
        }
	}
}
