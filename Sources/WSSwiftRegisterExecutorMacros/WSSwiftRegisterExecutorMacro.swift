import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// Implementation of the `stringify` macro, which takes an expression
/// of any type and produces a tuple containing the value of that expression
/// and the source code that produced the value. For example
///
///     #stringify(x + y)
///
///  will expand to
///
///     (x + y, "x + y")
//public struct StringifyMacro: ExpressionMacro {
//    public static func expansion(
//        of node: some FreestandingMacroExpansionSyntax,
//        in context: some MacroExpansionContext
//    ) -> ExprSyntax {
//        guard let argument = node.arguments.first?.expression else {
//            fatalError("compiler bug: the macro does not have any arguments")
//        }
//
//        return "(\(argument), \(literal: argument.description))"
//    }
//}

enum WSMacroError: Error, CustomStringConvertible {
  case invalidArgumentCount
  case missingTaskName
  case missingTaskOptions
  case missingExecutorClosure
  case invalidOptionsArgument
  
  var description: String {
    switch self {
      case .invalidArgumentCount:
        return "missing argument"
      case .missingTaskName:
        return "missing taskName argument"
      case .missingTaskOptions:
        return "missing taskOptions argument"
      case .missingExecutorClosure:
        return "missing executor closure"
      case .invalidOptionsArgument:
        return "missing or invalid taskOptions argument"
    }
  }
}

public struct WSSwiftRegisterExecutor: DeclarationMacro {
  public static func expansion(of node: some SwiftSyntax.FreestandingMacroExpansionSyntax, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
    let arguments = node.arguments
    
    guard arguments.count == 2 else {
      throw WSMacroError.invalidArgumentCount
    }
    
    guard let trailingClosure = node.trailingClosure else {
      throw WSMacroError.missingExecutorClosure
    }
    
    let nameExpr = arguments[arguments.index(at: 0)].expression
    guard let stringLiteral = nameExpr.as(StringLiteralExprSyntax.self),
          let taskName = stringLiteral.representedLiteralValue,
          !taskName.isEmpty else {
      throw WSMacroError.missingTaskName
    }
    
    let optionsExpr = arguments[arguments.index(at: 1)].expression
    guard let optionsCallExpr = optionsExpr.as(FunctionCallExprSyntax.self), optionsCallExpr.argumentCount >= 2 else {
      throw WSMacroError.invalidOptionsArgument
    }
    
    guard let period = optionsCallExpr.wsArgValue("period")?.wsSwiftPeriod,
          let priority = optionsCallExpr.wsArgValue("priority")?.wsSwiftPriority else {
      throw WSMacroError.invalidOptionsArgument
    }
    
    let group = optionsCallExpr.wsArgValue("group")
    let targetClass = optionsCallExpr.wsArgValue("targetClass")
    let delayTime = optionsCallExpr.wsArgValue("delayTime") ?? "0"
    let timeout = optionsCallExpr.wsArgValue("timeout") ?? "0"
    let flags = optionsCallExpr.wsArgValue("flags") ?? "0"
    
    let taskNameStorage = context.makeUniqueName("__var_taskName")
    let groupStorage = context.makeUniqueName("__var_group")
    let targetClassStorage = context.makeUniqueName("__var_targetClass")
    let taskDescriptor = context.makeUniqueName("__descriptor_\(taskName)")
    
    let nameDecl: DeclSyntax = """
    fileprivate let \(raw: taskNameStorage): UnsafePointer<CChar> = UnsafePointer(strdup("\(raw: taskName)")!)
    """
    
    var groupDecl: DeclSyntax
    if let group = group, !group.isEmpty {
      groupDecl = """
    fileprivate let \(raw: groupStorage): UnsafePointer<CChar>? = UnsafePointer(strdup("\(raw: group)")!)
    """
    } else {
      groupDecl = """
    fileprivate let \(raw: groupStorage): UnsafePointer<CChar>? = nil
    """
    }
    
    var targetClassDecl: DeclSyntax
    if let targetClass = targetClass, !targetClass.isEmpty {
      targetClassDecl = """
    fileprivate let \(raw: targetClassStorage): UnsafePointer<CChar>? = UnsafePointer(strdup("\(raw: targetClass)")!)
    """
    } else {
      targetClassDecl = """
    fileprivate let \(raw: targetClassStorage): UnsafePointer<CChar>? = nil
    """
    }
    
    var closureExpr  = ExprSyntax(trailingClosure)
    let firstLocation = trailingClosure.statements.first.flatMap { statement in
      context.location(
        of: statement,
        at: .afterLeadingTrivia,
        filePathMode: .filePath
      )
    }
    
    let mappedStatements = CodeBlockItemListSyntax {
      if let firstLocation {
        "#sourceLocation(file: \(firstLocation.file), line: \(firstLocation.line))"
      }
      
      for statement in trailingClosure.statements {
        statement
      }
      
      if firstLocation != nil {
        "#sourceLocation()"
      }
    }
    
    var mappedClosure = trailingClosure
    mappedClosure.statements = mappedStatements
    closureExpr = ExprSyntax(mappedClosure)
    
    let descriptorDecl: DeclSyntax = """
    @used
    @section("__DATA,__ws_swift_exec")
    private let \(raw: taskDescriptor): WSTupleExecutorDescriptor = (name: { () -> UnsafePointer<CChar> in return \(raw: taskNameStorage) }, options: (period: \(raw: period), priority: \(raw: priority), group: { () -> UnsafePointer<CChar>? in return \(raw: groupStorage) }, targetClass: { () -> UnsafePointer<CChar>? in return \(raw: targetClassStorage) }, delayTime: \(raw: delayTime), timeout: \(raw: timeout), flags: \(raw: flags)), executor: \(closureExpr))
    """
    return [nameDecl, groupDecl, targetClassDecl, descriptorDecl]
  }
}

@main
struct WSSwiftRegisterExecutorPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
//        StringifyMacro.self,
      WSSwiftRegisterExecutor.self,
    ]
}
