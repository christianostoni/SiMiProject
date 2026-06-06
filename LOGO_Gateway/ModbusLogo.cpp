#include "ModbusLogo.h"

// ─────────────────────────────────────────────
// VARIABILI GLOBALI
// ─────────────────────────────────────────────

IPAddress LOGO_IP(192, 168, 1, 175);
const int LOGO_PORT = 503;
ModbusIP modbus;

// ─────────────────────────────────────────────
// HELPER INTERNO — attende completamento transazione
// ─────────────────────────────────────────────

static void waitTransaction(uint16_t transId) {
  unsigned long start = millis();
  while (millis() - start < MODBUS_TIMEOUT) {
    modbus.task();
    if (!modbus.isTransaction(transId)) break;
    delay(10);
  }
}

// ─────────────────────────────────────────────
// LETTURA DIGITALI
// ─────────────────────────────────────────────

bool modbusReadAllDigital(bool* inputs,  int inputCount,
                          bool* outputs, int outputCount) {

  modbus.connect(LOGO_IP, LOGO_PORT);

  // ── Ingressi digitali I1-I24 ──
  for (int i = 0; i < inputCount; i++) {
    inputs[i] = false;
    uint16_t transId = modbus.readCoil(LOGO_IP,
                                       (uint16_t)(COIL_I_START + i),
                                       &inputs[i], 1);
    if (transId == 0) {
      modbus.disconnect(LOGO_IP);
      return false;
    }
    waitTransaction(transId);
  }

  // ── Uscite digitali Q1-Q20 ──
  for (int i = 0; i < outputCount; i++) {
    outputs[i] = false;
    uint16_t transId = modbus.readCoil(LOGO_IP,
                                       (uint16_t)(COIL_Q_START + i),
                                       &outputs[i], 1);
    if (transId == 0) {
      modbus.disconnect(LOGO_IP);
      return false;
    }
    waitTransaction(transId);
  }

  modbus.disconnect(LOGO_IP);
  return true;
}

// ─────────────────────────────────────────────
// LETTURA ANALOGICI
// ─────────────────────────────────────────────

bool modbusReadAllAnalog(uint16_t* analogIn,  int aiCount,
                         uint16_t* analogOut, int aqCount) {

  modbus.connect(LOGO_IP, LOGO_PORT);

  // ── Ingressi analogici AI1-AI8 — FC04 (readIreg) ──
  // Gli AI sono Input Register, non Holding Register
  for (int i = 0; i < aiCount; i++) {
    analogIn[i] = 0;
    uint16_t transId = modbus.readIreg(LOGO_IP,
                                       (uint16_t)(IREG_AI_START + i),
                                       &analogIn[i], 1);
    if (transId == 0) {
      modbus.disconnect(LOGO_IP);
      return false;
    }
    waitTransaction(transId);
  }

  // ── Uscite analogiche AQ1-AQ2 — FC03 (readHreg) ──
  for (int i = 0; i < aqCount; i++) {
    analogOut[i] = 0;
    uint16_t transId = modbus.readHreg(LOGO_IP,
                                       (uint16_t)(HREG_AQ_START + i),
                                       &analogOut[i], 1);
    if (transId == 0) {
      modbus.disconnect(LOGO_IP);
      return false;
    }
    waitTransaction(transId);
  }

  modbus.disconnect(LOGO_IP);
  return true;
}

// ─────────────────────────────────────────────
// SCRITTURA MARKER
// ─────────────────────────────────────────────

bool modbusWriteMarker(int markerNumber, bool value) {
  if (markerNumber < 1 || markerNumber > COIL_M_COUNT) return false;

  // Indirizzo coil: COIL_M_START + (markerNumber - 1)
  // M1 → 8256, M2 → 8257, ...
  uint16_t coilAddress = (uint16_t)(COIL_M_START + (markerNumber - 1));

  modbus.connect(LOGO_IP, LOGO_PORT);
  uint16_t transId = modbus.writeCoil(LOGO_IP, coilAddress, value);

  if (transId == 0) {
    modbus.disconnect(LOGO_IP);
    return false;
  }

  waitTransaction(transId);
  modbus.disconnect(LOGO_IP);
  return true;
}