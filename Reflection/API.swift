//
//  API.swift
//  Reflection
//
//  Created by Jiaqiang on 16/5/18.
//  Copyright © 2016 Whisper. All rights reserved.
//

import Foundation
import Alamofire

let api = API()

class API {
    let host = "https://api.douban.com/v2/"
    
    func commonEP(api:String) -> String{
        let url = "\(host)\(api)"
        print("request url-> \(url)")
        
        return url
    }
    
    
    func fetch_book(bookId: String, onSuccess: Book -> Void, onFail: NSError -> Void) {
        let endpoint = commonEP("book/\(bookId)")
        
        Alamofire.request(.GET, endpoint).responseJSON { (response) in
            if response.result.isSuccess {
                
                // Get dictionary of json
                let jsonDict = try! NSJSONSerialization.JSONObjectWithData(response.data!, options: [])
                
                // Convert to object
                let book = Book.parse(jsonDict as! NSDictionary)
                // Convert to object array
                let tags = Tag.parses(jsonDict["tags"] as! NSArray)
                print("tags -> \(tags.description)")
                
                onSuccess(book)
            }
        }
        
    }

}
