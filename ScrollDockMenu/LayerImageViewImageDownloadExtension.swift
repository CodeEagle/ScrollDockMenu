//
//  LayerImageViewImageDownloadExtension.swift
//  LuooAudioPlayerController
//
//  Created by LawLincoln on 16/6/14.
//  Copyright © 2016年 SelfStudio. All rights reserved.
//

import UIKit
//MARK:- LayerOrImageView
protocol LayerOrImageView: class {
	var ss_imageFillTarget: (CALayer?, UIImageView?) { get }
}

extension UIImageView: LayerOrImageView {
	public var ss_imageFillTarget: (CALayer?, UIImageView?) { return (nil, self) }
}

extension CALayer: LayerOrImageView {
	public var ss_imageFillTarget: (CALayer?, UIImageView?) { return (self, nil) }
}

private struct AssociatedKeys {
	static var Task = "Task"
}

extension LayerOrImageView {

	private var some: AnyObject {
		return ss_imageFillTarget.0 ?? ss_imageFillTarget.1!
	}

	private var _downloadTask: NSURLSessionTask? {
		get { return objc_getAssociatedObject(some, &AssociatedKeys.Task) as? NSURLSessionTask
		}
		set(val) { objc_setAssociatedObject(some, &AssociatedKeys.Task, val, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
	}

	func ss_imageForCache(URL: NSURL!) {
		guard let value = URL else { return }
		let request = NSURLRequest(URL: value, cachePolicy: .UseProtocolCachePolicy, timeoutInterval: 20)
		if let d = NSURLCache.sharedURLCache().cachedResponseForRequest(request)?.data, img = UIImage(data: d) {
			if let layer = ss_imageFillTarget.0 {
				layer.contents = img.CGImage
			} else if let imgv = ss_imageFillTarget.1 {
				imgv.image = img
			}
		}
	}

	func ss_setImageBy(URLString: String) {
		guard let value = NSURL(string: URLString) else { return }
		ss_imageWith(value)
	}

	func ss_imageWith(URL: NSURL!, complete: ((UIImage) -> Void)? = nil) {
		_downloadTask?.cancel()
		guard let value = URL else { return }
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
			let request = NSURLRequest(URL: value, cachePolicy: .UseProtocolCachePolicy, timeoutInterval: 20)
			let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { [weak self](data, _, _) in
				if let d = data, img = UIImage(data: d)?.decoded, sself = self {
					dispatch_async(dispatch_get_main_queue(), { () -> Void in
						if let layer = sself.ss_imageFillTarget.0 {
							layer.contents = img.CGImage
						} else if let imgv = sself.ss_imageFillTarget.1 {
							imgv.image = img
						}
						complete?(img)
					})
				}
			}
			task.resume()
			self._downloadTask = task
		})
	}
}

extension UIImage {
	var decoded: UIImage {
		let imageRef = self.CGImage
		let colorSpace = CGColorSpaceCreateDeviceRGB()
		let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedLast.rawValue).rawValue
		let context = CGBitmapContextCreate(nil, CGImageGetWidth(imageRef), CGImageGetHeight(imageRef), 8, 0, colorSpace, bitmapInfo)
		if let context = context {
			let rect = CGRect(x: 0, y: 0, width: CGImageGetWidth(imageRef), height: CGImageGetHeight(imageRef))
			CGContextDrawImage(context, rect, imageRef)
			let decompressedImageRef = CGBitmapContextCreateImage(context)
			return UIImage(CGImage: decompressedImageRef!, scale: scale, orientation: imageOrientation)
		} else {
			return self
		}
	}
}
