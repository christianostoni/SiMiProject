//
//  SterilizzatoreDetailView.swift
//  FactoryPanelApp
//

import SwiftUI

struct SterilizzatoreDetailView: View {
    @Environment(AppViewModel.self) private var appVM

    private var vm: MachineViewModel? {
        appVM.machineViewModels["sterilizzatore"]
    }

    private var bassaTemperaturaActive: Bool {
        vm?.digitalInput(at: AlarmTag.bassaTemperatura.inputArrayIndex) ?? false
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                AlarmBanner(isTriggered: bassaTemperaturaActive)
                    .animation(.spring(duration: 0.4), value: bassaTemperaturaActive)

                if let topic = appVM.lastUnhandledTopic,
                   let payload = appVM.lastUnhandledPayload {
                    DebugMessagePanel(topic: topic, payload: payload)
                }

                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 280))],
                    alignment: .leading,
                    spacing: 16
                ) {
                    ForEach(sterilizzatoreGroups) { group in
                        MotorGroupCard(group: group, vm: vm)
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle("Sterilizzatore")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ConnectionStateBadge(state: appVM.connectionState)
            }
        }
    }
}

// MARK: - Debug Panel

private struct DebugMessagePanel: View {
    let topic: String
    let payload: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Unhandled Message", systemImage: "exclamationmark.bubble")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.orange)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Topic:")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(topic)
                        .font(.caption2)
                        .fontDesign(.monospaced)
                }
                Text(payload)
                    .font(.caption2)
                    .fontDesign(.monospaced)
                    .lineLimit(4)
            }
        }
        .padding(14)
        .background(.orange.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(.orange.opacity(0.35), lineWidth: 1)
        )
    }
}

// MARK: - Motor Group Card

private struct MotorGroupCard: View {
    let group: MotorGroup
    let vm: MachineViewModel?

    private let columns = Array(repeating: GridItem(.flexible(minimum: 80), spacing: 10), count: 3)

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(group.title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(group.motors) { motor in
                    MotorButton(
                        definition: motor,
                        isActive: vm?.digitalOutput(at: motor.output.arrayIndex) ?? false,
                        onTap: {
                            vm?.pulse(markerNumber: motor.command.markerIndex)
                        }
                    )
                }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
    }
}
