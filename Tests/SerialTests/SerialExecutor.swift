import _CAsyncSequenceValidationSupport

@_silgen_name("swift_job_run")
@usableFromInline
internal func _swiftJobRun(
  _ job: UnownedJob,
  _ executor: UnownedSerialExecutor
) -> ()

final class TestExecutor: SerialExecutor {
  static let shared = TestExecutor()

  func enqueue(_ job: UnownedJob) {
    job._runSynchronously(on: asUnownedSerialExecutor())
  }

  func asUnownedSerialExecutor() -> UnownedSerialExecutor {
    UnownedSerialExecutor(ordinary: self)
  }
}
