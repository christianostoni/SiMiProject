//
//  SterilizzatoreTag.swift
//  FactoryPanelApp
//

import Foundation

// MARK: - Command Tags (Merker M)
// Formula: M byte.bit → (byte × 8) + bit + 1

enum CommandTag {
    case nastro_palettizzatore           // M 0.0
    case corda_palettizzatore            // M 0.1
    case tappeto_magnetico               // M 0.2
    case nastro_capovolgitore            // M 0.3
    case nastro_raffreddatore            // M 0.4
    case raffreddatore                   // M 0.5
    case nastro_ingr_raffreddatore       // M 0.6
    case nastro_accum_ingr_raffreddatore // M 1.0
    case piatto2                         // M 1.1
    case corda_carico_raffreddatore      // M 1.2
    case piatto1_carico_raffreddatore    // M 1.3
    case corda_carico_sterilizzatore     // M 3.7
    case piatto_ingr_scatole             // M 4.0
    case nastro_carico_sterilizzatore    // M 4.1
    case catena_traino_sterilizzatore    // M 4.2
    case piano_raffreddamento            // M 4.3
    case piano_sterilizzazione           // M 4.4
    case nastro_scarico_steril           // M 4.5

    var markerIndex: Int {
        switch self {
        case .nastro_palettizzatore:           return 1
        case .corda_palettizzatore:            return 2
        case .tappeto_magnetico:               return 3
        case .nastro_capovolgitore:            return 4
        case .nastro_raffreddatore:            return 5
        case .raffreddatore:                   return 6
        case .nastro_ingr_raffreddatore:       return 7
        case .nastro_accum_ingr_raffreddatore: return 9
        case .piatto2:                         return 10
        case .corda_carico_raffreddatore:      return 11
        case .piatto1_carico_raffreddatore:    return 12
        case .corda_carico_sterilizzatore:     return 32
        case .piatto_ingr_scatole:             return 33
        case .nastro_carico_sterilizzatore:    return 34
        case .catena_traino_sterilizzatore:    return 35
        case .piano_raffreddamento:            return 36
        case .piano_sterilizzazione:           return 37
        case .nastro_scarico_steril:           return 38
        }
    }
}

// MARK: - Output Tags (Uscite Q)
// Formula: Q byte.bit → (byte × 8) + bit + 1

enum OutputTag {
    case Q_nastro_palettizzatore           // Q 0.1 → 2
    case Q_corda_palettizzatore            // Q 0.2 → 3
    case Q_tappeto_magnetico               // Q 0.3 → 4
    case Q_nastro_capovol                  // Q 0.4 → 5
    case Q_nastro_usc_raffreddatore        // Q 0.5 → 6
    case Q_raffreddatore                   // Q 0.6 → 7
    case Q_nastro_ingr_raffreddatore       // Q 0.7 → 8
    case Q_nastro_ingr_accum_raffreddatore // Q 1.0 → 9
    case Q_piatto2                         // Q 1.1 → 10
    case Q_corda_carico_raffreddatore      // Q 1.2 → 11
    case Q_piatto1                         // Q 1.3 → 12
    case Q_nastro_scarico_sterilizzatore   // Q 1.4 → 13
    case Q_piano_sterilizzazione           // Q 1.5 → 14
    case Q_piano_raffreddamento            // Q 1.6 → 15
    case Q_traino_sterilizzatore           // Q 1.7 → 16
    case Q_nastro_carico_sterilizzatore    // Q 2.0 → 17
    case Q_piatto_ingresso_scatole         // Q 2.1 → 18
    case Q_corda_carico_sterilizzatore     // Q 2.2 → 19
    case Q_vapore_aperto_chiuso            // Q 2.3 → 20

