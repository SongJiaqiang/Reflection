//
//  ReflectionHelpers.swift
//  Reflection
//
//  Created by Jiaqiang on 16/5/18.
//  Copyright © 2016 Whisper. All rights reserved.
//

import Foundation

let logTitle = "[Reflection: ]"

extension String {
    
    func replace(target: String, withString: String) -> String {
        return (self as NSString).stringByReplacingOccurrencesOfString(target, withString: withString)
    }
    
    func deleteSpecialCharactor() -> String {
        return self.replace("Optional<", withString: "").replace(">", withString: "")
    }
    
    func getRawValueFromOptionalString() -> String {
        return self.replace("Optional(", withString: "").replace(")", withString: "").replace("\"", withString: "")
    }
    
    func dictionaryFromJson() -> NSDictionary {
        var result = NSDictionary()
        if self.isEmpty {
            return result
        }
        if let jsonData = self.dataUsingEncoding(NSUTF8StringEncoding) {
            do {
                if let jsonDict = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary {
                    result = jsonDict
                }
            } catch let error as NSError {
                print("\(logTitle)Convert json string failed with error: \(error)")
            }
        }
        return result
    }
}

    
func SwiftClassFromString(className: String) -> AnyClass? {
    
    if let c = NSClassFromString(className) {
        return c
    }
    
    if className.rangeOfString(".", options: NSStringCompareOptions.CaseInsensitiveSearch) == nil {
        let appName = CleanAppName()
        if let c = NSClassFromString("\(appName).\(className)") {
            return c
        }
    }
    return nil
}

func CleanAppName(forObject: NSObject? = nil) -> String {
    var bundle = NSBundle.mainBundle()
    if let _ = forObject {
        bundle = NSBundle(forClass: forObject!.dynamicType)
    }
    
    var appName = bundle.infoDictionary?["CFBundleName"] as? String ?? ""
    if appName == "" {
        appName = (bundle.bundleIdentifier!).characters.split(isSeparator: {
            $0 == "."
        }).map({
            String($0)
        }).last ?? ""
    }
    let cleanAppName = appName.replace(" ", withString: "_").replace("-", withString: "_")
    
    return cleanAppName
}

