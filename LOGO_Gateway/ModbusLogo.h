#ifndef MODBUS_LOGO_H
#define MODBUS_LOGO_H

#include <ModbusIP_ESP8266.h>
#include <ESP8266WiFi.h>

// ─────────────────────────────────────────────
// CONFIGURAZIONE CONNESSIONE
// ─────────────────────────────────────────────

extern IPAddress LOGO_IP;
extern const int LOGO_PORT;
extern ModbusIP modbus;

// ─────────────────────────────────────────────
// MAPPA INDIRIZZI LOGO! 8 + ESPANSIONI
// ─────────────────────────────────────────────

// Ingressi digitali — Coil (FC01), sola lettura
// I1 = coil 0, I2 = coil 1, ... I24 = coil 23
const int COIL_I_START   = 0;
const int COIL_I_COUNT   = 24;

// Uscite digitali — Coil (FC01/FC05), lettura/scrittura
// Q1 = coil 8192, Q2 = coil 8193, ... Q20 = coil 8211
const int COIL_Q_START   = 8192;
const int COIL_Q_COUNT   = 20;

// Marker — Coil (FC01/FC05), lettura/scrittura
// M1 = coil 8256, M2 = coil 8257, ... M64 = coil 8319
const int COIL_M_START   = 8256;
const int COIL_M_COUNT   = 64;

// Ingressi analogici — Input Register (FC04), sola lettura
// AI1 = ireg 0, AI2 = ireg 1, ... AI8 = ireg 7
// Valori 0-1000 (scala 0-10V)
const int IREG_AI_START  = 0;
const int IREG_AI_COUNT  = 8;

// Uscite analogiche — Holding Register (FC03/FC06), lettura/scrittura
// AQ1 = hreg 531, AQ2 = hreg 532
const int HREG_AQ_START  = 531;
const int HREG_AQ_COUNT  = 2;

// Timeout transazione Modbus in millisecondi
const int MODBUS_TIMEOUT = 3000;

// ─────────────────────────────────────────────
// DICHIARAZIONI FUNZIONI
// ─────────────────────────────────────────────

// Legge tutti gli ingressi e uscite digitali
// inputs:      array bool di dimensione COIL_I_COUNT
// outputs:     array bool di dimensione COIL_Q_COUNT
// Ritorna true se entrambe le letture sono riuscite
bool modbusReadAllDigital(bool* inputs,  int inputCount,
                          bool* outputs, int outputCount);

// Legge tutti gli ingressi analogici (FC04) e uscite analogiche (FC03)
// analogIn:    array uint16_t di dimensione IREG_AI_COUNT
// analogOut:   array uint16_t di dimensione HREG_AQ_COUNT
// Ritorna true se entrambe le letture sono riuscite
bool modbusReadAllAnalog(uint16_t* analogIn,  int aiCount,
                         uint16_t* analogOut, int aqCount);

// Scrive un singolo marker
// markerNumber: 1-64
// value:        true = set, false = reset
// Ritorna true se la scrittura è riuscita
bool modbusWriteMarker(int markerNumber, bool value);

#endif