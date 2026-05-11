import Foundation

/// Release 编译时 `dlog` 是 no-op，参数表达式不会被构造。
/// Debug 模式时和 `print` 行为一致。
@inlinable
func dlog(_ message: @autoclosure () -> String) {
    #if DEBUG
    print(message())
    #endif
}
