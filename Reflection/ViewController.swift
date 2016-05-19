//
//  ViewController.swift
//  Reflection
//
//  Created by Jiaqiang on 16/5/18.
//  Copyright © 2016 Whisper. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        api.fetch_book("1220562") { (book) in
            print("success -> \(book)")
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

