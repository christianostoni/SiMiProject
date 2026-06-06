//
//  configurations.swift
//  FactoryPanel
//
//  Created by Christian Ostoni on 01/06/2026.
//

import Foundation
import LogoLink


/*
let config:LogoLinkConfiguration = LogoLinkConfiguration(
    host: "192.168.1.242",
    port: 1883,
    clientID: "visionOS_app",
    username: "christian",
    password: "christian"
)
 */
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



let sterilizzatore:Machine = Machine(id:"sterilizzatore")

let machines:[Machine] = [sterilizzatore]




