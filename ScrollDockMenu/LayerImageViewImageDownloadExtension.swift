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

	fileprivate var some: AnyObject {
		return ss_imageFillTarget.0 ?? ss_imageFillTarget.1!
	}

	fileprivate var _downloadTask: URLSessionTask? {
		get { return objc_getAssociatedObject(some, &AssociatedKeys.Task) as? URLSessionTask
		}
		set(val) { objc_setAssociatedObject(some, &AssociatedKeys.Task, val, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
	}

	func ss_imageForCache(_ URL: Foundation.URL!) {
		guard let value = URL else { return }
		let request = URLRequest(url: value, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 20)
		if let d = URLCache.shared.cachedResponse(for: request)?.data, let img = UIImage(data: d) {
			if let layer = ss_imageFillTarget.0 {
				layer.contents = img.cgImage
			} else if let imgv = ss_imageFillTarget.1 {
				imgv.image = img
			}
		}
	}

	func ss_setImageBy(_ URLString: String) {
		guard let value = URL(string: URLString) else { return }
		ss_imageWith(value)
	}

	func ss_imageWith(_ URL: Foundation.URL!, complete: ((UIImage) -> Void)? = nil) {
		_downloadTask?.cancel()
		guard let value = URL else { return }
        DispatchQueue.global(qos: .default).async {
			let request = URLRequest(url: value, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 20)
			let task = URLSession.shared.dataTask(with: request, completionHandler: { [weak self](data, _, _) in
				if let d = data, let img = UIImage(data: d)?.decoded, let sself = self {
					DispatchQueue.main.async(execute: { () -> Void in
						if let layer = sself.ss_imageFillTarget.0 {
							layer.contents = img.cgImage
						} else if let imgv = sself.ss_imageFillTarget.1 {
							imgv.image = img
						}
						complete?(img)
					})
				}
			}) 
			task.resume()
			self._downloadTask = task
		}
	}
}

extension UIImage {
	var decoded: UIImage {
		let imageRef = self.cgImage
		let colorSpace = CGColorSpaceCreateDeviceRGB()
		let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue).rawValue
		let context = CGContext(data: nil, width: (imageRef?.width)!, height: (imageRef?.height)!, bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo)
		if let context = context {
			let rect = CGRect(x: 0, y: 0, width: (imageRef?.width)!, height: (imageRef?.height)!)
			context.draw(imageRef!, in: rect)
			let decompressedImageRef = context.makeImage()
			return UIImage(cgImage: decompressedImageRef!, scale: scale, orientation: imageOrientation)
		} else {
			return self
		}
	}
}
