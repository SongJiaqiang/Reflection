//
//  Reflection.swift
//  Reflection
//
//  Created by Jiaqiang on 16/5/18.
//  Copyright © 2016 Whisper. All rights reserved.
//

import UIKit

//MARK: Basic
class Reflection: NSObject, NSCoding {

    lazy var mirror: Mirror = {Mirror(reflecting: self)}()
    
    required override init() {
        super.init()
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        
        self.properties {(name, type, value) in
            assert(type.check(), "\(logTitle)Property '\(name)' type can not be a '\(type.realType.rawValue)' Type, Pleace use 'NSNumber' instead!")
            if let hasValue = self.ignoreCodingPropertiesForCoding() {
                print("aDecoder: \(name), \(aDecoder.decodeObjectForKey(name))")
                if !hasValue.contains(name) {
                    self.setValue(aDecoder.decodeObjectForKey(name), forKeyPath: name)
                }
            }else {
                self.setValue(aDecoder.decodeObjectForKey(name), forKeyPath: name)
            }
        }
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        self.properties { (name, type, value) in
            if let hasValue = self.ignoreCodingPropertiesForCoding() {
                if !hasValue.contains(name) {
                    aCoder.encodeObject(value as? AnyObject, forKey: name)
                }
            }else {
                if type.isArray {
                    if type.isReflection {
                        aCoder.encodeObject(value as? NSArray, forKey: name)
                    }else {
                        aCoder.encodeObject(value as? AnyObject, forKey: name)
                    }
                }else {
                    let realValue = (value as! String).getRawValueFromOptionalString()
                    aCoder.encodeObject(realValue, forKey: name)
                }
            }
        }
    }
    
    class func parseAggragateArray<T>(arrDict: NSArray, basicType: BasicType, instance: T) -> [T] {
        var objectsArray = [T]()
        
        if arrDict.count == 0 {
            return objectsArray
        }
        
        for (_, value) in arrDict.enumerate() {
            var element: T = instance
            
            if T.self is Int.Type {
                element = NSNumber(longLong: Int64(value as! String)!) as! T
            }else if T.self is Float.Type {
                element = NSNumber(float: Float(value as! String)!) as! T
            }else if T.self is Double.Type {
                element = NSNumber(double: Double(value as! String)!) as! T
            }else if T.self is NSNumber.Type {
                element = NSNumber(double: Double(value as! String)!) as! T
            }else {
                element = value as! T
            }
            
            objectsArray.append(element)
        }
        return objectsArray
    }
    
    func properties(property: (name: String, type: ReflectType, value: Any) -> Void) {
        for p in mirror.children {
            let pName = p.label
            let pValue = p.value
            
            let reflectType = ReflectType(propertyMirrorType: Mirror(reflecting: pValue), belongType: self.dynamicType)
            
            property(name: pName!, type: reflectType, value: pValue)
        }
    }
    
    func ignoreCodingPropertiesForCoding() -> [String]? {return nil}
    func ignorePropertiesForParse() -> [String]? {return nil}
    func mappingDict() -> [String:String]? {return nil}
    
}

//MARK: Parse functions
extension Reflection {
    /**
     @desc:
        Convert to object
     @params
        arr: dictionary
     */
    class func parse(dict: NSDictionary) -> Self {
        // new a model instance
        let model = self.init()
        
        // get mapping list
        let mappingDict = model.mappingDict()
        // get ignore property list
        let ignoreProperties = model.ignorePropertiesForParse()
        model.properties { (name, type, value) in
            let dataDictHasKey = dict[name] != nil
            let mappingDictHasKey = mappingDict?[name] != nil
            let needIgnore = ignoreProperties == nil ? false : ignoreProperties?.contains(name)
            
            if (dataDictHasKey || mappingDictHasKey) && !(needIgnore!) {
                let key  = mappingDictHasKey ? mappingDict![name] : name
                if !type.isArray {
                    if !type.isReflection {
                        if type.typeClass == Bool.self {
                            model.setValue(dict[key!]?.boolValue, forKeyPath: name)
                        }else {
                            model.setValue(dict[key!], forKeyPath: name)
                        }
                    }else {
                        if let _ = dict[key!] {
                            if let _ = model.valueForKeyPath(key!) {
                                model.setValue((type.typeClass as! Reflection.Type).parse(dict[key!] as! NSDictionary), forKeyPath: name)
                            }else {
                                if let cls = SwiftClassFromString(type.typeName) {
                                    model.setValue((cls as! Reflection.Type).parse(dict[key!] as! NSDictionary), forKeyPath: name)
                                }
                            }
                        }
                    }
                }else {
                    if let res = type.isAggragate() {
                        var arrAggragate = []
                        
                        if res is Int.Type {
                            arrAggragate = parseAggragateArray(dict[key!] as! NSArray, basicType: BasicType.Int, instance: 0)
                        }else if res is Float.Type {
                            arrAggragate = parseAggragateArray(dict[key!] as! NSArray, basicType: BasicType.Float, instance: 0.0)
                        }else if res is Double.Type {
                            arrAggragate = parseAggragateArray(dict[key!] as! NSArray, basicType: BasicType.Double, instance: 0.0)
                        }else if res is String.Type {
                            arrAggragate = parseAggragateArray(dict[key!] as! NSArray, basicType: BasicType.String, instance: "")
                        }else if res is NSNumber.Type {
                            arrAggragate = parseAggragateArray(dict[key!] as! NSArray, basicType: BasicType.Int, instance: NSNumber())
                        }
                        model.setValue(arrAggragate, forKeyPath: name)
                    } else {
                        let elementModelType = ReflectType.generateClass(type) as! Reflection.Type
                        let dictKeys = dict[key!] as! NSArray
                        var models = [Reflection]()
                        
                        for (_, value) in dictKeys.enumerate() {
                            let elementModel = elementModelType.parse(value as! NSDictionary)
                            models.append(elementModel)
                        }
                        model.setValue(models, forKeyPath: name)
                    }
                }
            }
        }
        return model
    }
    
    /** 
     @desc:
        Convert to object array
     @params
        arr: dictionary list
     */
    class func parses(arr: NSArray) -> [Reflection] {
        var models = [Reflection]()
        for (_, dict) in arr.enumerate() {
            let model = self.parse(dict as! NSDictionary)
            models.append(model)
        }
        return models
    }
    
}


