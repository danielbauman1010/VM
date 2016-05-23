import Foundation
class Tokenizer {
    
}
enum TokenType {
    case Register
    case LabelDefinition
    case Label
    case ImmediateString
    case ImmediateInteger
    case ImmediateTuple
    case Instruction
    case Directive
    case BadToken
}
struct Token: CustomStringConvertible {
    let type: TokenType
    let intValue: Int?
    let stringValue: String?
    let tupleValue: Tuple?
    var description: String {
        var output: String = ""
        switch type{
        case .Directive: output += "Directive"
        case .ImmediateInteger: output += "Immediate Integer: \(intValue!)"
        case .ImmediateString: output += "Immediate String: \(stringValue!)"
        case .Instruction: output += "Instruction"
        case .LabelDefinition: output += "Label Definition"
        case .Label: output += "Label"
        case .ImmediateTuple: output += "Tuple: \(tupleValue!)"
        case .Register: output += "Register"
        default: output += "Bad Token"
        }
        return output
    }
}
struct Tuple {
    
}