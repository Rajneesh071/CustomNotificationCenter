/*
 Playground to implement your own custom notification center
 Playground to implement your own custom NSNotification center
 It can work for any class, If you want to use it for any other type
 you can remove AnyClass
 */

import UIKit

protocol MyNotificationCenterProtocol {
    func addSubscribers(_ myClass:Any, notificationName:String, closure:@escaping (String, Any)->Void)
    func postNotification(_ name:String, object:Any) throws
    func removeSubscribers(_ myClass:Any) throws
}

class MyNotificationCenter : MyNotificationCenterProtocol {
    
    static let shared = MyNotificationCenter()
    private var subscribers : [String: [String : [(String, Any)->Void]]]
    
    private init() {
        subscribers = [:]
    }
    
    func addSubscribers(_ myClass: Any, notificationName: String, closure: @escaping (String, Any) -> Void) {
        //we will accept only class
        guard let inputClass = type(of: myClass) as? AnyClass else {
            return
        }
        
        let className = String(describing: inputClass)
        
        if subscribers[className] == nil {
            subscribers[className] = [notificationName : [closure]]
        } else if subscribers[className]?[notificationName] == nil {
            subscribers[className]?[notificationName] = [closure]
        } else {
            subscribers[className]?[notificationName]?.append(closure)
        }
    }
    
    func postNotification(_ name:String, object:Any) throws {
        var foundNotification =  false
        for (_ , value) in subscribers {
            for (notificationName, closures) in value {
                
                
                guard notificationName == name else { continue }
                closures.forEach { closure in
                    foundNotification = true
                    closure(notificationName, object)
                }
            }
        }
        if !foundNotification {
            throw MyNotificationCenterError.NotificationNotFound
        }
    }
    
    func removeSubscribers(_ myClass:Any) throws {
        guard let inputClass = type(of: myClass) as? AnyClass else {
            return
        }
        let className = String(describing: inputClass)
        guard let _ = subscribers.removeValue(forKey: className) else {
            throw MyNotificationCenterError.SubscribersNotFound
        }
    }
}

enum MyNotificationCenterError : Error {
    case NotificationNotFound
    case SubscribersNotFound
}



class MyClass {
    init() {
        MyNotificationCenter.shared.addSubscribers(self, notificationName: "one") { (name, object) in
            print(name)
            print(object)
        }
        
        MyNotificationCenter.shared.addSubscribers(self, notificationName: "two") { (name, object) in
            print(name)
            print(object)
        }
    }
    func postNotification()  {
        do {
            try MyNotificationCenter.shared.postNotification("one", object: "Hello")
            try MyNotificationCenter.shared.postNotification("two", object: "Hello")
            
        } catch MyNotificationCenterError.NotificationNotFound {
            print("Notification not found ")
        } catch {
            print("Unexpected Result")
        }
    }
    func removeSubscribers()  {
        do {
            try MyNotificationCenter.shared.removeSubscribers(self)
        } catch MyNotificationCenterError.SubscribersNotFound {
            print("Subscriber Not Found")
        } catch {
            print("Unexpected Result")
        }
    }
}

let classObject = MyClass()
classObject.removeSubscribers()
classObject.removeSubscribers()
