import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(WSSwiftRegisterExecutorMacros)
import WSSwiftRegisterExecutorMacros

let testMacros: [String: Macro.Type] = [
  //    "stringify": StringifyMacro.self,
  "WSSwiftRegisterExecutor": WSSwiftRegisterExecutor.self
]
#endif

final class WSSwiftRegisterExecutorTests: XCTestCase {
//  func testMacro() throws {
//#if canImport(WSSwiftRegisterExecutorMacros)
//    assertMacroExpansion(
//            """
//            #stringify(a + b)
//            """,
//            expandedSource: """
//            (a + b, "a + b")
//            """,
//            macros: testMacros
//    )
//#else
//    throw XCTSkip("macros are only supported when running tests for the host platform")
//#endif
//  }
//  
//  func testMacroWithStringLiteral() throws {
//#if canImport(WSSwiftRegisterExecutorMacros)
//    assertMacroExpansion(
//            #"""
//            #stringify("Hello, \(name)")
//            """#,
//            expandedSource: #"""
//            ("Hello, \(name)", #""Hello, \(name)""#)
//            """#,
//            macros: testMacros
//    )
//#else
//    throw XCTSkip("macros are only supported when running tests for the host platform")
//#endif
//  }
  
  func testWSSwiftRegisterExecutorMacro() throws {
#if canImport(WSSwiftRegisterExecutorMacros)
    assertMacroExpansion(
          #"""
          #WSSwiftRegisterExecutor(
          "task1",
          WSSwiftExecutorOptions.init(
          period: .constructorPeriod,
          priority: WSExecutorPriorityHigh,
          group: "nil",
          targetClass: nil,
          delayTime: 0,
          timeout: 3,
          flags: []
          )
          ) { context in
          print("sddsd")
          }
          """#,
          expandedSource: #"""
          fileprivate let __macro_local_14__var_taskNamefMu_: UnsafePointer<CChar> = "task1".withCString {
              UnsafePointer<CChar>(strdup($0)!)
          }
          fileprivate let __macro_local_11__var_groupfMu_: UnsafePointer<CChar>? = "nil".withCString {
              UnsafePointer<CChar>(strdup($0)!)
          }
          fileprivate let __macro_local_17__var_targetClassfMu_: UnsafePointer<CChar>? = nil
          @used
          @section("__DATA,__ws_swift_exec")
          private let __macro_local_18__descriptor_task1fMu_: WSTupleExecutorDescriptor = (name: { () -> UnsafePointer<CChar> in return __macro_local_14__var_taskNamefMu_ }, options: (period: 0, priority: 255, group: { () -> UnsafePointer<CChar>? in return __macro_local_11__var_groupfMu_ }, targetClass: { () -> UnsafePointer<CChar>? in return __macro_local_17__var_targetClassfMu_ }, delayTime: 0, timeout: 3, flags: 0), executor: { context in
          print("sddsd")})
          """#,
          macros: testMacros
    )
#else
    throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
  }
}
