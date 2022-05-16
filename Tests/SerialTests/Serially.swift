//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Async Algorithms open source project
//
// Copyright (c) 2022 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import _CAsyncSequenceValidationSupport

#if canImport(Darwin)
@_implementationOnly import Darwin
#elseif canImport(Glibc)
@_implementationOnly import Glibc
#elseif canImport(WinSDK)
#error("TODO: Port TaskDriver threading to windows")
#endif

#if canImport(Darwin)
func start_thread(_ raw: UnsafeMutableRawPointer) -> UnsafeMutableRawPointer? {
  Unmanaged<Serially>.fromOpaque(raw).takeRetainedValue().run()
  return nil
}
#elseif canImport(Glibc)
func start_thread(_ raw: UnsafeMutableRawPointer?) -> UnsafeMutableRawPointer? {
  Unmanaged<Serially>.fromOpaque(raw!).takeRetainedValue().run()
  return nil
}
#elseif canImport(WinSDK)
#error("unavailable")
#endif

final class Serially {
  let work: () -> Void
#if canImport(Darwin)
  var thread: pthread_t?
#elseif canImport(Glibc)
  var thread = pthread_t()
#elseif canImport(WinSDK)
#error("unavailable")
#endif

  @discardableResult
  init(_ work: @escaping () async -> Void) {
    self.work = {
      swift_task_enqueueGlobal_hook = { job, original in
        Job(job).execute()
      }

      Task {
        await work()
      }

      swift_task_enqueueGlobal_hook = nil
    }
    self.start()
    self.join()
  }

  func start() {
    pthread_create(&self.thread, nil, start_thread, Unmanaged.passRetained(self).toOpaque())
  }

  func run() {
#if canImport(Darwin)
    pthread_setname_np("Serial Queue")
#endif
    self.work()
  }

  func join() {
#if canImport(Darwin)
    pthread_join(self.thread!, nil)
#elseif canImport(Glibc)
    pthread_join(self.thread, nil)
#elseif canImport(WinSDK)
#error("unavailable")
#endif
  }
}
