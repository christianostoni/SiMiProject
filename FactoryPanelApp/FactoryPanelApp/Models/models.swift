//
//  models.swift
//  FactoryPanelApp
//

import Foundation
import LogoLink

let config: LogoLinkConfiguration = LogoLinkConfiguration(
    host: "h59f2942.ala.eu-central-1.emqxsl.com",
    port: 8883,
    clientID: "visionOS_app",
    username: "christian",
    password: "christian123",
    useTLS: true,
    allowSelfSignedCerts: false,
    caCertificateBundle: "emqxsl-ca"
)

let sterilizzatore: Machine = Machine(id: "sterilizzatore")

let machines: [Machine] = [sterilizzatore]
