import Foundation

protocol RequestParameterRepresenting {
    var requestParameterValue: String { get }
}

extension String: RequestParameterRepresenting {
    var requestParameterValue: String {
        return self
    }
}

extension RequestParameterRepresenting where Self: RawRepresentable, RawValue == String {
    var requestParameterValue: String {
        return rawValue
    }
}

extension Array: RequestParameterRepresenting where Element: RequestParameterRepresenting {
    var requestParameterValue: String {
        return map { $0.requestParameterValue }.joined(separator: ",")
    }
}
