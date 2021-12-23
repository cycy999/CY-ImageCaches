//
//  ImageCaches.swift
//  CY-ImageCaches
//
//  Created by YanChen on 2021/12/23.
//

import UIKit

enum ImageCacheType {
    case networking
    case disk //磁盘中读出
    case memory //内存中读出
}

//负责在memory与disk存储
class ImageCaches: NSObject {

    var imageDataCache = NSCache<NSString, NSData>()
    
    static let shared = ImageCaches()
    
    //根据图片名获取图片缓存路径
    func filePathForKey(fileName: String) -> String {
        guard let path = ImageCaches.getCachesImagePath() else {
            return ""
        }
        return path + "/" + fileName
    }
}

extension ImageCaches {
    func writeImageData(data: Data, fileName: String) {
        self.imageDataCache.setObject(data as NSData, forKey: fileName as NSString)
        let filePath = filePathForKey(fileName: fileName)
        FileManager.default.createFile(atPath: filePath, contents: data, attributes: nil)
    }
    
    //将下载的图片   从原始地址移动到 image文件夹
    func moveImageDataName(fileName: String?, atUrl url: URL?) -> Bool {
        guard let fileName = fileName else {
            return false
        }
        guard let url = url else {
            return false
        }

        do {
            let data = try Data(contentsOf: url)
            imageDataCache.setObject(data as NSData, forKey: fileName as NSString)
            let filePath = filePathForKey(fileName: fileName)
            let filePathUrl = URL(fileURLWithPath: filePath)
            print("======:\(filePath)")
            return (try? FileManager.default.moveItem(at: url, to: filePathUrl)) != nil
        } catch {
            return false
        }
    }
    
    // 根据图片名读取缓存数据
    func readDataForKey(fileName: String) -> Data? {
        if let memoryData = imageDataCache.object(forKey: fileName as NSString) {
            return memoryData as Data
        }
        let filePath = filePathForKey(fileName: fileName)
        if let fileData = FileManager.default.contents(atPath: filePath) {
            imageDataCache.setObject(fileData as NSData, forKey: fileName as NSString)
            return fileData
        }
        return nil
    }
    
    func readFileAsync(fileName: String, complete: @escaping (Data?, ImageCacheType) -> Void) {
        if let memoryData = imageDataCache.object(forKey: fileName as NSString) {
            complete(memoryData as Data, .memory)
            return
        }
        let filePath = filePathForKey(fileName: fileName)
        if let fileData = FileManager.default.contents(atPath: filePath) {
            imageDataCache.setObject(fileData as NSData, forKey: fileName as NSString)
            complete(fileData as Data, .disk)
            return
        }
        complete(nil, .disk)
    }
}

extension ImageCaches {
    // 获得缓存图片的文件夹
    class func getCachesImagePath() -> String? {
        guard let filePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first else {
            return nil
        }
        let imagesPath = filePath.appending("/Images")
        
        if FileManager.default.fileExists(atPath: imagesPath) {
            return imagesPath
        }
    
        guard let result = try? FileManager.default.createDirectory(atPath: imagesPath, withIntermediateDirectories: true, attributes: nil) else {
            return nil
        }
        print("=====getCachesImagePath:",result)
        return imagesPath
    }
    
    class func clearCachesImage() {
        guard let path = ImageCaches.getCachesImagePath() else {
            return
        }
        do {
            //删除文件夹
            try FileManager.default.removeItem(atPath: path)
            //创建
            _ = ImageCaches.getCachesImagePath()
        } catch {
            print(error)
        }
    }
}
