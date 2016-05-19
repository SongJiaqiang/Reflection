//
//  Models.swift
//  Reflection
//
//  Created by Jiaqiang on 5/18/16.
//  Copyright © 2016 Whisper. All rights reserved.
//

import Foundation


class Book: Reflection {
    var id: NSNumber?
    var title: String?
    var summary: String?
    var url: String?
    var price: String?
    var images: Image?
    var tags: [Tag]?
    var authorIntro: String?
    
    override func mappingDict() -> [String : String]? {
        return ["authorIntro":"author_intro"]
    }
}


class Image: Reflection {
    var small: String?
    var large: String?
    var medium: String?
}


class Tag:Reflection {
    var count: NSNumber?
    var name: String?
    var title: String?
}