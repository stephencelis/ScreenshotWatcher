import XCTest
@testable import ScreenshotWatcher

class ScreenshotWatcherTests: XCTestCase {
  @MainActor
  func testBasics() async throws {
    let vm = ViewModel()
    let task = Task { await vm.task() }

    XCTAssertEqual(vm.count, 0)

    // Give the task an opportunity to start executing its work.
    await Task.yield()

    NotificationCenter.default
      .post(name: UIApplication.userDidTakeScreenshotNotification, object: nil)

    // Give the task an opportunity to update the view model.
    await Task.yield()

    XCTAssertEqual(vm.count, 1)

    task.cancel()
    await task.value
  }
}
