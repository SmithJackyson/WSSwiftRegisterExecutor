//
//  WSSwiftRegisterExecutor.swift
//  WSSwiftRegisterExecutor
//
//  Created by SmithJackyson on 2026/11/22.
//

import SwiftSyntax
import WSSwiftExecutorCommon

extension FunctionCallExprSyntax {
  
  var argumentCount: Int { arguments.count }
  
  func wsArgValue(_ argName: String) -> String? {
    for argument in arguments {
      guard let label = argument.label?.text, label == argName else {
        continue
      }
      if let literalExpr = argument.expression
        .as(StringLiteralExprSyntax.self) {
        return literalExpr.representedLiteralValue
      } else if let memberExpr = argument.expression
        .as(MemberAccessExprSyntax.self) {
        return memberExpr.declName.baseName.text
      } else if let integerExpr = argument.expression.as(IntegerLiteralExprSyntax.self) {
        return integerExpr.literal.text
      } else if let declExpr = argument.expression.as(DeclReferenceExprSyntax.self) {
        return declExpr.baseName.text
      } else if argument.expression.as(NilLiteralExprSyntax.self) != nil {
        return nil
      } else if let arrayExpr = argument.expression.as(ArrayExprSyntax.self) {
        var flags: UInt32 = 0
        if arrayExpr.elements.count > 0 {
          for element in arrayExpr.elements {
            if let memberExpr = element.expression.as(MemberAccessExprSyntax.self) {
              let flag = memberExpr.declName.baseName.text.wsSwiftFlags
              flags += flag
            } else if let infixExpr = element.expression.as(InfixOperatorExprSyntax.self) {
              flags += infixExpr.wsOptionsValue
            } else {
              assert(false)
            }
          }
          return String(flags)
        } else {
          return "0"
        }
      }
      // support more type in future
      return nil
    }
    return nil
  }
}

extension InfixOperatorExprSyntax {
  var wsOptionsValue: UInt32 {
    var leftValue: UInt32 = 0
    if let leftOp = leftOperand.as(MemberAccessExprSyntax.self) {
      leftValue = leftOp.declName.baseName.text.wsSwiftFlags
    } else if let leftOp = leftOperand.as(InfixOperatorExprSyntax.self) {
      leftValue = leftOp.wsOptionsValue
    }
    
    var rightValue: UInt32 = 0
    if let rightOp = rightOperand.as(MemberAccessExprSyntax.self) {
      rightValue = rightOp.declName.baseName.text.wsSwiftFlags
    } else if let rightOp = rightOperand.as(InfixOperatorExprSyntax.self) {
      rightValue = rightOp.wsOptionsValue
    }
    
    return leftValue + rightValue
  }
}
