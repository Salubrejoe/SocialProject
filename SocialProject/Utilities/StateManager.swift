import Foundation

/// AnyObject: constrain StateManager to classes only
/// so we do not need a mutating func when trying to set self.error

@MainActor
protocol StateManager : AnyObject{
  var error: Error? { get set }
  var isWorking: Bool { get set }
}

extension StateManager {
  var isWorking: Bool {
    get { false }
    set { }
  }
  ///With this default implementation, view models that don’t require an isWorking property
  ///—such as the PostRowViewModel—can conform to the StateManager protocol without needing to add this property.
}

extension StateManager {
  typealias AsyncAction = () async throws -> Void
  
  func withStateManagingTask(perform action: @escaping AsyncAction) {
    Task {
      await withStateManagement(perform: action)
    }
  }
  
  private func withStateManagement(perform action: @escaping AsyncAction) async {
    isWorking = true
    do {
      try await action()
    } catch {
      print("[\(Self.self)] Error: \(error)")
      self.error = error
    }
    isWorking = false
  }
}
