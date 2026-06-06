//
//  ContentView.swift
//  FactoryPanelApp
//
//  Created by Christian Ostoni on 06/06/2026.
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
            .navigationTitle("Impianto")
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
                    "Seleziona una macchina",
                    systemImage: "gearshape.2",
                    description: Text("Scegli una macchina dalla barra laterale.")
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

#Preview {
    ContentView()
        .environment(AppViewModel())
}
