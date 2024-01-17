import Foundation
import HAKit
import RealmSwift
import Shared

final class CarPlayActionsViewModel {
    private var actionsToken: NotificationToken?
    weak var templateProvider: CarPlayActionsTemplate?

    func update() {
        let actions = Current.realm().objects(Action.self)
            .sorted(byKeyPath: "Position")
            .filter("Scene == nil")

        actionsToken?.invalidate()
        actionsToken = actions.observe { [weak self] _ in
            self?.templateProvider?.updateList(for: actions)
        }

        templateProvider?.updateList(for: actions)
    }

    func invalidateActionsToken() {
        actionsToken?.invalidate()
    }

    func handleAction(action: Action, completion: @escaping () -> Void) {
        guard let server = Current.servers.server(for: action) else {
            completion()
            return
        }
        Current.api(for: server).HandleAction(actionID: action.ID, source: .CarPlay).pipe { result in
            switch result {
            case .fulfilled:
                break
            case let .rejected(error):
                Current.Log.info(error)
            }
            completion()
        }
    }
}