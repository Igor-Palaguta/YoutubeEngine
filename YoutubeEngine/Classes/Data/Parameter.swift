import Foundation

protocol Parameter {
   var parameterValue: String { get }
}

extension String: Parameter {
   var parameterValue: String {
      return self
   }
}

extension SequenceType where Generator.Element: Parameter {
   func joinParameters() -> String {
      return self.map { $0.parameterValue }.joinWithSeparator(",")
   }
}
