//
//  AlarmBanner.swift
//  FactoryPanelApp
//

import SwiftUI

struct AlarmBanner: View {
    let isTriggered: Bool

    var body: some View {
        if isTriggered {
            HStack(spacing: 14) {
                Image(systemName: "thermometer.snowflake.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.red)

                VStack(alignment: .leading, spacing: 2) {
                    Text("ALARM")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                    Text("Low Temperature")
                        .font(.headline)
                        .fontWeight(.bold)
                }

                Spacer()

                Label("ACTIVE", systemImage: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.red)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.red.opacity(0.15), in: Capsule())
                    .overlay(Capsule().strokeBorder(.red.opacity(0.4), lineWidth: 1))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(.red.opacity(0.1), in: RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(.red.opacity(0.45), lineWidth: 1)
            )
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}
