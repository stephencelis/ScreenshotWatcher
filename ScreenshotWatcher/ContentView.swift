import SwiftUI

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

struct ContentView: View {
  @ObservedObject var viewModel = ViewModel()

  var body: some View {
    Text("\(viewModel.count) screenshots have been taken")
      .task { await viewModel.task() }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
