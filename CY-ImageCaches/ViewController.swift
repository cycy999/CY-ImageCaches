//
//  ViewController.swift
//  CY-ImageCaches
//
//  Created by YanChen on 2021/12/23.
//

import UIKit

class ViewController: UIViewController {

    var imageView: UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        imageView = UIImageView()
        imageView?.backgroundColor = UIColor.cyan
        view.addSubview(imageView!)
        imageView?.frame = CGRect(x: 0, y: 100, width: 300, height: 240)
        imageView?.setImageWithUrl(url: "https://august-app-resources.s3-us-west-2.amazonaws.com/images/1.png", placeholderImageName: nil)
        
        /// 从缓存读取尝试一次
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.imageView?.setImageWithUrl(url: "https://august-app-resources.s3-us-west-2.amazonaws.com/images/1.png", placeholderImageName: nil)
        }
    }

    

}

extension UIImageView {
    func setImageWithUrl(url: String, placeholderImageName: String?) {
        if let placeholderImageName = placeholderImageName {
            self.image = UIImage.init(named: placeholderImageName)
        }
        let loader = ImageLoader()
        loader.loadImageWithUrl(url: URL(string: url)!) { data, error, type, result, imageUrl in
            print("========\(type)")
            if result {
                guard let data = data else {
                    return
                }
                DispatchQueue.main.async {
                    self.image = UIImage.init(data: data)
                }
            }
        }
    }
}
