//
//  ConnectionStateBadge.swift
//  FactoryPanel
//
//  Created by Christian Ostoni on 02/06/2026.
//

import SwiftUI
import LogoLink

struct ConnectionStateBadge: View {
    let state: ConnectionState

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(dotColor)
                .frame(width: 8, height: 8)
                .shadow(color: dotColor.opacity(0.8), radius: dotGlow ? 4 : 0)
            Text(label)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.primary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(.regularMaterial, in: Capsule())
        .animation(.easeInOut(duration: 0.3), value: label)
    }

    private var dotColor: Color {
        switch state {
        case .connected:              return .green
        case .connecting:             return .yellow
        case .reconnecting:           return .orange
        case .disconnected:           return .secondary
        case .failed:                 return .red
        }
    }

    private var dotGlow: Bool {
        if case .connected = state { return true }
        return false
    }

    private var label: String {
        switch state {
        case .connected:              return "Connected"
        case .connecting:             return "Connecting..."
        case .reconnecting(let n):   return "Reconnecting (\(n))"
        case .disconnected:           return "Disconnected"
        case .failed(let e):          return "Error: \(e.localizedDescription)"
        }
    }
}
