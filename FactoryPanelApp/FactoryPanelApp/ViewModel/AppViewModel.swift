//
//  AppViewModel.swift
//  FactoryPanelApp
//

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

    func logoLink(didReceiveStatus status: MachineStatusResponse, for machine: Machine) {
        machineViewModels[machine.id]?.apply(status: status)
    }

    func logoLink(didReceiveCommandResponse response: MachineCommandResponse, for machine: Machine) {
        machineViewModels[machine.id]?.apply(response: response)
    }

    func logoLink(didReceiveUnhandledMessage payload: String, on topic: String) {
        lastUnhandledTopic = topic
        lastUnhandledPayload = payload
    }
}