    var outputIndex: Int {
        switch self {
        case .Q_nastro_palettizzatore:           return 1
        case .Q_corda_palettizzatore:            return 3
        case .Q_tappeto_magnetico:               return 4
        case .Q_nastro_capovol:                  return 5
        case .Q_nastro_usc_raffreddatore:        return 6
        case .Q_raffreddatore:                   return 7
        case .Q_nastro_ingr_raffreddatore:       return 8
        case .Q_nastro_ingr_accum_raffreddatore: return 9
        case .Q_piatto2:                         return 10
        case .Q_corda_carico_raffreddatore:      return 11
        case .Q_piatto1:                         return 12
        case .Q_nastro_scarico_sterilizzatore:   return 13
        case .Q_piano_sterilizzazione:           return 14
        case .Q_piano_raffreddamento:            return 15
        case .Q_traino_sterilizzatore:           return 16
        case .Q_nastro_carico_sterilizzatore:    return 17
        case .Q_piatto_ingresso_scatole:         return 18
        case .Q_corda_carico_sterilizzatore:     return 19
        case .Q_vapore_aperto_chiuso:            return 20
        }
    }

    var arrayIndex: Int { outputIndex - 1 }
}

// MARK: - Alarm Tags

enum AlarmTag {
    case bassaTemperatura // M 1.4 → index 13 → array[12]

    var inputArrayIndex: Int {
        switch self {
        case .bassaTemperatura: return 12
        }
    }
}

// MARK: - Motor Layout Data

struct MotorDefinition: Identifiable {
    let id = UUID()
    let displayName: String
    let command: CommandTag
    let output: OutputTag
}

struct MotorGroup: Identifiable {
    let id = UUID()
    let title: String
    let motors: [MotorDefinition]
}

let sterilizzatoreGroups: [MotorGroup] = [
    MotorGroup(title: "Palettizzatore", motors: [
        MotorDefinition(displayName: "Nastro",        command: .nastro_palettizzatore,  output: .Q_nastro_palettizzatore),
        MotorDefinition(displayName: "Corda",         command: .corda_palettizzatore,   output: .Q_corda_palettizzatore),
        MotorDefinition(displayName: "Nastro Capov.", command: .nastro_capovolgitore,   output: .Q_nastro_capovol),
    ]),
    MotorGroup(title: "Ingresso", motors: [
        MotorDefinition(displayName: "Tappeto Magn.", command: .tappeto_magnetico,      output: .Q_tappeto_magnetico),
        MotorDefinition(displayName: "Piatto Ingr.",  command: .piatto_ingr_scatole,    output: .Q_piatto_ingresso_scatole),
    ]),
    MotorGroup(title: "Raffreddatore", motors: [
        MotorDefinition(displayName: "Nastro Uscita", command: .nastro_raffreddatore,            output: .Q_nastro_usc_raffreddatore),
        MotorDefinition(displayName: "Motore",        command: .raffreddatore,                   output: .Q_raffreddatore),
        MotorDefinition(displayName: "Nastro Ingr.",  command: .nastro_ingr_raffreddatore,       output: .Q_nastro_ingr_raffreddatore),
        MotorDefinition(displayName: "Nastro Accum.", command: .nastro_accum_ingr_raffreddatore, output: .Q_nastro_ingr_accum_raffreddatore),
        MotorDefinition(displayName: "Corda Carico",  command: .corda_carico_raffreddatore,      output: .Q_corda_carico_raffreddatore),
        MotorDefinition(displayName: "Piatto 1",      command: .piatto1_carico_raffreddatore,    output: .Q_piatto1),
        MotorDefinition(displayName: "Piatto 2",      command: .piatto2,                         output: .Q_piatto2),
        MotorDefinition(displayName: "Piano Raffr.",  command: .piano_raffreddamento,            output: .Q_piano_raffreddamento),
    ]),
    MotorGroup(title: "Sterilizzatore", motors: [
        MotorDefinition(displayName: "Nastro Carico",  command: .nastro_carico_sterilizzatore, output: .Q_nastro_carico_sterilizzatore),
        MotorDefinition(displayName: "Catena Traino",  command: .catena_traino_sterilizzatore, output: .Q_traino_sterilizzatore),
        MotorDefinition(displayName: "Corda Carico",   command: .corda_carico_sterilizzatore,  output: .Q_corda_carico_sterilizzatore),
        MotorDefinition(displayName: "Nastro Scarico", command: .nastro_scarico_steril,        output: .Q_nastro_scarico_sterilizzatore),
        MotorDefinition(displayName: "Piano Steril.",  command: .piano_sterilizzazione,        output: .Q_piano_sterilizzazione),
    ]),
]
