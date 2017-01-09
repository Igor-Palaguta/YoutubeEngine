import Foundation

protocol Parameter {
   var parameterValue: String { get }
}

extension String: Parameter {
   var parameterValue: String {
      return self
   }
}

extension Sequence where Iterator.Element: Parameter {
   func joinParameters() -> String {
      return self.map { $0.parameterValue }.joined(separator: ",")
   }
}
