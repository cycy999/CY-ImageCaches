//
//  ImageLoader.swift
//  CY-ImageCaches
//
//  Created by YanChen on 2021/12/23.
//

import UIKit

class ImageLoader: NSObject {

    func loadImageWithUrl(url: URL, complete:@escaping (Data?, Error?, ImageCacheType, Bool, URL) -> Void) {
        //判断本地之前是否缓存过该图片
        let imageCache = ImageCaches.shared
        imageCache.readFileAsync(fileName: url.lastPathComponent) { [self] data, type in
            if let data = data {
                complete(data, nil, type, true, url)
            } else {
                downloadImageFromNetworkWithUrl(url: url, complete: complete)
            }
        }
    }
    
    // 网络加载图片
    func downloadImageFromNetworkWithUrl(url: URL, complete:@escaping (Data?, Error?, ImageCacheType, Bool, URL) -> Void) {
        let downloadTask = URLSession.shared.downloadTask(with: url) {
            locationUrl, response, error in
            if let error = error {
                complete(nil, error, .networking, false, url)
                return
            }
            guard let data = try? Data.init(contentsOf: url) else {
                complete(nil, error, .networking, false, url)
                return
            }
            let result = ImageCaches.shared.moveImageDataName(fileName: response?.url?.lastPathComponent, atUrl: locationUrl)
            print("read image to location result: \(result)")
            complete(data, nil, .networking, true, url)
        }
        downloadTask.resume()
    }
}
