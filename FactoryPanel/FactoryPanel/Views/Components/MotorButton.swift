//
//  MotorButton.swift
//  FactoryPanel
//
//  Created by Christian Ostoni on 02/06/2026.
//

import SwiftUI

struct MotorButton: View {
    let definition: MotorDefinition
    let isActive: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Image(systemName: isActive ? "power.circle.fill" : "power.circle")
                    .font(.system(size: 28, weight: .regular))
                    .foregroundStyle(isActive ? .white : .secondary)

                Text(definition.displayName)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(isActive ? .white : .primary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)
            }
            .frame(width: 110, height: 92)
            .background(
                isActive ? Color.green : Color(white: 0.18, opacity: 1),
                in: RoundedRectangle(cornerRadius: 18)
            )
            .shadow(
                color: isActive ? Color.green.opacity(0.55) : .clear,
                radius: 14, x: 0, y: 0
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(
                        isActive ? Color.green.opacity(0.3) : Color.white.opacity(0.08),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
        .hoverEffect()
        .animation(.easeInOut(duration: 0.2), value: isActive)
    }
}
