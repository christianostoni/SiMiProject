import Foundation
import LogoLink

@Observable
@MainActor
final class AppViewModel: LogoLinkDelegate {

    let logoLink: LogoLink = LogoLink()
    private(set) var machineViewModels: [String: MachineViewModel] = [:]

    private(set) var lastUnhandledTopic: String?
    private(set) var lastUnhandledPayload: String?

    var connectionState: ConnectionState { logoLink.connectionState }
    var isConnected: Bool {
        if case .connected = logoLink.connectionState { return true }
        return false
    }

    init() {
        logoLink.delegate = self

        for machine in machines {
            logoLink.register(machine: machine)
            machineViewModels[machine.id] = MachineViewModel(
                machine: machine,
                logoLink: logoLink
            )
        }

        logoLink.connect(config: config)
    }

    // MARK: - LogoLinkDelegate
    // Routing via delegate: Machine viene dal topic (non dal JSON, che può non avere il campo "machine")

    func logoLink(didReceiveStatus status: MachineStatusResponse, for machine: Machine) {
        print("[AppVM] STATUS ricevuto → machine: \(machine.id), state: \(status.state), outputs: \(status.digitalIO.outputs)")
        machineViewModels[machine.id]?.apply(status: status)
    }

    func logoLink(didReceiveCommandResponse response: MachineCommandResponse, for machine: Machine) {
        print("[AppVM] RESPONSE ricevuto → machine: \(machine.id), action: \(response.payload.action)")
        machineViewModels[machine.id]?.apply(response: response)
    }

    func logoLink(didReceiveUnhandledMessage payload: String, on topic: String) {
        print("[AppVM] UNHANDLED → topic: \(topic), payload: \(payload)")
        lastUnhandledTopic = topic
        lastUnhandledPayload = payload
    }
}
