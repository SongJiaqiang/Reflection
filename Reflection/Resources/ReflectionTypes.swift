//
//  ReflectionTypes.swift
//  Reflection
//
//  Created by Jiaqiang on 16/5/18.
//  Copyright © 2016 Whisper. All rights reserved.
//

import Foundation

enum BasicType {
    case String
    case Int
    case Float
    case Double
    case Bool
    case NSNumber
}

enum RealType: String {
    case None = "None"
    case Int = "Int"
    case Float = "Float"
    case Double = "Double"
    case String = "String"
    case Bool = "Bool"
    case Class = "Class"
}

let basicTypes = ["String", "Int", "Float", "Double", "Bool"]
let extraTypes = ["__NSCFNumber", "_NSContiguousString", "NSTaggedPointerString"]
let sdkTypes = ["__NSCFNumber", "NSNumber", "_NSContiguousString", "UIImage", "_NSZeroData"]
let aggragateTypes: [String:Any.Type] = [
    "String" : String.self,
    "Int" : Int.self,
    "Float" : Float.self,
    "Double" : Double.self,
    "Bool" : Bool.self,
    "NSNumber" : NSNumber.self
]

class ReflectType {
    
    var typeName: String!
    var typeClass: Any.Type!
    var displayStyle: Mirror.DisplayStyle!
    var displayStyleDesc: String!
    var belongType: Any.Type!
    
    var isOptional: Bool = false
    var isArray: Bool = false
    var isReflection: Bool = false
    var realType: RealType = .None
    
    private var propertyMirrorType: Mirror
    
    init(propertyMirrorType: Mirror, belongType: Any.Type) {
        self.propertyMirrorType = propertyMirrorType
        self.belongType = belongType
        
        parseBegin()
    }
    
    func parseBegin() {
        parseTypeName()
        parseTypeClass()
        parseTypeDisplayStyle()
        parseTypeDisplayStyleDesc()
    }
    
    func parseTypeName() {
        typeName = "\(propertyMirrorType.subjectType)".deleteSpecialCharactor()
    }
    
    func parseTypeClass() {
        typeClass = propertyMirrorType.subjectType
    }
    
    func parseTypeDisplayStyle() {
        displayStyle = propertyMirrorType.displayStyle
        
        guard let _ = displayStyle else {
            if basicTypes.contains(typeName) {
                displayStyle = .Struct
            }
            return
        }
        
        if extraTypes.contains(typeName) {
            displayStyle = .Struct
        }
    }
    
    func parseTypeDisplayStyleDesc() {
        guard let _ = displayStyle else {
            return
        }
        
        switch displayStyle! {
        case .Struct:
            displayStyleDesc = "Struct"
            break
        case .Class:
            displayStyleDesc = "Class"
            break
        case .Optional:
            displayStyleDesc = "Optional"
            isOptional = true
            break
        case .Enum:
            displayStyleDesc = "Enum"
            break
        case .Tuple:
            displayStyleDesc = "Tuple"
            break
        default:
            displayStyleDesc = "Other: Collection/Dictionary/Set"
        }
        
        fetchRealType()
    }
    
    func fetchRealType() {
        if typeName.containsString("Array") {
            isArray = true
        }
        
        if typeName.containsString("Int") {
            realType = RealType.Int
        }else if typeName.containsString("Float") {
            realType = RealType.Float
        }else if typeName.containsString("Double") {
            realType = RealType.Double
        }else if typeName.containsString("String") {
            realType = RealType.String
        }else if typeName.containsString("Bool") {
            realType = RealType.Bool
        }else {
            realType = RealType.Class
        }
        
        if realType == .Class && !sdkTypes.contains(typeName) {
            isReflection = true
        }
    }
    
    class func generateClass(type: ReflectType) -> AnyClass {
        let arrayString = type.typeName
        let classString = arrayString.replace("Array<", withString: "").replace("Optional<", withString: "").replace(">", withString: "")
        var classInstance: AnyClass? = SwiftClassFromString(classString)
        
        guard let _ = classInstance else {
            if type.isReflection {
                let nameSpaceString = "\(type.belongType).\(classString)"
                classInstance = SwiftClassFromString(nameSpaceString)
            }
            return classInstance!
        }
        return classInstance!
    }
    
    func isAggragate() -> Any? {
        var res: Any! = nil
        for (typeString, type) in aggragateTypes {
            if typeName.containsString(typeString) {
                res = type
            }
        }
        return res
    }
    
    func check() -> Bool {
        if isArray {
            return true
        }
        
        return realType != RealType.Int && realType != RealType.Float && realType != RealType.Double
    }
    
}