import UIKit


public func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    #if DEBUG
        Swift.print(items[0], separator:separator, terminator: terminator)
    #endif
}

public func DLog(message: String, function: String = #function) {
    #if DEBUG
        print("\(function): \(message)")
    #endif
}

public enum DisplayType {
    case unknown
    case iphone4
    case iphone5
    case iphone6
    case iphone6plus
    case iphoneX
    case iphone11ProMax
    case iphone11Pro
    case iPad
    static let iphone7 = iphone6
    static let iphone7plus = iphone6plus
    static let iphone8 = iphone6
    static let iphone8plus = iphone6plus
}

public final class Display {
    class var width:CGFloat { return UIScreen.main.bounds.size.width }
    class var height:CGFloat { return UIScreen.main.bounds.size.height }
    class var maxLength:CGFloat { return max(width, height) }
    class var minLength:CGFloat { return min(width, height) }
    class var zoomed:Bool { return UIScreen.main.nativeScale >= UIScreen.main.scale }
    class var retina:Bool { return UIScreen.main.scale >= 2.0 }
    class var phone:Bool { return UIDevice.current.userInterfaceIdiom == .phone }
    class var pad:Bool { return UIDevice.current.userInterfaceIdiom == .pad }
    
    class var typeIsLike:DisplayType {
        if phone && maxLength < 568 {
            return .iphone4
        }
        else if phone && maxLength == 568 {
                return .iphone5
        }
        else if phone && maxLength == 667 {
            return .iphone6
        }
        else if phone && maxLength == 736 {
            return .iphone6plus
        }
        else if phone && maxLength == 812 {
            return .iphone11Pro
        }
        else if phone && maxLength == 896 {
            return .iphoneX
        }
        else if phone && maxLength == 926 {
            return .iphoneX
        }
        else if pad && maxLength == 1024 || pad && maxLength == 1366 || pad && maxLength == 1194 || pad && maxLength == 1112 || pad && maxLength == 1080{
            return .iPad
        }
        return .iphone6plus//.unknown
    }
}
