import Foundation

public enum Part: String, Parameter, CaseIterable {
    case snippet
    case contentDetails
    case statistics

    var parameterValue: String {
        return rawValue
    }
}
