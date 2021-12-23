//
//  ImageFileManager.swift
//  CY-ImageCaches
//
//  Created by YanChen on 2021/12/23.
//

import UIKit

class ImageFileManager: NSObject {
    
    static let queueName = "fileManagerQueue"
    private var queue: DispatchQueue?
    
    static let shared = ImageFileManager()

    func readFile(path: String) -> Data? {
        if FileManager.default.fileExists(atPath: path) {
            return FileManager.default.contents(atPath: path)
        }
        return nil
    }
    
    func readFileAsync(path: String, complete: @escaping (Data?) -> Void) {
        guard FileManager.default.fileExists(atPath: path) else {
            complete(nil)
            return
        }
        print("======\(path)")
        let data = FileManager.default.contents(atPath: path)
        complete(data)
    }
    
    func writeFile(path: String, data: Data) -> Bool {
        if FileManager.default.fileExists(atPath: path) {
            try? FileManager.default.removeItem(atPath: path)
        }
        return FileManager.default.createFile(atPath: path, contents: data, attributes: nil)
    }
    
    
    func writeFileAsync(path: String, data: Data, complete: @escaping (Bool) -> Void) {
        if FileManager.default.fileExists(atPath: path) {
            try? FileManager.default.removeItem(atPath: path)
        }
        let result = FileManager.default.createFile(atPath: path, contents: data, attributes: nil)
        complete(result)
    }
}
