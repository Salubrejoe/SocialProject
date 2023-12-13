import SwiftUI

/// The children classes need to be instanciated with an Initial Value and an Action:
///
/// 1. Values will be tubles of strings like email, password, username
/// 2. The action will be associated with the submission of the form
/// 3. Dynamic Member LookUp means I can lookup self.value by just invoking self.

@MainActor
@dynamicMemberLookup
class FormViewModel<Value>: ObservableObject, StateManager {
  typealias Action = (Value) async throws -> Void
  
  private let action  : Action
  @Published var value: Value
  @Published var error: Error?
  
  /// Variable that tells the UI when to display a Progress View
  @Published var isWorking = false
  
  
  subscript<T>(dynamicMember keyPath: WritableKeyPath<Value, T>) -> T {
    get { value[keyPath: keyPath] }
    set { value[keyPath: keyPath] = newValue }
  }
  
  
  init(initialValue: Value, action: @escaping Action) {
    self.value = initialValue
    self.action = action
  }
  
  /// This method needs to be non isolated so we can pass it to the (perform:) initializer of .onSubmit
  /// Estetic?
  nonisolated func submit() {
    Task {
      await withStateManagingTask { [self] in
        try await self.action(value)
      }
    }
  }
}
