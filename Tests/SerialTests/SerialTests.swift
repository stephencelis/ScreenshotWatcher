import XCTest
import SwiftUI
@testable import Serial

final class SerialTests: XCTestCase {
//  @MainActor
  func testBasics() async throws {
    Serially {
      let vm = ViewModel()
      let task = Task {
        await vm.task()
      }

      XCTAssertEqual(vm.count, 0)

      // Give the task an opportunity to start executing its work.
      //    await Task.yield()

      await NotificationCenter.default
        .post(name: UIApplication.userDidTakeScreenshotNotification, object: nil)

      // Give the task an opportunity to update the view model.
      //    await Task.yield()

      XCTAssertEqual(vm.count, 1)

      task.cancel()
      await task.value
    }
  }
}

class ViewModel: ObservableObject {
  @Published var count = 0

  @MainActor
  func task() async {
    let screenshots = NotificationCenter.default
      .notifications(named: UIApplication.userDidTakeScreenshotNotification)
    for await _ in screenshots {
      self.count += 1
    }
  }
}
