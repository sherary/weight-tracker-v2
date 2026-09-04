import Foundation
import SwiftData

final class WidgetStore {
    static let key = WidgetConfigs.stepperKey
    static let suiteName = WidgetConfigs.groupName
    
    static var value: Double {
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            return 0
        }
        
        return defaults.double(forKey: key)
    }
    
    static func set(value: Double) {
        guard let defaults = UserDefaults(suiteName: suiteName) else { return }
        
        defaults.set(value, forKey: key)
    }
}
