import Foundation

public enum Part: String, RequestParameterRepresenting, CaseIterable {
    case snippet
    case contentDetails
    case statistics
}
