//
//  ContentView.swift
//  FactoryPanel
//
//  Created by Christian Ostoni on 28/05/2026.
//

import SwiftUI
import LogoLink

struct ContentView: View {
    @Environment(AppViewModel.self) private var appVM
    @State private var selectedMachineID: String? = "sterilizzatore"

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedMachineID) {
                ForEach(
                    appVM.machineViewModels.values.sorted(by: { $0.machine.id < $1.machine.id }),
                    id: \.machine.id
                ) { machineVM in
                    MachineRow(vm: machineVM)
                        .tag(machineVM.machine.id)
                }
            }
            .navigationTitle("Plant")
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    ConnectionStateBadge(state: appVM.connectionState)
                }
            }
        } detail: {
            if selectedMachineID == "sterilizzatore" {
                SterilizzatoreDetailView()
            } else {
                ContentUnavailableView(
                    "Select a Machine",
                    systemImage: "gearshape.2",
                    description: Text("Choose a machine from the sidebar.")
                )
            }
        }
    }
}

// MARK: - Machine Row

private struct MachineRow: View {
    let vm: MachineViewModel

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(vm.isOnline ? Color.green : Color.secondary.opacity(0.4))
                .frame(width: 9, height: 9)
            VStack(alignment: .leading, spacing: 2) {
                Text(vm.machine.id.capitalized)
                    .font(.body)
                    .fontWeight(.medium)
                Text(vm.statusLabel)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environment(AppViewModel())
}
