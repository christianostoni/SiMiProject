//
//  MachineViewModel.swift
//  FactoryPanelApp
//

import Foundation
import LogoLink

@Observable
@MainActor
final class MachineViewModel {

    let machine: Machine

    private(set) var lastStatus: MachineStatusResponse?
    private(set) var lastResponse: MachineCommandResponse?

    private weak var logoLink: LogoLink?

    init(machine: Machine, logoLink: LogoLink) {
        self.machine = machine
        self.logoLink = logoLink
    }

    // MARK: - Data ingestion

    func apply(status: MachineStatusResponse) {
        lastStatus = status
    }

    func apply(response: MachineCommandResponse) {
        lastResponse = response
    }

    // MARK: - Commands

    func writeCoil(markerNumber: Int, value: Int) {
        guard let logoLink else { return }
        let command = MachineCommand(
            machine: machine.id,
            topic_risposta: machine.id + "/response",
            payload: Payload(
                action: "write",
                markerNumber: markerNumber,
                value: value
            )
        )
        logoLink.sendCommand(command, to: machine)
    }

    /// SET (1) → 200ms → RESET (0): simula pressione pulsante fisico su marker PLC stateless.
    func pulse(markerNumber: Int, pulseDuration: UInt64 = 200_000_000) {
        Task {
            writeCoil(markerNumber: markerNumber, value: 1)
            try? await Task.sleep(nanoseconds: pulseDuration)
            writeCoil(markerNumber: markerNumber, value: 0)
        }
    }

    // MARK: - Computed UI properties

    var isOnline: Bool { lastStatus?.state ?? false }

    var digitalInputs: [Bool]  { lastStatus?.digitalIO.inputs  ?? [] }
    var digitalOutputs: [Bool] { lastStatus?.digitalIO.outputs ?? [] }
    var analogInputs: [Int]    { lastStatus?.analogIO.inputs   ?? [] }
    var analogOutputs: [Int]   { lastStatus?.analogIO.outputs  ?? [] }

    var statusLabel: String {
        guard lastStatus != nil else { return "In attesa..." }
        return isOnline ? "Online" : "Offline"
    }

    func digitalInput(at index: Int) -> Bool {
        guard index < digitalInputs.count else { return false }
        return digitalInputs[index]
    }

    func digitalOutput(at index: Int) -> Bool {
        guard index < digitalOutputs.count else { return false }
        return digitalOutputs[index]
    }
}
